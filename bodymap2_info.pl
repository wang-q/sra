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

#my $mysra = MySRA->new;
my $mysra = MySRA->new(proxy => "http://127.0.0.1:8087");

# http://www.ebi.ac.uk/ena/data/view/ERP000546
# http://www.ebi.ac.uk/ena/data/warehouse/filereport?accession=ERP000546&result=read_run&fields=study_accession,secondary_study_accession,sample_accession,secondary_sample_accession,experiment_accession,run_accession,scientific_name,instrument_model,library_layout,run_file_md5

# http://www.ncbi.nlm.nih.gov/Traces/study/?acc=ERP000546

my $name_of = {
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
};

my $master = {};
for my $srs ( sort keys %{$name_of} ) {

    my $name = $name_of->{$srs};
    print "$srs\t$name\n";

    my @srx = @{ $mysra->srp_worker($srs) };
    print "@srx\n";
    
    my $sample = {};
    for (@srx) {
        $sample->{$_} = $mysra->srx_worker($_);
    }
    $master->{$name} = $sample;
    print "\n";
}

DumpFile( "bodymap2.yml", $master );