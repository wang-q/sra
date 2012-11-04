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

# ERP000565 ERA023479
# sf-2 is missing, use downloaded bam file
my %ids   = (
    Bur_0  => "ERS025622",
    Can_0  => "ERS025623",
    Col_0  => "ERS025624",
    Ct_1   => "ERS025625",
    Edi_0  => "ERS025626",
    Hi_0   => "ERS025627",
    Kn_0   => "ERS025628",
    Ler_0  => "ERS025629",
    Mt_0   => "ERS025630",
    No_0   => "ERS025631",
    Oy_0   => "ERS025632",
    Po_0   => "ERS025633",
    Rsch_4 => "ERS025634",
    Sf_2   => "ERS025635",
    Tsu_0  => "ERS025636",
    Wil_2  => "ERS025637",
    Ws_0   => "ERS025638",
    Wu_0   => "ERS025639",
    Zu_0   => "ERS025640",
);

my $master = {};
for my $key ( sort keys %ids ) {
    print "$key\n";
    my @srx = @{ $mysra->srs_worker( $ids{$key} ) };
    print "@srx\n";

    my $sample = {};
    for (@srx) {
        $sample->{$_} = $mysra->srx_worker($_);
    }
    $master->{$key} = $sample;
    print "\n";
}

DumpFile( "ath19.yml", $master );
