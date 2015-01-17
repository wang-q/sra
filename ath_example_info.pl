#!/usr/bin/perl
use strict;
use warnings;

use Getopt::Long;
use Pod::Usage;
use YAML qw(Dump Load DumpFile LoadFile);

use List::MoreUtils qw(uniq zip);

use FindBin;
use lib "$FindBin::Bin/lib";

use MySRA;

#my $mysra = MySRA->new;
my $mysra = MySRA->new(proxy => "http://127.0.0.1:8087");

# http://www.ncbi.nlm.nih.gov/Traces/study/?acc=SRP003951

my $name_of = {
    SRS118358 => "WT",
    SRS118359 => "hy5_215",
};

my $master = {};
for my $srs ( sort keys %{$name_of} ) {

    my $name = $name_of->{$srs};
    print "$srs\t$name\n";

    my @srx = @{ $mysra->srp_worker($srs) };
    print "@srx\n";
    
    my $sample = {};
    for (@srx) {
        $sample->{$_} = $mysra->srx_worker($_);
    }
    $master->{$name} = $sample;
    print "\n";
}

DumpFile( "ath_example.yml", $master );