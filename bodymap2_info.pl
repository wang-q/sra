#!/usr/bin/perl
use strict;
use warnings;
use autodie;

use Tie::IxHash;
use YAML qw(Dump Load DumpFile LoadFile);

use FindBin;
use lib "$FindBin::Bin/lib";
use MySRA;

# http://www.ebi.ac.uk/ena/data/view/ERP000546
# http://www.ncbi.nlm.nih.gov/Traces/study/?acc=ERP000546

my $file    = "bodymap2";
tie my %name_of, "Tie::IxHash";
%name_of = (
    ERS025081 => "kidney",
    ERS025082 => "heart",
    ERS025083 => "ovary",
    ERS025084 => "16_tissues_mixture_1",
    ERS025085 => "brain",
    ERS025086 => "lymph_node",
    ERS025087 => "16_tissues_mixture_2",
    ERS025088 => "breast",
    ERS025089 => "colon",
    ERS025090 => "thyroid",
    ERS025091 => "white_blood_cells",
    ERS025092 => "adrenal",
    ERS025093 => "16_tissues_mixture_3",
    ERS025094 => "testes",
    ERS025095 => "prostate",
    ERS025096 => "liver",
    ERS025097 => "skeletal_muscle",
    ERS025098 => "adipose",
    ERS025099 => "lung",
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
