# *de novo* rna-seq projects with `anchr`

[TOC levels=1-3]: # " "
- [*de novo* rna-seq projects with `anchr`](#de-novo-rna-seq-projects-with-anchr)
- [Other euk](#other-euk)
- [Thailand](#thailand)
- [Malaysia](#malaysia)


# Other euk

Naja kaouthia 孟加拉眼镜蛇 https://www.ncbi.nlm.nih.gov/bioproject/PRJNA302200

Trinity 2.6.6 要求 fq 文件头有特定的标记, 因此下载 sra 而不是 fq.

```bash
mkdir -p ~/data/rna-seq/other_euk/sra
cd ~/data/rna-seq/other_euk/sra

cat << EOF > source.csv
SRX1432812,Malaysia,
SRX1432814,Thailand,
EOF

perl ~/Scripts/sra/sra_info.pl source.csv -v \
    > sra_info.yml

perl ~/Scripts/sra/sra_prep.pl sra_info.yml

aria2c -x 9 -s 3 -c -i sra_info.ftp.txt

md5sum --check sra_info.md5.txt

cat sra_info.md5.txt |
    cut -d ' ' -f 2 |
    parallel --no-run-if-empty --linebuffer -k -j 3 "
        fastq-dump --defline-seq '@\$sn[_\$rn]/\$ri' --split-files ./{}
    "

find . -name "*.fastq" | parallel -j 2 pigz -p 8

```

* Rsync to hpcc

```bash
rsync -avP \
    ~/data/rna-seq/other_euk/ \
    wangq@202.119.37.251:data/rna-seq/other_euk

# rsync -avP wangq@202.119.37.251:data/rna-seq/other_euk/ ~/data/rna-seq/other_euk

```

# Thailand

```bash
mkdir -p ~/data/rna-seq/other_euk/Thailand/2_illumina
cd ~/data/rna-seq/other_euk/Thailand/2_illumina

ln -s ../../sra/SRR2917657_1.fastq.gz R1.fq.gz
ln -s ../../sra/SRR2917657_2.fastq.gz R2.fq.gz

```

```bash
WORKING_DIR=${HOME}/data/rna-seq/other_euk
BASE_NAME=Thailand

cd ${WORKING_DIR}/${BASE_NAME}

rm -f *.sh
anchr template \
    . \
    --basename ${BASE_NAME} \
    --queue mpi \
    --genome 50_000_000 \
    --fastqc \
    --kmergenie \
    --insertsize \
    --sgapreqc \
    --trim2 "--dedupe" \
    --qual2 "20 25 30" \
    --len2 "60" \
    --filter "adapter,phix" \
    --mergereads \
    --ecphase "1,2,3" \
    --cov2 "all" \
    --tadpole \
    --trinity \
    --parallel 24 \
    --xmx 110g

bash 0_bsub.sh

bsub -q mpi -n 24 -J "${BASE_NAME}-8_trinity"     "bash 8_trinity.sh"
bsub -q mpi -n 24 -J "${BASE_NAME}-8_trinity_cor" "bash 8_trinity_cor.sh"
bsub -q mpi -n 24 -J "${BASE_NAME}-8_trinity_MR"  "bash 8_trinity_MR.sh"

find . -maxdepth 2 -name "*.fa" -or -name "*.fasta" |
    sort |
    tar -czvf ${BASE_NAME}.tar.gz -T -

```

Table: statInsertSize

| Group             |  Mean | Median | STDev | PercentOfPairs/PairOrientation |
|:------------------|------:|-------:|------:|-------------------------------:|
| R.tadpole.bbtools | 202.1 |    213 |  40.5 |                         20.14% |
| R.tadpole.picard  | 201.7 |    212 |  39.4 |                             FR |


Table: statReads

| Name       | N50 |   Sum |        # |
|:-----------|----:|------:|---------:|
| Illumina.R |  90 | 4.63G | 51430686 |


Table: statTrimReads

| Name     | N50 |   Sum |        # |
|:---------|----:|------:|---------:|
| clumpify |  90 | 2.24G | 24861182 |
| trim     |  90 | 2.14G | 24083532 |
| filter   |  90 | 2.14G | 24083532 |
| R1       |  90 | 1.07G | 12041766 |
| R2       |  90 | 1.07G | 12041766 |
| Rs       |   0 |     0 |        0 |


```text
#R.trim
#Matched        12771   0.05137%
#Name   Reads   ReadsPct
```

```text
#R.filter
#Matched        0       0.00000%
#Name   Reads   ReadsPct
```

```text
#R.peaks
#k      31
#unique_kmers   119710664
#error_kmers    119399322
#genomic_kmers  311342
#main_peak      981
#genome_size_in_peaks   499427
#genome_size    1713473
#haploid_genome_size    856736
#fold_coverage  366
#haploid_fold_coverage  727
#ploidy 2
#het_rate       0.00388
#percent_repeat_in_peaks        36.540
#percent_repeat 80.429
#start  center  stop    max     volume
```


Table: statMergeReads

| Name          | N50 |     Sum |        # |
|:--------------|----:|--------:|---------:|
| clumped       |  90 |   2.14G | 24040986 |
| ecco          |  90 |   2.14G | 24040986 |
| eccc          |  90 |   2.14G | 24040986 |
| ecct          |  90 |   1.77G | 19930674 |
| extended      | 130 |   2.45G | 19930674 |
| merged.raw    | 253 |   2.03G |  8481927 |
| unmerged.raw  | 116 | 336.21M |  2966820 |
| unmerged.trim | 116 | 336.18M |  2966502 |
| M1            | 255 |   1.54G |  6434327 |
| U1            | 116 | 168.49M |  1483251 |
| U2            | 116 | 167.69M |  1483251 |
| Us            |   0 |       0 |        0 |
| M.cor         | 248 |   1.88G | 15835156 |

| Group              |  Mean | Median | STDev | PercentOfPairs |
|:-------------------|------:|-------:|------:|---------------:|
| M.ihist.merge1.txt | 121.8 |    121 |  24.7 |         12.40% |
| M.ihist.merge.txt  | 239.1 |    250 |  42.9 |         85.11% |


Table: statQuorum

| Name     | CovIn | CovOut | Discard% | Kmer | RealG |   EstG | Est/Real |   RunTime |
|:---------|------:|-------:|---------:|-----:|------:|-------:|---------:|----------:|
| Q0L0.R   |  21.4 |   18.8 |   12.28% | "63" |  100M | 39.94M |     0.40 | 0:04'29'' |
| Q20L60.R |  21.0 |   18.5 |   12.05% | "63" |  100M | 39.51M |     0.40 | 0:04'18'' |
| Q25L60.R |  20.0 |   17.6 |   11.81% | "63" |  100M | 38.46M |     0.38 | 0:03'55'' |
| Q30L60.R |  18.0 |   15.9 |   11.70% | "63" |  100M | 36.27M |     0.36 | 0:03'31'' |


Table: statKunitigsAnchors.md

| Name           | CovCor | Mapped% | N50Anchor |   Sum |    # | N50Others |   Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|------:|-----:|----------:|------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q0L0XallP000   |   37.6 |  10.32% |      1329 |  2.6M | 1900 |      1359 | 5.74M | 7409 |   18.0 | 7.0 |   3.0 |  36.0 | "31,41,51,61,71,81" | 0:05'45'' | 0:01'13'' |
| Q20L60XallP000 |   36.9 |  10.61% |      1327 | 2.62M | 1916 |      1360 | 5.77M | 7453 |   18.0 | 7.0 |   3.0 |  36.0 | "31,41,51,61,71,81" | 0:05'37'' | 0:01'13'' |
| Q25L60XallP000 |   35.3 |  10.83% |      1310 | 2.29M | 1691 |      1372 | 5.91M | 7071 |   17.0 | 6.0 |   3.0 |  34.0 | "31,41,51,61,71,81" | 0:05'25'' | 0:01'12'' |
| Q30L60XallP000 |   31.8 |  11.01% |      1298 | 2.09M | 1567 |      1374 |  5.4M | 6511 |   17.0 | 6.0 |   3.0 |  34.0 | "31,41,51,61,71,81" | 0:04'51'' | 0:01'09'' |


Table: statTadpoleAnchors.md

| Name           | CovCor | Mapped% | N50Anchor |   Sum |    # | N50Others |   Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|------:|-----:|----------:|------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q0L0XallP000   |   37.6 |  12.51% |      1299 | 2.21M | 1637 |      1336 | 3.53M | 5538 |   24.0 | 8.0 |   3.0 |  48.0 | "31,41,51,61,71,81" | 0:02'11'' | 0:01'06'' |
| Q20L60XallP000 |   36.9 |  12.72% |      1306 | 2.21M | 1636 |      1335 |  3.5M | 5499 |   24.0 | 8.0 |   3.0 |  48.0 | "31,41,51,61,71,81" | 0:02'09'' | 0:01'06'' |
| Q25L60XallP000 |   35.3 |  13.70% |      1314 | 2.12M | 1567 |      1329 | 3.42M | 5293 |   24.0 | 8.0 |   3.0 |  48.0 | "31,41,51,61,71,81" | 0:02'07'' | 0:01'06'' |
| Q30L60XallP000 |   31.8 |  14.22% |      1286 | 1.91M | 1433 |      1320 | 3.11M | 4863 |   24.0 | 8.0 |   3.0 |  48.0 | "31,41,51,61,71,81" | 0:01'52'' | 0:01'05'' |


Table: statMRKunitigsAnchors.md

| Name       | CovCor | Mapped% | N50Anchor |  Sum |    # | N50Others |   Sum |    # | median |  MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:-----------|-------:|--------:|----------:|-----:|-----:|----------:|------:|-----:|-------:|-----:|------:|------:|--------------------:|----------:|----------:|
| MRXallP000 |   37.7 |  12.52% |      1370 | 2.9M | 2054 |      1375 | 2.81M | 4423 |   35.0 | 12.0 |   3.0 |  70.0 | "31,41,51,61,71,81" | 0:09'38'' | 0:00'56'' |


Table: statMRTadpoleAnchors.md

| Name       | CovCor | Mapped% | N50Anchor |   Sum |    # | N50Others |   Sum |    # | median |  MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:-----------|-------:|--------:|----------:|------:|-----:|----------:|------:|-----:|-------:|-----:|------:|------:|--------------------:|----------:|----------:|
| MRXallP000 |   37.7 |  25.24% |      1402 | 3.36M | 2334 |      1441 | 3.08M | 4755 |   40.0 | 15.0 |   3.0 |  80.0 | "31,41,51,61,71,81" | 0:02'44'' | 0:01'00'' |


Table: statMergeAnchors.md

| Name                     | Mapped% | N50Anchor |   Sum |    # | N50Others |   Sum |    # | median | MAD | lower | upper | RunTimeAN |
|:-------------------------|--------:|----------:|------:|-----:|----------:|------:|-----:|-------:|----:|------:|------:|----------:|
| 7_mergeAnchors           |   0.00% |      1421 | 5.83M | 4011 |      1463 | 9.33M | 6389 |    0.0 | 0.0 |   0.0 |   0.0 |           |
| 7_mergeKunitigsAnchors   |   0.00% |      1341 | 3.08M | 2236 |      1412 | 7.08M | 4980 |    0.0 | 0.0 |   0.0 |   0.0 |           |
| 7_mergeMRKunitigsAnchors |   0.00% |      1370 |  2.9M | 2054 |      1400 |  2.7M | 1937 |    0.0 | 0.0 |   0.0 |   0.0 |           |
| 7_mergeMRTadpoleAnchors  |   0.00% |      1402 | 3.36M | 2334 |      1462 | 2.96M | 2047 |    0.0 | 0.0 |   0.0 |   0.0 |           |
| 7_mergeTadpoleAnchors    |   0.00% |      1326 | 2.72M | 1991 |      1379 | 4.15M | 2985 |    0.0 | 0.0 |   0.0 |   0.0 |           |


Table: statOtherAnchors.md

| Name         | Mapped% | N50Anchor |    Sum |    # | N50Others |    Sum |     # | median |    MAD | lower |  upper | RunTimeAN |
|:-------------|--------:|----------:|-------:|-----:|----------:|-------:|------:|-------:|-------:|------:|-------:|----------:|
| 8_spades     |  57.11% |      1337 |  3.53M | 2550 |      2117 | 18.29M | 12439 |   15.0 |    7.0 |   3.0 |   30.0 | 0:01'52'' |
| 8_spades_MR  |  52.02% |      1562 |  5.63M | 3596 |      1844 |  6.29M |  8376 |   37.0 |   16.0 |   3.0 |   74.0 | 0:01'19'' |
| 8_megahit    |  51.50% |      1431 |  4.62M | 3170 |      1915 | 13.03M | 11703 |   18.0 |    8.0 |   3.0 |   36.0 | 0:01'40'' |
| 8_megahit_MR |  52.05% |      1506 |  5.13M | 3371 |      1727 |   5.9M |  7773 |   37.0 |   16.0 |   3.0 |   74.0 | 0:01'20'' |
| 8_platanus   |  10.23% |      1445 | 22.83K |   16 |      1491 | 31.39K |    21 | 2595.0 | 1269.0 |   3.0 | 5190.0 | 0:00'49'' |


Table: statFinal

| Name                     |  N50 |      Sum |     # |
|:-------------------------|-----:|---------:|------:|
| 7_mergeAnchors.anchors   | 1421 |  5833899 |  4011 |
| 7_mergeAnchors.others    | 1463 |  9329117 |  6389 |
| spades.contig            | 1482 | 34947423 | 40324 |
| spades.scaffold          | 1530 | 34956404 | 39630 |
| spades.non-contained     | 2456 | 21819608 |  9935 |
| spades_MR.contig         | 1526 | 17014440 | 14761 |
| spades_MR.scaffold       | 1533 | 17016301 | 14728 |
| spades_MR.non-contained  | 2054 | 11911056 |  6169 |
| megahit.contig           | 1296 | 29716540 | 33835 |
| megahit.non-contained    | 2173 | 17646505 |  8774 |
| megahit_MR.contig        | 1007 | 21946060 | 27194 |
| megahit_MR.non-contained | 1866 | 11034726 |  6124 |
| platanus.contig          |  115 |   448856 |  3286 |
| platanus.scaffold        |  783 |   141157 |   317 |
| platanus.non-contained   | 1491 |    54223 |    35 |


# Malaysia

```bash
mkdir -p ~/data/rna-seq/other_euk/Malaysia/2_illumina
cd ~/data/rna-seq/other_euk/Malaysia/2_illumina

ln -s ../../sra/SRR2917658_1.fastq.gz R1.fq.gz
ln -s ../../sra/SRR2917658_2.fastq.gz R2.fq.gz

```

```bash
WORKING_DIR=${HOME}/data/rna-seq/other_euk
BASE_NAME=Malaysia

cd ${WORKING_DIR}/${BASE_NAME}

rm -f *.sh
anchr template \
    . \
    --basename ${BASE_NAME} \
    --queue mpi \
    --genome 50_000_000 \
    --fastqc \
    --kmergenie \
    --insertsize \
    --sgapreqc \
    --trim2 "--dedupe" \
    --qual2 "20 25 30" \
    --len2 "60" \
    --filter "adapter,phix" \
    --mergereads \
    --ecphase "1,2,3" \
    --cov2 "all" \
    --tadpole \
    --trinity \
    --parallel 24 \
    --xmx 110g

bash 0_bsub.sh

bsub -q mpi -n 24 -J "${BASE_NAME}-8_trinity"     "bash 8_trinity.sh"
bsub -q mpi -n 24 -J "${BASE_NAME}-8_trinity_cor" "bash 8_trinity_cor.sh"
bsub -q mpi -n 24 -J "${BASE_NAME}-8_trinity_MR"  "bash 8_trinity_MR.sh"

find . -maxdepth 2 -name "*.fa" -or -name "*.fasta" |
    sort |
    tar -czvf ${BASE_NAME}.tar.gz -T -

```

Table: statInsertSize

| Group             |  Mean | Median | STDev | PercentOfPairs/PairOrientation |
|:------------------|------:|-------:|------:|-------------------------------:|
| R.tadpole.bbtools | 180.4 |    185 |  28.6 |                         26.74% |
| R.tadpole.picard  | 179.5 |    184 |  28.2 |                             FR |


Table: statReads

| Name       | N50 |   Sum |        # |
|:-----------|----:|------:|---------:|
| Illumina.R |  90 | 4.83G | 53663062 |
| trim.R     |  90 | 3.37G | 37798466 |
| Q20L60     |  90 | 3.32G | 37229880 |
| Q25L60     |  90 | 3.19G | 35874577 |
| Q30L60     |  90 | 2.91G | 33077099 |


Table: statTrimReads

| Name     | N50 |   Sum |        # |
|:---------|----:|------:|---------:|
| clumpify |  90 | 3.48G | 38687242 |
| trim     |  90 | 3.37G | 37798466 |
| filter   |  90 | 3.37G | 37798466 |
| R1       |  90 | 1.69G | 18899233 |
| R2       |  90 | 1.68G | 18899233 |
| Rs       |   0 |     0 |        0 |


```text
#R.trim
#Matched	19553	0.05054%
#Name	Reads	ReadsPct
```

```text
#R.filter
#Matched	0	0.00000%
#Name	Reads	ReadsPct
```

```text
#R.peaks
#k	31
#unique_kmers	201937956
#main_peak	844
#genome_size	514055
#haploid_genome_size	514055
#fold_coverage	459
#haploid_fold_coverage	459
#ploidy	1
#percent_repeat	92.358
#start	center	stop	max	volume
```


Table: statMergeReads

| Name          | N50 |     Sum |        # |
|:--------------|----:|--------:|---------:|
| clumped       |  90 |   3.37G | 37767158 |
| ecco          |  90 |   3.37G | 37767158 |
| eccc          |  90 |   3.37G | 37767158 |
| ecct          |  90 |   2.75G | 30846892 |
| extended      | 130 |   3.82G | 30846892 |
| merged.raw    | 225 |   3.07G | 14040349 |
| unmerged.raw  | 113 | 306.43M |  2766194 |
| unmerged.trim | 113 |  306.4M |  2765838 |
| M1            | 226 |    2.7G | 12322086 |
| U1            | 113 | 153.61M |  1382919 |
| U2            | 112 | 152.79M |  1382919 |
| Us            |   0 |       0 |        0 |
| M.cor         | 223 |   3.02G | 27410010 |

| Group              |  Mean | Median | STDev | PercentOfPairs |
|:-------------------|------:|-------:|------:|---------------:|
| M.ihist.merge1.txt | 136.8 |    144 |  25.6 |         14.89% |
| M.ihist.merge.txt  | 218.7 |    223 |  29.4 |         91.03% |


Table: statQuorum

| Name     | CovIn | CovOut | Discard% | Kmer | RealG |   EstG | Est/Real |   RunTime |
|:---------|------:|-------:|---------:|-----:|------:|-------:|---------:|----------:|
| Q0L0.R   |  67.4 |   57.6 |   14.48% | "63" |   50M | 67.27M |     1.35 | 0:06'02'' |
| Q20L60.R |  66.4 |   57.0 |   14.14% | "63" |   50M |  66.7M |     1.33 | 0:06'00'' |
| Q25L60.R |  63.8 |   55.0 |   13.79% | "63" |   50M | 65.27M |     1.31 | 0:05'50'' |
| Q30L60.R |  58.3 |   50.4 |   13.54% | "63" |   50M | 62.12M |     1.24 | 0:05'20'' |


Table: statKunitigsAnchors.md

| Name           | CovCor | Mapped% | N50Anchor |   Sum |    # | N50Others |   Sum |     # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|------:|-----:|----------:|------:|------:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q0L0XallP000   |   57.6 |  11.69% |      1282 | 3.37M | 2529 |      1313 | 7.92M | 10525 |   22.0 | 9.0 |   3.0 |  44.0 | "31,41,51,61,71,81" | 0:08'47'' | 0:01'25'' |
| Q20L60XallP000 |   57.0 |  11.99% |      1282 | 3.42M | 2565 |      1318 |    8M | 10622 |   22.0 | 9.0 |   3.0 |  44.0 | "31,41,51,61,71,81" | 0:08'41'' | 0:01'24'' |
| Q25L60XallP000 |   55.0 |  12.40% |      1288 | 3.43M | 2554 |      1319 | 7.96M | 10516 |   22.0 | 9.0 |   3.0 |  44.0 | "31,41,51,61,71,81" | 0:08'23'' | 0:01'23'' |
| Q30L60XallP000 |   50.4 |  12.90% |      1298 |  3.4M | 2512 |      1326 | 7.66M | 10099 |   22.0 | 9.0 |   3.0 |  44.0 | "31,41,51,61,71,81" | 0:07'44'' | 0:01'21'' |


Table: statTadpoleAnchors.md

| Name           | CovCor | Mapped% | N50Anchor |   Sum |    # | N50Others |   Sum |    # | median |  MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|------:|-----:|----------:|------:|-----:|-------:|-----:|------:|------:|--------------------:|----------:|----------:|
| Q0L0XallP000   |   57.6 |  15.17% |      1334 |  3.6M | 2610 |      1296 | 6.17M | 9410 |   30.0 | 11.0 |   3.0 |  60.0 | "31,41,51,61,71,81" | 0:03'38'' | 0:01'21'' |
| Q20L60XallP000 |   57.0 |  15.45% |      1334 | 3.62M | 2628 |      1298 | 6.19M | 9431 |   30.0 | 11.0 |   3.0 |  60.0 | "31,41,51,61,71,81" | 0:03'40'' | 0:01'21'' |
| Q25L60XallP000 |   55.0 |  15.86% |      1331 | 3.54M | 2568 |      1296 | 6.08M | 9252 |   30.0 | 11.0 |   3.0 |  60.0 | "31,41,51,61,71,81" | 0:03'26'' | 0:01'19'' |
| Q30L60XallP000 |   50.4 |  15.93% |      1326 | 3.38M | 2463 |      1298 | 5.63M | 8678 |   30.0 | 11.0 |   3.0 |  60.0 | "31,41,51,61,71,81" | 0:03'08'' | 0:01'15'' |


Table: statMRKunitigsAnchors.md

| Name       | CovCor | Mapped% | N50Anchor |   Sum |    # | N50Others |   Sum |    # | median |  MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:-----------|-------:|--------:|----------:|------:|-----:|----------:|------:|-----:|-------:|-----:|------:|------:|--------------------:|----------:|----------:|
| MRXallP000 |   60.3 |  17.37% |      1376 | 4.66M | 3299 |      1373 | 5.94M | 8311 |   37.0 | 14.0 |   3.0 |  74.0 | "31,41,51,61,71,81" | 0:14'43'' | 0:01'31'' |


Table: statMRTadpoleAnchors.md

| Name       | CovCor | Mapped% | N50Anchor |   Sum |    # | N50Others |   Sum |    # | median |  MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:-----------|-------:|--------:|----------:|------:|-----:|----------:|------:|-----:|-------:|-----:|------:|------:|--------------------:|----------:|----------:|
| MRXallP000 |   60.3 |  26.97% |      1420 | 5.58M | 3857 |      1448 | 6.66M | 9208 |   43.0 | 17.0 |   3.0 |  86.0 | "31,41,51,61,71,81" | 0:04'46'' | 0:01'19'' |


Table: statMergeAnchors.md

| Name                     | Mapped% | N50Anchor |   Sum |    # | N50Others |    Sum |     # | median | MAD | lower | upper | RunTimeAN |
|:-------------------------|--------:|----------:|------:|-----:|----------:|-------:|------:|-------:|----:|------:|------:|----------:|
| 7_mergeAnchors           |   0.00% |      1421 |  8.7M | 5958 |      1444 | 15.41M | 10621 |    0.0 | 0.0 |   0.0 |   0.0 |           |
| 7_mergeKunitigsAnchors   |   0.00% |      1319 |  4.4M | 3205 |      1359 |  9.71M |  7051 |    0.0 | 0.0 |   0.0 |   0.0 |           |
| 7_mergeMRKunitigsAnchors |   0.00% |      1376 | 4.66M | 3299 |      1399 |  5.72M |  4087 |    0.0 | 0.0 |   0.0 |   0.0 |           |
| 7_mergeMRTadpoleAnchors  |   0.00% |      1420 | 5.58M | 3857 |      1470 |  6.41M |  4385 |    0.0 | 0.0 |   0.0 |   0.0 |           |
| 7_mergeTadpoleAnchors    |   0.00% |      1358 |  4.4M | 3140 |      1337 |  7.25M |  5356 |    0.0 | 0.0 |   0.0 |   0.0 |           |


Table: statOtherAnchors.md

| Name         | Mapped% | N50Anchor |    Sum |    # | N50Others |    Sum |     # | median |   MAD | lower |  upper | RunTimeAN |
|:-------------|--------:|----------:|-------:|-----:|----------:|-------:|------:|-------:|------:|------:|-------:|----------:|
| 8_spades     |  65.87% |      1465 |  8.45M | 5656 |      2280 | 25.61M | 20132 |   23.0 |  12.0 |   3.0 |   46.0 | 0:02'28'' |
| 8_spades_MR  |  57.61% |      1569 | 10.02M | 6329 |      1955 |  12.2M | 15073 |   43.0 |  20.0 |   3.0 |   86.0 | 0:01'45'' |
| 8_megahit    |  58.94% |      1490 |   8.6M | 5664 |      1940 | 20.02M | 19146 |   25.0 |  13.0 |   3.0 |   50.0 | 0:02'14'' |
| 8_megahit_MR |  59.83% |      1515 |  9.27M | 6040 |      1813 |  12.1M | 14547 |   43.0 |  20.0 |   3.0 |   86.0 | 0:01'45'' |
| 8_platanus   |   6.29% |      1310 | 33.75K |   26 |      1454 | 44.37K |    43 | 1768.0 | 599.0 |   3.0 | 3536.0 | 0:00'49'' |


Table: statFinal

| Name                     |  N50 |      Sum |     # |
|:-------------------------|-----:|---------:|------:|
| 7_mergeAnchors.anchors   | 1421 |  8700135 |  5958 |
| 7_mergeAnchors.others    | 1444 | 15414243 | 10621 |
| spades.contig            | 1368 | 58471762 | 79749 |
| spades.scaffold          | 1380 | 58474792 | 79482 |
| spades.non-contained     | 2677 | 34052767 | 14690 |
| spades_MR.contig         | 1571 | 31916741 | 30291 |
| spades_MR.scaffold       | 1575 | 31923494 | 30219 |
| spades_MR.non-contained  | 2163 | 22224975 | 11070 |
| megahit.contig           | 1210 | 50681342 | 61966 |
| megahit.non-contained    | 2208 | 28615489 | 14011 |
| megahit_MR.contig        | 1056 | 41005917 | 49887 |
| megahit_MR.non-contained | 1956 | 21368109 | 11398 |
| platanus.contig          |  136 |   652201 |  4585 |
| platanus.scaffold        |  699 |   234981 |   511 |
| platanus.non-contained   | 1454 |    78124 |    55 |

