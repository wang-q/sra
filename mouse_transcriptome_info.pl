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
my $mysra = MySRA->new( proxy => "http://127.0.0.1:8087" );

# http://www.ebi.ac.uk/ena/data/view/SRP012040
# http://www.ebi.ac.uk/ena/data/warehouse/filereport?accession=SRP012040&result=read_run&fields=study_accession,secondary_study_accession,sample_accession,secondary_sample_accession,experiment_accession,run_accession,scientific_name,instrument_model,library_layout,run_file_md5

my $name_of = {
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
};

my $master = {};
for my $item ( sort keys %{$name_of} ) {

    my $name = $name_of->{$item};
    print "$item\t$name\n";

    my @srx = @{ $mysra->srp_worker($item) };
    print "@srx\n";

    my $sample = {};
    for (@srx) {
        $sample->{$_} = $mysra->srx_worker($_);
    }
    $master->{$name} = $sample;
    print "\n";
}

DumpFile( "mouse_transcriptome.yml", $master );
