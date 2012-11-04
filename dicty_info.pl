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

# SRA012238
my $srp = "SRP002085";

my %name_of = (
    SRX017832 => "QS1",
    SRX017812 => "68",
    SRX018144 => "QS17",
    SRX018099 => "WS15",
    SRX018021 => "WS14",
    SRX018020 => "S224",
    SRX018019 => "QS9",
    SRX018018 => "QS80",
    SRX018017 => "QS74",
    SRX018016 => "QS73",
    SRX018015 => "QS69",
    SRX018012 => "QS4",
    SRX018011 => "QS37",
    SRX017848 => "QS36",
    SRX017847 => "QS23",
    SRX017846 => "QS18",
    SRX017845 => "QS11",
    SRX017814 => "AX4",
    SRX017813 => "70",
    SRX017442 => "TW5A",
    SRX017441 => "TW5A",
    SRX017440 => "MA12C1",
    SRX017439 => "MA12C1",
);

print "$srp\n";
my @srx = @{ $mysra->srp_worker($srp) };
print "@srx\n";

my $master = {};
for my $srx (@srx) {
    my $srx_info = $mysra->srx_worker($srx);
    if ( !defined $srx_info ) {
        warn "SRX worker error\n";
        next;
    }
    my $name = $name_of{$srx};
    $master->{$name}{$srx} = $srx_info;
}
print "\n";

DumpFile( "dicty.yml", $master );
