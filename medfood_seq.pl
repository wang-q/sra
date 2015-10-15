#!/usr/bin/perl
use strict;
use warnings;
use autodie;

use Path::Tiny;
use Text::CSV_XS;
use List::MoreUtils qw(uniq);
use YAML qw(Dump Load DumpFile LoadFile);

use FindBin;
use lib "$FindBin::Bin/lib";

use MyBAM;

#----------------------------------------------------------#
# parameters
#----------------------------------------------------------#
my $base_dir = File::Spec->catdir( $ENV{HOME}, "data/rna-seq/medfood" );
my $csv_file = "medfood_all.csv";

my $parallel = 8;
my $memory   = 64;

#----------------------------#
# directories
#----------------------------#
my $brew_home = `brew --prefix`;
my $bin_dir   = {
    script  => $FindBin::Bin,
    trinity => path( $ENV{HOME}, "share/trinityrnaseq-2.0.6" )->stringify,
};
my $data_dir = {
    sra  => path( $base_dir, "sra" )->stringify,
    proc => path( $base_dir, "process" )->stringify,
    bash => path( $base_dir, "bash" )->stringify,
    log  => path( $base_dir, "log" )->stringify,
    ref  => path( $base_dir, "ref" )->stringify,
};
my $ref_file = { adapters => File::Spec->catfile( $base_dir, "ref", "illumina_adapters.fa" ), };

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

    $mybam->write( $item, path( $data_dir->{bash}, "sra." . $item->{name} . ".sh" )->stringify );
}

for my $item (@data) {
    my $mybam = MyBAM->new(
        base_dir => $base_dir,
        bin_dir  => $bin_dir,
        data_dir => $data_dir,
        ref_file => $ref_file,
        parallel => $parallel,
        memory   => $memory,
        sickle   => 1,
    );

    $mybam->head_trinity($item);
    $mybam->trinity($item);
    $mybam->trinity_rsem($item);

    $mybam->write( $item, path( $data_dir->{bash}, "tri." . $item->{name} . ".sh" )->stringify );
}

#----------------------------------------------------------#
# Execute bash in background with GNU screen
#----------------------------------------------------------#
{
    my $text = <<'EOF';
#----------------------------#
# Quality assessment & improvement
#----------------------------#
cd [% $data_dir.log %]

[% FOREACH item IN data -%]
# [% item.name %]
screen -L -dmS sra_[% item.name %] bash [% data_dir.bash %]/sra.[% item.name %].sh

[% END -%]

#----------------------------#
# Monitoring
#----------------------------#
###
cd [% base_dir %]

### Kill all custom named sessions
# screen -ls | grep Detached | sort | grep -v pts- | perl -nl -e '/^\s+(\d+)/ and system qq{screen -S $1 -X quit}'

### Count running sessions
# screen -ls | grep Detached | sort | grep -v pts- | wc -l

### What's done
# find [% data_dir.sra %]  -type f -regextype posix-extended -regex ".*\/[DES]RR.*" | sort | wc -l
# find [% data_dir.proc %] -type f -name "*fastq.gz" | sort | wc -l
# find [% data_dir.proc %] -type f -name "*_[12].fastq.gz" | sort | wc -l
# find [% data_dir.proc %] -type f -name "*_fastqc.zip" | sort | grep -v trimmed | wc -l
# find [% data_dir.proc %] -type f -name "*_[12]_fastqc.zip" | sort | grep -v trimmed | wc -l
#
# find [% data_dir.proc %] -type f -name "*scythe.fq.gz" | sort | grep trimmed | wc -l
# find [% data_dir.proc %] -type f -name "*sickle.fq.gz" | sort | grep trimmed | wc -l
# find [% data_dir.proc %] -type f -name "*fq_fastqc.zip" | sort | grep trimmed | wc -l

### total size
# find [% data_dir.sra %]  -type f -regextype posix-extended -regex ".*\/[DES]RR.*" | perl -nl -MNumber::Format -e '$sum += (stat($_))[7]; END{print Number::Format::format_bytes($sum)}'
# find [% data_dir.proc %] -type f -name "*fastq.gz" | perl -nl -MNumber::Format -e '$sum += (stat($_))[7]; END{print Number::Format::format_bytes($sum)}'
# find [% data_dir.proc %] -type f -name "*sickle.fq.gz" | perl -nl -MNumber::Format -e '$sum += (stat($_))[7]; END{print Number::Format::format_bytes($sum)}'

### Clean
# find [% data_dir.proc %] -type d -name "*fastqc" | sort | xargs rm -fr
# find [% data_dir.proc %] -type f -name "*fastq.gz" | sort | grep -v trimmed | xargs rm
# find [% data_dir.proc %] -type f -name "*matches.txt" | sort | xargs rm
# find [% data_dir.proc %] -type f -name "*scythe.fq.gz" | sort | grep trimmed | xargs rm

#----------------------------#
# trinity
#----------------------------#
cd [% $data_dir.log %]

[% FOREACH item IN data -%]
# [% item.name %]
screen -L -dmS tri_[% item.name %] sh [% data_dir.bash %]/tri.[% item.name %].sh

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
        path( $base_dir, "screen.sh.txt" )->stringify
    ) or die Template->error;
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
