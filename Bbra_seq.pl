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
my $csv_file = "Bbra_test.csv";

my $base_dir = shift
    || File::Spec->catdir( $ENV{HOME}, "data/setaria_italica" );

my $bin_dir = {
    stk  => File::Spec->catdir( $ENV{HOME}, "share/sratoolkit" ),
    gatk => File::Spec->catdir( $ENV{HOME}, "share/GenomeAnalysisTK" ),
    pcd  => File::Spec->catdir( $ENV{HOME}, "share/picard" ),
    soap => File::Spec->catdir( $ENV{HOME}, "bin" ),
};
my $data_dir = {
    sra  => File::Spec->catdir( $base_dir, "SRP003868" ),
    proc => File::Spec->catdir( $base_dir, "process" ),
    bash => File::Spec->catdir( $base_dir, "bash" ),
};

my $parallel = 12;
my $memory   = 32;

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
        my $ilegnth  = $_->[4];
        my $srr      = $_->[5];

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
            ilegnth  => $ilegnth,
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

    $mybam->soap_head($item);
    $mybam->soap_srr_dump_pe($item);
    $mybam->soap_kmerfreq($item);
    $mybam->soap_corrector($item);
    $mybam->soap_denovo($item);

    #$mybam->bwa_aln_pe_picard($item);
    #$mybam->merge_bam_picard($item);
    #$mybam->realign_dedup($item);
    #
    ##$mybam->recal($item);
    #$mybam->calmd_baq($item);
    #$mybam->call_snp_filter($item);
    #$mybam->call_indel($item);
    #$mybam->vcf_to_fasta($item);
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
