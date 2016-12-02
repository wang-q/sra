#!/usr/bin/perl
use strict;
use warnings;
use autodie;

use Getopt::Long::Descriptive;
use FindBin;
use YAML::Syck;

use Path::Tiny;
use Text::CSV_XS;
use List::MoreUtils::PP;

use lib "$FindBin::RealBin/lib";
use MyBAM;

#----------------------------------------------------------#
# GetOpt section
#----------------------------------------------------------#

(
    #@type Getopt::Long::Descriptive::Opts
    my $opt,

    #@type Getopt::Long::Descriptive::Usage
    my $usage,
    )
    = Getopt::Long::Descriptive::describe_options(
    "Create bash files for reference based dna-seq projects\n" . "Usage: perl %c [options]",
    [ 'help|h', 'display this message' ],
    [],
    [ 'base|b=s',     'Base directory',                  { required => 1, }, ],
    [ 'csv|c=s',      'CSV file of project information', { required => 1, }, ],
    [ 'parallel|p=i', 'Parallel mode',                   { default  => 8, }, ],
    [ 'memory|m=i',   'Memory size for JVM',             { default  => 16, }, ],
    { show_defaults => 1, }
    );

$usage->die if $opt->{help};

#----------------------------------------------------------#
# parameters
#----------------------------------------------------------#
my $bin_dir = {
    script => $FindBin::RealBin,
    stk    => path( $ENV{HOME}, "bin" )->stringify,
    gatk   => path( $ENV{HOME}, "share", "gatk" )->stringify,
    pcd    => path( $ENV{HOME}, "share", "picard-tools-1.128" )->stringify,
};
my $data_dir = {
    sra  => path( $opt->{base}, "sra" )->stringify,
    proc => path( $opt->{base}, "process" )->stringify,
    bash => path( $opt->{base}, "bash" )->stringify,
    log  => path( $opt->{base}, "log" )->stringify,
    ref  => path( $opt->{base}, "ref" )->stringify,
};
my $ref_file = {
    adapters => path( $opt->{base}, "ref", "illumina_adapters.fa" )->stringify,
    seq      => path( $opt->{base}, "ref", "genome.fa" )->stringify,
    sizes    => path( $opt->{base}, "ref", "chr.sizes" )->stringify,
};

for my $key ( keys %{$data_dir} ) {
    path( $data_dir->{$key} )->mkpath;
}

#----------------------------------------------------------#
# read csv
#----------------------------------------------------------#
my @rows;
my $csv = Text::CSV_XS->new( { binary => 1 } )
    or die "Cannot use CSV: " . Text::CSV_XS->error_diag;
open my $fh, "<", $opt->{csv};
$csv->getline($fh);    # skip headers
while ( my $row = $csv->getline($fh) ) {
    push @rows, $row;
}
close $fh;

my @data;
my @names = List::MoreUtils::PP::uniq( map { $_->[0] } @rows );
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
        base_dir => $opt->{base},
        bin_dir  => $bin_dir,
        data_dir => $data_dir,
        ref_file => $ref_file,
        parallel => $opt->{parallel},
        memory   => $opt->{memory},
    );

    $mybam->head($item);
    $mybam->srr_dump($item);
    $mybam->fastqc($item);
    $mybam->scythe_sickle($item);
    $mybam->fastqc($item);
    $mybam->tail($item);

    my $sh_file = path( $data_dir->{bash}, "sra." . $item->{name} . ".sh" )->stringify;
    print "Create [$sh_file]\n";
    $mybam->write( $item, $sh_file );
}

for my $item (@data) {
    my $mybam = MyBAM->new(
        base_dir => $opt->{base},
        bin_dir  => $bin_dir,
        data_dir => $data_dir,
        ref_file => $ref_file,
        parallel => $opt->{parallel},
        memory   => $opt->{memory},
        sickle   => 1,
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
    $mybam->tail($item);

    my $sh_file = path( $data_dir->{bash}, "bwa." . $item->{name} . ".sh" )->stringify;
    print "Create [$sh_file]\n";
    $mybam->write( $item, $sh_file );
}

#----------------------------------------------------------#
# Execute bash in background with GNU screen
#----------------------------------------------------------#
{
    my $mybam = MyBAM->new(
        base_dir => $opt->{base},
        bin_dir  => $bin_dir,
        data_dir => $data_dir,
        ref_file => $ref_file,
        parallel => $opt->{parallel},
        memory   => $opt->{memory},
        sickle   => 1,
    );

    $mybam->screen_sra( \@data );
    $mybam->screen_bwa( \@data );

    my $sh_file = path( $opt->{base}, "screen.sh.txt" )->stringify;
    print "Create [$sh_file]\n";
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
