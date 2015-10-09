#!/usr/bin/perl
use strict;
use warnings;
use autodie;

use YAML qw(Dump Load DumpFile LoadFile);

use FindBin;
use lib "$FindBin::Bin/lib";
use MySRA;

my $file = "ath_tetrad";
my $name = "ERP003793";

my $mysra = MySRA->new;

print "$name\n";
my @srx = @{ $mysra->erp_worker($name) };
print "@srx\n";

my $master = {};
for my $srx (@srx) {
    my $srx_info = $mysra->erx_worker($srx);
    
    # In this project, each srx only contain one srr. So for convenient, use srr as sample name.
    my $sample_name      = $srx_info->{srr}[0];
    my $sample   = { $srx => $srx_info };
    $master->{$name} = $sample;
}
print "\n";

DumpFile( "$file.yml", $master );
