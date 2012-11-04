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

my $base_dir = File::Spec->catdir( $ENV{HOME}, "/data/yeast10000" );
my $bin_dir = {
    stk  => File::Spec->catdir( $ENV{HOME}, "share/sratoolkit" ),
    gatk => File::Spec->catdir( $ENV{HOME}, "share/GenomeAnalysisTK" ),
    pcd  => File::Spec->catdir( $ENV{HOME}, "share/picard" ),
};
my $data_dir = {
    sra  => File::Spec->catdir( $base_dir, "ERP000547" ),
    proc => File::Spec->catdir( $base_dir, "process_imr" ),
    bash => File::Spec->catdir( $base_dir, "bash_imr" ),
};
my $ref_file = {
    seq => File::Spec->catfile( $base_dir, "ref", "S288C.fa" ),
    vcf => File::Spec->catfile( $base_dir, "ref", "S288C.vcf" ),
};
my $parallel = 8;
my $memory   = 4;

my $mybam = MyBAM->new(
    base_dir => $base_dir,
    bin_dir  => $bin_dir,
    data_dir => $data_dir,
    ref_file => $ref_file,

    parallel => $parallel,
    memory   => $memory,
);

my @rows;
my $csv = Text::CSV_XS->new( { binary => 1 } )
    or die "Cannot use CSV: " . Text::CSV_XS->error_diag;
open my $fh, "<", "yeast10000.csv";
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
        my $srr      = $_->[4];
        my $rg_str   = $_->[7];

        my $file = File::Spec->catfile( $data_dir->{sra}, "$srr.sra" );
        if ( !-e $file ) {
            print "Can't find $srr.sra for $name\n";
            $item = undef;
            next ITEM;
        }
        my $lane = {
            file     => $file,
            srx      => $srx,
            platform => $platform,
            srr      => $srr,
            rg_str   => $rg_str,
        };

        push @{ $item->{lanes} }, $lane;
    }
    push @data, $item;
}

for my $item (@data) {
    $mybam->imr_denom_desc($item);
    my $desc_file = $data_dir->{bash} . "/" . $item->{name} . "_imr.t";
    $item->{desc_file} = $desc_file;
    $mybam->write( $item, 'imr', $desc_file );

    $mybam->head($item);
    $mybam->srr_dump_pe_q64($item);
    $mybam->imr_run($item);
    $mybam->write($item);

}

#{
#    my @jobs;
#    while ( scalar @data ) {
#        my @batching = splice @data, 0, 5;
#        push @jobs, [@batching];
#    }
#
#    my $text = <<'EOF';
##!/bin/bash
#cd [% base_dir %]
#rm [% base_dir %]/fail.log
#
#[% FOREACH job IN jobs -%]
## [% job.0.name %]
#bsub -q mpi_2 -n [% parallel %] -J [% job.0.name %] "[% FOREACH item IN job -%] sh [% bash_dir %]/[% item.name %]_sra.sh && [% END -%] sleep 1"
## sh [% bash_dir %]/[% item.name %]_sra.sh
#
#[% END -%]
#
#EOF
#    my $tt = Template->new;
#    $tt->process(
#        \$text,
#        {   jobs     => \@jobs,
#            base_dir => $base_dir,
#            bash_dir => $data_dir->{bash},
#            parallel => $parallel,
#        },
#        File::Spec->catfile( $base_dir, "master.sh" )
#    ) or die Template->error;
#}
