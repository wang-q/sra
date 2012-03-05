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

my $mysra = MySRA->new;

my @ids = (
    391, 517, 375, 321, 40,  852, 176, 57,  380, 208, 38,  138, 727, 443,
    757, 897, 738, 332, 181, 406, 177, 320, 737, 392, 357, 492, 377, 502,
    508, 381, 
);
@ids = uniq(@ids);

my $master = {};
for my $id (@ids) {
    my $name = "DGRP-$id";
    print "$name\n";
    my @srx = @{ $mysra->srs_worker($name) };
    print "@srx\n";

    my $sample = {};
    for (@srx) {
        $sample->{$_} = $mysra->srx_worker($_);
    }
    $master->{$name} = $sample;
    print "\n";
}

DumpFile( "dgrp.yml", $master );
