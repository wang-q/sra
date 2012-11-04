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

my @srx = qw{ DRX000450 };

my $master = {};
for my $srx (@srx) {
    my $srx_info = $mysra->srx_worker($srx);
    my $srr      = $srx_info->{srr}[0];
    my $sample   = { $srx => $srx_info };
    $master->{$srr} = $sample;
}
print "\n";

DumpFile( "rice_omachi.yml", $master );
