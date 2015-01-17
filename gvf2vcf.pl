#!/usr/bin/perl
use strict;
use warnings;
use autodie;

use YAML qw(Dump Load DumpFile LoadFile);

use AlignDB::Util qw(:all);

my $gvf_file    = shift or die "Provide a gvf file\n";


#print standard VCF header
print "##fileformat=VCFv4.0\n";
print
    "##INFO=<ID=Database,Number=1,Type=String,Description=\"Database identifier\">\n";
print
    "##INFO=<ID=dbID,Number=1,Type=String,Description=\"Database identifier\">\n";
print "#CHROM\tPOS\tID\tREF\tALT\tQUAL\tFILTER\tINFO\n";

open my $gvf_fh, "<", $gvf_file;
while ( my $line = <$gvf_fh> ) {
    chomp $line;
    next if $line =~ /##/;   # skip comment fields
    die
        "ERROR: Incomplete/Wrong Format? GVF file missing Variant and/or Reference nucleotide details!"
        if ( $line !~ /Variant_seq/ || $line !~ /Reference_seq/ );

    my @data         = split /\t/, $line;
    my $contig       = $data[0];
    my $source       = $data[1];
    my $variant_type = $data[2];
    if ( $variant_type eq "sequence_alteration" ) { next; }
    my $start          = $data[3];
    my $end            = $data[4];
    my $score          = $data[5];
    my $strand         = $data[6];
    my $phase          = $data[7];
    my $attributes     = $data[8];
    
    $contig = "chr" . $contig;

    my ($variant_seq)   = $attributes =~ /Variant_seq=([ACGTRYSWKMBDHVN-]+)/;
    my ($reference_seq) = $attributes =~ /Reference_seq=([ACGTRYSWKMBDHVN-]+)/;
    my ($ID)            = $attributes =~ /Dbxref=(\S+);/;

    my $Quality = ".";
    my $Filter  = ".";

    if ( $reference_seq eq $variant_seq ) {
        print STDERR
            "Warning! variant not supported for output in VCF v4.0, skipped: $_\n";
        next;
    }

    if ( $reference_seq =~ /[RYSWKMBDHV]/ ) {
        $reference_seq =~ s/[RYSWKMBDHV]/N/g;
    }
    if ( $variant_seq =~ /[RYSWKMBDHV]/ ) {
        $variant_seq =~ s/[RYSWKMBDHV]/N/g;
    }

    my ( $dbName, $dbID ) = $ID =~ /(\S+):(\S+)/;
    print "$contig\t$start\t$dbID\t$reference_seq\t$variant_seq\t$Quality\t$Filter\tDatabase=$dbName;dbID=$dbID\n";

}
close $gvf_fh;
