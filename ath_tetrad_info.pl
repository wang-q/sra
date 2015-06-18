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

my $name= "ERP003793";
my $file = "ath_tetrad";

my $mysra = MySRA->new;


print "$name\n";
my @srx = @{ $mysra->srp_worker($name) };
print "@srx\n";

my $master = {};
for my $srx (@srx) {
    my $srx_info = $mysra->srx_worker($srx);
    my $srr      = $srx_info->{srr}[0];
    my $sample   = { $srx => $srx_info };
    $master->{$srr} = $sample;
}
print "\n";

DumpFile( "$file.yml", $master );
