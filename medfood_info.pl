#!/usr/bin/perl
use strict;
use warnings;
use autodie;

use Tie::IxHash;
use YAML::Syck;

use FindBin;
use lib "$FindBin::Bin/lib";
use MySRA;

my $file = "medfood";
tie my %name_of, "Tie::IxHash";
%name_of = (
    SRX305204 => "Crataegus_pinnatifida",    # 山楂
    SRX800799 => "Portulaca_oleracea",       # 马齿苋
    ERX651070 => "Glycyrrhiza_glabra",       # 光果甘草
    SRX852542 => "Dolichos_lablab",          # 扁豆
    SRX479329 => "Dimocarpus_longan",        # 龙眼

    SRX365197 => "Cassia_obtusifolia",       # 决明
    SRX467333 => "Prunus_armeniaca",         # 杏
    SRX131618 => "Hippophae_rhamnoides",     # 沙棘
    SRX064894 => "Siraitia_grosvenorii",     # 罗汉果
    SRX096106 => "Lonicera_japonica",        # 忍冬

    SRX287501 => "Houttuynia_cordata",       # 蕺菜
    SRX392897 => "Zingiber_officinale",      # 姜
    SRX360220 => "Gardenia_jasminoides",     # 栀子
    SRX246913 => "Poria_cocos",              # 茯苓
    SRX320098 => "Morus_alba",               # 桑

    SRX977888 => "Citrus_reticulata",        # 橘
    SRX314622 => "Chrysanthemum_morifolium", # 菊
    SRX255211 => "Cichorium_intybus",        # 菊苣
    SRX814013 => "Brassica_juncea",          # 芥
    DRX026628 => "Perilla_frutescens",       # 紫苏

    DRX014826 => "Pueraria_lobata",          # 野葛
    SRX890122 => "Piper_nigrum",             # 胡椒
    SRX533468 => "Mentha_arvensis",          # 薄荷
    SRX848973 => "Pogostemon_cablin",        # 广藿香
    SRX803910 => "Coriandrum_sativum",       # 芫荽

    SRX173215 => "Rose_rugosa",              # 玫瑰
    SRX096128 => "Prunella_vulgaris",        # 夏枯草
    SRX447081 => "Crocus_sativus",           # 藏红花
    SRX146981 => "Curcuma_Longa",            # 姜黄

    SRX761199 => "Malus_hupehensis",         # 湖北海棠

    SRX477950  => "Oryza_sativa_Japonica",
    SRX1418190 => "Arabidopsis_thaliana",
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

YAML::Syck::DumpFile( "$file.yml", $master );
