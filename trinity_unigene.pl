#!/usr/bin/env perl

=head1 NAME

filter_fasta_by_rsem_values.pl - Use RSEM relative abundance values to filter a
transcript assembly FASTA file

=head1 SYNOPSIS

USAGE: filter_fasta_by_rsem_values.pl 
            --rsem_output=/path/to/RSEM.isoforms.results[,...]
            --fasta=/path/to/Trinity.fasta
            --output=/path/to/output.fasta

=cut

use warnings;
use strict;
use autodie;

use Getopt::Long qw(:config no_ignore_case no_auto_abbrev pass_through);
use Pod::Usage;
use YAML qw(Dump Load DumpFile LoadFile);

use File::Slurp;

my %options;
my $results = GetOptions(
    \%options,           'rsem_output|r=s',
    'fasta|f=s',         'output|o=s',
    'tpm_cutoff|t=s',    'fpkm_cutoff|c=s',
    'isopct_cutoff|i=s', 'unigene|u',
    'log|l=s',           'help|h',
) or pod2usage();

## display documentation
pod2usage( -exitstatus => 0, -verbose => 2, -output => \*STDERR, )
    if $options{help};

## make sure everything passed was peachy
check_parameters( \%options );

#----------------------------------------------------------#
# Start
#----------------------------------------------------------#

## open the log if requested
my $logfh;
if ( defined $options{log} ) {
    open $logfh, ">", $options{log};
}
else {
    $logfh = *STDOUT;
}

_log("INFO: Opening RSEM file ($options{rsem_output})");
my $rsem = load_rsem_output( $options{rsem_output} );

_log("INFO: creating output file: ($options{output})");
open my $ofh, ">", $options{output};

_log("INFO: reading input FASTA file: ($options{fasta})");
my @lines = read_file( $options{fasta} );

#----------------------------#
# read fasta headers
#----------------------------#
my @trans_ids = map { ( split /\s+/ )[0] }
    grep {/^>/} @lines;
s/^>// for @trans_ids;
print "Original: @{[scalar @trans_ids]} \n";

## make sure we have cutoffs for this
@trans_ids = grep { exists $rsem->{$_} } @trans_ids;
print "Rsem: @{[scalar @trans_ids]} \n";

#----------------------------#
# three filters
#----------------------------#
if ( defined $options{fpkm_cutoff} ) {
    @trans_ids = grep { $rsem->{$_}{fpkm} >= $options{fpkm_cutoff} } @trans_ids;
    print "fpkm: @{[scalar @trans_ids]} \n";
}

if ( defined $options{tpm_cutoff} ) {
    @trans_ids = grep { $rsem->{$_}{tpm} >= $options{tpm_cutoff} } @trans_ids;
    print "tpm: @{[scalar @trans_ids]} \n";
}

if ( defined $options{isopct_cutoff} ) {
    @trans_ids = grep {
        my $gene_id          = $rsem->{iso_to_gene}{$_};
        my $num_iso_per_gene = $rsem->{iso_count_per_gene}{$gene_id};
        $num_iso_per_gene == 1
            or ( $rsem->{$_}{isopct} >= $options{isopct_cutoff}
            && $num_iso_per_gene > 1 );
    } @trans_ids;
    print "isopct: @{[scalar @trans_ids]} \n";
}

#----------------------------#
# keep 1 trans per gene
#----------------------------#
if ( $options{unigene} ) {
    my @out_trans_ids;

    my %iso_score;
    for my $trans_id (@trans_ids) {
        $iso_score{$trans_id}
            = $rsem->{$trans_id}{length} * $rsem->{$trans_id}{isopct} / 100;
    }

    my %gene_to_iso;
    for my $trans_id (@trans_ids) {
        my $gene_id = $rsem->{$trans_id}{gene};
        if ( exists $gene_to_iso{$gene_id} ) {
            push @{ $gene_to_iso{$gene_id} }, $trans_id;
        }
        else {
            $gene_to_iso{$gene_id} = [$trans_id];
        }
    }

    for my $gene_id ( keys %gene_to_iso ) {
        my @order = sort { $iso_score{$b} <=> $iso_score{$a} }
            @{ $gene_to_iso{$gene_id} };
        push @out_trans_ids, $order[0];
    }
    
    @trans_ids = @out_trans_ids;
    print "unigene: @{[scalar @trans_ids]} \n";
}

#----------------------------#
# write filtered file
#----------------------------#
my %seen;
$seen{$_}++ for @trans_ids;

my $keep = 0;
for my $line (@lines) {
    if ( $line =~ /^\>(\S+)/ ) {
        my $trans_id = $1;
        $keep = $seen{$trans_id} ? 1 : 0;
    }
    print {$ofh} $line if $keep;
}

close $ofh;

exit;

#----------------------------------------------------------#
# Subroutine
#----------------------------------------------------------#
sub load_rsem_output {
    my $file = shift;

    ## relative abundance data.  looks like:
    #   $rel{'comp3119_c0_seq1'} = { fpkm   => 63.55,
    #                                tpm    => 10324,
    #                                isopct => 31.43
    #                              }
    my %rel = ();

    open my $ifh, "<", $file;

    while ( my $line = <$ifh> ) {
        chomp $line;

        next if $line =~ /^\s*$/;
        my @cols = split( "\t", $line );

        $rel{ $cols[0] } = {
            fpkm   => $cols[6],
            tpm    => $cols[5],
            isopct => $cols[7],
            line   => $line,
            trans  => $cols[0],
            gene   => $cols[1],
            length => $cols[2],
        };

    }

    _log(     "INFO: Loaded RSEM values for "
            . scalar( keys %rel )
            . " transcripts" );

    my %trans_to_gene;
    my %gene_to_iso;

    ## generate trans to gene mapping and count isoforms per gene.
    for my $trans_id ( keys %rel ) {
        my $rsem_entry = $rel{$trans_id};

        my $gene_id = $rsem_entry->{gene};
        $gene_to_iso{$gene_id}->{$trans_id} = 1;
        $trans_to_gene{$trans_id} = $gene_id;
    }

    $rel{iso_to_gene} = \%trans_to_gene;

    for my $gene_id ( keys %gene_to_iso ) {
        my @trans     = keys %{ $gene_to_iso{$gene_id} };
        my $num_trans = scalar(@trans);
        $rel{iso_count_per_gene}->{$gene_id} = $num_trans;
    }

    return \%rel;
}

sub _log {
    my $msg = shift;

    print $logfh "$msg\n" if $logfh;
}

sub logdie {
    my $msg = shift;

    print STDERR "$msg\n";
    print $logfh "$msg\n" if $logfh;

    exit(1);
}

sub check_parameters {
    my $options = shift;

    ## make sure required arguments were passed
    my @required = qw( rsem_output fasta output );
    for my $option (@required) {
        unless ( defined $$options{$option} ) {
            logdie("ERROR: --$option is a required option");
        }
    }

}
