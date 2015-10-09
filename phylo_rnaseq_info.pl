#!/usr/bin/perl
use strict;
use warnings;
use autodie;

use YAML qw(Dump Load DumpFile LoadFile);

use FindBin;
use lib "$FindBin::Bin/lib";
use MySRA;

my $file = "phylo_rnaseq";
my $name_of = {
    SRX423303 => "Arabidopsis_thaliana",
    SRX096984 => "Lactuca_sativa",
    SRX648126 => "Acorus_americanus",
    ERX168857 => "Oryza_sativa",
};

my $mysra = MySRA->new;

my $master = {};
for my $srs ( sort keys %{$name_of} ) {

    my $name = $name_of->{$srs};
    print "$srs\t$name\n";

    my @srx = @{ $mysra->srp_worker($srs) };
    print "@srx\n";
    
    my $sample = {};
    for (@srx) {
        $sample->{$_} = $mysra->erx_worker($_);
    }
    $master->{$name} = $sample;
    print "\n";
}

DumpFile( "$file.yml", $master );
