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

my %name_of = (
    SRS117874 => "cynomolgus_bgi",
    SRS300124 => "cynomolgus_wugsc",
    SRS115022 => "rhesus_bgi",
    SRS282749 => "rhesus_un_nhpgc",
);

my $master = {};
for my $srs ( sort keys %name_of ) {

    my $name = $name_of{$srs};
    print "$srs\t$name\n";

    my @srx = @{ $mysra->srs_worker($srs) };
    print "@srx\n";

    my $sample = {};
    for (@srx) {
        $sample->{$_} = $mysra->srx_worker($_);
    }
    $master->{$name} = $sample;
    print "\n";
}

DumpFile( "monkey.yml", $master );
