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

# http://intermine.modencode.org/query/experiment.do?experiment=Tissue-specific+Transcriptional+Profiling+of+D.+melanogaster+using+Illumina+poly%28A%29%2B+RNA-Seq
# http://www.ebi.ac.uk/ena/data/view/SRP003905
# http://www.ebi.ac.uk/ena/data/warehouse/filereport?accession=SRP003905&result=read_run&fields=study_accession,secondary_study_accession,sample_accession,secondary_sample_accession,experiment_accession,run_accession,scientific_name,instrument_model,library_layout,run_file_md5

my $name_of = {
    SRS118258 => "mated_female_eclosion_1d_heads",
    SRS118259 => "mated_female_eclosion_20d_heads",
    SRS118260 => "mated_female_eclosion_4d_heads",
    SRS118261 => "mated_female_eclosion_4d_ovaries",
    SRS118262 => "mated_male_eclosion_1d_heads",
    SRS118263 => "mated_male_eclosion_20d_heads",
    SRS118264 => "mated_male_eclosion_4d_accessory_glands",
    SRS118265 => "mated_male_eclosion_4d_heads",
    SRS118266 => "mated_male_eclosion_4d_testes",
    SRS118267 => "mixed_males_females_eclosion_1d_carcass",
    SRS118268 => "mixed_males_females_eclosion_1d_digestive_system",
    SRS118269 => "mixed_males_females_eclosion_20d_carcass",
    SRS118270 => "mixed_males_females_eclosion_20d_digestive_system",
    SRS118271 => "mixed_males_females_eclosion_4d_carcass",
    SRS118272 => "mixed_males_females_eclosion_4d_digestive_system",
    SRS118273 => "virgin_female_eclosion_1d_heads",
    SRS118274 => "virgin_female_eclosion_20d_heads",
    SRS118275 => "virgin_female_eclosion_4d_heads",
    SRS118276 => "virgin_female_eclosion_4d_ovaries",
    SRS118277 => "third_instar_larvae_wandering_stage_carcass",
    SRS118278 => "third_instar_larvae_wandering_stage_CNS",
    SRS118279 => "third_instar_larvae_wandering_stage_digestive_system",
    SRS118280 => "third_instar_larvae_wandering_stage_fat_body",
    SRS118281 => "third_instar_larvae_wandering_stage_imaginal_discs",
    SRS118282 => "third_instar_larvae_wandering_stage_salivary_glands",
    SRS118283 => "WPP_2d_CNS",
    SRS118284 => "WPP_2d_fat_body",
    SRS118285 => "WPP_fat_body",
    SRS118286 => "WPP_salivary_glands",
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

DumpFile( "dmel_transcriptome.yml", $master );
