#!/usr/bin/perl
use strict;
use warnings;
use autodie;

use Path::Tiny;
use Text::CSV_XS;
use List::MoreUtils qw(uniq zip);
use YAML qw(Dump Load DumpFile LoadFile);

use FindBin;
use lib "$FindBin::Bin/lib";
use MyBAM;

#----------------------------------------------------------#
# parameters
#----------------------------------------------------------#
my $base_dir = path( $ENV{HOME}, "data", "dna-seq", "cele_mmp" )->stringify;

my $csv_file = "cele_mmp.csv";

my $parallel = 8;
my $memory   = 16;    # It's enough for picard and gatk

#----------------------------#
# directories
#----------------------------#
my $bin_dir   = {
    script => $FindBin::Bin,
    gatk   => path( $ENV{HOME}, "share/gatk" )->stringify,
    pcd    => path( $ENV{HOME}, "share/picard-tools-1.128" )->stringify,
};
my $data_dir = {
    sra  => path( $base_dir, "sra" )->stringify,
    proc => path( $base_dir, "process" )->stringify,
    bash => path( $base_dir, "bash" )->stringify,
    log  => path( $base_dir, "log" )->stringify,
    ref  => path( $base_dir, "ref" )->stringify,
};
my $ref_file = {
    adapters => path( $base_dir, "ref", "illumina_adapters.fa" )->stringify,
    seq      => path( $base_dir, "ref", "Cele_82.fa" )->stringify,
    sizes    => path( $base_dir, "ref", "chr.sizes" )->stringify,
};

for my $key ( keys %{$data_dir} ) {
    path( $data_dir->{$key} )->mkpath;
}

#----------------------------------------------------------#
# read csv
#----------------------------------------------------------#
$csv_file = path( $FindBin::Bin, $csv_file )->stringify;
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
    $item->{dir} = path( $data_dir->{proc}, $name )->stringify;
    $item->{lanes} = [];
    my @lines = grep { $_->[0] eq $name } @rows;
    for (@lines) {
        my $srx      = $_->[1];
        my $platform = $_->[2];
        my $layout   = $_->[3];
        my $srr      = $_->[5];

        my $file;
        if ( path( $data_dir->{sra}, $srr )->is_file ) {
            $file = path( $data_dir->{sra}, $srr )->stringify;
        }
        elsif ( path( $data_dir->{sra}, "$srr.sra" )->is_file ) {
            $file = path( $data_dir->{sra}, "$srr.sra" )->stringify;
        }
        else {
            print "Can't find $srr(.sra) for $name\n";
            $item = undef;
            next ITEM;
        }

        my $rg_str = '@RG' . "\\tID:$srr" . "\\tLB:$srx" . "\\tPL:$platform" . "\\tSM:$name";
        my $lane   = {
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

#----------------------------------------------------------#
# generate bash files
#----------------------------------------------------------#
for my $item (@data) {
    my $mybam = MyBAM->new(
        base_dir => $base_dir,
        bin_dir  => $bin_dir,
        data_dir => $data_dir,
        ref_file => $ref_file,
        parallel => $parallel,
        memory   => $memory,
    );

    $mybam->head($item);
    $mybam->srr_dump($item);
    $mybam->fastqc($item);
    $mybam->scythe_sickle($item);
    $mybam->fastqc($item);

    my $sh_file = path( $data_dir->{bash}, "sra." . $item->{name} . ".sh" )->stringify;
    print "Create [$sh_file].\n";
    $mybam->write( $item, $sh_file );
}

for my $item (@data) {
    my $mybam = MyBAM->new(
        base_dir => $base_dir,
        bin_dir  => $bin_dir,
        data_dir => $data_dir,
        ref_file => $ref_file,
        parallel => $parallel,
        memory   => $memory,
    );

    $mybam->head($item);
    $mybam->bwa_mem($item);
    $mybam->merge_bam($item);
    $mybam->realign_indel($item);
    $mybam->recal_reads($item) if exists $ref_file->{vcf};

    # the following is not current best practices
    $mybam->call_snp_filter($item);
    $mybam->call_indel($item);
    $mybam->vcf_to_fasta($item);
    $mybam->clean($item);

    my $sh_file = path( $data_dir->{bash}, "bwa." . $item->{name} . ".sh" )->stringify;
    print "Create [$sh_file].\n";
    $mybam->write( $item, $sh_file );
}

#----------------------------------------------------------#
# Execute bash in background with GNU screen
#----------------------------------------------------------#
{
    my $mybam = MyBAM->new(
        base_dir => $base_dir,
        bin_dir  => $bin_dir,
        data_dir => $data_dir,
        ref_file => $ref_file,
        parallel => $parallel,
        memory   => $memory,
        sickle   => 1,
    );

    $mybam->screen_sra( \@data );
    $mybam->screen_bwa( \@data );

    my $sh_file = path( $base_dir, "screen.sh.txt" )->stringify;
    print "Create [$sh_file].\n";
    $mybam->write( undef, $sh_file );
}

{    # for Scythe
    my $text = <<'EOF';
>multiplexing-forward
GATCGGAAGAGCACACGTCT
>solexa-forward
AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT
>truseq-forward-contam
AGATCGGAAGAGCACACGTCTGAACTCCAGTCAC
>truseq-reverse-contam
AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGTA
>nextera-forward-read-contam
CTGTCTCTTATACACATCTCCGAGCCCACGAGAC
>nextera-reverse-read-contam
CTGTCTCTTATACACATCTGACGCTGCCGACGA
>solexa-reverse
AGATCGGAAGAGCGGTTCAGCAGGAATGCCGAG

EOF
    my $tt = Template->new;
    $tt->process( \$text, {}, path( $data_dir->{ref}, "illumina_adapters.fa" )->stringify )
        or die Template->error;
}
