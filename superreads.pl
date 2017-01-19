#!/usr/bin/perl
use strict;
use warnings;
use autodie;

use Getopt::Long::Descriptive;
use Template;
use Path::Tiny;
use IO::Zlib;

#----------------------------------------------------------#
# GetOpt section
#----------------------------------------------------------#

my $description = <<'EOF';
This script runs MaSuRCA (3.2.1) and prepares the long reads and unassembled reads files.

Modified from superreads.pl in StringTie.

Usage: perl %c <pair_read_1> <pair_read_2> [options]
EOF

(    #@type Getopt::Long::Descriptive::Opts
    my $opt,

    #@type Getopt::Long::Descriptive::Usage
    my $usage,
    )
    = Getopt::Long::Descriptive::describe_options(
    $description,
    [ 'help|h', 'display this message' ],
    [],
    [ 'size|s=i',     'fragment size',                        { default => 300, }, ],
    [ 'std|d=i',      'fragment size standard deviation',     { default => 20, }, ],
    [ 'parallel|p=i', 'number of threads to use',             { default => 8, }, ],
    [ 'jf=i',         'jellyfish hash size',                  { default => 500_000_000, }, ],
    [ 'kmer=s',       'kmer size to be used for super reads', { default => 'auto', }, ],
    [ 'prefix|r=s',   'prefix for paired-reads',              { default => 'pe', }, ],
    [ 'long|l',       'create long reads', ],
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
    print STDERR "==> Starting masurca\n";

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
CA_PARAMETERS = ovlMerSize=30 cgwErrorRate=0.15
LIMIT_JUMP_COVERAGE = 60
EXTEND_JUMP_READS = 0
GRAPH_KMER_SIZE = [% kmer %]
NUM_THREADS = [% parallel %]
JF_SIZE = [% jf %]
END

EOF

    #@type Template
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
            kmer     => $opt->{kmer},
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
    print STDERR "==> Done.\n";
}

if ( $opt->{long} ) {
    print STDERR "==> Starting creating long reads\n";
    get_long_reads( $ARGV[0], $ARGV[1], $opt->{prefix}, $opt->{size} );
    print STDERR "==> Done.\n";
}

#----------------------------------------------------------#
# Subroutines
#----------------------------------------------------------#

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

    my $read_placement = "work1/readPlacementsInSuperReads.final.read.superRead.offset.ori.txt";
    die "MaSuRCA file $read_placement could not be found!\n"
        if ( !( -e $read_placement ) );

    my $super_read_fasta = "work1/superReadSequences.fasta";
    die "MaSuRCA file $super_read_fasta could not be found!\n"
        if ( !( -e $super_read_fasta ) );

    # masurca renamed sequences in fq as the original orders
    # $read_prefix as 'pe'
    # the first pair in fq renamed to pe0 and pe1,  0 / 2 = 0
    # the second pair in fq renamed to pe2 and pe3, 2 / 2 = 1
    # the third pair in fq renamed to pe4 and pe5,  4 / 2 = 2
    #
    # 0, 1, 2... are indexes of read pairs in fq files. Use them to identify read pairs.

    # stores the info of pair-end reads in super reads.
    # key: pair index
    # value: array ref
    #   0 = first read position in super read;
    #   1 = second read position;
    #   2 = orientation of first read;
    #   3 = original name in fq files
    # unpaired reads are discarded
    my $info_of = [];

    # records all read pairs contained by a super-read
    # key: sr id
    # value: array ref of pair indexes
    my $pairs_in_sr = {};

    {
        my $prev_idx = -1;
        my $prev_ori;
        my $prev_pos;
        my $prev_sr_id;

        my $in_fh = IO::Zlib->new( $read_placement, "rb" );
        while ( my $line = $in_fh->getline ) {
            chomp $line;
            my ( $read_id, $sr_id, $position, $orientation ) = split /\s+/, $line;
            if ( $read_id =~ /^$read_prefix(\d+)/ ) {
                my $read_idx = $1;

                # if we have two reads in a row, the first one being an even number,
                # then check paired end constraints
                if ( $read_idx == $prev_idx + 1 && $read_idx % 2 == 1 ) {

                    # then we have a pair of reads
                    if ( $sr_id eq $prev_sr_id ) {    # then they are in the same unitig
                        if (   ( $orientation eq "F" && $prev_ori eq "R" )
                            || ( $orientation eq "R" && $prev_ori eq "F" ) )
                        {
                            $prev_pos = 0 if $prev_pos < 0;
                            $position = 0 if $position < 0;
                            my $distance = $prev_pos - $position;

                            if ( $orientation eq "R" && $prev_ori eq "F" ) {
                                $distance = $position - $prev_pos;
                            }

                            # if reads are placed the right way,
                            # and they are within a factor of 2 of the right dist apart
                            if ( $distance > 50 && $distance < $fragment_length * 2 ) {
                                my $pair_idx = $prev_idx / 2;

                                # mark this read pair in sr, update original names later
                                $info_of->[$pair_idx]
                                    = [ $prev_pos, $position, $prev_ori, $pair_idx ];

                                if ( !exists $pairs_in_sr->{$sr_id} ) {
                                    $pairs_in_sr->{$sr_id} = [];
                                }
                                push @{ $pairs_in_sr->{$sr_id} }, $pair_idx;
                            }
                        }
                    }
                }

                # always save the ID and compare to the next one
                $prev_idx   = $read_idx;
                $prev_ori   = $orientation;
                $prev_pos   = $position;
                $prev_sr_id = $sr_id;
            }
            else {
                $prev_idx = -1;
            }
        }
        $in_fh->close;
    }

    {
        my $in_fh  = IO::Zlib->new( $pair1file,             "rb" );
        my $out_fh = IO::Zlib->new( "notAssembled_1.fq.gz", "wb" );
        my $pair_idx = 0;
        while ( my $line = $in_fh->getline ) {
            chomp $line;
            if ( ref $info_of->[$pair_idx] eq "ARRAY" ) {
                $info_of->[$pair_idx][3] = $line;    # record original names
                $in_fh->getline;
                $in_fh->getline;
                $in_fh->getline;
            }
            else {
                print {$out_fh} $line, "\n";
                print {$out_fh} $in_fh->getline;
                print {$out_fh} $in_fh->getline;
                print {$out_fh} $in_fh->getline;
            }
            $pair_idx++;
        }
        $in_fh->close;
        $out_fh->close;
    }

    {
        my $in_fh  = IO::Zlib->new( $pair2file,             "rb" );
        my $out_fh = IO::Zlib->new( "notAssembled_2.fq.gz", "wb" );
        my $pair_idx = 0;
        while ( my $line = $in_fh->getline ) {
            chomp $line;
            if ( ref $info_of->[$pair_idx] eq "ARRAY" ) {
                $in_fh->getline;
                $in_fh->getline;
                $in_fh->getline;
            }
            else {
                print {$out_fh} $line, "\n";
                print {$out_fh} $in_fh->getline;
                print {$out_fh} $in_fh->getline;
                print {$out_fh} $in_fh->getline;
            }
            $pair_idx++;
        }
        $in_fh->close;
        $out_fh->close;
    }

    {
        my $in_fh  = IO::Zlib->new( $super_read_fasta, "rb" );
        my $out_fh = IO::Zlib->new( "LongReads.fq.gz", "wb" );

        my $sr_id;
        while ( my $line = $in_fh->getline ) {
            chomp $line;
            if ( $line eq '' or substr( $line, 0, 1 ) eq " " ) {
                next;
            }
            elsif ( substr( $line, 0, 1 ) eq "#" ) {
                next;
            }
            elsif ( substr( $line, 0, 1 ) eq ">" ) {
                ($sr_id) = split /\s+/, $line;
                $sr_id =~ s/^>//;
            }
            else {
                my $sr_seq = $line;
                if ( exists $pairs_in_sr->{$sr_id} ) {
                    for my $pair_idx ( @{ $pairs_in_sr->{$sr_id} } ) {
                        my $end5 = $info_of->[$pair_idx][0];
                        my $end3 = $info_of->[$pair_idx][1];
                        if ( $end5 > $end3 ) {
                            $end5 = $info_of->[$pair_idx][1];
                            $end3 = $info_of->[$pair_idx][0];
                        }

                        my $len = $end3 - $end5;
                        my $longread_seq = substr( $sr_seq, $end5, $len );
                        if ( $info_of->[$pair_idx][2] eq 'R' ) {
                            $longread_seq = reverse $longread_seq;
                            $longread_seq =~ tr/ACGTacgt/TGCAtgca/;
                        }

                        # now print it in fastq format
                        print {$out_fh} $info_of->[$pair_idx][3], "\n";
                        print {$out_fh} $longread_seq, "\n";
                        print {$out_fh} "+\n";

                        # use quality value "J" which is 41, I think
                        print {$out_fh} 'J' x length($longread_seq), "\n";
                    }
                }
            }
        }
    }

}
