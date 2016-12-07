#!/usr/bin/perl
use strict;
use warnings;
use autodie;

use Getopt::Long::Descriptive;
use Path::Tiny;

#----------------------------------------------------------#
# GetOpt section
#----------------------------------------------------------#

my $description = <<'EOF';
Use RSEM relative abundance values to filter a transcript assembly FASTA file.

Modified from filter_fasta_by_rsem_values.pl in Trinity.

Usage: perl %c -r <RSEM.isoforms.results> -f <Trinity.fasta> -o <output.fasta> [options]
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
    [ 'rsem_output|r=s',   '', { required => 1, }, ],
    [ 'fasta|f=s',         '', { required => 1, }, ],
    [ 'output|o=s',        '', { required => 1, }, ],
    [ 'tpm_cutoff|t=s',    '', ],
    [ 'fpkm_cutoff|c=s',   '', ],
    [ 'isopct_cutoff|i=s', '', ],
    [ 'unigene|u',         '', ],
    [ 'log|l=s',           '', ],
    { show_defaults => 1, }
    );

$usage->die if $opt->{help};

#----------------------------------------------------------#
# Start
#----------------------------------------------------------#

## open the log if requested
my $log_fh;
if ( defined $opt->{log} ) {
    open $log_fh, ">", $opt->{log};
}
else {
    $log_fh = *STDOUT;
}

_log("INFO: Opening RSEM file ($opt->{rsem_output})");
my $rsem = load_rsem_output( $opt->{rsem_output} );

_log("INFO: creating output file: ($opt->{output})");
open my $out_fh, ">", $opt->{output};

_log("INFO: reading input FASTA file: ($opt->{fasta})");
my @lines = path( $opt->{fasta} )->lines;

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
if ( defined $opt->{fpkm_cutoff} ) {
    @trans_ids = grep { $rsem->{$_}{fpkm} >= $opt->{fpkm_cutoff} } @trans_ids;
    print "fpkm: @{[scalar @trans_ids]} \n";
}

if ( defined $opt->{tpm_cutoff} ) {
    @trans_ids = grep { $rsem->{$_}{tpm} >= $opt->{tpm_cutoff} } @trans_ids;
    print "tpm: @{[scalar @trans_ids]} \n";
}

if ( defined $opt->{isopct_cutoff} ) {
    @trans_ids = grep {
        my $gene_id          = $rsem->{iso_to_gene}{$_};
        my $num_iso_per_gene = $rsem->{iso_count_per_gene}{$gene_id};
        $num_iso_per_gene == 1
            or ( $rsem->{$_}{isopct} >= $opt->{isopct_cutoff}
            && $num_iso_per_gene > 1 );
    } @trans_ids;
    print "isopct: @{[scalar @trans_ids]} \n";
}

#----------------------------#
# keep 1 trans per gene
#----------------------------#
if ( $opt->{unigene} ) {
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
        my @order = sort { $iso_score{$b} <=> $iso_score{$a} } @{ $gene_to_iso{$gene_id} };
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
    print {$out_fh} $line if $keep;
}

close $out_fh;

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

    open my $in_fh, "<", $file;

    while ( my $line = <$in_fh> ) {
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
    close $in_fh;

    _log( "INFO: Loaded RSEM values for " . scalar( keys %rel ) . " transcripts" );

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

    print $log_fh "$msg\n" if $log_fh;
}

sub logdie {
    my $msg = shift;

    print STDERR "$msg\n";
    print $log_fh "$msg\n" if $log_fh;

    exit(1);
}
