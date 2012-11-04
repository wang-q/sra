#!/usr/bin/perl
use strict;
use warnings;
use autodie;

use File::Spec;
use Text::CSV_XS;
use List::MoreUtils qw(uniq zip);
use YAML qw(Dump Load DumpFile LoadFile);

use FindBin;
use lib "$FindBin::Bin/lib";

use MyBAM;

my $base_dir = File::Spec->catdir( $ENV{HOME}, "/data/dioscorea_villosa" );
my $bin_dir = {
    stk  => File::Spec->catdir( $ENV{HOME}, "share/sratoolkit" ),
    gatk => File::Spec->catdir( $ENV{HOME}, "share/GenomeAnalysisTK" ),
    pcd  => File::Spec->catdir( $ENV{HOME}, "share/picard" ),
    trinity  => File::Spec->catdir( $ENV{HOME}, "share/trinityrnaseq_r2012-01-25p1" ),
};
my $data_dir = {
    sra  => File::Spec->catdir( $base_dir, "SRP006697" ),
    proc => File::Spec->catdir( $base_dir, "process" ),
    bash => File::Spec->catdir( $base_dir, "bash" ),
};
my $parallel = 8;
my $memory   = 4;

my @rows;
my $csv = Text::CSV_XS->new( { binary => 1 } )
    or die "Cannot use CSV: " . Text::CSV_XS->error_diag;
open my $fh, "<", "dioscorea_villosa_leaf_stem_root.csv";
$csv->getline($fh);    # skip headers
while ( my $row = $csv->getline($fh) ) {
    push @rows, $row;
}
close $fh;

my @data;
my @names = uniq( map { $_->[0] } @rows );
ITEM: for my $name (@names) {

    my $item = { name => $name };
    $item->{dir} = File::Spec->catdir( $data_dir->{proc}, $name );
    $item->{lanes} = [];
    my @lines = grep { $_->[0] eq $name } @rows;
    for (@lines) {
        my $srx      = $_->[1];
        my $platform = $_->[2];
        my $layout   = $_->[3];
        my $srr      = $_->[4];

        my $file = File::Spec->catfile( $data_dir->{sra}, "$srr.sra" );
        if ( !-e $file ) {
            print "Can't find $srr.sra for $name\n";
            $item = undef;
            next ITEM;
        }

        my $rg_str
            = '@RG'
            . "\\tID:$srr"
            . "\\tLB:$srx"
            . "\\tPL:$platform"
            . "\\tSM:$name";
        my $lane = {
            file     => $file,
            srx      => $srx,
            platform => $platform,
            layout   => $layout,
            srr      => $srr,
            rg_str   => $rg_str,
        };

        push @{ $item->{lanes} }, $lane;
    }
    push @data, $item;
}

for my $item (@data) {
    my $mybam = MyBAM->new(
        base_dir => $base_dir,
        bin_dir  => $bin_dir,
        data_dir => $data_dir,
        parallel => $parallel,
        memory   => $memory,
    );

    $mybam->head($item);
    $mybam->srr_dump_pe($item);
    $mybam->trinity_pe($item);
    #$mybam->bwa_aln_pe($item);
    #$mybam->merge_bam($item);
    #$mybam->realign_dedup($item);
    #$mybam->recal($item);
    #$mybam->calmd_baq($item);
    #$mybam->call_snp_indel($item);
    #$mybam->vcf_to_fasta($item);
    #$mybam->clean($item);

    $mybam->write($item);
}

{
    my @jobs;
    while ( scalar @data ) {
        my @batching = splice @data, 0, 5;
        push @jobs, [@batching];
    }

    my $text = <<'EOF';
#!/bin/bash
cd [% base_dir %]
rm [% base_dir %]/fail.log

[% FOREACH job IN jobs -%]
# [% job.0.name %]
bsub -q mpi_2 -n [% parallel %] -J [% job.0.name %] "[% FOREACH item IN job -%] sh [% bash_dir %]/[% item.name %]_sra.sh && [% END -%] sleep 1"
# sh [% bash_dir %]/[% item.name %]_sra.sh

[% END -%]

EOF
    my $tt = Template->new;
    $tt->process(
        \$text,
        {   jobs     => \@jobs,
            base_dir => $base_dir,
            bash_dir => $data_dir->{bash},
            parallel => $parallel,
        },
        File::Spec->catfile( $base_dir, "master.sh" )
    ) or die Template->error;
}
