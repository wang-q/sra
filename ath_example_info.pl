#!/usr/bin/perl
use strict;
use warnings;
use autodie;

use YAML qw(Dump Load DumpFile LoadFile);

use FindBin;
use lib "$FindBin::Bin/lib";
use MySRA;

my $file = "ath_example";

# http://www.ncbi.nlm.nih.gov/Traces/study/?acc=SRP003951
my $name_of = {
    SRS118358 => "WT",
    SRS118359 => "hy5_215",
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
