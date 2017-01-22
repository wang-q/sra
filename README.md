[TOC levels=1-3]: #

# Table of Contents
- [Purpose](#purpose)
- [*De novo* rna-seq projects (`dn_rna.pl`)](#de-novo-rna-seq-projects-dn_rnapl)
    - [medfood: medicine food homology. Rna-seq survey.](#medfood-medicine-food-homology-rna-seq-survey)
        - [chickpea](#chickpea)
        - [Dioscorea villosa 长柔毛薯蓣](#dioscorea-villosa-长柔毛薯蓣)
- [De novo rna-seq projects starting from FASTQ (dn_rna_fq_*.pl)](#de-novo-rna-seq-projects-starting-from-fastq-dn_rna_fq_pl)
    - [Spartina alterniflora 互花米草](#spartina-alterniflora-互花米草)
    - [Cercis gigantea 巨紫荆](#cercis-gigantea-巨紫荆)
    - [Gleditsia sinensis 皂荚树](#gleditsia-sinensis-皂荚树)
    - [Sophora japonica 槐树](#sophora-japonica-槐树)
- [De novo dna-seq projects (dn_dna_*.pl)](#de-novo-dna-seq-projects-dn_dna_pl)
    - [Atha Ler-0](#atha-ler-0)
    - [Caenorhabditis elegans](#caenorhabditis-elegans)
    - [Setaria italica](#setaria-italica)
    - [Glycine max cultivar Williams 82](#glycine-max-cultivar-williams-82)
    - [Oropetium thomaeum](#oropetium-thomaeum)
    - [Quercus lobata 加州峡谷栎树](#quercus-lobata-加州峡谷栎树)
- [Reference based rna-seq projects (rb_rna_*.pl)](#reference-based-rna-seq-projects-rb_rna_pl)
    - [ath example](#ath-example)
    - [Human bodymap2](#human-bodymap2)
    - [Mouse transcriptome](#mouse-transcriptome)
    - [Dmel transcriptome](#dmel-transcriptome)
    - [Rat hypertension](#rat-hypertension)
- [Reference based dna-seq projects (rb_dna_*.pl)](#reference-based-dna-seq-projects-rb_dna_pl)
    - [cele_mmp: 40 wild strains from *C. elegans* million mutation project](#cele_mmp-40-wild-strains-from-c-elegans-million-mutation-project)
    - [dicty](#dicty)
    - [ath19](#ath19)
    - [dpgp](#dpgp)
    - [japonica24](#japonica24)
    - [dgrp](#dgrp)
    - [Glycine soja](#glycine-soja)
- [Unused projects](#unused-projects)


# Purpose

Processing NCBI sra/EBI ena data

# *De novo* rna-seq projects (`dn_rna.pl`)

## medfood: medicine food homology. Rna-seq survey.

Grab information.

```bash
mkdir -p ~/data/rna-seq/medfood/sra
cd ~/data/rna-seq/medfood/sra

cat << EOF > source.csv
SRX305204,Crataegus_pinnatifida,山楂
SRX800799,Portulaca_oleracea,马齿苋
ERX651070,Glycyrrhiza_glabra,光果甘草

SRX852542,Dolichos_lablab,扁豆
SRX479329,Dimocarpus_longan,龙眼

SRX365197,Cassia_obtusifolia,决明
SRX467333,Prunus_armeniaca,杏
SRX131618,Hippophae_rhamnoides,沙棘
SRX064894,Siraitia_grosvenorii,罗汉果
SRX096106,Lonicera_japonica,忍冬

SRX287501,Houttuynia_cordata,蕺菜
SRX392897,Zingiber_officinale,姜
SRX360220,Gardenia_jasminoides,栀子
SRX246913,Poria_cocos,茯苓
SRX320098,Morus_alba,桑

SRX977888,Citrus_reticulata,橘
SRX314622,Chrysanthemum_morifolium,菊
SRX255211,Cichorium_intybus,菊苣
SRX814013,Brassica_juncea,芥
DRX026628,Perilla_frutescens,紫苏

DRX014826,Pueraria_lobata,野葛
SRX890122,Piper_nigrum,胡椒
SRX533468,Mentha_arvensis,薄荷
SRX848973,Pogostemon_cablin,广藿香
SRX803910,Coriandrum_sativum,芫荽

SRX173215,Rose_rugosa,玫瑰
SRX096128,Prunella_vulgaris,夏枯草
SRX447081,Crocus_sativus,藏红花
SRX146981,Curcuma_Longa,姜黄

SRX761199,Malus_hupehensis,湖北海棠
SRX1023176,Osmanthus_fragrans_Semperflorens,四季桂
SRX1023177,Osmanthus_fragrans_Thunbergii,金桂
SRX1023178,Osmanthus_fragrans_Latifolius,银桂

SRX868796,Jasminum_sambac,茉莉
SRX858389,Fraxinus_pennsylvanica_Leaf,美国红梣
SRX858390,Fraxinus_pennsylvanica_Petiole,
SRX823915,Fraxinus_velutina,绒毛白蜡
SRX661505,Olea_europaea,油橄榄
SRX1821033,Glycine_max_1,大豆
SRX712834,Glycine_max_2,

SRX477950,Oryza_sativa_Japonica,粳稻
SRX1418190,Arabidopsis_thaliana,拟南芥

SRX912524,Arabidopsis_lyrata,深山南芥
SRX1037948,Brassica_oleracea,甘蓝
SRX1532416,Brassica_rapa,大白菜
ERX1320225,Hordeum_vulgare,大麦
SRX472726,Populus_trichocarpa,杨树
SRX173254,Prunus_persica,桃
SRX1182185,Solanum_lycopersicum,番茄
SRX1121732,Solanum_tuberosum,马铃薯
ERX1189411,Sorghum_bicolor,高粱
SRX150765,Triticum_aestivum,小麦
SRX1496848,Vitis_vinifera,葡萄
SRX155038,Zea_mays,玉米

SRX474947,Coelastrum_microporum,空星藻
SRX474946,Coelastrum_pulchrum,
SRX474949,Cosmarium_turpinii,鼓藻
SRX474948,Cosmarium_botrytis,
ERX337145,Cosmarium_ochthodes,
SRX474945,Closterium_acerosum,新月藻
SRX718727,Klebsormidium_flaccidum,克里藻
SRX691225,Klebsormidium_crenulatum,
ERX337139,Klebsormidium_subtile,
#NONE,Micrasterias,微星鼓藻属
SRX474960,Mougeotia_1,转板藻
ERX337143,Mougeotia_2,
SRX718258,Spirogyra_pratensis,水绵
ERX337144,Spirogyra_sp
SRX474976,Staurastrum_cingulum,角星鼓藻
SRX474977,Staurastrum_ophiura,
SRX474978,Staurastrum_punctulatum,
SRX474979,Staurastrum_tetracerum,
SRX474985,Zygnema_cylindricum,亚小双星藻
EOF

perl ~/Scripts/sra/sra_info.pl source.csv \
    > medfood.yml
```

Download.

```bash
cd ~/data/rna-seq/medfood/sra
perl ~/Scripts/sra/sra_prep.pl medfood.yml --md5

aria2c -x 9 -s 3 -c -i medfood.ftp.txt

md5sum --check medfood.md5.txt
```

Metainfo of Pueraria_lobata in NCBI is wrong.

```bash
cd ~/data/rna-seq/medfood/sra
cat medfood.csv \
    | grep -v "Pueraria_lobata" \
    > medfood_all.csv
echo Pueraria_lobata,DRX014826,ILLUMINA,SINGLE,,DRR016460,23802502,2.19G \
    >> medfood_all.csv
```

Generate bash files and run a sample.

```bash
perl ~/Scripts/sra/dn_rna.pl -b ~/data/rna-seq/medfood -c ~/data/rna-seq/medfood/sra/medfood_all.csv

#cd ~/data/rna-seq/medfood/sra
#bash bash/sra.Cichorium_intybus.sh

```

Open `~/data/rna-seq/medfood/screen.sh.txt` and paste bash lines to terminal.

When the size of `screen.sra_XXX-0.log` reach 6.5K, the process should be finished. The size of
`screen.tri_XXX-0.log` varies a lot, from 700K to 30M.

```bash
cd ~/data/rna-seq/medfood/log

# sra
screen -L -dmS sra_Cichorium_intybus bash /home/wangq/data/rna-seq/medfood/bash/sra.Cichorium_intybus.sh

# screen.sra_Hippophae_rhamnoides-0.log

# ...

# trinity
screen -L -dmS tri_Cichorium_intybus bash /home/wangq/data/rna-seq/medfood/bash/tri.Cichorium_intybus.sh

# ...
```

Failed.

```text
Sat May 28 03:40:27 CST 2016 Malus_hupehensis [trinity] failed
Tue Jun 14 10:36:46 CST 2016 Glycine_max_2 [trinity_rsem] failed
```

## chickpea

Grab information.

```bash
mkdir -p ~/data/rna-seq/chickpea/sra
cd ~/data/rna-seq/chickpea/sra

cat << EOF > source.csv
SRX402846,ShootCold,
SRX402839,RootControl,
SRX402841,RootSalinity,
SRX402842,RootCold,
SRX402843,ShootControl,
SRX402840,RootDesiccation,
SRX402844,ShootDesiccation,
SRX402845,ShootSalinity,
SRX402846,ShootCold,
EOF

perl ~/Scripts/sra/sra_info.pl source.csv \
    > chickpea_rnaseq.yml
```

Download.

```bash
cd ~/data/rna-seq/chickpea/sra
perl ~/Scripts/sra/sra_prep.pl chickpea_rnaseq.yml --md5

aria2c -x 9 -s 3 -c -i chickpea_rnaseq.ftp.txt

md5sum --check chickpea_rnaseq.md5.txt
```

## Dioscorea villosa 长柔毛薯蓣

SRP006697

Grab information.

```bash
mkdir -p ~/data/rna-seq/dioscorea_villosa/sra
cd ~/data/rna-seq/dioscorea_villosa/sra

cat << EOF > source.csv
SRX060310,mature_leaf,
SRX060311,stem,
SRX060329,root,
EOF

perl ~/Scripts/sra/sra_info.pl source.csv \
    > dioscorea_villosa.yml
```

Download.

```bash
cd ~/data/rna-seq/dioscorea_villosa/sra
perl ~/Scripts/sra/sra_prep.pl dioscorea_villosa.yml --md5

aria2c -x 9 -s 3 -c -i dioscorea_villosa.ftp.txt

md5sum --check dioscorea_villosa.md5.txt
```

# *De novo* rna-seq projects starting from FASTQ (dn_rna_fq_*.pl)

## Spartina alterniflora 互花米草

Create information.

```bash
mkdir -p ~/data/rna-seq/spartina/sra
cd ~/data/rna-seq/spartina/sra

cat << EOF > spartina.csv
name,srx,platform,layout,ilength,srr,spot,base
spartina,LAN1_SA1,Illumina,PAIRED,,LAN1_SA1,42426645,8.4G
EOF
```

Generate bash files and run.

```bash
perl ~/Scripts/sra/dn_rna.pl \
    --fq \
    -b ~/data/rna-seq/spartina \
    -c ~/data/rna-seq/spartina/sra/spartina.csv

cd ~/data/rna-seq/spartina
bash bash/sra.spartina.sh
bash bash/tri.spartina.sh
```

## Cercis gigantea 巨紫荆

Create information.

```bash
mkdir -p ~/data/rna-seq/cercis_gigantea/sra
cd ~/data/rna-seq/cercis_gigantea/sra

cat << EOF > cercis_gigantea.csv
name,srx,platform,layout,ilength,srr,spot,base
cercis_gigantea,LAN8_SA4,Illumina,PAIRED,,LAN8_SA4,42426645,6.9G
EOF
```

Generate bash files and run.

```bash
perl ~/Scripts/sra/dn_rna.pl \
    --fq \
    -b ~/data/rna-seq/cercis_gigantea \
    -c ~/data/rna-seq/cercis_gigantea/sra/cercis_gigantea.csv

cd ~/data/rna-seq/cercis_gigantea
bash bash/sra.cercis_gigantea.sh
bash bash/tri.cercis_gigantea.sh
```

## Gleditsia sinensis 皂荚树

Create information.

```bash
mkdir -p ~/data/rna-seq/gleditsia_sinensis/sra
cd ~/data/rna-seq/gleditsia_sinensis/sra

cat << EOF > gleditsia_sinensis.csv
name,srx,platform,layout,ilength,srr,spot,base
gleditsia_sinensis,ZJ,Illumina,PAIRED,,ZJ,37785244,7632619288
EOF
```

Generate bash files and run.

```bash
perl ~/Scripts/sra/dn_rna.pl \
    --fq \
    -b ~/data/rna-seq/gleditsia_sinensis \
    -c ~/data/rna-seq/gleditsia_sinensis/sra/gleditsia_sinensis.csv

cd ~/data/rna-seq/gleditsia_sinensis
bash bash/sra.gleditsia_sinensis.sh
bash bash/tri.gleditsia_sinensis.sh
```

## Sophora japonica 槐树

Create information.

```bash
mkdir -p ~/data/rna-seq/sophora_japonica/sra
cd ~/data/rna-seq/sophora_japonica/sra

cat << EOF > sophora_japonica.csv
name,srx,platform,layout,ilength,srr,spot,base
sophora_japonica,HS,Illumina,PAIRED,,HS,37785244,7.1G
EOF
```

Generate bash files and run.

```bash
perl ~/Scripts/sra/dn_rna.pl \
    --fq \
    -b ~/data/rna-seq/sophora_japonica \
    -c ~/data/rna-seq/sophora_japonica/sra/sophora_japonica.csv

cd ~/data/rna-seq/sophora_japonica
bash bash/sra.sophora_japonica.sh
bash bash/tri.sophora_japonica.sh
```

# *De novo* dna-seq projects (dn_dna_*.pl)

## Atha Ler-0

Grab information.

```bash
mkdir -p ~/data/dna-seq/atha_ler_0/sra
cd ~/data/dna-seq/atha_ler_0/sra

cat << EOF > source.csv
SRX1567556,Ler-0-1,Ler sequencing and assembly
SRX202247,Ler-0-2,Ler_XL_4
EOF

perl ~/Scripts/sra/sra_info.pl source.csv \
    > atha_ler_0.yml

```

Download.

```bash
cd ~/data/dna-seq/atha_ler_0/sra
perl ~/Scripts/sra/sra_prep.pl atha_ler_0.yml --md5

aria2c -x 9 -s 3 -c -i atha_ler_0.ftp.txt

md5sum --check atha_ler_0.md5.txt
```

Generate bash files and run.

```bash
perl ~/Scripts/sra/dn_dna.pl -b ~/data/dna-seq/atha_ler_0 -c ~/data/dna-seq/atha_ler_0/sra/atha_ler_0.csv

cd ~/data/dna-seq/atha_ler_0
bash bash/sra.Ler-0-1.sh
bash bash/sra.Ler-0-2.sh
```

## Caenorhabditis elegans

Grab information.

```bash
mkdir -p ~/data/dna-seq/cele_n2/sra
cd ~/data/dna-seq/cele_n2/sra

cat << EOF > source.csv
DRX007633,cele_n2,
EOF

perl ~/Scripts/sra/sra_info.pl source.csv -v \
    > sra_info.yml
```

Download.

```bash
cd ~/data/dna-seq/cele_n2/sra
perl ~/Scripts/sra/sra_prep.pl sra_info.yml --md5

aria2c -x 9 -s 3 -c -i sra_info.ftp.txt

md5sum --check sra_info.md5.txt
```

Generate bash files and run.

```bash
perl ~/Scripts/sra/dn_dna.pl -b ~/data/dna-seq/cele_n2 -c ~/data/dna-seq/cele_n2/sra/sra_info.csv

cd ~/data/dna-seq/cele_n2
bash bash/sra.cele_n2.sh

find . -type d -name "*fastqc" | sort | xargs rm -fr
find . -type f -name "*_fastqc.zip" | sort | xargs rm
find . -type f -name "*matches.txt" | sort | xargs rm
```

## Setaria italica

Grab information.

```bash
mkdir -p ~/data/dna-seq/setaria_italica/sra
cd ~/data/dna-seq/setaria_italica/sra

cat << EOF > source.csv
SRP011164,setaria_italica,小米
EOF

perl ~/Scripts/sra/sra_info.pl source.csv -v -s erp \
    > setaria_italica.yml
```

Download.

```bash
cd ~/data/dna-seq/setaria_italica/sra
perl ~/Scripts/sra/sra_prep.pl setaria_italica.yml --md5

#aria2c -x 9 -s 3 -c -i ath_example.ftp.txt

#md5sum --check ath_example.md5.txt
```

## Glycine max cultivar Williams 82

Grab information.

```bash
mkdir -p ~/data/dna-seq/glycine_max/sra
cd ~/data/dna-seq/glycine_max/sra

cat << EOF > source.csv
SRP062333,glycine_max,
EOF

perl ~/Scripts/sra/sra_info.pl source.csv -v -s erp \
    > glycine_max.yml

```

Download.

```bash
cd ~/data/dna-seq/glycine_max/sra
perl ~/Scripts/sra/sra_prep.pl glycine_max.yml --md5

aria2c -x 9 -s 3 -c -i glycine_max.ftp.txt

md5sum --check glycine_max.md5.txt
```

## Oropetium thomaeum

```bash
mkdir -p ~/data/dna-seq/oropetium_thomaeum/sra
cd ~/data/dna-seq/oropetium_thomaeum/sra

cat << EOF > source.csv
SRP059326,Oropetium_thomaeum,复活草
EOF

perl ~/Scripts/sra/sra_info.pl source.csv -v -s erp \
    > oropetium_thomaeum.yml

```

Download.

```bash
cd ~/data/dna-seq/oropetium_thomaeum/sra
perl ~/Scripts/sra/sra_prep.pl oropetium_thomaeum.yml --md5

aria2c -x 9 -s 3 -c -i oropetium_thomaeum.ftp.txt

md5sum --check oropetium_thomaeum.md5.txt
```

## Quercus lobata 加州峡谷栎树

```bash
mkdir -p ~/data/dna-seq/quercus_lobata/sra
cd ~/data/dna-seq/quercus_lobata/sra

cat << EOF > source.csv
SRP072046,Quercus_lobata,加州峡谷栎树
EOF

perl ~/Scripts/sra/sra_info.pl source.csv -v -s erp \
    > quercus_lobata.yml
```

Download.

```bash
cd ~/data/dna-seq/quercus_lobata/sra
perl ~/Scripts/sra/sra_prep.pl quercus_lobata.yml --md5

aria2c -x 9 -s 3 -c -i quercus_lobata.ftp.txt

md5sum --check quercus_lobata.md5.txt
```

# Reference based rna-seq projects (rb_rna_*.pl)

## ath example

http://www.ncbi.nlm.nih.gov/Traces/study/?acc=SRP003951

Grab information.

```bash
mkdir -p ~/data/rna-seq/ath_example/sra
cd ~/data/rna-seq/ath_example/sra

cat << EOF >  ath_example.source.csv 
SRS118358,WT,
SRS118359,hy5_215,
EOF

perl ~/Scripts/sra/sra_info.pl ath_example.source.csv  \
    > ath_example.yml

```

Download.

```bash
cd ~/data/rna-seq/ath_example/sra
perl ~/Scripts/sra/sra_prep.pl ath_example.yml --md5

aria2c -x 9 -s 3 -c -i ath_example.ftp.txt

md5sum --check ath_example.md5.txt
```

## Human bodymap2

* http://www.ebi.ac.uk/ena/data/view/ERP000546
* http://www.ncbi.nlm.nih.gov/Traces/study/?acc=ERP000546

Grab information.

```bash
mkdir -p ~/data/rna-seq/bodymap2/sra
cd ~/data/rna-seq/bodymap2/sra

cat << EOF > source.csv
ERS025081,kidney,
ERS025082,heart,
ERS025083,ovary,
ERS025085,brain,
ERS025086,lymph_node,
ERS025088,breast,
ERS025089,colon,
ERS025090,thyroid,
ERS025091,white_blood_cells,
ERS025092,adrenal,
ERS025094,testes,
ERS025095,prostate,
ERS025096,liver,
ERS025097,skeletal_muscle,
ERS025098,adipose,
ERS025099,lung,
ERS025084,16_tissues_mixture_1,
ERS025087,16_tissues_mixture_2,
ERS025093,16_tissues_mixture_3,
EOF

perl ~/Scripts/sra/sra_info.pl source.csv \
    > bodymap2.yml
```

Download.

```bash
cd ~/data/rna-seq/bodymap2/sra
perl ~/Scripts/sra/sra_prep.pl bodymap2.yml --md5

aria2c -x 9 -s 3 -c -i bodymap2.ftp.txt

md5sum --check bodymap2.md5.txt
```

## Mouse transcriptome

http://www.ebi.ac.uk/ena/data/view/SRP012040

Grab information.

```bash
mkdir -p ~/data/rna-seq/mouse_trans/sra
cd ~/data/rna-seq/mouse_trans/sra

cat << EOF > source.csv
SRX135150,Ovary,
SRX135151,MammaryGland,
SRX135152,Stomach,
SRX135153,SmIntestine,
SRX135154,Duodenum,
SRX135155,Adrenal,
SRX135156,LgIntestine,
SRX135157,GenitalFatPad,
SRX135158,SubcFatPad,
SRX135159,Thymus,
SRX135160,Testis,
SRX135161,Kidney,
SRX135162,Liver,
SRX135163,Lung,
SRX135164,Spleen,
SRX135165,Colon,
SRX135166,Heart,
EOF

perl ~/Scripts/sra/sra_info.pl source.csv -s erp \
    > mouse_transcriptome.yml
```

Download.

```bash
cd ~/data/rna-seq/mouse_trans/sra
perl ~/Scripts/sra/sra_prep.pl mouse_transcriptome.yml --md5

aria2c -x 9 -s 3 -c -i mouse_transcriptome.ftp.txt

md5sum --check mouse_transcriptome.md5.txt
```

## Dmel transcriptome

* http://intermine.modencode.org/query/experiment.do?experiment=Tissue-specific+Transcriptional+Profiling+of+D.+melanogaster+using+Illumina+poly%28A%29%2B+RNA-Seq
* http://www.ebi.ac.uk/ena/data/view/SRP003905

Grab information.

```bash
mkdir -p ~/data/rna-seq/dmel_trans/sra
cd ~/data/rna-seq/dmel_trans/sra

cat << EOF > source.csv
SRS118258,mated_female_eclosion_1d_heads,
SRS118259,mated_female_eclosion_20d_heads,
SRS118260,mated_female_eclosion_4d_heads,
SRS118261,mated_female_eclosion_4d_ovaries,
SRS118262,mated_male_eclosion_1d_heads,
SRS118263,mated_male_eclosion_20d_heads,
SRS118264,mated_male_eclosion_4d_accessory_glands,
SRS118265,mated_male_eclosion_4d_heads,
SRS118266,mated_male_eclosion_4d_testes,
SRS118267,mixed_males_females_eclosion_1d_carcass,
SRS118268,mixed_males_females_eclosion_1d_digestive_system,
SRS118269,mixed_males_females_eclosion_20d_carcass,
SRS118270,mixed_males_females_eclosion_20d_digestive_system,
SRS118271,mixed_males_females_eclosion_4d_carcass,
SRS118272,mixed_males_females_eclosion_4d_digestive_system,
SRS118273,virgin_female_eclosion_1d_heads,
SRS118274,virgin_female_eclosion_20d_heads,
SRS118275,virgin_female_eclosion_4d_heads,
SRS118276,virgin_female_eclosion_4d_ovaries,
SRS118277,third_instar_larvae_wandering_stage_carcass,
SRS118278,third_instar_larvae_wandering_stage_CNS,
SRS118279,third_instar_larvae_wandering_stage_digestive_system,
SRS118280,third_instar_larvae_wandering_stage_fat_body,
SRS118281,third_instar_larvae_wandering_stage_imaginal_discs,
SRS118282,third_instar_larvae_wandering_stage_salivary_glands,
SRS118283,WPP_2d_CNS,
SRS118284,WPP_2d_fat_body,
SRS118285,WPP_fat_body,
SRS118286,WPP_salivary_glands,
EOF

perl ~/Scripts/sra/sra_info.pl source.csv \
    > dmel_transcriptome.yml
```

Download.

```bash
cd ~/data/rna-seq/dmel_trans/sra
perl ~/Scripts/sra/sra_prep.pl dmel_transcriptome.yml --md5

aria2c -x 9 -s 3 -c -i dmel_transcriptome.ftp.txt

md5sum --check dmel_transcriptome.md5.txt
```

## Rat hypertension

Information.

```bash
cat <<EOF > ~/Scripts/sra/rat_hypertension.csv
name,srx,platform,layout,ilength,srr,spot,base
Control,Control_S4,Illumina,PAIRED,,Control_S4,,
QHDG,QHDG_S12,Illumina,PAIRED,,QHDG_S12,,
QLDG,QLDG_S13,Illumina,PAIRED,,QLDG_S13,,
EOF

```

Prepare reference genome.

```bash
mkdir -p ~/data/alignment/Ensembl/Rat
cd ~/data/alignment/Ensembl/Rat

#curl -O --socks5 127.0.0.1:1080 ftp://ftp.ensembl.org/pub/release-82/fasta/rattus_norvegicus/dna/Rattus_norvegicus.Rnor_6.0.dna_sm.toplevel.fa.gz
wget -N ftp://ftp.ensembl.org/pub/release-82/fasta/rattus_norvegicus/dna/Rattus_norvegicus.Rnor_6.0.dna_sm.toplevel.fa.gz

gzip -d -c Rattus_norvegicus.Rnor_6.0.dna_sm.toplevel.fa.gz > toplevel.fa
faops count toplevel.fa | perl -aln -e 'next if $F[0] eq 'total'; print $F[0] if $F[1] > 50000; print $F[0] if $F[1] > 5000  and $F[6]/$F[1] < 0.05' | uniq > listFile
faops some toplevel.fa listFile toplevel.filtered.fa
faops split-name toplevel.filtered.fa .
rm toplevel.fa toplevel.filtered.fa listFile

cat KL*.fa > Un.fa
cat AABR*.fa >> Un.fa
rm KL*.fa AABR*.fa

mkdir -p ~/data/rna-seq/rat_hypertension/ref
cd ~/data/rna-seq/rat_hypertension/ref

cat ~/data/alignment/Ensembl/Rat/{1,2,3,4,5,6,7,8,9,10}.fa > rat_82.fa
cat ~/data/alignment/Ensembl/Rat/{11,12,13,14,15,16,17,18,19,20}.fa >> rat_82.fa
cat ~/data/alignment/Ensembl/Rat/{X,Y,MT,Un}.fa >> rat_82.fa
faops size rat_82.fa > chr.sizes

samtools faidx rat_82.fa
bwa index -a bwtsw rat_82.fa
bowtie2-build rat_82.fa rat_82

java -jar ~/share/picard-tools-1.128/picard.jar \
    CreateSequenceDictionary \
    R=rat_82.fa O=rat_82.dict

wget -N ftp://ftp.ensembl.org/pub/release-82/gtf/rattus_norvegicus/Rattus_norvegicus.Rnor_6.0.82.gtf.gz
gzip -d -c Rattus_norvegicus.Rnor_6.0.82.gtf.gz > rat_82.gtf

perl -nl -e '/^(MT|KL|AABR)/ and print' rat_82.gtf > rat_82.mask.gtf

```

Generate bash files.

```bash
cd ~/data/rna-seq/rat_hypertension
perl ~/Scripts/sra/rat_hypertension_seq.pl

bash bash/sra.Control.sh

```

# Reference based dna-seq projects (rb_dna_*.pl)

## cele_mmp: 40 wild strains from *C. elegans* million mutation project

From http://genome.cshlp.org/content/23/10/1749.abstract ,
http://genome.cshlp.org/content/suppl/2013/08/20/gr.157651.113.DC2/Supplemental_Table_12.txt

Grab information.

```bash
mkdir -p ~/data/dna-seq/cele_mmp/sra
cd ~/data/dna-seq/cele_mmp/sra

cat << EOF > source.csv
SRX218993,AB1,
SRX218973,AB3,
SRX218981,CB4853,
SRX218994,CB4854,
SRX219150,CB4856,
SRX218999,ED3017,
SRX219003,ED3021,
SRX218982,ED3040,
SRX219000,ED3042,
SRX218983,ED3049,
SRX218984,ED3052,
SRX219004,ED3057,
SRX218977,ED3072,
SRX218988,GXW1,
SRX218989,JU1088,
SRX218974,JU1171,
SRX218990,JU1400,
SRX218979,JU1401,
SRX218975,JU1652,
SRX218971,JU258,
SRX218978,JU263,
SRX218991,JU300,
SRX218992,JU312,
SRX218969,JU322,
SRX219001,JU345,
SRX219005,JU360,
SRX219002,JU361,
SRX219153,JU394,
SRX218972,JU397,
SRX218980,JU533,
SRX218970,JU642,
SRX219006,JU775,
SRX218995,KR314,
SRX218996,LKC34,
SRX218997,MY1,
SRX218966,MY14,
SRX218967,MY16,
SRX218998,MY2,
SRX218968,MY6,
SRX219154,PX174,
EOF

perl ~/Scripts/sra/sra_info.pl source.csv \
    > cele_mmp.yml
```

Download.

```bash
cd ~/data/dna-seq/cele_mmp/sra
perl ~/Scripts/sra/sra_prep.pl -i cele_mmp.yml --md5

aria2c -x 9 -s 3 -c -i cele_mmp.ftp.txt

md5sum --check cele_mmp.md5.txt
```

Prepare reference genome.

`~/data/alignment/Ensembl/Cele` should contain
[C. elegans genome files](https://github.com/wang-q/withncbi/blob/master/pop/OPs-download.md#caenorhabditis-elegans)
from ensembl.

```bash
mkdir -p ~/data/dna-seq/cele_mmp/ref
cd ~/data/dna-seq/cele_mmp/ref

cat ~/data/alignment/Ensembl/Cele/{I,II,III,IV,V,X}.fa > genome.fa
faops size genome.fa > chr.sizes

samtools faidx genome.fa
bwa index -a bwtsw genome.fa

java -jar ~/share/picard-tools-1.128/picard.jar \
    CreateSequenceDictionary \
    R=genome.fa O=genome.dict
```

Generate bash files and run a sample.

```bash
perl ~/Scripts/sra/rb_dna.pl -b ~/data/dna-seq/cele_mmp -c ~/data/dna-seq/cele_mmp/sra/cele_mmp.csv

cd ~/data/dna-seq/cele_mmp
bash bash/sra.AB1.sh

```

Open `~/data/dna-seq/cele_mmp/screen.sh.txt` and paste bash lines to terminal.

## dicty

SRA012238, SRP002085

Grab information.

```bash
mkdir -p ~/data/dna-seq/dicty/sra
cd ~/data/dna-seq/dicty/sra

cat << EOF > source.csv
SRX017832,QS1,
SRX017812,68,
SRX018144,QS17,
SRX018099,WS15,
SRX018021,WS14,
SRX018020,S224,
SRX018019,QS9,
SRX018018,QS80,
SRX018017,QS74,
SRX018016,QS73,
SRX018015,QS69,
SRX018012,QS4,
SRX018011,QS37,
SRX017848,QS36,
SRX017847,QS23,
SRX017846,QS18,
SRX017845,QS11,
SRX017814,AX4,
SRX017813,70,
SRX017442,TW5A,
SRX017441,TW5A,
SRX017440,MA12C1,
SRX017439,MA12C1,
EOF

perl ~/Scripts/sra/sra_info.pl source.csv \
    > dicty.yml
```

Download.

```bash
cd ~/data/dna-seq/dicty/sra
perl ~/Scripts/sra/sra_prep.pl dicty.yml --md5

aria2c -x 9 -s 3 -c -i dicty.ftp.txt

md5sum --check dicty.md5.txt
```

## ath19

ERP000565 ERA023479

sf-2 is missing, although we can download the bam file from the 19genomes site.

Grab information.

```bash
mkdir -p ~/data/dna-seq/ath19/sra
cd ~/data/dna-seq/ath19/sra

cat << EOF > source.csv
ERS025622,Bur_0,
ERS025623,Can_0,
ERS025624,Col_0,
ERS025625,Ct_1,
ERS025626,Edi_0,
ERS025627,Hi_0,
ERS025628,Kn_0,
ERS025629,Ler_0,
ERS025630,Mt_0,
ERS025631,No_0,
ERS025632,Oy_0,
ERS025633,Po_0,
ERS025634,Rsch_4,
ERS025635,Sf_2,
ERS025636,Tsu_0,
ERS025637,Wil_2,
ERS025638,Ws_0,
ERS025639,Wu_0,
ERS025640,Zu_0,
EOF

perl ~/Scripts/sra/sra_info.pl source.csv \
    > ath19.yml
```

Download.

```bash
cd ~/data/dna-seq/ath19/sra
perl ~/Scripts/sra/sra_prep.pl ath19.yml --md5

aria2c -x 9 -s 3 -c -i ath19.ftp.txt

md5sum --check ath19.md5.txt
```

Prepare reference genome.

`~/data/alignment/Ensembl/Atha` should contain
[A. thaliana genome files](https://github.com/wang-q/withncbi/blob/master/pop/OPs-download.md#arabidopsis-19-genomes)
from ensembl.

```bash
mkdir -p ~/data/dna-seq/ath19/ref
cd ~/data/dna-seq/ath19/ref

cat ~/data/alignment/Ensembl/Atha/{1,2,3,4,5}.fa > genome.fa
faops size genome.fa > chr.sizes

samtools faidx genome.fa
bwa index -a bwtsw genome.fa

java -jar ~/share/picard-tools-1.128/picard.jar \
    CreateSequenceDictionary \
    R=genome.fa O=genome.dict
```

Generate bash files and run a sample.

```bash
perl ~/Scripts/sra/rb_dna.pl -b ~/data/dna-seq/ath19 -c ~/data/dna-seq/ath19/sra/ath19.csv

cd ~/data/dna-seq/ath19
bash bash/sra.Ler_0.sh
```

Open `~/data/dna-seq/ath19/screen.sh.txt` and paste bash lines to terminal.

```bash
cd /home/wangq/data/dna-seq/ath19/log
screen -L -dmS sra_Ler_0 bash /home/wangq/data/dna-seq/ath19/bash/sra.Ler_0.sh

# ...

cd /home/wangq/data/dna-seq/ath19/log
screen -L -dmS bwa_Ler_0 bash /home/wangq/data/dna-seq/ath19/bash/bwa.Ler_0.sh

# ...
```

## dpgp

Grab information.

```bash
mkdir -p ~/data/dna-seq/dpgp/sra
cd ~/data/dna-seq/dpgp/sra

cat << EOF > source.csv
SRX058145,CK1,
SRX058153,CO15N,
SRX058161,ED10N,
SRX058178,EZ5N,
SRX058186,FR217,
SRX058199,GA185,
SRX058205,GU10,
SRX058260,KN6,
SRX058267,KR39,
SRX058273,KT1,
SRX058378,NG3N,
SRX058281,RC1,
SRX058341,RG15,
SRX058291,SP254,
SRX058285,TZ8,
SRX058380,UG7,
SRX058383,UM526,
SRX058389,ZI268,
SRX058391,ZL130,
SRX058293,ZO12,
SRX058373,ZS37,
EOF

perl ~/Scripts/sra/sra_info.pl source.csv \
    > dpgp.yml
```

Download.

```bash
cd ~/data/dna-seq/dpgp/sra
perl ~/Scripts/sra/sra_prep.pl dpgp.yml --md5

aria2c -x 9 -s 3 -c -i dpgp.ftp.txt

md5sum --check dpgp.md5.txt
```

## japonica24

Grab information.

```bash
mkdir -p ~/data/dna-seq/japonica24/sra
cd ~/data/dna-seq/japonica24/sra

cat << EOF > source.csv
#TEJ
SRS086330,IRGC1107,
SRS086334,IRGC2540,
SRS086337,IRGC27630,
SRS086341,IRGC32399,
SRS086345,IRGC418,
SRS086354,IRGC55471,
SRS086360,IRGC8191,
# tagged as TRJ in Table.S1
SRS086343,IRGC38698,

#TRJ
SRS086329,IRGC11010,
SRS086333,IRGC17757,
SRS086342,IRGC328,
SRS086346,IRGC43325,
SRS086349,IRGC43675,
SRS086351,IRGC50448,
SRS086358,IRGC66756,
SRS086362,IRGC8244,
SRS086336,IRGC26872,

#ARO
SRS086331,IRGC12793,
SRS086344,IRGC38994,
SRS086365,IRGC9060,
SRS086366,IRGC9062,
SRS086371,RA4952,
SRS086340,IRGC31856,

# IRGC43397 is admixed
# So there are 23 japonica accessions
EOF

perl ~/Scripts/sra/sra_info.pl source.csv \
    > japonica24.yml
```

Download.

```bash
cd ~/data/dna-seq/japonica24/sra
perl ~/Scripts/sra/sra_prep.pl japonica24.yml --md5

aria2c -x 9 -s 3 -c -i japonica24.ftp.txt

md5sum --check japonica24.md5.txt
```

## dgrp

Grab information.

```bash
mkdir -p ~/data/dna-seq/dgrp/sra
cd ~/data/dna-seq/dgrp/sra

cat << EOF > dgrp.source.csv
strain DGRP-38,DGRP-38
strain DGRP-40,DGRP-40
strain DGRP-57,DGRP-57
strain DGRP-138,DGRP-138
strain DGRP-176,DGRP-176
strain DGRP-177,DGRP-177
strain DGRP-181,DGRP-181
strain DGRP-208,DGRP-208
strain DGRP-320,DGRP-320
strain DGRP-321,DGRP-321
strain DGRP-332,DGRP-332
strain DGRP-357,DGRP-357
strain DGRP-375,DGRP-375
strain DGRP-377,DGRP-377
strain DGRP-380,DGRP-380
strain DGRP-381,DGRP-381
strain DGRP-391,DGRP-391
strain DGRP-392,DGRP-392
strain DGRP-406,DGRP-406
strain DGRP-443,DGRP-443
strain DGRP-492,DGRP-492
strain DGRP-502,DGRP-502
strain DGRP-508,DGRP-508
strain DGRP-517,DGRP-517
strain DGRP-727,DGRP-727
strain DGRP-737,DGRP-737
strain DGRP-738,DGRP-738
strain DGRP-757,DGRP-757
strain DGRP-852,DGRP-852
strain DGRP-897,DGRP-897
EOF

perl ~/Scripts/sra/sra_info.pl dgrp.source.csv \
    -v --source srs \
    > dgrp.yml

```

Download.

```bash
cd ~/data/dna-seq/dgrp/sra
perl ~/Scripts/sra/sra_prep.pl dgrp.yml --md5

#aria2c -x 9 -s 3 -c -i dgrp.ftp.txt

#md5sum --check dgrp.md5.txt
```

## Glycine soja

Grab information.

```bash
mkdir -p ~/data/dna-seq/glycine_soja/sra
cd ~/data/dna-seq/glycine_soja/sra

cat << EOF > source.csv
SRP000993,glycine_soja,野生大豆
EOF

perl ~/Scripts/sra/sra_info.pl source.csv \
    > glycine_soja.yml
```

Download.

```bash
cd ~/data/dna-seq/glycine_soja/sra
perl ~/Scripts/sra/sra_prep.pl glycine_soja.yml --md5 -p illumina

#aria2c -x 9 -s 3 -c -i ath_example.ftp.txt

#md5sum --check ath_example.md5.txt
```

# Unused projects

* Glycine max Genome sequencing: SRP015830, PRJNA175477
* 10_000_diploid_yeast_genomes: ERP000547, PRJEB2446
* Arabidopsis thaliana recombinant tetrads and DH lines: ERP003793, PRJEB4500
* Resequencing of 50 rice individuals: SRP003189
* rice_omachi: DRX000450
* Botryococcus braunii Showa library: SRX127228
* Two monkeys
    * SRS117874 => cynomolgus_bgi
    * SRS300124 => cynomolgus_wugsc
    * SRS115022 => rhesus_bgi
    * SRS282749 => rhesus_un_nhpgc
* Single sperm: SRP013494
    * "SRX151616" => "De_Novo_Mutation_Cell_23",
    * "SRX151625" => "Genome_Instability_Cell_23",
    * "SRX151664" => "Genome_Instability_Cell_24",
    * "SRX151727" => "De_Novo_Mutation_Cell_24",
    * "SRX151626" => "Genome_Instability_Cell_27",
    * "SRX151728" => "De_Novo_Mutation_Cell_27",
    * "SRX151627" => "Genome_Instability_Cell_28",
    * "SRX151729" => "De_Novo_Mutation_Cell_28",
    * "SRX151909" => "Genome_Instability_Sperm_gDNA",
    * "SRX151628" => "Genome_Instability_Cell_41",
    * "SRX151629" => "Genome_Instability_Cell_42",
    * "SRX151630" => "Genome_Instability_Cell_45",
    * "SRX151631" => "Genome_Instability_Cell_48",
    * "SRX151911" => "Genome_Instability_Cell_49",
    * "SRX151875" => "Genome_Instability_Cell_58",
    * "SRX151916" => "Genome_Instability_Cell_59",
    * "SRX151883" => "Genome_Instability_Cell_60",
    * "SRX151876" => "Genome_Instability_Cell_61",
    * "SRX151884" => "Genome_Instability_Cell_62",
    * "SRX151885" => "Genome_Instability_Cell_63",
    * "SRX151877" => "Genome_Instability_Cell_64",
    * "SRX151878" => "Genome_Instability_Cell_65",
    * "SRX151879" => "Genome_Instability_Cell_66",
    * "SRX151880" => "Genome_Instability_Cell_67",
    * "SRX151881" => "Genome_Instability_Cell_68",
    * "SRX151882" => "Genome_Instability_Cell_69",
    * "SRX151886" => "Genome_Instability_Cell_70",
    * "SRX151887" => "Genome_Instability_Cell_71",
    * "SRX151902" => "Genome_Instability_Cell_72",
    * "SRX151903" => "Genome_Instability_Cell_73",
    * "SRX151904" => "Genome_Instability_Cell_74",
    * "SRX151918" => "Genome_Instability_Cell_75",
    * "SRX151919" => "Genome_Instability_Cell_76",
    * "SRX151920" => "Genome_Instability_Cell_77",
    * "SRX151923" => "Genome_Instability_Cell_78",
    * "SRX151924" => "Genome_Instability_Cell_79",
    * "SRX151846" => "De_Novo_Mutation_Cell_101",
    * "SRX151850" => "De_Novo_Mutation_Cell_113",
    * "SRX151852" => "De_Novo_Mutation_Cell_135",
    * "SRX151853" => "De_Novo_Mutation_Cell_136",
