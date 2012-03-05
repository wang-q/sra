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

my %ids = (
    CK1   => "SRX058145",
    CO15N => "SRX058153",
    ED10N => "SRX058161",
    EZ5N  => "SRX058178",
    FR217 => "SRX058186",
    GA185 => "SRX058199",
    GU10  => "SRX058205",
    KN6   => "SRX058260",
    KR39  => "SRX058267",
    KT1   => "SRX058273",
    NG3N  => "SRX058378",
    RC1   => "SRX058281",
    RG15  => "SRX058341",
    SP254 => "SRX058291",
    TZ8   => "SRX058285",
    UG7   => "SRX058380",
    UM526 => "SRX058383",
    ZI268 => "SRX058389",
    ZL130 => "SRX058391",
    ZO12  => "SRX058293",
    ZS37  => "SRX058373",
);

my $master = {};
for my $id ( keys %ids ) {
    print "$id\n";

    my $srx = $ids{$id};

    my $sample = {};
    $sample->{$srx} = $mysra->srx_worker($srx);
    $master->{$id}  = $sample;
    print "\n";
}

DumpFile( "dpgp.yml", $master );
