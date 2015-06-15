#!/usr/bin/perl
use strict;
use warnings;
use autodie;

use File::Spec;
use Text::CSV_XS;
use List::Util qw(max min);
use List::MoreUtils qw(uniq zip);
use YAML qw(Dump Load DumpFile LoadFile);

use FindBin;
use lib "$FindBin::Bin/lib";

use MyBAM;

my $csv_file = "chickpea_rnaseq.csv";
my $base_dir = File::Spec->catdir( $ENV{HOME}, "data/rna-seq/chickpea" );
my $bin_dir = {
    script => $FindBin::Bin,
    stk    => File::Spec->catdir( $ENV{HOME}, "share/sratoolkit" ),
    fastqc => File::Spec->catdir( $ENV{HOME}, "bin" ),
    scythe => File::Spec->catdir( $ENV{HOME}, "bin" ),
    sickle => File::Spec->catdir( $ENV{HOME}, "bin" ),
	trinity =>
    File::Spec->catdir( $ENV{HOME}, "share/trinityrnaseq_r2013-02-25" ),
};
my $data_dir = {
    sra  => File::Spec->catdir( $base_dir, "data" ),
    proc => File::Spec->catdir( $base_dir, "process" ),
    bash => File::Spec->catdir( $base_dir, "bash" ),
    log  => File::Spec->catdir( $base_dir, "log" ),
    ref  => File::Spec->catdir( $base_dir, "ref" ),
};
my $ref_file = {
    adapters => File::Spec->catfile( $base_dir, "ref", "illumina_adapters.fa" ),
};

my $parallel = 8;
my $memory   = 64;

for my $key ( keys %{$data_dir} ) {
    mkdir $data_dir->{$key} if !-d $data_dir->{$key};
}

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

            #$item = undef;
            #next ITEM;
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
        ref_file => $ref_file,
        parallel => $parallel,
        memory   => $memory,
    );

    $mybam->head($item);

    #$mybam->srr_dump_parallel($item);
    $mybam->srr_dump($item);
    $mybam->fastqc($item);
    $mybam->scythe_sickle($item);
    $mybam->fastqc($item);

    $mybam->write(
        $item,
        File::Spec->catfile(
            $data_dir->{bash}, "sra." . $item->{name} . ".sh"
        )
    );
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
    $mybam->trinity_se($item);

    $mybam->write( $item,
        File::Spec->catfile( $data_dir->{bash}, "trinity." . $item->{name} . ".sh" )
    );
}

#----------------------------------------------------------#
# Execute bash in background with GNU screen
#----------------------------------------------------------#
{
    my $text = <<'EOF';
#----------------------------#
# Quality assessment & improvement
#----------------------------#
[% FOREACH item IN data -%]
# [% item.name %]
screen -L -dmS sra_[% item.name %] sh [% data_dir.bash %]/sra.[% item.name %].sh

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
# find [% data_dir.sra %]  -type f -name "*sra" | sort | wc -l
# find [% data_dir.proc %] -type f -name "*fastq.gz" | sort | wc -l
# find [% data_dir.proc %] -type f -name "*_[12].fastq.gz" | sort | wc -l
# find [% data_dir.proc %] -type f -name "*_fastqc.zip" | sort | grep -v trimmed | wc -l
# find [% data_dir.proc %] -type f -name "*_[12]_fastqc.zip" | sort | grep -v trimmed | wc -l
#
# find [% data_dir.proc %] -type f -name "*scythe.fq.gz" | sort | grep trimmed | wc -l
# find [% data_dir.proc %] -type f -name "*sickle.fq.gz" | sort | grep trimmed | wc -l
# find [% data_dir.proc %] -type f -name "*fq_fastqc.zip" | sort | grep trimmed | wc -l

### total size
# find [% data_dir.sra %]  -type f -name "*sra" | perl -nl -MNumber::Format -e '$sum += (stat($_))[7]; END{print Number::Format::format_bytes($sum)}'
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
[% FOREACH item IN data -%]
# [% item.name %]
screen -L -dmS tri_[% item.name %] sh [% data_dir.bash %]/trinity.[% item.name %].sh

[% END -%]

### What's running
# find [% data_dir.proc %] -type f -name "temp.samheader.sam" | sort

### What's done
# find [% data_dir.proc %] -type f -name "accepted_hits.bam" | sort | wc -l
# find [% data_dir.proc %] -type f -name "transcripts.gtf" | sort | wc -l

### total size
# find [% data_dir.proc %] -type f -name "accepted_hits.bam" | perl -nl -MNumber::Format -e '$sum += (stat($_))[7]; END{print Number::Format::format_bytes($sum)}'
# find [% data_dir.proc %] -type f -name "unmapped.bam" | perl -nl -MNumber::Format -e '$sum += (stat($_))[7]; END{print Number::Format::format_bytes($sum)}'

### Clean
# find [% data_dir.proc %] -type d -name "logs" | sort | grep th_out | xargs rm -fr

EOF
    my $tt = Template->new;
    $tt->process(
        \$text,
        {   data     => \@data,
            base_dir => $base_dir,
            data_dir => $data_dir,
            parallel => $parallel,
        },
        File::Spec->catfile( $base_dir, "screen.sh.txt" )
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
    $tt->process( \$text, {},
        File::Spec->catfile( $data_dir->{ref}, "illumina_adapters.fa" ) )
        or die Template->error;
}

__END__

# linode
aria2c -x 12 -s 4 -c -i chickpea_rnaseq.ftp.txt

# local workstation
cd /home/wangq/data/rna-seq/chickpea/
rsync --progress -av wangq@104.200.21.23:/home/wangq/SRR* .


