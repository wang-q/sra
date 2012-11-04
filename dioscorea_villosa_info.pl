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

my $srp = "SRP006697";

my $master = {};
{

    my $name = "dioscorea_villosa";
    print "$srp\t$name\n";

    my @srx = @{ $mysra->srp_worker($srp) };
    print "@srx\n";
    
    my $sample = {};
    for (@srx) {
        $sample->{$_} = $mysra->srx_worker($_);
    }
    $master->{$name} = $sample;
    print "\n";
}


DumpFile( "dioscorea_villosa.yml", $master );
