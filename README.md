# Processing NCBI sra/EBI ena data

## Projects

### medfood: medicine food homology. Rna-seq survey.

Download.

```bash
cd ~/Scripts/sra
perl medfood_info.pl

perl sra_prep.pl -i medfood.yml --md5

mkdir -p ~/data/rna-seq/medfood/sra
cd ~/data/rna-seq/medfood/sra
cp ~/Scripts/sra/medfood.ftp.txt .
aria2c -x 9 -s 3 -c -i medfood.ftp.txt

cd ~/data/rna-seq/medfood/sra
cp ~/Scripts/sra/medfood.md5.txt .
md5sum --check medfood.md5.txt
```

ENA didn't display DRX correctly, so manually downlaod files and add information for DRX026628 and DRX014826.

Use `prefetch` of sra toolkit to download DRR files.

```bash
prefetch DRR029569 DRR029570 DRR016460

cp ~/ncbi/public/sra/DRR*.sra ~/data/rna-seq/medfood/sra
```

* http://www.ncbi.nlm.nih.gov/sra/?term=DRX026628
* http://www.ncbi.nlm.nih.gov/sra/?term=DRX014826

```bash
cd ~/Scripts/sra

cp medfood.csv medfood_all.csv
echo Perilla_frutescens,DRX026628,ILLUMINA,PAIRED,199,DRR029569,4000000,808M >> medfood_all.csv
echo Perilla_frutescens,DRX026628,ILLUMINA,PAIRED,199,DRR029570,2135878,431.4M >> medfood_all.csv

# NCBI metainfo error
# http://trace.ncbi.nlm.nih.gov/Traces/study/?acc=DRX014826
echo Pueraria_lobata,DRX014826,ILLUMINA,SINGLE,,DRR016460,23802502,2.4G >> medfood_all.csv
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
