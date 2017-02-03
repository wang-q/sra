#!/usr/bin/perl
use strict;
use warnings;
use autodie;

use Getopt::Long;

#----------------------------------------------------------#
# GetOpt section
#----------------------------------------------------------#

=head1 NAME

falcon_name_fasta.pl - rename FASTA reads with format acceptable to FALCON;
                       as side product, generate old-to-new name table.

=head1 SYNOPSIS

    perl falcon_name_fasta.pl -i <infile> [options]
      Options:
        --help                  brief help message
        --infile    -i  STR     input stream/files
        --outfile   -o  STR     output file name; default is (infile).outfile
        --prefix    -p  STR     optional prefix; default is "falcon_read"
        --table     -t  STR     table of old to new read names; default is "old2new_names.txt"

=head1 AUTHORS

Erich Schwarz <ems394@cornell.edu>, <https://github.com/PacificBiosciences/FALCON/issues/251>, 11/13/2015.

Modified by Qiang Wang.

=cut

GetOptions(
    'help|?' => sub { Getopt::Long::HelpMessage(0) },
    'infile|i=s'  => \( my $infile  = q{} ),
    'outfile|o=s' => \( my $outfile = q{} ),
    'prefix|p=s'  => \( my $prefix  = q{} ),
    'table|t=s'   => \( my $table   = q{} ),
) or Getopt::Long::HelpMessage(1);

if ( !$infile ) {
    warn "Need input file.\n";
    Getopt::Long::HelpMessage(0);
}

if ( $prefix =~ /\W/xms ) {
    die "Cannot accept prefix with space or non-word characters (such as \".\"): $prefix\n";
}

if ( $outfile =~ /[^\w\.]/xms ) {
    die "Cannot accept outfile with space or non-standard characters: $outfile\n";
}

# Have human-readable default value:
$prefix ||= 'falcon_read';
$prefix = safename($prefix);

$outfile ||= "$infile.outfile";
$outfile = safename($outfile);

$table ||= 'old2new_names.txt';
$table = safename($table);

#----------------------------------------------------------#
# Run
#----------------------------------------------------------#
my $i            = 0;
my $orig_seqname = q{};
my @orig_seqs    = ();

my $data_ref = {};

# Accept either a stream from 'stdin' or a standard file.
my $in_fh;
if ( lc $infile eq 'stdin' ) {
    $in_fh = *STDIN{IO};
}
else {
    open $in_fh, '<', $infile;
}

open my $out_fh,   '>', $outfile;
open my $table_fh, '>', $table;

while ( my $input = <$in_fh> ) {
    chomp $input;
    if ( $input =~ /\A > (\S+) /xms ) {
        $orig_seqname = $1;
        if ( exists $data_ref->{'orig_seqname'}->{$orig_seqname} ) {
            die "Redundant sequence name: $orig_seqname\n";
        }
        $data_ref->{'orig_seqname'}->{$orig_seqname}->{'seen'} = 1;
        push @orig_seqs, $orig_seqname;
    }
    elsif ( $input =~ / \A \s* [A-Za-z] /xms ) {
        $input =~ s/\s//g;
        if ( $input =~ / [^ACGTNacgtn] /xms ) {
            die "Can't parse: $input\n";
        }
        $data_ref->{'orig_seqname'}->{$orig_seqname}->{'sequence'} .= $input;
    }
    else {
        if ( $input !~ /\A \s* \z/xms ) {
            die "Can't parse: $input\n";
        }
    }
}
close $in_fh;

for my $orig_seq1 (@orig_seqs) {
    $data_ref->{'orig_seqname'}->{$orig_seq1}->{'length'}
        = length( $data_ref->{'orig_seqname'}->{$orig_seq1}->{'sequence'} );
}

my $seq_count = @orig_seqs;
my $DIGITS    = length($seq_count);

for my $orig_seq2 (@orig_seqs) {
    $i++;
    my $serial_no = $i;
    my $sf_format = '%0' . $DIGITS . 'u';
    $serial_no = sprintf( $sf_format, $serial_no )
        or die "Can't zero-pad serial number $serial_no\n";

    my $new_name
        = $prefix . q{/}
        . $serial_no . q{/0_}
        . $data_ref->{'orig_seqname'}->{$orig_seq2}->{'length'};

    print $out_fh '>' . "$new_name\n";
    print $table_fh "$orig_seq2\t$new_name\n";
    my @output_lines
        = unpack( "a60" x ( $data_ref->{'orig_seqname'}->{$orig_seq2}->{'length'} / 60 + 1 ),
        $data_ref->{'orig_seqname'}->{$orig_seq2}->{'sequence'} );
    for my $output_line (@output_lines) {
        if ( $output_line =~ /\S/ ) {
            print $out_fh "$output_line\n";
        }
    }
}

close $out_fh;
close $table_fh;

#----------------------------------------------------------#
# Subroutines
#----------------------------------------------------------#

sub safename {
    my $_filename      = $_[0];
    my $_orig_filename = $_filename;
    if ( -e $_orig_filename ) {
        my $_suffix1 = 1;
        $_filename = $_filename . ".$_suffix1";
        while ( -e $_filename ) {
            $_suffix1++;
            $_filename =~ s/\.\d+\z//xms;
            $_filename = $_filename . ".$_suffix1";
        }
    }
    return $_filename;
}
