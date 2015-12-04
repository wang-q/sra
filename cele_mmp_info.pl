#!/usr/bin/perl
use strict;
use warnings;
use autodie;

use Tie::IxHash;
use YAML qw(Dump Load DumpFile LoadFile);

use FindBin;
use lib "$FindBin::Bin/lib";
use MySRA;

# From http://genome.cshlp.org/content/23/10/1749.abstract
my $file = "cele_mmp";

# 40 Wild strains from C. elegans million mutation project
# http://genome.cshlp.org/content/suppl/2013/08/20/gr.157651.113.DC2/Supplemental_Table_12.txt
tie my %name_of, "Tie::IxHash";
%name_of = (
    SRX218993 => "AB1",
    SRX218973 => "AB3",
    SRX218981 => "CB4853",
    SRX218994 => "CB4854",
    SRX219150 => "CB4856",
    SRX218999 => "ED3017",
    SRX219003 => "ED3021",
    SRX218982 => "ED3040",
    SRX219000 => "ED3042",
    SRX218983 => "ED3049",
    SRX218984 => "ED3052",
    SRX219004 => "ED3057",
    SRX218977 => "ED3072",
    SRX218988 => "GXW1",
    SRX218989 => "JU1088",
    SRX218974 => "JU1171",
    SRX218990 => "JU1400",
    SRX218979 => "JU1401",
    SRX218975 => "JU1652",
    SRX218971 => "JU258",
    SRX218978 => "JU263",
    SRX218991 => "JU300",
    SRX218992 => "JU312",
    SRX218969 => "JU322",
    SRX219001 => "JU345",
    SRX219005 => "JU360",
    SRX219002 => "JU361",
    SRX219153 => "JU394",
    SRX218972 => "JU397",
    SRX218980 => "JU533",
    SRX218970 => "JU642",
    SRX219006 => "JU775",
    SRX218995 => "KR314",
    SRX218996 => "LKC34",
    SRX218997 => "MY1",
    SRX218966 => "MY14",
    SRX218967 => "MY16",
    SRX218998 => "MY2",
    SRX218968 => "MY6",
    SRX219154 => "PX174",
);

my $mysra = MySRA->new;

my $master = {};
for my $key ( keys %name_of ) {

    my $name = $name_of{$key};
    print "$key\t$name\n";

    my @srx = @{ $mysra->srp_worker($key) };
    print "@srx\n";

    my $sample = {};
    for (@srx) {
        $sample->{$_} = $mysra->erx_worker($_);
    }
    $master->{$name} = $sample;
    print "\n";
}

DumpFile( "$file.yml", $master );
