#!/usr/bin/perl
use strict;
use warnings;

use Getopt::Long::Descriptive;
use Template;
use Path::Tiny;

#----------------------------------------------------------#
# GetOpt section
#----------------------------------------------------------#

(    #@type Getopt::Long::Descriptive::Opts
    my $opt,

    #@type Getopt::Long::Descriptive::Usage
    my $usage,
    )
    = Getopt::Long::Descriptive::describe_options(
    "This script runs MaSuRCA and prepares the super-reads and unassembled reads files.\n\n"
        . "Usage: perl %c <pair_read_1> <pair_read_2> [options]",
    [ 'help|h', 'display this message' ],
    [],
    [ 'prefix|r=s',   'prefix for paired-reads',          { default => 'pe', }, ],
    [ 'size|f=i',     'fragment size',                    { default => 300, }, ],
    [ 'std|d=i',      'fragment size standard deviation', { default => 20, }, ],
    [ 'parallel|p=i', 'number of threads to use',         { default => 8, }, ],
    [ 'jf|j=i',       'jellyfish hash size',              { default => 500_000_000, }, ],
    [   'masurca|m=s',
        'masurca directory',
        { default => path( $ENV{HOME}, "share", "MaSuRCA" )->stringify, },
    ],
    { show_defaults => 1, }
    );

$usage->die if $opt->{help};

if ( @ARGV != 2 ) {
    my $message = "This script need two input fastq files.\n\tIt found";
    $message .= sprintf " [%s]", $_ for @ARGV;
    $message .= ".\n";
    $usage->die( { pre_text => $message } );
}
for (@ARGV) {
    if ( !Path::Tiny::path($_)->is_file ) {
        $usage->die( { pre_text => "The input file [$_] doesn't exist.\n" } );
    }
}

if ( !Path::Tiny::path( $opt->{masurca} )->is_dir ) {
    $usage->die( { pre_text => "The masurca directory [$opt->{masurca}] doesn't exist.\n" } );
}

#----------------------------------------------------------#
# start
#----------------------------------------------------------#

{
    print STDERR "==> Starting step 1: run masurca...\n";

    my $text = <<'EOF';
# PE and 5 fields:
#   1) two_letter_prefix
#   2) mean
#   3) stdev
#   4) fastq(.gz)_fwd_reads
#   5) fastq(.gz)_rev_reads.
# The PE reads are always assumed to be innies, i.e. --->.<---.
# Reverse reads are optional for PE libraries.
DATA
PE= [% prefix %] [% size %] [% std %] [% r1file %] [% r2file %]
END

PARAMETERS
# this is k-mer size for deBruijn graph values between 25 and 101 are supported,
# auto will compute the optimal size based on the read data and GC content.
GRAPH_KMER_SIZE = auto
# set this to 1 for Illumina-only assemblies and to 0 if you have 1x or more long (Sanger, 454) reads,
# you can also set this to 0 for large data sets with high jumping clone coverage, e.g. >50x
USE_LINKING_MATES = 0
# this parameter is useful if you have too many jumping library mates.
# Typically set it to 60 for bacteria and 300 for the other organisms
LIMIT_JUMP_COVERAGE = 300
# these are the additional parameters to Celera Assembler.
# do not worry about performance, number or processors or batch sizes -- these are computed automatically.
# set cgwErrorRate=0.25 for bacteria and 0.1<=cgwErrorRate<=0.15 for other organisms.
CA_PARAMETERS = cgwErrorRate=0.15 ovlMemory=4GB
# minimum count k-mers used in error correction 1 means all k-mers are used.
# one can increase to 2 if coverage >100
KMER_COUNT_THRESHOLD = 1
# auto-detected number of cpus to use
NUM_THREADS = [% parallel %]
# this is mandatory jellyfish hash size -- a safe value is estimated_genome_size*estimated_coverage
JF_SIZE = [% jf %]
# this specifies if we do (1) or do not (0) want to trim long runs of homopolymers (e.g. GGGGGGGG) from 3' read ends, use it for high GC genomes
DO_HOMOPOLYMER_TRIM = 0
END

EOF

    my $tt = Template->new;
    $tt->process(
        \$text,
        {   prefix   => $opt->{prefix},
            size     => $opt->{size},
            std      => $opt->{std},
            r1file   => $ARGV[0],
            r2file   => $ARGV[1],
            parallel => $opt->{parallel},
            jf       => $opt->{jf},
        },
        path("sr_config.txt")->stringify
    ) or die Template->error;

    my $run_masurca = path( $opt->{masurca}, "bin", "masurca" )->stringify . " sr_config.txt";
    print STDERR "==> Running $run_masurca\n";
    die "Could not run MaSuRCA command: $run_masurca\n" if system($run_masurca);

    my $assemble_script = "assemble.sh";
    if ( !( -e $assemble_script ) ) {
        print STDERR "Could not find assembly script: $assemble_script\n";
        exit;
    }
    update_assemble_script($assemble_script);
    print STDERR "==> Running assemble.sh\n";
    my $run_assembly = "bash " . $assemble_script;
    die "Assembly script did not finish running!\n" if system($run_assembly);
    print STDERR "==> Done step 1.\n";
}

{
    print STDERR "==> Starting step 2: prepare super-reads for spliced alignment....\n";
    get_long_reads( $ARGV[0], $ARGV[1], $opt->{prefix}, $opt->{size} );
    print STDERR "==> Done step 2.\n";
}

#----------------------------------------------------------#
# Subroutines
#----------------------------------------------------------#

sub get_filename_prefix {
    my ($filename) = @_;

    my @b = split( /\//, $filename );
    my @a = split( /\./, $b[-1] );

    if ( ( $a[-1] =~ m/\.bzi?p?2$/ ) || ( $a[-1] =~ m/.g?zi?p?$/ ) ) {
        pop(@a);
    }

    if ( ( $a[-1] eq 'fq' ) || ( $a[-1] eq 'fastq' ) ) { pop(@a); }

    my $newname = join( '.', @a );

    return ($newname);
}

sub update_assemble_script {
    my $filename = shift;

    my $out = "";

    open my $in_fh, "<", $filename;
    while (<$in_fh>) {
        if (/^runCA/) { last; }
        $out .= $_;
    }
    close $in_fh;

    path($filename)->spew($out);
}

sub get_long_reads {
    my ( $pair1file, $pair2file, $read_prefix, $fragment_length, ) = @_;

    my $readplacement = "work1/readPlacementsInSuperReads.final.read.superRead.offset.ori.txt";
    die "MaSuRCA file $readplacement could not be found!\n"
        if ( !( -e $readplacement ) );

    my $superreadfasta = "work1/superReadSequences.fasta";
    die "MaSuRCA file $superreadfasta could not be found!\n"
        if ( !( -e $superreadfasta ) );

    # stores the supereads info:
    # 0=first read pair position;
    # 1=second read pair position;
    # 2=orientation of first read;
    # 3=position of read in fastq file
    my @read;

    my $n             = 0;
    my $prev_read_num = -1;
    my $prev_orient;
    my $prev_pos;
    my $prev_superread;

    my %longread;
    my %isname;

    open( F, $readplacement );
    while (<F>) {
        chomp;
        my ( $read_id, $super_read, $position, $orientation ) = split(/\s+/);
        if ( $read_id =~ /^$read_prefix(\d+)/ ) {
            my $read_num = $1;

            # if we have two reads in a row, the first one being an even number,
            # then check paired end constraints
            if (   $read_num == $prev_read_num + 1
                && $read_num % 2 == 1 )
            {
                # then we have a pair of reads
                if ( $super_read eq $prev_superread ) {    # then they are in the same unitig
                    if (( $orientation eq "F" && $prev_orient eq "R" )
                        || (   $orientation eq "R"
                            && $prev_orient eq "F" )
                        )
                    {
                        if ( $prev_pos < 0 ) { $prev_pos = 0; }
                        if ( $position < 0 ) { $position = 0; }
                        my $distance = $prev_pos - $position;
                        if ( $orientation eq "R" && $prev_orient eq "F" ) {
                            $distance = $position - $prev_pos;
                        }

                        # if reads are placed the right way,
                        # and they are within a factor of 2 of the right dist apart
                        if (   $distance > 50
                            && $distance < $fragment_length * 2
                            && $distance > 0 )
                        {
                            push(
                                @{ $read[$n] },
                                ( $prev_pos, $position, $prev_orient, $prev_read_num / 2 )
                            );
                            $longread{ $prev_read_num / 2 } = 1;
                            push( @{ $isname{$super_read} }, $n );
                            $n++;
                        }
                    }
                }
            }

            # always save the ID and compare to the next one
            $prev_read_num  = $read_num;
            $prev_orient    = $orientation;
            $prev_pos       = $position;
            $prev_superread = $super_read;
        }
        else { $prev_read_num = -1; }
    }
    close(F);

    if ( $pair1file =~ /\.gz$/ ) {
        open( F, "zcat $pair1file|" );
    }
    else {
        open( F, $pair1file );
    }

    open( O, "| gzip -c > notAssembled_1.fa.gz" );
    $n = 0;
    while (<F>) {
        chomp;
        if ( $longread{$n} ) {
            $longread{$n} = $_;
            <F>;
            <F>;
            <F>;
        }
        else {
            print O $_, "\n";
            my $line = <F>;
            print O $line;
            $line = <F>;
            print O $line;
            $line = <F>;
            print O $line;
        }
        $n++;
    }
    close(F);
    close(O);

    if ( $pair2file =~ /\.gz$/ ) {
        open( F, "zcat $pair2file|" );
    }
    else {
        open( F, $pair2file );
    }

    open( O, "| gzip -c > notAssembled_2.fa.gz" );
    $n = 0;
    while (<F>) {
        chomp;
        if ( !$longread{$n} ) {
            print O $_, "\n";
            my $line = <F>;
            print O $line;
            $line = <F>;
            print O $line;
            $line = <F>;
            print O $line;
        }
        else { <F>; <F>; <F>; }
        $n++;
    }
    close(F);
    close(O);

    open( O, "| gzip -c > LongReads.fq.gz" );

    $/ = ">";
    open( F, $superreadfasta );
    while (<F>) {
        chomp;
        if ($_) {
            my ($name) = /^(\S+)\s+/;
            if ( $isname{$name} ) {
                my $pos = index( $_, "\n" );
                my $seq = substr( $_, $pos + 1 );
                local $/ = "\n";
                chomp($seq);
                for ( my $i = 0; $i < scalar( @{ $isname{$name} } ); $i++ ) {
                    my $n    = $isname{$name}[$i];
                    my $end5 = $read[$n][0];
                    my $end3 = $read[$n][1];
                    if ( $end5 > $end3 ) {
                        $end5 = $read[$n][1];
                        $end3 = $read[$n][0];
                    }

                    my $len = $end3 - $end5;
                    my $longread_seq = substr( $seq, $end5, $len );
                    if ( $read[$n][2] eq 'R' ) {
                        $longread_seq = reverse $longread_seq;
                        $longread_seq =~ tr/ACGTacgt/TGCAtgca/;
                    }

                    # now print it in fastq format
                    print O $longread{ $read[$n][3] }, "\n";
                    print O $longread_seq, "\n";
                    print O "+\n";

                    # use quality value "J" which is 41, I think
                    print O 'J' x length($longread_seq), "\n";
                }
            }
        }
    }
    close(F);
}
