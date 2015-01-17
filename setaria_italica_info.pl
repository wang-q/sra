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

my $srp = "SRP011164";

my $master = {};
{

    my $name = "setaria_italica";
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


DumpFile( "setaria_italica.yml", $master );
