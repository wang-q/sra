# Processing NCBI sra/EBI ena data

## Projects

### medfood: medicine food homology. Rna-seq survey.

Grab information.

```bash
cd ~/Scripts/sra

cat << EOF |
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

SRX477950,Oryza_sativa_Japonica,粳稻
SRX1418190,Arabidopsis_thaliana,拟南芥
EOF
    grep . \
    | grep -v "^#" \
    | YML_FILE="medfood.yml" perl -nla -F"," -I lib -MMySRA -MYAML::Syck -e '
        BEGIN {
            $mysra = MySRA->new;
            $master = {};
        }

        my ($key, $name) = ($F[0], $F[1]);
        print "$key\t$name";

        my @srx = @{ $mysra->srp_worker($key) };
        print "@srx";

        my $sample = {};
        for (@srx) {
            $sample->{$_} = $mysra->erx_worker($_);
        }
        $master->{$name} = $sample;
        print "";

        END {
            YAML::Syck::DumpFile( $ENV{YML_FILE}, $master );
        }
    '

```

Download.

```bash
cd ~/Scripts/sra

perl sra_prep.pl medfood.yml --md5

mkdir -p ~/data/rna-seq/medfood/sra
cd ~/data/rna-seq/medfood/sra
cp ~/Scripts/sra/medfood.ftp.txt .
aria2c -x 9 -s 3 -c -i medfood.ftp.txt

cd ~/data/rna-seq/medfood/sra
cp ~/Scripts/sra/medfood.md5.txt .
md5sum --check medfood.md5.txt
```

Metainfo of Pueraria_lobata in NCBI is wrong.

```bash
cd ~/Scripts/sra
cat medfood.csv \
    | grep -v "Pueraria_lobata" \
    > medfood_all.csv
echo Pueraria_lobata,DRX014826,ILLUMINA,SINGLE,,DRR016460,23802502,2.19G \
    >> medfood_all.csv
```

Generate bash files and run a sample.

```bash
cd ~/data/rna-seq/medfood
perl ~/Scripts/sra/medfood_seq.pl

bash bash/sra.Cichorium_intybus.sh

```

Open `~/data/rna-seq/medfood/screen.sh.txt` and paste bash lines to terminal.

When the size of `screen.sra_XXX-0.log` reach 6.5K, the process should be finished.
The size of `screen.tri_XXX-0.log` varies a lot, from 700K to 30M.

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

### cele82: 40 Wild strains from *C. elegans* million mutation project

Download.

```bash
cd ~/Scripts/sra
perl cele_mmp_info.pl

perl sra_prep.pl -i cele_mmp.yml --md5

mkdir -p ~/data/dna-seq/cele_mmp/sra
cd ~/data/dna-seq/cele_mmp/sra
cp ~/Scripts/sra/cele_mmp.ftp.txt .
aria2c -x 9 -s 3 -c -i cele_mmp.ftp.txt

cd ~/data/dna-seq/cele_mmp/sra
cp ~/Scripts/sra/cele_mmp.md5.txt .
md5sum --check cele_mmp.md5.txt

# rsync -avP wangq@45.79.80.100:data/dna-seq/ ~/data/dna-seq
```

Prepare reference genome.

`~/data/alignment/Ensembl/Cele` should contain [C. elegans genome files](https://github.com/wang-q/withncbi/blob/master/pop/OPs-download.md#caenorhabditis-elegans) from ensembl.

```bash
mkdir -p ~/data/dna-seq/cele_mmp/ref
cd ~/data/dna-seq/cele_mmp/ref

cat ~/data/alignment/Ensembl/Cele/{I,II,III,IV,V,X}.fa > Cele_82.fa
faops size Cele_82.fa > chr.sizes

samtools faidx Cele_82.fa
bwa index -a bwtsw Cele_82.fa

java -jar ~/share/picard-tools-1.128/picard.jar \
    CreateSequenceDictionary \
    R=Cele_82.fa O=Cele_82.dict
```

Generate bash files and run a sample.

```bash
cd ~/data/dna-seq/cele_mmp
perl ~/Scripts/sra/cele_mmp_seq.pl

bash bash/sra.AB1.sh

```

Open `~/data/dna-seq/cele_mmp/screen.sh.txt` and paste bash lines to terminal.

### Rat hypertension

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
