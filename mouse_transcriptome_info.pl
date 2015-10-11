#!/usr/bin/perl
use strict;
use warnings;
use autodie;

use Tie::IxHash;
use YAML qw(Dump Load DumpFile LoadFile);

use FindBin;
use lib "$FindBin::Bin/lib";
use MySRA;

# http://www.ebi.ac.uk/ena/data/view/SRP012040


my $file    = "dmel_transcriptome";
tie my %name_of, "Tie::IxHash";
%name_of = (
    SRX135150 => 'Ovary',
    SRX135151 => 'MammaryGland',
    SRX135152 => 'Stomach',
    SRX135153 => 'SmIntestine',
    SRX135154 => 'Duodenum',
    SRX135155 => 'Adrenal',
    SRX135156 => 'LgIntestine',
    SRX135157 => 'GenitalFatPad',
    SRX135158 => 'SubcFatPad',
    SRX135159 => 'Thymus',
    SRX135160 => 'Testis',
    SRX135161 => 'Kidney',
    SRX135162 => 'Liver',
    SRX135163 => 'Lung',
    SRX135164 => 'Spleen',
    SRX135165 => 'Colon',
    SRX135166 => 'Heart',
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
