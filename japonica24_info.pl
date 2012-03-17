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

    #TEJ
    SRS086330 => "IRGC1107",
    SRS086334 => "IRGC2540",
    SRS086337 => "IRGC27630",
    SRS086341 => "IRGC32399",
    SRS086345 => "IRGC418",
    SRS086354 => "IRGC55471",
    SRS086360 => "IRGC8191",
    SRS086343 => "IRGC38698", # tagged as TRJ in Table.S1

    #TRJ
    SRS086329 => "IRGC11010",
    SRS086333 => "IRGC17757",
    SRS086342 => "IRGC328",
    SRS086346 => "IRGC43325",
    SRS086349 => "IRGC43675",
    SRS086351 => "IRGC50448",
    SRS086358 => "IRGC66756",
    SRS086362 => "IRGC8244",
    SRS086336 => "IRGC26872",

    #ARO
    SRS086331 => "IRGC12793",
    SRS086344 => "IRGC38994",
    SRS086365 => "IRGC9060",
    SRS086366 => "IRGC9062",
    SRS086371 => "RA4952",
    SRS086340 => "IRGC31856",
    
    # IRGC43397 is admixed
    # So there are 23 japonica accessions
);

my $master = {};
for my $srs ( keys %ids ) {

    my $name = $ids{$srs};
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

DumpFile( "japonica24.yml", $master );
