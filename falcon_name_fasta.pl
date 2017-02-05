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
    'in|i=s'     => \( my $in_fn    = q{} ),
    'out|o=s'    => \( my $out_fn   = q{} ),
    'prefix|p=s' => \( my $prefix   = q{} ),
    'table|t=s'  => \( my $table_fn = q{} ),
) or Getopt::Long::HelpMessage(1);

if ( !$in_fn ) {
    warn "Need input file.\n";
    Getopt::Long::HelpMessage(0);
}

if ( $prefix =~ /\W/xms ) {
    die "Cannot accept prefix with space or non-word characters (such as \".\"): $prefix\n";
}

if ( $out_fn =~ /[^\w\.]/xms ) {
    die "Cannot accept outfile with space or non-standard characters: $out_fn\n";
}

# Have human-readable default value:
$prefix ||= 'falcon_read';
$prefix = safename($prefix);

$out_fn ||= "$in_fn.outfile";
$out_fn = safename($out_fn);

$table_fn ||= 'old2new_names.txt';
$table_fn = safename($table_fn);

#----------------------------------------------------------#
# Run
#----------------------------------------------------------#
my $i            = 0;
my $orig_seqname = q{};
my @orig_seqs    = ();

my $data_ref = {};

# Accept either a stream from 'stdin' or a standard file.
my $in_fh;
if ( lc $in_fn eq 'stdin' ) {
    $in_fh = *STDIN{IO};
}
else {
    open $in_fh, '<', $in_fn;
}

open my $out_fh,   '>', $out_fn;
open my $table_fh, '>', $table_fn;

while ( my $line = <$in_fh> ) {
    chomp $line;
    if ( $line =~ /\A > (\S+) /xms ) {
        $orig_seqname = $1;
        if ( exists $data_ref->{'orig_seqname'}->{$orig_seqname} ) {
            die "Redundant sequence name: $orig_seqname\n";
        }
        $data_ref->{'orig_seqname'}->{$orig_seqname}->{'seen'} = 1;
        push @orig_seqs, $orig_seqname;
    }
    elsif ( $line =~ / \A \s* [A-Za-z] /xms ) {
        $line =~ s/\s//g;
        if ( $line =~ / [^ACGTNacgtn] /xms ) {
            die "Can't parse: $line\n";
        }
        $data_ref->{'orig_seqname'}->{$orig_seqname}->{'sequence'} .= $line;
    }
    else {
        if ( $line !~ /\A \s* \z/xms ) {
            die "Can't parse: $line\n";
        }
    }
}
close $in_fh;

for my $orig_seq1 (@orig_seqs) {
    $data_ref->{'orig_seqname'}->{$orig_seq1}->{'length'}
        = length( $data_ref->{'orig_seqname'}->{$orig_seq1}->{'sequence'} );
}

for my $orig_seq2 (@orig_seqs) {
    $i++;
    my $serial_no = $i;
    $serial_no = sprintf( '%u', $serial_no );

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
