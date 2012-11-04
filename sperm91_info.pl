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

my $srp = "SRP013494";

print "SRP: $srp\n";
my @srx = @{ $mysra->srp_worker($srp) };
print "@srx\n";

my %ids = (
    "SRX151616" => "De_Novo_Mutation_Cell_23",
    "SRX151625" => "Genome_Instability_Cell_23",
    "SRX151664" => "Genome_Instability_Cell_24",
    "SRX151727" => "De_Novo_Mutation_Cell_24",
    "SRX151626" => "Genome_Instability_Cell_27",
    "SRX151728" => "De_Novo_Mutation_Cell_27",
    "SRX151627" => "Genome_Instability_Cell_28",
    "SRX151729" => "De_Novo_Mutation_Cell_28",
    "SRX151909" => "Genome_Instability_Sperm_gDNA",
    "SRX151628" => "Genome_Instability_Cell_41",
    "SRX151629" => "Genome_Instability_Cell_42",
    "SRX151630" => "Genome_Instability_Cell_45",
    "SRX151631" => "Genome_Instability_Cell_48",
    "SRX151911" => "Genome_Instability_Cell_49",
    "SRX151875" => "Genome_Instability_Cell_58",
    "SRX151916" => "Genome_Instability_Cell_59",
    "SRX151883" => "Genome_Instability_Cell_60",
    "SRX151876" => "Genome_Instability_Cell_61",
    "SRX151884" => "Genome_Instability_Cell_62",
    "SRX151885" => "Genome_Instability_Cell_63",
    "SRX151877" => "Genome_Instability_Cell_64",
    "SRX151878" => "Genome_Instability_Cell_65",
    "SRX151879" => "Genome_Instability_Cell_66",
    "SRX151880" => "Genome_Instability_Cell_67",
    "SRX151881" => "Genome_Instability_Cell_68",
    "SRX151882" => "Genome_Instability_Cell_69",
    "SRX151886" => "Genome_Instability_Cell_70",
    "SRX151887" => "Genome_Instability_Cell_71",
    "SRX151902" => "Genome_Instability_Cell_72",
    "SRX151903" => "Genome_Instability_Cell_73",
    "SRX151904" => "Genome_Instability_Cell_74",
    "SRX151918" => "Genome_Instability_Cell_75",
    "SRX151919" => "Genome_Instability_Cell_76",
    "SRX151920" => "Genome_Instability_Cell_77",
    "SRX151923" => "Genome_Instability_Cell_78",
    "SRX151924" => "Genome_Instability_Cell_79",
    "SRX151846" => "De_Novo_Mutation_Cell_101",
    "SRX151850" => "De_Novo_Mutation_Cell_113",
    "SRX151852" => "De_Novo_Mutation_Cell_135",
    "SRX151853" => "De_Novo_Mutation_Cell_136",
);

my $master = {};
for my $srx (@srx) {
    my $srx_info = $mysra->srx_worker($srx);
    my $name     = $ids{$srx} ? $ids{$srx} : $srx;
    my $sample   = { $srx => $srx_info };
    $master->{$name} = $sample;
}
print "\n";

DumpFile( "sperm91.yml", $master );
