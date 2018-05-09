# cpDNA

[TOC levels=1-3]: # " "
- [cpDNA](#cpdna)
- [*Medicago truncatula*](#medicago-truncatula)
- [HM050](#hm050)
    - [HM050: download](#hm050-download)
    - [HM050: template](#hm050-template)
    - [HM050: run](#hm050-run)
- [HM340](#hm340)
    - [HM340: download](#hm340-download)
    - [HM340: template](#hm340-template)
    - [HM340: run](#hm340-run)


# *Medicago truncatula*

* Genome: GCF_000219495.3, 389.98 Mb
* Chloroplast: NC_003119, 124033 bp
* Mitochondrion: NC_029641, 271618 bp

* `--matchk 27 --artifact ../../1_genome/ref.fa`: doesn't work

* Reference genome

```bash
mkdir -p ~/data/dna-seq/cpDNA/Medicago
cd ~/data/dna-seq/cpDNA/Medicago

for ACCESSION in "NC_003119" "NC_029641"; do
    URL=$(printf "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nucleotide&rettype=%s&id=%s&retmode=text" "fasta" "${ACCESSION}");
    curl $URL -o ${ACCESSION}.fa
done

#aria2c -x 9 -s 3 -c ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/219/495/GCF_000219495.3_MedtrA17_4.0/GCF_000219495.3_MedtrA17_4.0_genomic.fna.gz

TAB=$'\t'
cat <<EOF > replace.tsv
NC_016407.2${TAB}1
NC_016408.2${TAB}2
NC_016409.2${TAB}3
NC_016410.2${TAB}4
NC_016411.2${TAB}5
NC_016412.2${TAB}6
NC_016413.2${TAB}7
NC_016414.2${TAB}8
NC_003119.8${TAB}Pt
NC_029641.1${TAB}Mt
EOF

cat NC_003119.fa NC_029641.fa |
    faops replace stdin replace.tsv stdout |
    faops order stdin <(echo Pt; echo Mt) genome.fa

#faops replace GCF_000219495.3*_genomic.fna.gz replace.tsv stdout |
#    faops order stdin <(echo {1..8}) ref.fa

```

* Illumina

```bash
cd ~/data/dna-seq/cpDNA/Medicago

cat << EOF > sra_ftp.txt
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR155/008/SRR1552478/SRR1552478_1.fastq.gz
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR155/008/SRR1552478/SRR1552478_2.fastq.gz
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR152/005/SRR1524305/SRR1524305_1.fastq.gz
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR152/005/SRR1524305/SRR1524305_2.fastq.gz
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR103/003/SRR1034293/SRR1034293_1.fastq.gz
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR103/003/SRR1034293/SRR1034293_2.fastq.gz
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR216/006/SRR2163426/SRR2163426_1.fastq.gz
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR216/006/SRR2163426/SRR2163426_2.fastq.gz
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR166/008/SRR1664358/SRR1664358_1.fastq.gz
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR166/008/SRR1664358/SRR1664358_2.fastq.gz
EOF

aria2c -x 9 -s 3 -c -i sra_ftp.txt

cat << EOF > sra_md5.txt
3f570ce4060ffcb741f43501b3afe94f  SRR1552478_1.fastq.gz
b45ce0743d9f446e62473963ce7ac40b  SRR1552478_2.fastq.gz
f03019da3054b8659b80ffdaf388599f  SRR1524305_1.fastq.gz
ff624191ea6080c87663ad78e844ac80  SRR1524305_2.fastq.gz
52581dcbcb9506dffe3d920fc0d83921  SRR1034293_1.fastq.gz
3582cc84b309658811259d38d514cf62  SRR1034293_2.fastq.gz
28ce4e3b8138df654780401245113bf9  SRR2163426_1.fastq.gz
8756862c6043ffa96a8b1a5413865cd2  SRR2163426_2.fastq.gz
a86d4a063e107f2ce77ef1ca0051df86  SRR1664358_1.fastq.gz
5b6ec25a47d48194b7afea6bbaa6a6a3  SRR1664358_2.fastq.gz
EOF

md5sum --check sra_md5.txt

```

* Rsync to hpcc

```bash
rsync -avP \
    ~/data/dna-seq/cpDNA/Medicago/ \
    wangq@202.119.37.251:data/dna-seq/cpDNA/Medicago

# rsync -avP wangq@202.119.37.251:data/dna-seq/cpDNA/ ~/data/dna-seq/cpDNA

```

# HM050

*Medicago truncatula* HM050

## HM050: download

* Illumina
    * [SRR1034293](https://www.ncbi.nlm.nih.gov/sra/?term=SRR1034293)
    * 22.7 Gb
    * ~58.2x

```bash
mkdir -p ~/data/dna-seq/cpDNA/HM050/1_genome
cd ~/data/dna-seq/cpDNA/HM050/1_genome

ln -fs ../../Medicago/genome.fa genome.fa
#ln -fs ../../Medicago/ref.fa ref.fa

mkdir -p ~/data/dna-seq/cpDNA/HM050/2_illumina
cd ~/data/dna-seq/cpDNA/HM050/2_illumina

ln -fs ../../Medicago/SRR1034293_1.fastq.gz R1.fq.gz
ln -fs ../../Medicago/SRR1034293_2.fastq.gz R2.fq.gz

```


## HM050: template


```bash
WORKING_DIR=${HOME}/data/dna-seq/cpDNA
BASE_NAME=HM050

cd ${WORKING_DIR}/${BASE_NAME}

rm -f *.sh
anchr template \
    . \
    --basename ${BASE_NAME} \
    --queue mpi \
    --genome 1_000_000 \
    --fastqc \
    --kmergenie \
    --insertsize \
    --sgapreqc \
    --trim2 "--dedupe --cutoff 240 --cutk 31" \
    --qual2 "25" \
    --len2 "60" \
    --filter "adapter,phix,artifact" \
    --mergereads \
    --ecphase "1,2,3" \
    --cov2 "40 80 120 160 240 320" \
    --tadpole \
    --splitp 100 \
    --statp 2 \
    --fillanchor \
    --xmx 110g \
    --parallel 24

```

## HM050: run

```bash
WORKING_DIR=${HOME}/data/dna-seq/cpDNA
BASE_NAME=HM050

cd ${WORKING_DIR}/${BASE_NAME}
#rm -fr 4_*/ 6_*/ 7_*/ 8_*/ && rm -fr 2_illumina/trim 2_illumina/mergereads statReads.md 

bash 0_bsub.sh
#bkill -J "${BASE_NAME}-*"

#bash 0_master.sh
#bash 0_cleanup.sh

```

Table: statInsertSize

| Group             |  Mean | Median | STDev | PercentOfPairs/PairOrientation |
|:------------------|------:|-------:|------:|-------------------------------:|
| R.tadpole.bbtools | 327.6 |    356 |  79.0 |                         15.62% |
| R.tadpole.picard  | 329.8 |    356 |  75.2 |                             FR |


Table: statReads

| Name       | N50 |    Sum |         # |
|:-----------|----:|-------:|----------:|
| Illumina.R | 100 | 22.71G | 227105112 |
| trim.R     | 100 |  8.68G |  89738832 |
| Q25L60     | 100 |  8.05G |  84200593 |


Table: statTrimReads

| Name     | N50 |    Sum |         # |
|:---------|----:|-------:|----------:|
| clumpify | 100 | 20.52G | 205232542 |
| highpass | 100 |  9.21G |  92051816 |
| trim     | 100 |  7.89G |  81717308 |
| filter   | 100 |  7.89G |  81717308 |
| R1       | 100 |  3.94G |  40858654 |
| R2       | 100 |  3.96G |  40858654 |
| Rs       |   0 |      0 |         0 |


```text
#R.trim
#Matched	434033	0.47151%
#Name	Reads	ReadsPct
TruSeq_Adapter_Index_1_6	143350	0.15573%
Nextera_LMP_Read2_External_Adapter	94426	0.10258%
```

```text
#R.filter
#Matched	0	0.00000%
#Name	Reads	ReadsPct
```

```text
#R.peaks
#k	31
#unique_kmers	144701630
#main_peak	236
#genome_size	4229244
#haploid_genome_size	4229244
#fold_coverage	230
#haploid_fold_coverage	230
#ploidy	1
#percent_repeat	99.500
#start	center	stop	max	volume
```


Table: statMergeReads

| Name          | N50 |   Sum |        # |
|:--------------|----:|------:|---------:|
| clumped       | 100 | 7.87G | 81503598 |
| ecco          | 100 | 7.86G | 81503598 |
| eccc          | 100 | 7.86G | 81503598 |
| ecct          | 100 |    6G | 62395076 |
| extended      | 129 | 7.74G | 62395076 |
| merged.raw    | 390 | 3.63G | 12685491 |
| unmerged.raw  | 124 | 4.51G | 37024094 |
| unmerged.trim | 124 | 4.51G | 37014236 |
| M1            | 394 | 2.33G |  7198283 |
| U1            | 124 | 2.25G | 18507118 |
| U2            | 125 | 2.26G | 18507118 |
| Us            |   0 |     0 |        0 |
| M.cor         | 136 | 6.85G | 51410802 |

| Group              |  Mean | Median | STDev | PercentOfPairs |
|:-------------------|------:|-------:|------:|---------------:|
| M.ihist.merge1.txt | 144.7 |    157 |  36.2 |         11.39% |
| M.ihist.merge.txt  | 286.1 |    363 | 122.3 |         40.66% |


Table: statQuorum

| Name     |  CovIn | CovOut | Discard% | Kmer | RealG |   EstG | Est/Real |   RunTime |
|:---------|-------:|-------:|---------:|-----:|------:|-------:|---------:|----------:|
| Q0L0.R   | 7893.3 | 7378.5 |    6.52% | "71" |    1M | 39.41M |    39.41 | 0:13'55'' |
| Q25L60.R | 7316.2 | 6910.8 |    5.54% | "71" |    1M | 35.84M |    35.84 | 0:13'13'' |


Table: statKunitigsAnchors.md

| Name | CovCor | Mapped% | N50Anchor | Sum | # | N50Others | Sum | # | median | MAD | lower | upper | Kmer | RunTimeKU | RunTimeAN |
|:-----|-------:|--------:|----------:|----:|--:|----------:|----:|--:|-------:|----:|------:|------:|-----:|----------:|----------:|


Table: statTadpoleAnchors.md

| Name           | CovCor | Mapped% | N50Anchor |     Sum |   # | N50Others |     Sum |   # | median |  MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|--------:|----:|----------:|--------:|----:|-------:|-----:|------:|------:|--------------------:|----------:|----------:|
| Q0L0X40P000    |   40.0 |  16.34% |      1986 |  99.54K |  52 |      1943 |  74.66K | 143 |   22.0 | 10.0 |   3.0 |  44.0 | "31,41,51,61,71,81" | 0:00'23'' | 0:00'19'' |
| Q0L0X40P001    |   40.0 |  17.84% |      2291 | 101.66K |  51 |      1533 |  72.38K | 151 |   22.0 | 10.0 |   3.0 |  44.0 | "31,41,51,61,71,81" | 0:00'22'' | 0:00'19'' |
| Q0L0X40P002    |   40.0 |  15.61% |      1805 | 103.26K |  58 |      1837 |  72.08K | 156 |   20.0 | 10.0 |   3.0 |  40.0 | "31,41,51,61,71,81" | 0:00'22'' | 0:00'19'' |
| Q0L0X80P000    |   80.0 |  20.06% |      2208 | 212.31K | 103 |      4253 |  226.7K | 301 |   18.0 |  8.0 |   3.0 |  36.0 | "31,41,51,61,71,81" | 0:00'28'' | 0:00'20'' |
| Q0L0X80P001    |   80.0 |  19.00% |      2048 | 204.89K | 104 |      4149 | 185.92K | 296 |   18.0 |  7.5 |   3.0 |  36.0 | "31,41,51,61,71,81" | 0:00'28'' | 0:00'20'' |
| Q0L0X80P002    |   80.0 |  20.39% |      1776 | 213.47K | 115 |      3782 | 227.61K | 331 |   19.0 |  9.0 |   3.0 |  38.0 | "31,41,51,61,71,81" | 0:00'27'' | 0:00'21'' |
| Q0L0X120P000   |  120.0 |  23.01% |      3118 | 261.61K | 101 |      4182 | 266.05K | 354 |   23.0 |  9.0 |   3.0 |  46.0 | "31,41,51,61,71,81" | 0:00'32'' | 0:00'22'' |
| Q0L0X120P001   |  120.0 |  22.93% |      2932 | 266.94K | 106 |      3655 |  264.2K | 409 |   23.0 |  9.0 |   3.0 |  46.0 | "31,41,51,61,71,81" | 0:00'34'' | 0:00'22'' |
| Q0L0X120P002   |  120.0 |  22.38% |      3391 | 268.66K | 103 |      4228 | 277.69K | 378 |   23.0 |  9.0 |   3.0 |  46.0 | "31,41,51,61,71,81" | 0:00'32'' | 0:00'22'' |
| Q0L0X160P000   |  160.0 |  21.81% |      4473 | 280.18K |  86 |      3338 | 248.01K | 365 |   29.0 | 10.0 |   3.0 |  58.0 | "31,41,51,61,71,81" | 0:00'35'' | 0:00'22'' |
| Q0L0X160P001   |  160.0 |  23.18% |      5283 | 267.79K |  73 |      3450 | 269.03K | 344 |   28.0 |  9.0 |   3.0 |  56.0 | "31,41,51,61,71,81" | 0:00'35'' | 0:00'23'' |
| Q0L0X160P002   |  160.0 |  22.28% |      6265 | 280.34K |  80 |      3213 |  251.4K | 338 |   29.0 | 10.0 |   3.0 |  58.0 | "31,41,51,61,71,81" | 0:00'34'' | 0:00'22'' |
| Q0L0X240P000   |  240.0 |  20.73% |      6514 | 275.28K |  61 |      3452 |  236.6K | 299 |   41.0 | 14.0 |   3.0 |  82.0 | "31,41,51,61,71,81" | 0:00'45'' | 0:00'23'' |
| Q0L0X240P001   |  240.0 |  22.87% |      4709 | 281.57K |  78 |      3457 | 234.19K | 357 |   41.0 | 12.0 |   3.0 |  82.0 | "31,41,51,61,71,81" | 0:00'43'' | 0:00'23'' |
| Q0L0X240P002   |  240.0 |  20.60% |      5417 | 272.76K |  68 |      3229 |  219.6K | 310 |   40.0 | 13.0 |   3.0 |  80.0 | "31,41,51,61,71,81" | 0:00'43'' | 0:00'23'' |
| Q0L0X320P000   |  320.0 |  19.30% |      6226 | 283.98K |  75 |      3456 |  202.8K | 297 |   54.0 | 15.5 |   3.0 | 108.0 | "31,41,51,61,71,81" | 0:00'49'' | 0:00'24'' |
| Q0L0X320P001   |  320.0 |  19.73% |      6352 | 271.49K |  64 |      3624 | 199.72K | 281 |   53.0 | 15.0 |   3.0 | 106.0 | "31,41,51,61,71,81" | 0:00'49'' | 0:00'24'' |
| Q0L0X320P002   |  320.0 |  20.05% |      5363 | 273.58K |  69 |      2639 | 222.58K | 310 |   54.0 | 16.5 |   3.0 | 108.0 | "31,41,51,61,71,81" | 0:00'48'' | 0:00'24'' |
| Q25L60X40P000  |   40.0 |  18.15% |      2221 |  95.19K |  50 |      2209 |  69.31K | 137 |   23.0 |  8.5 |   3.0 |  46.0 | "31,41,51,61,71,81" | 0:00'22'' | 0:00'19'' |
| Q25L60X40P001  |   40.0 |  18.51% |      1672 |  104.4K |  59 |      2085 |  76.32K | 161 |   22.0 | 12.0 |   3.0 |  44.0 | "31,41,51,61,71,81" | 0:00'20'' | 0:00'19'' |
| Q25L60X40P002  |   40.0 |  18.46% |      1837 | 100.31K |  58 |      1881 |  77.99K | 169 |   22.0 | 11.5 |   3.0 |  44.0 | "31,41,51,61,71,81" | 0:00'21'' | 0:00'20'' |
| Q25L60X80P000  |   80.0 |  22.39% |      2400 | 206.24K |  99 |      4030 |  193.1K | 307 |   18.0 |  7.0 |   3.0 |  36.0 | "31,41,51,61,71,81" | 0:00'28'' | 0:00'21'' |
| Q25L60X80P001  |   80.0 |  22.92% |      2301 | 208.95K | 100 |      4483 | 225.61K | 308 |   20.0 |  9.0 |   3.0 |  40.0 | "31,41,51,61,71,81" | 0:00'28'' | 0:00'21'' |
| Q25L60X80P002  |   80.0 |  22.71% |      2250 | 214.84K | 110 |      3389 | 211.17K | 315 |   20.0 |  9.0 |   3.0 |  40.0 | "31,41,51,61,71,81" | 0:00'27'' | 0:00'21'' |
| Q25L60X120P000 |  120.0 |  24.26% |      3740 | 260.15K |  86 |      4483 | 247.28K | 339 |   24.0 |  8.0 |   3.0 |  48.0 | "31,41,51,61,71,81" | 0:00'33'' | 0:00'22'' |
| Q25L60X120P001 |  120.0 |  24.42% |      3742 |  261.7K |  94 |      3440 | 223.72K | 347 |   23.0 |  8.0 |   3.0 |  46.0 | "31,41,51,61,71,81" | 0:00'33'' | 0:00'22'' |
| Q25L60X120P002 |  120.0 |  22.25% |      3753 | 261.51K |  87 |      4534 |  213.8K | 321 |   23.0 |  8.0 |   3.0 |  46.0 | "31,41,51,61,71,81" | 0:00'31'' | 0:00'22'' |
| Q25L60X160P000 |  160.0 |  24.89% |      5602 | 275.52K |  76 |      3801 | 241.72K | 340 |   30.0 | 11.0 |   3.0 |  60.0 | "31,41,51,61,71,81" | 0:00'35'' | 0:00'22'' |
| Q25L60X160P001 |  160.0 |  23.45% |      4827 | 270.78K |  79 |      3817 |  222.8K | 320 |   29.0 | 10.0 |   3.0 |  58.0 | "31,41,51,61,71,81" | 0:00'35'' | 0:00'23'' |
| Q25L60X160P002 |  160.0 |  23.98% |      7952 |  268.1K |  62 |      4488 | 224.35K | 277 |   30.0 | 10.0 |   3.0 |  60.0 | "31,41,51,61,71,81" | 0:00'36'' | 0:00'22'' |
| Q25L60X240P000 |  240.0 |  25.01% |      5626 | 268.58K |  68 |      3679 | 242.05K | 340 |   42.0 | 12.0 |   3.0 |  84.0 | "31,41,51,61,71,81" | 0:00'42'' | 0:00'23'' |
| Q25L60X240P001 |  240.0 |  22.63% |      7743 | 270.81K |  61 |      3307 |  223.8K | 285 |   43.0 | 14.0 |   3.0 |  86.0 | "31,41,51,61,71,81" | 0:00'41'' | 0:00'23'' |
| Q25L60X240P002 |  240.0 |  24.76% |      6369 | 277.49K |  66 |      3734 |  233.8K | 305 |   42.0 | 13.0 |   3.0 |  84.0 | "31,41,51,61,71,81" | 0:00'42'' | 0:00'24'' |
| Q25L60X320P000 |  320.0 |  25.16% |      5701 | 284.22K |  76 |      3655 | 224.63K | 319 |   57.0 | 19.0 |   3.0 | 114.0 | "31,41,51,61,71,81" | 0:00'48'' | 0:00'25'' |
| Q25L60X320P001 |  320.0 |  23.70% |      6642 | 280.65K |  70 |      3757 |  235.8K | 332 |   56.0 | 16.0 |   3.0 | 112.0 | "31,41,51,61,71,81" | 0:00'49'' | 0:00'24'' |
| Q25L60X320P002 |  320.0 |  26.47% |      7260 | 279.12K |  61 |      4504 | 227.97K | 288 |   55.0 | 16.0 |   3.0 | 110.0 | "31,41,51,61,71,81" | 0:00'50'' | 0:00'25'' |


Table: statMRKunitigsAnchors.md

| Name | CovCor | Mapped% | N50Anchor | Sum | # | N50Others | Sum | # | median | MAD | lower | upper | Kmer | RunTimeKU | RunTimeAN |
|:-----|-------:|--------:|----------:|----:|--:|----------:|----:|--:|-------:|----:|------:|------:|-----:|----------:|----------:|


Table: statMRTadpoleAnchors.md

| Name       | CovCor | Mapped% | N50Anchor |     Sum |  # | N50Others |     Sum |   # | median |  MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:-----------|-------:|--------:|----------:|--------:|---:|----------:|--------:|----:|-------:|-----:|------:|------:|--------------------:|----------:|----------:|
| MRX40P000  |   40.0 |  20.46% |      6215 | 270.54K | 66 |      6338 | 189.01K | 196 |   14.0 |  5.0 |   3.0 |  28.0 | "31,41,51,61,71,81" | 0:00'24'' | 0:00'23'' |
| MRX40P001  |   40.0 |  20.74% |      8185 | 266.01K | 53 |      4907 | 195.88K | 174 |   14.0 |  6.0 |   3.0 |  28.0 | "31,41,51,61,71,81" | 0:00'24'' | 0:00'23'' |
| MRX40P002  |   40.0 |  20.53% |      8959 | 268.15K | 54 |      5139 | 181.77K | 175 |   14.0 |  5.0 |   3.0 |  28.0 | "31,41,51,61,71,81" | 0:00'22'' | 0:00'20'' |
| MRX80P000  |   80.0 |  19.64% |     13797 | 272.46K | 33 |      7102 | 160.31K | 125 |   25.0 | 10.0 |   3.0 |  50.0 | "31,41,51,61,71,81" | 0:00'28'' | 0:00'21'' |
| MRX80P001  |   80.0 |  21.14% |     15538 | 283.69K | 34 |      6200 | 175.97K | 131 |   27.0 | 11.0 |   3.0 |  54.0 | "31,41,51,61,71,81" | 0:00'27'' | 0:00'20'' |
| MRX80P002  |   80.0 |  17.96% |     23745 | 282.12K | 36 |      5277 | 140.24K | 101 |   26.0 | 25.0 |   3.0 |  52.0 | "31,41,51,61,71,81" | 0:00'26'' | 0:00'19'' |
| MRX120P000 |  120.0 |  20.41% |     20665 | 285.83K | 31 |      5105 | 154.21K | 114 |   39.0 | 23.5 |   3.0 |  78.0 | "31,41,51,61,71,81" | 0:00'31'' | 0:00'22'' |
| MRX120P001 |  120.0 |  17.48% |     18434 | 287.34K | 36 |      5036 | 133.71K |  91 |   39.0 | 27.0 |   3.0 |  78.0 | "31,41,51,61,71,81" | 0:00'31'' | 0:00'22'' |
| MRX120P002 |  120.0 |  18.37% |     16360 | 283.87K | 36 |      5927 | 141.56K | 102 |   39.0 | 23.0 |   3.0 |  78.0 | "31,41,51,61,71,81" | 0:00'32'' | 0:00'21'' |
| MRX160P000 |  160.0 |  18.03% |     13849 | 287.41K | 35 |      5105 | 135.39K | 104 |   51.0 | 38.0 |   3.0 | 102.0 | "31,41,51,61,71,81" | 0:00'33'' | 0:00'21'' |
| MRX160P001 |  160.0 |  18.96% |     14068 | 290.18K | 39 |      5946 | 146.69K | 114 |   52.0 | 32.0 |   3.0 | 104.0 | "31,41,51,61,71,81" | 0:00'33'' | 0:00'21'' |
| MRX160P002 |  160.0 |  17.94% |     14545 | 279.76K | 33 |      5730 | 139.18K |  82 |   52.0 | 37.0 |   3.0 | 104.0 | "31,41,51,61,71,81" | 0:00'34'' | 0:00'21'' |
| MRX240P000 |  240.0 |  17.73% |     15662 | 284.72K | 32 |      5036 | 127.11K |  84 |   78.0 | 65.0 |   3.0 | 156.0 | "31,41,51,61,71,81" | 0:00'40'' | 0:00'21'' |
| MRX240P001 |  240.0 |  17.88% |     10501 | 284.29K | 42 |      4504 | 139.27K | 104 |   77.0 | 54.0 |   3.0 | 154.0 | "31,41,51,61,71,81" | 0:00'40'' | 0:00'23'' |
| MRX240P002 |  240.0 |  17.20% |     16407 |  276.5K | 34 |      5890 | 135.66K | 101 |   78.0 | 45.5 |   3.0 | 156.0 | "31,41,51,61,71,81" | 0:00'40'' | 0:00'22'' |
| MRX320P000 |  320.0 |  17.81% |     12205 | 279.84K | 37 |      4305 |  133.8K |  97 |  103.0 | 72.0 |   3.0 | 206.0 | "31,41,51,61,71,81" | 0:00'44'' | 0:00'23'' |
| MRX320P001 |  320.0 |  17.67% |     11420 | 274.04K | 38 |      4080 | 136.51K | 105 |  101.0 | 56.5 |   3.0 | 202.0 | "31,41,51,61,71,81" | 0:00'44'' | 0:00'22'' |
| MRX320P002 |  320.0 |  17.23% |     14461 | 277.15K | 36 |      4504 | 135.52K |  95 |  104.0 | 62.0 |   3.0 | 208.0 | "31,41,51,61,71,81" | 0:00'44'' | 0:00'22'' |


Table: statMergeAnchors.md

| Name                     | Mapped% | N50Anchor |     Sum |   # | N50Others |   Sum |    # | median | MAD | lower | upper | RunTimeAN |
|:-------------------------|--------:|----------:|--------:|----:|----------:|------:|-----:|-------:|----:|------:|------:|----------:|
| 7_mergeAnchors           |   0.00% |     21149 |   1.26M | 175 |      4051 |    4M | 1221 |    0.0 | 0.0 |   0.0 |   0.0 |           |
| 7_mergeKunitigsAnchors   |   0.00% |         0 |       0 |   0 |         0 |     0 |    0 |    0.0 | 0.0 |   0.0 |   0.0 |           |
| 7_mergeMRKunitigsAnchors |   0.00% |         0 |       0 |   0 |         0 |     0 |    0 |    0.0 | 0.0 |   0.0 |   0.0 |           |
| 7_mergeMRTadpoleAnchors  |   0.00% |     54123 | 855.09K |  78 |      4057 | 1.85M |  388 |    0.0 | 0.0 |   0.0 |   0.0 |           |
| 7_mergeTadpoleAnchors    |   0.00% |      6538 | 994.93K | 204 |      3190 | 6.66M | 3082 |    0.0 | 0.0 |   0.0 |   0.0 |           |


Table: statOtherAnchors.md

| Name         | Mapped% | N50Anchor |     Sum |   # | N50Others |     Sum |    # | median |   MAD | lower |  upper | RunTimeAN |
|:-------------|--------:|----------:|--------:|----:|----------:|--------:|-----:|-------:|------:|------:|-------:|----------:|
| 8_spades     |   9.97% |      1198 | 373.99K | 303 |      1439 |   1.01M | 1165 |   70.0 |  39.0 |   3.0 |  140.0 | 0:01'49'' |
| 8_spades_MR  |  28.71% |      1265 | 642.25K | 496 |      2609 |   1.31M | 1115 |  174.0 | 102.0 |   3.0 |  348.0 | 0:01'29'' |
| 8_megahit    |  10.25% |      8372 | 314.34K |  79 |      5434 | 148.06K |  119 | 1089.0 | 992.0 |   3.0 | 2178.0 | 0:01'38'' |
| 8_megahit_MR |  29.64% |      1172 | 322.44K | 268 |      1310 |   1.59M | 1322 |  179.0 | 119.0 |   3.0 |  358.0 | 0:01'30'' |
| 8_platanus   |  10.05% |      3075 | 116.48K |  43 |      5398 | 152.16K |   60 | 1655.0 | 779.0 |   3.0 | 3310.0 | 0:01'38'' |


Table: statFinal

| Name                     |    N50 |       Sum |       # |
|:-------------------------|-------:|----------:|--------:|
| Genome                   | 271618 |    395651 |       2 |
| 7_mergeAnchors.anchors   |  21149 |   1260323 |     175 |
| 7_mergeAnchors.others    |   4051 |   3997223 |    1221 |
| anchorLong               |  28848 |   1250707 |     161 |
| anchorFill               |  41230 |   1219257 |     129 |
| spades.contig            |     93 | 106264696 | 1000890 |
| spades.scaffold          |     93 | 106305730 | 1000118 |
| spades.non-contained     |   1377 |   1382853 |     901 |
| spades_MR.contig         |    848 |   4838860 |    9126 |
| spades_MR.scaffold       |    858 |   4841764 |    9081 |
| spades_MR.non-contained  |   1867 |   1956356 |     960 |
| megahit.contig           |    364 |   7327950 |   20591 |
| megahit.non-contained    |  19773 |    462393 |      86 |
| megahit_MR.contig        |    587 |  12302424 |   21894 |
| megahit_MR.non-contained |   1316 |   1908223 |    1208 |
| platanus.contig          |    111 |   3255289 |   25177 |
| platanus.scaffold        |    112 |   1823864 |   13621 |
| platanus.non-contained   |  16417 |    268640 |      50 |


# HM340

*Medicago truncatula* HM340

## HM340: download

* Illumina
    * [SRR1524305](https://www.ncbi.nlm.nih.gov/sra/?term=SRR1524305) 33.2 Gb
    * ~85.1x

```bash
mkdir -p ~/data/dna-seq/cpDNA/HM340/1_genome
cd ~/data/dna-seq/cpDNA/HM340/1_genome

ln -fs ../../Medicago/genome.fa genome.fa

mkdir -p ~/data/dna-seq/cpDNA/HM340/2_illumina
cd ~/data/dna-seq/cpDNA/HM340/2_illumina

ln -fs ~/data/dna-seq/cpDNA/Medicago/SRR1524305_1.fastq.gz R1.fq.gz
ln -fs ~/data/dna-seq/cpDNA/Medicago/SRR1524305_2.fastq.gz R2.fq.gz

```


## HM340: template

```bash
WORKING_DIR=${HOME}/data/dna-seq/cpDNA
BASE_NAME=HM340

cd ${WORKING_DIR}/${BASE_NAME}

rm -f *.sh
anchr template \
    . \
    --basename ${BASE_NAME} \
    --queue mpi \
    --genome 1000000 \
    --fastqc \
    --kmergenie \
    --insertsize \
    --sgapreqc \
    --trim2 "--dedupe --cutoff 170 --cutk 31" \
    --qual2 "25" \
    --len2 "60" \
    --filter "adapter,phix,artifact" \
    --mergereads \
    --ecphase "1,2,3" \
    --cov2 "40 80 120 160" \
    --tadpole \
    --splitp 100 \
    --statp 2 \
    --fillanchor \
    --redoanchors \
    --parallel 24 \
    --xmx 110g

```

## HM340: run

```bash
WORKING_DIR=${HOME}/data/dna-seq/cpDNA
BASE_NAME=HM340

cd ${WORKING_DIR}/${BASE_NAME}
#rm -fr 4_*/ 6_*/ 7_*/ 8_*/ 2_illumina/trim 2_illumina/mergereads statReads.md 

bash 0_bsub.sh
#bash 0_master.sh

#bash 0_cleanup.sh

```

