#!/usr/bin/perl
use strict;
use warnings;

use File::Spec;
use Text::CSV_XS;
use List::MoreUtils qw(uniq zip);
use YAML qw(Dump Load DumpFile LoadFile);

use FindBin;
use lib "$FindBin::Bin/lib";

use MyBAM;

#----------------------------------------------------------#
# RepeatMasker has been done
#----------------------------------------------------------#
my $csv_file = "dicty.csv";

my $base_dir = shift
    || File::Spec->catdir( $ENV{HOME}, "data/dicty" );

my $bin_dir = {
    stk  => File::Spec->catdir( $ENV{HOME}, "share/sratoolkit" ),
    gatk => File::Spec->catdir( $ENV{HOME}, "share/GenomeAnalysisTK" ),
    pcd  => File::Spec->catdir( $ENV{HOME}, "share/picard" ),
};
my $data_dir = {
    sra  => File::Spec->catdir( $base_dir, "SRA012238" ),
    proc => File::Spec->catdir( $base_dir, "process" ),
    bash => File::Spec->catdir( $base_dir, "bash" ),
};
my $ref_file = {
    seq => File::Spec->catfile( $base_dir, "ref", "dicty_65.fa" ),
    #vcf => File::Spec->catfile( $base_dir, "ref", "nip_65.vcf" ),
    sizes => File::Spec->catfile( $base_dir, "ref", "chr.sizes" ),
};

my $parallel = 8;
my $memory   = 8;
my $tmpdir   = "/gpfsTMP/wangq";

my @rows;
my $csv = Text::CSV_XS->new( { binary => 1 } )
    or die "Cannot use CSV: " . Text::CSV_XS->error_diag;
open my $fh, "<", $csv_file;
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
            print "Can't find $srr for $name\n";
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
        ref_file => $ref_file,
        parallel => $parallel,
        memory   => $memory,
        tmpdir   => $tmpdir,
    );

    $mybam->head($item);
    $mybam->srr_dump_pe($item);
    $mybam->bwa_aln_pe_picard($item);
    $mybam->merge_bam_picard($item);
    $mybam->realign_dedup($item);

    #$mybam->recal($item);
    $mybam->calmd_baq($item);
    $mybam->call_snp_filter($item);
    $mybam->call_indel($item);
    $mybam->vcf_to_fasta($item);
    $mybam->clean($item);

    $mybam->write($item);
}

{
    my $text = <<'EOF';
#!/bin/bash
cd [% base_dir %]
rm [% base_dir %]/fail.log

[% FOREACH item IN data -%]
# [% item.name %]
bsub -q mpi_2 -n [% parallel %] -J [% item.name %] "sh [% data_dir.bash %]/[% item.name %]_sra.sh"
# sh [% data_dir.bash %]/[% item.name %]_sra.sh

[% END -%]

EOF
    my $tt = Template->new;
    $tt->process(
        \$text,
        {   data     => \@data,
            base_dir => $base_dir,
            data_dir => $data_dir,
            parallel => $parallel,
        },
        File::Spec->catfile( $base_dir, "master.sh" )
    ) or die Template->error;
}
