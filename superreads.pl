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
This script runs MaSuRCA and prepares the long reads and unassembled reads files.

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
    [ 'size|s=i',     'fragment size',                    { default => 300, }, ],
    [ 'std|d=i',      'fragment size standard deviation', { default => 20, }, ],
    [ 'parallel|p=i', 'number of threads to use',         { default => 8, }, ],
    [ 'jf|j=i',       'jellyfish hash size',              { default => 500_000_000, }, ],
    [ 'prefix|r=s',   'prefix for paired-reads',          { default => 'pe', }, ],
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
CA_PARAMETERS= ovlMerSize=30 cgwErrorRate=0.25 merylMemory=8192 ovlMemory=4GB
LIMIT_JUMP_COVERAGE = 60
KMER_COUNT_THRESHOLD = 1
EXTEND_JUMP_READS=0
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

    # stores the supereads info:
    # 0=first read pair position;
    # 1=second read pair position;
    # 2=orientation of first read;
    # 3=position of read in fastq file
    my @read;

    my %longread;
    my %isname;

    {
        my $n             = 0;
        my $prev_read_num = -1;
        my $prev_orient;
        my $prev_pos;
        my $prev_superread;

        my $in_fh = IO::Zlib->new( $read_placement, "rb" );
        while ( my $line = $in_fh->getline ) {
            chomp $line;
            my ( $read_id, $super_read, $position, $orientation ) = split /\s+/, $line;
            if ( $read_id =~ /^$read_prefix(\d+)/ ) {
                my $read_num = $1;

                # if we have two reads in a row, the first one being an even number,
                # then check paired end constraints
                if (   $read_num == $prev_read_num + 1
                    && $read_num % 2 == 1 )
                {
                    # then we have a pair of reads
                    if ( $super_read eq $prev_superread ) {    # then they are in the same unitig
                        if (   ( $orientation eq "F" && $prev_orient eq "R" )
                            || ( $orientation eq "R" && $prev_orient eq "F" ) )
                        {
                            $prev_pos = 0 if $prev_pos < 0;
                            $position = 0 if $position < 0;
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
            else {
                $prev_read_num = -1;
            }
        }
        $in_fh->close;
    }

    {
        my $in_fh  = IO::Zlib->new( $pair1file,             "rb" );
        my $out_fh = IO::Zlib->new( "notAssembled_1.fq.gz", "wb" );
        my $n      = 0;
        while ( my $line = $in_fh->getline ) {
            chomp $line;
            if ( $longread{$n} ) {
                $longread{$n} = $line;
                <$in_fh>;
                <$in_fh>;
                <$in_fh>;
            }
            else {
                print {$out_fh} $line, "\n";
                print {$out_fh} <$in_fh>;
                print {$out_fh} <$in_fh>;
                print {$out_fh} <$in_fh>;
            }
            $n++;
        }
        $in_fh->close;
        $out_fh->close;
    }

    {
        my $in_fh  = IO::Zlib->new( $pair2file,             "rb" );
        my $out_fh = IO::Zlib->new( "notAssembled_2.fq.gz", "wb" );
        my $n      = 0;
        while ( my $line = $in_fh->getline ) {
            chomp $line;
            if ( !$longread{$n} ) {
                print {$out_fh} $line, "\n";
                print {$out_fh} <$in_fh>;
                print {$out_fh} <$in_fh>;
                print {$out_fh} <$in_fh>;
            }
            else {
                <$in_fh>;
                <$in_fh>;
                <$in_fh>;
            }
            $n++;
        }
        $in_fh->close;
        $out_fh->close;
    }

    {
        my $in_fh  = IO::Zlib->new( $super_read_fasta, "rb" );
        my $out_fh = IO::Zlib->new( "LongReads.fq.gz", "wb" );

        my $name;
        while ( my $line = $in_fh->getline ) {
            chomp $line;
            if ( $line eq '' or substr( $line, 0, 1 ) eq " " ) {
                next;
            }
            elsif ( substr( $line, 0, 1 ) eq "#" ) {
                next;
            }
            elsif ( substr( $line, 0, 1 ) eq ">" ) {
                ($name) = split /\s+/, $line;
                $name =~ s/^>//;
            }
            else {
                my $seq = $line;
                if ( $isname{$name} ) {
                    for ( my $i = 0; $i < scalar( @{ $isname{$name} } ); $i++ ) {
                        my $j    = $isname{$name}[$i];
                        my $end5 = $read[$j][0];
                        my $end3 = $read[$j][1];
                        if ( $end5 > $end3 ) {
                            $end5 = $read[$j][1];
                            $end3 = $read[$j][0];
                        }

                        my $len = $end3 - $end5;
                        my $longread_seq = substr( $seq, $end5, $len );
                        if ( $read[$j][2] eq 'R' ) {
                            $longread_seq = reverse $longread_seq;
                            $longread_seq =~ tr/ACGTacgt/TGCAtgca/;
                        }

                        # now print it in fastq format
                        print {$out_fh} $longread{ $read[$j][3] }, "\n";
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
