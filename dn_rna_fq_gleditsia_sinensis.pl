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

my $base_dir = File::Spec->catdir( $ENV{HOME}, "data/rna-seq/gleditsia_sinensis" );
my $bin_dir = {
    script => $FindBin::Bin,
    stk    => File::Spec->catdir( $ENV{HOME}, "share/sratoolkit" ),
    gatk   => File::Spec->catdir( $ENV{HOME}, "share/GenomeAnalysisTK" ),
    pcd    => File::Spec->catdir( $ENV{HOME}, "share/picard" ),
    trinity =>
        File::Spec->catdir( $ENV{HOME}, "share/trinityrnaseq_r2013-02-25" ),
    ngsqc   => File::Spec->catdir( $ENV{HOME}, "share/NGSQCToolkit_v2.3" ),
    seqprep => File::Spec->catdir( $ENV{HOME}, "bin" ),
    sickle  => File::Spec->catdir( $ENV{HOME}, "bin" ),
};
my $data_dir = {
    sra  => File::Spec->catdir( $base_dir, "data" ),
    proc => File::Spec->catdir( $base_dir, "process" ),
    bash => File::Spec->catdir( $base_dir, "bash" ),
};
my $adapters = {
    A => 'AGATCGGAAGAGCACACGTC',
    B => 'AGATCGGAAGAGCGTCGTGT ',
};

my $parallel = 16;
my $memory   = 128;

my $csv_file = "gleditsia_sinensis.csv";

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

        my $file = [
            File::Spec->catfile( $data_dir->{sra}, "$srr.1.fq" ),
            File::Spec->catfile( $data_dir->{sra}, "$srr.2.fq" ),
        ];

        #if ( !-e $file ) {
        #    print "Can't find $srr.N.fq for $name\n";
        #    $item = undef;
        #    next ITEM;
        #}

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
            fq       => 1,
            adapters => $adapters,
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

    $mybam->head_trinity($item);
    $mybam->seqprep_pe($item);
    $mybam->trinity_pe($item);
    $mybam->trinity_rsem($item);

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
