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

my $name_of = {
    SRX402846 => "ShootCold",
    SRX402839 => "RootControl",
    SRX402841 => "RootSalinity",
    SRX402842 => "RootCold",
    SRX402843 => "ShootControl",
    SRX402840 => "RootDesiccation",
    SRX402844 => "ShootDesiccation",
    SRX402845 => "ShootSalinity",
    SRX402846 => "ShootCold",
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

DumpFile( "chickpea_rnaseq.yml", $master );
