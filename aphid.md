# *De novo* assemblies of aphids

[TOC levels=1-3]: # " "
- [*De novo* assemblies of aphids](#de-novo-assemblies-of-aphids)
- [RefSeq organelles](#refseq-organelles)
- [*Acyrthosiphon pisum* (pea aphid)](#acyrthosiphon-pisum-pea-aphid)
- [Lusignan](#lusignan)
    - [Lusignan: download](#lusignan-download)
    - [Lusignan: template](#lusignan-template)
    - [Lusignan: run](#lusignan-run)
    - [Lusignan: diamond](#lusignan-diamond)


# RefSeq organelles

20180517

```bash
mkdir -p ~/data/dna-seq/aphid/organelles
cd ~/data/dna-seq/aphid/organelles

wget -N ftp://ftp.ncbi.nlm.nih.gov/genomes/refseq/mitochondrion/mitochondrion.1.protein.faa.gz
wget -N ftp://ftp.ncbi.nlm.nih.gov/genomes/refseq/mitochondrion/mitochondrion.2.protein.faa.gz

wget -N ftp://ftp.ncbi.nlm.nih.gov/genomes/refseq/plastid/plastid.1.protein.faa.gz
wget -N ftp://ftp.ncbi.nlm.nih.gov/genomes/refseq/plastid/plastid.2.protein.faa.gz

gzip -c -d *.protein.faa.gz > organelles.protein.fa

diamond makedb --in organelles.protein.fa --db organelles.protein --threads 24

```


# *Acyrthosiphon pisum* (pea aphid)

* Genome: GCF_000142985.2, 541.692 Mb
* Mitochondrion: NC_011594.1, 16971 bp

* Reference genome

```bash
mkdir -p ~/data/dna-seq/aphid/data
cd ~/data/dna-seq/aphid/data

aria2c -x 9 -s 3 -c ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/142/985/GCF_000142985.2_Acyr_2.0/GCF_000142985.2_Acyr_2.0_genomic.fna.gz

```

* Grab SRP information
    * https://www.ncbi.nlm.nih.gov/bioproject/PRJNA454786
        * 6 SRX
        * poolseq of 20 or 14 individuals
        * collected on Medicago sativa
    * https://www.ncbi.nlm.nih.gov/bioproject/PRJNA385905

```bash
mkdir -p ~/data/dna-seq/aphid/sra
cd ~/data/dna-seq/aphid/sra

cat << EOF > source.csv
SRP144419,aphid_medicago,
SRP106773,aphid_others,
EOF

perl ~/Scripts/sra/sra_info.pl source.csv -v -s erp --fq \
    > sra_info.yml

# check before running these
perl ~/Scripts/sra/sra_prep.pl sra_info.yml

```

* SRP144419/PRJNA454786

| Location      | SRX        | SRR        | Bases (Gb) |
|:--------------|:-----------|:-----------|:-----------|
| Switzerland   | SRX4028530 | SRR7100182 | 28.1       |
| Ranspach      | SRX4028529 | SRR7100183 | 28         |
| Mirecourt     | SRX4028528 | SRR7100184 | 27         |
| Castelnaudary | SRX4028527 | SRR7100185 | 26.6       |
| Gers          | SRX4028526 | SRR7100186 | 23.8       |
| Lusignan      | SRX4028525 | SRR7100187 | 25.5       |

* SRP106773/PRJNA385905

| Host                  | 中文名    | Individuals | SRX        | SRR        | Bases (Gb) |
|:----------------------|:---------|:------------|:-----------|:-----------|:-----------|
| Vicia cracca          | 广布野豌豆 | 29          | SRX4038418 | SRR7110604 | 36.9       |
| Onobrychis viciifolia | 驴食草    | 37          | SRX4038417 | SRR7110605 | 41.4       |
| Securigea varia       |          | 26          | SRX4038416 | SRR7110606 | 39         |
| Ononis spinosa        | 芒柄花属   | 27          | SRX4038415 | SRR7110607 | 43.3       |
| Medicago lupulina     | 天蓝苜蓿   | 27          | SRX4038414 | SRR7110608 | 41.8       |
| Medicago officinalis  |          | 34          | SRX4038413 | SRR7110609 | 38.5       |
| Lotus corniculatus    | 百脉根    | 30          | SRX4038412 | SRR7110610 | 45.2       |
| Genista tinctoria     | 染料木    | 30          | SRX4038411 | SRR7110611 | 42.7       |
| Genista sagitallis    |          | 34          | SRX4038410 | SRR7110612 | 47.4       |


* Illumina

```bash
mkdir -p ~/data/dna-seq/aphid/data
cd ~/data/dna-seq/aphid/data

cat << EOF > sra_ftp.txt
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR710/007/SRR7100187/SRR7100187_1.fastq.gz
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR710/007/SRR7100187/SRR7100187_2.fastq.gz
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR710/006/SRR7100186/SRR7100186_1.fastq.gz
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR710/006/SRR7100186/SRR7100186_2.fastq.gz
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR710/005/SRR7100185/SRR7100185_1.fastq.gz
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR710/005/SRR7100185/SRR7100185_2.fastq.gz
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR710/004/SRR7100184/SRR7100184_1.fastq.gz
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR710/004/SRR7100184/SRR7100184_2.fastq.gz
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR710/003/SRR7100183/SRR7100183_1.fastq.gz
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR710/003/SRR7100183/SRR7100183_2.fastq.gz
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR710/002/SRR7100182/SRR7100182_1.fastq.gz
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR710/002/SRR7100182/SRR7100182_2.fastq.gz
EOF

aria2c -x 9 -s 3 -c -i sra_ftp.txt

cat << EOF > sra_md5.txt
d3901a8112fda02f7fb6898e1f5be236 SRR7100187_1.fastq.gz
baaf5b3dec3396e0eeb6c8fbc301e1e5 SRR7100187_2.fastq.gz
8d623e590402eb542d9c52b373661d2a SRR7100186_1.fastq.gz
834f5d34038993dedfce47d186aa4639 SRR7100186_2.fastq.gz
ea8898a381e5940c8375cfe888631713 SRR7100185_1.fastq.gz
102312244dbf29049a4157e1c359b0c7 SRR7100185_2.fastq.gz
09383f6a975427b3d5525bd3a77577bd SRR7100184_1.fastq.gz
5f2da219c010f249af56eb7b4edb0028 SRR7100184_2.fastq.gz
f9ac2f070944b0c41ecd3e68cbc811e7 SRR7100183_1.fastq.gz
179340ecab8ed41e08e34b1a61eda8e9 SRR7100183_2.fastq.gz
023762eb0484aa950e7870e556c69844 SRR7100182_1.fastq.gz
6fc1b743b0fdb90bd0f68e752af6929d SRR7100182_2.fastq.gz
EOF

md5sum --check sra_md5.txt

```


* Rsync to hpcc

```bash
rsync -avP \
    ~/data/dna-seq/aphid/ \
    wangq@202.119.37.251:data/dna-seq/aphid

# rsync -avP wangq@202.119.37.251:data/dna-seq/aphid/ ~/data/dna-seq/aphid

```


# Lusignan

## Lusignan: download

```bash
mkdir -p ~/data/dna-seq/aphid/Lusignan/2_illumina
cd ~/data/dna-seq/aphid/Lusignan/2_illumina

ln -fs ../../data/SRR7100187_1.fastq.gz R1.fq.gz
ln -fs ../../data/SRR7100187_2.fastq.gz R2.fq.gz

```


## Lusignan: template


```bash
WORKING_DIR=${HOME}/data/dna-seq/aphid
BASE_NAME=Lusignan

cd ${WORKING_DIR}/${BASE_NAME}

rm -f *.sh
anchr template \
    . \
    --basename ${BASE_NAME} \
    --queue mpi \
    --genome 541_692_000 \
    --fastqc \
    --kmergenie \
    --insertsize \
    --sgapreqc \
    --trim2 "--dedupe" \
    --qual2 "25" \
    --len2 "60" \
    --filter "adapter,phix,artifact" \
    --mergereads \
    --ecphase "1,2,3" \
    --cov2 "all" \
    --tadpole \
    --statp 1 \
    --redoanchors \
    --fillanchor \
    --xmx 110g \
    --parallel 24

```

## Lusignan: run

```bash
WORKING_DIR=${HOME}/data/dna-seq/aphid
BASE_NAME=Lusignan

cd ${WORKING_DIR}/${BASE_NAME}
# rm -fr 4_*/ 6_*/ 7_*/ 8_*/ && rm -fr 2_illumina/trim 2_illumina/mergereads statReads.md 
# find . -type d -name "anchor" | xargs rm -fr

bash 0_bsub.sh
# bkill -J "${BASE_NAME}-*"

# bash 0_master.sh
# bash 0_cleanup.sh

```

Table: statInsertSize

| Group             |  Mean | Median | STDev | PercentOfPairs/PairOrientation |
|:------------------|------:|-------:|------:|-------------------------------:|
| R.tadpole.bbtools | 223.0 |    213 |  80.3 |                         11.65% |
| R.tadpole.picard  | 220.8 |    210 |  80.8 |                             FR |


Table: statReads

| Name       | N50 |    Sum |         # |
|:-----------|----:|-------:|----------:|
| Illumina.R | 100 | 25.53G | 255269522 |
| trim.R     | 100 | 22.21G | 223659996 |
| Q25L60     | 100 | 21.53G | 216919901 |


Table: statTrimReads

| Name     | N50 |    Sum |         # |
|:---------|----:|-------:|----------:|
| clumpify | 100 |  25.2G | 252022546 |
| trim     | 100 | 22.21G | 223660014 |
| filter   | 100 | 22.21G | 223659996 |
| R1       | 100 | 11.14G | 111829998 |
| R2       | 100 | 11.07G | 111829998 |
| Rs       |   0 |      0 |         0 |


```text
#R.trim
#Matched	3137704	1.24501%
#Name	Reads	ReadsPct
Reverse_adapter	2830352	1.12306%
```

```text
#R.filter
#Matched	11	0.00000%
#Name	Reads	ReadsPct
```

```text
#R.peaks
#k	31
#unique_kmers	846005368
#main_peak	25
#genome_size	455843721
#haploid_genome_size	455843721
#fold_coverage	25
#haploid_fold_coverage	25
#ploidy	1
#percent_repeat	13.712
#start	center	stop	max	volume
```


Table: statMergeReads

| Name          | N50 |    Sum |         # |
|:--------------|----:|-------:|----------:|
| clumped       | 100 | 22.21G | 223647648 |
| ecco          | 100 | 22.21G | 223647648 |
| eccc          | 100 | 22.21G | 223647648 |
| ecct          | 100 | 20.41G | 205451216 |
| extended      | 140 |  27.7G | 205451216 |
| merged.raw    | 293 | 19.06G |  69659661 |
| unmerged.raw  | 140 |  8.66G |  66131894 |
| unmerged.trim | 140 |  8.66G |  66128384 |
| M1            | 293 | 18.94G |  69193557 |
| U1            | 140 |  4.37G |  33064192 |
| U2            | 140 |  4.28G |  33064192 |
| Us            |   0 |      0 |         0 |
| M.cor         | 247 | 27.67G | 204515498 |

| Group              |  Mean | Median | STDev | PercentOfPairs |
|:-------------------|------:|-------:|------:|---------------:|
| M.ihist.merge1.txt | 150.2 |    153 |  23.2 |         16.32% |
| M.ihist.merge.txt  | 273.6 |    274 |  68.1 |         67.81% |


Table: statQuorum

| Name     | CovIn | CovOut | Discard% | Kmer |   RealG |    EstG | Est/Real |   RunTime |
|:---------|------:|-------:|---------:|-----:|--------:|--------:|---------:|----------:|
| Q0L0.R   |  41.0 |   38.5 |    6.03% | "71" | 541.69M | 537.23M |     0.99 | 0:46'27'' |
| Q25L60.R |  39.7 |   37.8 |    4.99% | "71" | 541.69M | 534.25M |     0.99 | 0:45'44'' |


Table: statKunitigsAnchors.md

| Name           | CovCor | Mapped% | N50Anchor |    Sum |     # | N50Others |    Sum |     # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|-------:|------:|----------:|-------:|------:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q0L0XallP000   |   38.5 |   8.33% |      1431 | 38.09M | 25414 |      1047 | 11.59M | 62986 |   33.0 | 3.0 |   8.0 |  63.0 | "31,41,51,61,71,81" | 1:25'42'' | 0:09'43'' |
| Q25L60XallP000 |   37.8 |   8.67% |      1419 | 37.95M | 25511 |      1051 | 12.47M | 64049 |   32.0 | 3.0 |   7.7 |  61.5 | "31,41,51,61,71,81" | 1:24'23'' | 0:10'11'' |


Table: statTadpoleAnchors.md

| Name           | CovCor | Mapped% | N50Anchor |    Sum |     # | N50Others |    Sum |     # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|-------:|------:|----------:|-------:|------:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q0L0XallP000   |   38.5 |  13.55% |      1472 | 53.25M | 34777 |      1041 | 15.18M | 89147 |   34.0 | 3.0 |   8.3 |  64.5 | "31,41,51,61,71,81" | 0:35'25'' | 0:12'47'' |
| Q25L60XallP000 |   37.8 |  13.58% |      1473 | 54.28M | 35386 |      1035 | 13.51M | 90013 |   33.0 | 3.0 |   8.0 |  63.0 | "31,41,51,61,71,81" | 0:34'50'' | 0:12'38'' |


Table: statMRKunitigsAnchors.md

| Name       | CovCor | Mapped% | N50Anchor |    Sum |     # | N50Others |   Sum |     # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:-----------|-------:|--------:|----------:|-------:|------:|----------:|------:|------:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| MRXallP000 |   51.1 |   6.28% |      1510 | 33.11M | 20976 |      1036 | 7.62M | 47386 |   45.0 | 5.0 |  10.0 |  90.0 | "31,41,51,61,71,81" | 2:35'56'' | 0:07'20'' |


Table: statMRTadpoleAnchors.md

| Name       | CovCor | Mapped% | N50Anchor |    Sum |     # | N50Others |    Sum |     # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:-----------|-------:|--------:|----------:|-------:|------:|----------:|-------:|------:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| MRXallP000 |   51.1 |   8.95% |      1537 | 45.72M | 28673 |      1038 | 11.06M | 65030 |   46.0 | 5.0 |  10.3 |  91.5 | "31,41,51,61,71,81" | 0:55'19'' | 0:09'09'' |


Table: statMergeAnchors.md

| Name                     | Mapped% | N50Anchor |    Sum |     # | N50Others |    Sum |     # | median | MAD | lower | upper | RunTimeAN |
|:-------------------------|--------:|----------:|-------:|------:|----------:|-------:|------:|-------:|----:|------:|------:|----------:|
| 7_mergeAnchors           |  12.70% |      1542 |  53.9M | 33776 |      1039 | 39.28M | 34089 |   34.0 | 3.0 |   8.3 |  64.5 | 0:13'00'' |
| 7_mergeKunitigsAnchors   |   6.25% |      1445 | 34.14M | 22649 |      1046 | 15.09M | 12256 |   34.0 | 3.0 |   8.3 |  64.5 | 0:06'53'' |
| 7_mergeMRKunitigsAnchors |   5.01% |      1485 | 27.57M | 17855 |      1049 | 10.69M |  9279 |   34.0 | 3.0 |   8.3 |  64.5 | 0:07'28'' |
| 7_mergeMRTadpoleAnchors  |   6.97% |      1538 | 40.16M | 25208 |      1045 | 13.12M | 11697 |   33.0 | 3.0 |   8.0 |  63.0 | 0:06'51'' |
| 7_mergeTadpoleAnchors    |   9.62% |      1502 | 49.66M | 31908 |      1040 | 17.97M | 15047 |   34.0 | 3.0 |   8.3 |  64.5 | 0:09'28'' |


Table: statOtherAnchors.md

| Name         | Mapped% | N50Anchor |     Sum |      # | N50Others |    Sum |      # | median | MAD | lower | upper | RunTimeAN |
|:-------------|--------:|----------:|--------:|-------:|----------:|-------:|-------:|-------:|----:|------:|------:|----------:|
| 8_spades     |  68.74% |      8189 | 368.43M |  70301 |      1700 |  37.4M | 121353 |   29.0 | 4.0 |   5.7 |  58.0 | 1:00'30'' |
| 8_spades_MR  |  66.56% |      7956 | 378.71M |  73843 |      1323 |  32.2M | 130531 |   38.0 | 7.0 |   5.7 |  76.0 | 0:55'49'' |
| 8_megahit    |  55.77% |      3455 | 299.71M | 107044 |      1142 | 46.86M | 217003 |   29.0 | 4.0 |   5.7 |  58.0 | 0:41'16'' |
| 8_megahit_MR |  59.78% |      2129 | 322.28M | 161246 |      1127 | 60.32M | 315171 |   35.0 | 9.0 |   3.0 |  70.0 | 0:45'09'' |
| 8_platanus   |  33.90% |      2773 | 192.19M |  79183 |      1185 | 46.58M | 147134 |   30.0 | 4.0 |   6.0 |  60.0 | 0:22'06'' |


Table: statFinal

| Name                     |   N50 |       Sum |       # |
|:-------------------------|------:|----------:|--------:|
| 7_mergeAnchors.anchors   |  1542 |  53898161 |   33776 |
| 7_mergeAnchors.others    |  1039 |  39280097 |   34089 |
| anchorLong               |  2852 |   5818720 |    2244 |
| anchorFill               |  2978 |   5862669 |    2168 |
| spades.contig            | 13991 | 423376713 |   96935 |
| spades.scaffold          | 14302 | 423415238 |   95187 |
| spades.non-contained     | 14773 | 405829923 |   51120 |
| spades_MR.contig         | 11267 | 434147105 |  125901 |
| spades_MR.scaffold       | 11957 | 434334863 |  122981 |
| spades_MR.non-contained  | 12108 | 410913735 |   59591 |
| megahit.contig           |  2789 | 461562365 |  408189 |
| megahit.non-contained    |  4069 | 346571650 |  109989 |
| megahit_MR.contig        |  1007 | 765292655 |  970854 |
| megahit_MR.non-contained |  2404 | 382744455 |  174463 |
| platanus.contig          |    85 | 751446294 | 8721352 |
| platanus.scaffold        |  2578 | 356424417 |  654126 |
| platanus.non-contained   |  4737 | 238777812 |   67958 |

## Lusignan: diamond

```bash
WORKING_DIR=${HOME}/data/dna-seq/aphid
BASE_NAME=Lusignan

cd ${WORKING_DIR}/${BASE_NAME}

#    -q 2_illumina/mergereads/pe.cor.fa.gz \


diamond blastx \
    --db ../organelles/organelles.protein.dmnd \
    -q 8_megahit_MR/final.contigs.fa \
    -o diamond_out \
    -p 16

```

