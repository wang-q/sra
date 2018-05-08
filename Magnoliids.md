# Magnoliids: anchr + spades + platanus

[TOC levels=1-3]: # " "
- [Magnoliids: anchr + spades + platanus](#magnoliids-anchr--spades--platanus)
- [FCM03, 荜菝](#fcm03-荜菝)
    - [FCM03: download](#fcm03-download)
    - [FCM03: template](#fcm03-template)
    - [FCM03: run](#fcm03-run)
- [FCM05, 三白草](#fcm05-三白草)
    - [FCM05: download](#fcm05-download)
    - [FCM05: template](#fcm05-template)
    - [FCM05: run](#fcm05-run)
- [FCM05B](#fcm05b)
    - [FCM05B: download](#fcm05b-download)
    - [FCM05B: template](#fcm05b-template)
    - [FCM05B: run](#fcm05b-run)
- [FCM05C](#fcm05c)
    - [FCM05C: download](#fcm05c-download)
    - [FCM05C: template](#fcm05c-template)
    - [FCM05C: run](#fcm05c-run)
- [FCM05D](#fcm05d)
    - [FCM05D: download](#fcm05d-download)
    - [FCM05D: template](#fcm05d-template)
    - [FCM05D: run](#fcm05d-run)
- [FCM05DSE](#fcm05dse)
    - [FCM05DSE: download](#fcm05dse-download)
    - [FCM05DSE: template](#fcm05dse-template)
    - [FCM05DSE: run](#fcm05dse-run)
- [FCM05DSE2](#fcm05dse2)
    - [FCM05DSE2: download](#fcm05dse2-download)
    - [FCM05DSE2: template](#fcm05dse2-template)
    - [FCM05DSE2: run](#fcm05dse2-run)
- [FCM05E](#fcm05e)
    - [FCM05E: download](#fcm05e-download)
    - [FCM05E: template](#fcm05e-template)
    - [FCM05E: run](#fcm05e-run)
- [FCM07, 蜡梅](#fcm07-蜡梅)
    - [FCM07: download](#fcm07-download)
    - [FCM07: template](#fcm07-template)
    - [FCM07: run](#fcm07-run)
- [FCM13, 红楠](#fcm13-红楠)
    - [FCM13: download](#fcm13-download)
    - [FCM13: template](#fcm13-template)
    - [FCM13: run](#fcm13-run)
- [FCM15, 金钱蒲](#fcm15-金钱蒲)
    - [FCM15: download](#fcm15-download)
    - [FCM15: template](#fcm15-template)
    - [FCM15: run](#fcm15-run)
- [FCM16, 金鱼藻](#fcm16-金鱼藻)
    - [FCM16: download](#fcm16-download)
    - [FCM16: template](#fcm16-template)
    - [FCM16: run](#fcm16-run)
- [Blasia](#blasia)
    - [Blasia: download](#blasia-download)
    - [Blasia: template](#blasia-template)
    - [Blasia: run](#blasia-run)
- [XIAN01](#xian01)
    - [XIAN01: download](#xian01-download)
    - [XIAN01: template](#xian01-template)
    - [XIAN01: run](#xian01-run)
- [Create tarballs](#create-tarballs)


# FCM03, 荜菝

* *Piper longum L.*
* Taxonomy ID: [49511](https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?mode=Info&id=49511)

## FCM03: download

* Illumina

```bash
mkdir -p ~/data/dna-seq/xjy2/FCM03/2_illumina
cd ~/data/dna-seq/xjy2/FCM03/2_illumina

ln -s ../../data/D7g7512_FCM03_R1_001.fastq.gz R1.fq.gz
ln -s ../../data/D7g7512_FCM03_R2_001.fastq.gz R2.fq.gz

```

## FCM03: template

* Rsync to hpcc

```bash
rsync -avP \
    ~/data/dna-seq/xjy2/data/ \
    wangq@202.119.37.251:data/dna-seq/xjy2/data

rsync -avP \
    ~/data/dna-seq/xjy2/FCM03/ \
    wangq@202.119.37.251:data/dna-seq/xjy2/FCM03

#rsync -avP wangq@202.119.37.251:data/dna-seq/xjy2/FCM03/ ~/data/dna-seq/xjy2/FCM03

```

```bash
WORKING_DIR=${HOME}/data/dna-seq/xjy2
BASE_NAME=FCM03

cd ${WORKING_DIR}/${BASE_NAME}

rm -f *.sh
anchr template \
    . \
    --basename ${BASE_NAME} \
    --queue largemem \
    --is_euk \
    --genome 500_000_000 \
    --fastqc \
    --kmergenie \
    --insertsize \
    --sgapreqc \
    --trim2 "--dedupe --tile" \
    --qual2 "25" \
    --len2 "60" \
    --filter "adapter,phix,artifact" \
    --mergereads \
    --ecphase "1,3" \
    --cov2 "all" \
    --tadpole \
    --fillanchor \
    --xmx 240g \
    --parallel 24

```

## FCM03: run

```bash
WORKING_DIR=${HOME}/data/dna-seq/xjy2
BASE_NAME=FCM03

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
| R.tadpole.bbtools | 312.8 |    327 |  78.4 |                          9.43% |
| R.tadpole.picard  | 307.9 |    322 |  80.3 |                             FR |


Table: statReads

| Name       | N50 |    Sum |         # |
|:-----------|----:|-------:|----------:|
| Illumina.R | 151 | 23.45G | 155328164 |
| trim.R     | 150 | 17.58G | 119982980 |
| Q25L60     | 150 | 16.93G | 117188875 |


Table: statTrimReads

| Name           | N50 |    Sum |         # |
|:---------------|----:|-------:|----------:|
| clumpify       | 151 |  19.3G | 127822412 |
| filteredbytile | 151 |  18.3G | 121223970 |
| trim           | 150 | 17.58G | 119983024 |
| filter         | 150 | 17.58G | 119982980 |
| R1             | 150 |  8.86G |  59991490 |
| R2             | 150 |  8.72G |  59991490 |
| Rs             |   0 |      0 |         0 |


```text
#R.trim
#Matched	891366	0.73531%
#Name	Reads	ReadsPct
Reverse_adapter	314661	0.25957%
pcr_dimer	164954	0.13607%
TruSeq_Universal_Adapter	135482	0.11176%
```

```text
#R.filter
#Matched	22	0.00002%
#Name	Reads	ReadsPct
```

```text
#R.peaks
#k	31
#unique_kmers	1258767196
#main_peak	12
#genome_size	518579163
#haploid_genome_size	518579163
#fold_coverage	12
#haploid_fold_coverage	12
#ploidy	1
#percent_repeat	12.562
#start	center	stop	max	volume
```


Table: statMergeReads

| Name          | N50 |    Sum |         # |
|:--------------|----:|-------:|----------:|
| clumped       | 150 | 17.48G | 119257308 |
| ecco          | 150 | 17.48G | 119257308 |
| ecct          | 150 | 13.07G |  88723044 |
| extended      | 190 | 16.25G |  88723044 |
| merged.raw    | 388 | 13.23G |  35454443 |
| unmerged.raw  | 180 |  3.09G |  17814158 |
| unmerged.trim | 180 |  3.09G |  17813794 |
| M1            | 387 | 11.97G |  32220483 |
| U1            | 182 |  1.57G |   8906897 |
| U2            | 178 |  1.52G |   8906897 |
| Us            |   0 |      0 |         0 |
| M.cor         | 371 | 15.09G |  82254760 |

| Group              |  Mean | Median | STDev | PercentOfPairs |
|:-------------------|------:|-------:|------:|---------------:|
| M.ihist.merge1.txt | 227.5 |    231 |  37.6 |         13.49% |
| M.ihist.merge.txt  | 373.1 |    380 |  67.2 |         79.92% |


Table: statQuorum

| Name     | CovIn | CovOut | Discard% |  Kmer | RealG |    EstG | Est/Real |   RunTime |
|:---------|------:|-------:|---------:|------:|------:|--------:|---------:|----------:|
| Q0L0.R   |  35.2 |   29.6 |   15.80% | "105" |  500M |  546.2M |     1.09 | 0:34'42'' |
| Q25L60.R |  33.9 |   29.7 |   12.37% | "105" |  500M | 542.67M |     1.09 | 0:53'24'' |


Table: statKunitigsAnchors.md

| Name           | CovCor | Mapped% | N50Anchor |    Sum |     # | N50Others |    Sum |      # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|-------:|------:|----------:|-------:|-------:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q0L0XallP000   |   29.6 |  18.50% |      1489 | 86.95M | 56244 |      1176 |  54.9M | 164339 |   17.0 | 5.0 |   3.0 |  34.0 | "31,41,51,61,71,81" | 1:28'38'' | 0:18'13'' |
| Q25L60XallP000 |   29.7 |  18.77% |      1519 |  95.9M | 61132 |      1125 | 45.23M | 168819 |   18.0 | 5.0 |   3.0 |  36.0 | "31,41,51,61,71,81" | 1:28'17'' | 0:19'20'' |


Table: statTadpoleAnchors.md

| Name           | CovCor | Mapped% | N50Anchor |    Sum |     # | N50Others |    Sum |      # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|-------:|------:|----------:|-------:|-------:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q0L0XallP000   |   29.6 |  23.67% |      1508 | 93.41M | 60125 |      1133 |  42.1M | 158052 |   18.0 | 4.0 |   3.0 |  36.0 | "31,41,51,61,71,81" | 0:38'26'' | 0:16'58'' |
| Q25L60XallP000 |   29.7 |  23.90% |      1536 | 100.2M | 63583 |      1085 | 34.72M | 161616 |   19.0 | 4.0 |   3.0 |  38.0 | "31,41,51,61,71,81" | 0:39'42'' | 0:17'36'' |


Table: statMRKunitigsAnchors.md

| Name       | CovCor | Mapped% | N50Anchor |    Sum |     # | N50Others |    Sum |      # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:-----------|-------:|--------:|----------:|-------:|------:|----------:|-------:|-------:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| MRXallP000 |   30.2 |  16.54% |      1536 | 89.36M | 56604 |      1187 | 38.48M | 132794 |   20.0 | 5.0 |   3.0 |  40.0 | "31,41,51,61,71,81" | 1:46'32'' | 0:12'18'' |


Table: statMRTadpoleAnchors.md

| Name       | CovCor | Mapped% | N50Anchor |    Sum |     # | N50Others |    Sum |      # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:-----------|-------:|--------:|----------:|-------:|------:|----------:|-------:|-------:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| MRXallP000 |   30.2 |  21.00% |      1548 | 95.72M | 60300 |      1192 | 38.69M | 135006 |   20.0 | 5.0 |   3.0 |  40.0 | "31,41,51,61,71,81" | 0:44'58'' | 0:12'43'' |


Table: statMergeAnchors.md

| Name                     | Mapped% | N50Anchor |     Sum |     # | N50Others |    Sum |     # | median | MAD | lower | upper | RunTimeAN |
|:-------------------------|--------:|----------:|--------:|------:|----------:|-------:|------:|-------:|----:|------:|------:|----------:|
| 7_mergeAnchors           |   0.00% |      1607 | 128.37M | 78171 |      1226 | 71.24M | 56247 |    0.0 | 0.0 |   0.0 |   0.0 |           |
| 7_mergeKunitigsAnchors   |   0.00% |      1523 |  97.47M | 61945 |      1233 | 50.07M | 40075 |    0.0 | 0.0 |   0.0 |   0.0 |           |
| 7_mergeMRKunitigsAnchors |   0.00% |      1536 |  89.36M | 56604 |      1246 | 34.68M | 27876 |    0.0 | 0.0 |   0.0 |   0.0 |           |
| 7_mergeMRTadpoleAnchors  |   0.00% |      1548 |  95.72M | 60300 |      1253 | 35.17M | 28046 |    0.0 | 0.0 |   0.0 |   0.0 |           |
| 7_mergeTadpoleAnchors    |   0.00% |      1540 | 102.32M | 64747 |      1189 | 38.35M | 31545 |    0.0 | 0.0 |   0.0 |   0.0 |           |


Table: statOtherAnchors.md

| Name         | Mapped% | N50Anchor |     Sum |      # | N50Others |     Sum |      # | median | MAD | lower | upper | RunTimeAN |
|:-------------|--------:|----------:|--------:|-------:|----------:|--------:|-------:|-------:|----:|------:|------:|----------:|
| 8_spades     |  55.10% |      2423 | 313.73M | 142868 |      1547 | 130.83M | 238792 |   16.0 | 4.0 |   3.0 |  32.0 | 1:07'33'' |
| 8_spades_MR  |  59.29% |      2656 | 341.75M | 146153 |      1305 | 104.56M | 254331 |   18.0 | 5.0 |   3.0 |  36.0 | 1:02'19'' |
| 8_megahit    |  47.42% |      2004 | 231.99M | 121526 |      1427 | 133.17M | 236416 |   16.0 | 4.0 |   3.0 |  32.0 | 0:43'20'' |
| 8_megahit_MR |  50.77% |      1825 | 244.13M | 137315 |      1393 | 145.89M | 289311 |   17.0 | 6.0 |   3.0 |  34.0 | 0:32'23'' |
| 8_platanus   |  15.30% |      1804 |  88.79M |  50069 |      1200 |  36.95M | 107971 |   18.0 | 3.0 |   3.0 |  36.0 | 0:08'54'' |


Table: statFinal

| Name                     |  N50 |       Sum |        # |
|:-------------------------|-----:|----------:|---------:|
| 7_mergeAnchors.anchors   | 1607 | 128365694 |    78171 |
| 7_mergeAnchors.others    | 1226 |  71243406 |    56247 |
| anchorLong               |    0 |         0 |        0 |
| spades.contig            | 3093 | 696591270 |  1699642 |
| spades.scaffold          | 3673 | 697655012 |  1687380 |
| spades.non-contained     | 7692 | 444579105 |    96376 |
| spades_MR.contig         | 4864 | 529003283 |   320441 |
| spades_MR.scaffold       | 6301 | 530232461 |   306215 |
| spades_MR.non-contained  | 6367 | 446338736 |   110685 |
| megahit.contig           | 2766 | 495339976 |   413844 |
| megahit.non-contained    | 4245 | 365188501 |   115480 |
| megahit_MR.contig        | 1616 | 607842599 |   571311 |
| megahit_MR.non-contained | 2933 | 390090213 |   156341 |
| platanus.contig          |   78 | 792681578 | 10920724 |
| platanus.scaffold        |  398 | 346736194 |  1173163 |
| platanus.non-contained   | 2319 | 125741365 |    58462 |

# FCM05, 三白草

* *Saururus chinensis*
* 
* Taxonomy ID: [54806](https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?mode=Info&id=54806)

## FCM05: download

```bash
mkdir -p ~/data/dna-seq/xjy2/FCM05/2_illumina
cd ~/data/dna-seq/xjy2/FCM05/2_illumina

ln -s ../../data/D7g7512_FCM05_R1_001.fastq.gz R1.fq.gz
ln -s ../../data/D7g7512_FCM05_R2_001.fastq.gz R2.fq.gz

```

## FCM05: template

* Rsync to hpcc

```bash
rsync -avP \
    ~/data/dna-seq/xjy2/data/ \
    wangq@202.119.37.251:data/dna-seq/xjy2/data

rsync -avP \
    ~/data/dna-seq/xjy2/FCM05/ \
    wangq@202.119.37.251:data/dna-seq/xjy2/FCM05

#rsync -avP wangq@202.119.37.251:data/dna-seq/xjy2/FCM05/ ~/data/dna-seq/xjy2/FCM05

```

```bash
WORKING_DIR=${HOME}/data/dna-seq/xjy2
BASE_NAME=FCM05
QUEUE_NAME=largemem

cd ${WORKING_DIR}/${BASE_NAME}

anchr template \
    . \
    --basename ${BASE_NAME} \
    --genome 530000000 \
    --is_euk \
    --trim2 "--uniq --bbduk" \
    --cov2 "all" \
    --qual2 "25 30" \
    --len2 "60" \
    --filter "adapter,phix,artifact" \
    --tadpole \
    --mergereads \
    --tile \
    --ecphase "1,2,3" \
    --parallel 24

```

## FCM05: run

```bash
# Illumina QC
bsub -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-2_fastqc" "bash 2_fastqc.sh"
bsub -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-2_kmergenie" "bash 2_kmergenie.sh"

# preprocess Illumina reads
bsub -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-2_trim" "bash 2_trim.sh"

# reads stats
bsub -w "ended(${BASE_NAME}-2_trim)" \
    -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-9_statReads" "bash 9_statReads.sh"

# merge reads
bsub -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-2_mergereads" "bash 2_mergereads.sh"

# insert size
bsub -w "done(${BASE_NAME}-2_trim)" \
    -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-2_insertSize" "bash 2_insertSize.sh"

# spades and platanus
bsub -w "done(${BASE_NAME}-2_trim)" \
    -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-8_spades" "bash 8_spades.sh"

bsub -w "done(${BASE_NAME}-2_trim)" \
    -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-8_platanus" "bash 8_platanus.sh"

# quorum
bsub -w "done(${BASE_NAME}-2_trim)" \
    -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-2_quorum" "bash 2_quorum.sh"
bsub -w "done(${BASE_NAME}-2_quorum)" \
    -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-9_statQuorum" "bash 9_statQuorum.sh"

# down sampling, k-unitigs and anchors
bsub -w "done(${BASE_NAME}-2_quorum)" \
    -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-4_downSampling" "bash 4_downSampling.sh"

bsub -w "done(${BASE_NAME}-4_downSampling)" \
    -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-4_kunitigs" "bash 4_kunitigs.sh"
bsub -w "done(${BASE_NAME}-4_kunitigs)" \
    -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-4_anchors" "bash 4_anchors.sh"
bsub -w "done(${BASE_NAME}-4_anchors)" \
    -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-9_statAnchors_4_kunitigs" "bash 9_statAnchors.sh 4_kunitigs statKunitigsAnchors.md"

bsub -w "done(${BASE_NAME}-4_downSampling)" \
    -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-4_tadpole" "bash 4_tadpole.sh"
bsub -w "done(${BASE_NAME}-4_tadpole)" \
    -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-4_tadpoleAnchors" "bash 4_tadpoleAnchors.sh"
bsub -w "done(${BASE_NAME}-4_tadpoleAnchors)" \
    -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-9_statAnchors_4_tadpole" "bash 9_statAnchors.sh 4_tadpole statTadpoleAnchors.md"

# merge anchors
bsub -w "done(${BASE_NAME}-4_anchors)" \
    -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-6_mergeAnchors_4_kunitigs" "bash 6_mergeAnchors.sh 4_kunitigs 6_mergeKunitigsAnchors"

bsub -w "done(${BASE_NAME}-4_tadpoleAnchors)" \
    -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-6_mergeAnchors_4_tadpole" "bash 6_mergeAnchors.sh 4_tadpole 6_mergeTadpoleAnchors"

bsub -w "done(${BASE_NAME}-6_mergeAnchors_4_kunitigs) && done(${BASE_NAME}-6_mergeAnchors_4_tadpole)" \
    -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-6_mergeAnchors" "bash 6_mergeAnchors.sh 6_mergeAnchors"

# stats
# bash 9_statFinal.sh

# bash 0_cleanup.sh

```

| Name     | N50 |    Sum |         # |
|:---------|----:|-------:|----------:|
| Illumina | 151 | 24.45G | 161903886 |
| uniq     | 151 | 19.93G | 131977706 |
| bbduk    | 150 | 19.71G | 131759380 |
| Q25L60   | 150 |    18G | 124630562 |
| Q30L60   | 150 | 17.27G | 122989806 |

| Group  |  Mean | Median | STDev | PercentOfPairs |
|:-------|------:|-------:|------:|---------------:|
| Q25L60 | 337.1 |    343 |  66.7 |          8.07% |
| Q30L60 | 337.7 |    344 |  66.5 |          8.87% |

| Name           | N50 |    Sum |         # |
|:---------------|----:|-------:|----------:|
| clumped        | 151 | 18.27G | 120984318 |
| filteredbytile | 151 | 17.33G | 114744484 |
| trimmed        | 150 | 16.69G | 113590964 |
| filtered       | 150 | 16.69G | 113588460 |
| ecco           | 150 | 16.69G | 113588460 |
| eccc           | 150 | 16.69G | 113588460 |
| ecct           | 150 | 13.66G |  92499802 |
| extended       | 190 | 17.06G |  92499802 |
| merged         | 389 | 14.98G |  39865434 |
| unmerged.raw   | 179 |   2.2G |  12768934 |
| unmerged       | 175 |  1.94G |  11960344 |

| Group            |  Mean | Median | STDev | PercentOfPairs |
|:-----------------|------:|-------:|------:|---------------:|
| ihist.merge1.txt | 226.9 |    230 |  38.7 |         13.42% |
| ihist.merge.txt  | 375.7 |    381 |  64.7 |         86.20% |

```text
#mergeReads
#Matched	1259	0.00111%
#Name	Reads	ReadsPct
TruSeq_Universal_Adapter	408	0.00036%
contam_256	247	0.00022%
contam_32	111	0.00010%
```

| Name   | CovIn | CovOut | Discard% | AvgRead |  Kmer | RealG |    EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|------:|------:|--------:|---------:|----------:|
| Q25L60 |  34.0 |   28.5 |   16.14% |     144 | "105" |  530M | 576.67M |     1.09 | 0:35'22'' |
| Q30L60 |  32.6 |   28.4 |   12.84% |     141 |  "99" |  530M | 571.22M |     1.08 | 0:33'23'' |

| Name           | CovCor | Mapped% | N50Anchor |     Sum |     # | N50Others |    Sum |      # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|--------:|------:|----------:|-------:|-------:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q25L60XallP000 |   28.5 |  48.25% |      3301 | 258.31M | 97322 |      1033 | 26.16M | 231579 |   21.0 | 4.0 |   3.0 |  42.0 | "31,41,51,61,71,81" | 2:59'12'' | 1:22'12'' |
| Q30L60XallP000 |   28.4 |  49.22% |      3331 |  258.2M | 96782 |      1035 | 26.43M | 232321 |   21.0 | 4.0 |   3.0 |  42.0 | "31,41,51,61,71,81" | 2:56'33'' | 1:24'35'' |

| Name           | CovCor | Mapped% | N50Anchor |     Sum |     # | N50Others |    Sum |      # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|--------:|------:|----------:|-------:|-------:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q25L60XallP000 |   28.5 |  52.85% |      3331 | 251.31M | 94407 |      1036 | 27.82M | 238909 |   21.0 | 4.0 |   3.0 |  42.0 | "31,41,51,61,71,81" | 1:45'58'' | 1:26'51'' |
| Q30L60XallP000 |   28.4 |  53.40% |      3313 | 249.68M | 94062 |      1038 | 28.28M | 242072 |   21.0 | 4.0 |   3.0 |  42.0 | "31,41,51,61,71,81" | 1:45'20'' | 1:28'22'' |

| Name                           |   N50 |       Sum |       # |
|:-------------------------------|------:|----------:|--------:|
| 6_mergeKunitigsAnchors.anchors |  3416 | 263839720 |   97466 |
| 6_mergeKunitigsAnchors.others  |  1088 |  24257704 |   20880 |
| 6_mergeTadpoleAnchors.anchors  |  3556 | 271161640 |   98017 |
| 6_mergeTadpoleAnchors.others   |  1075 |  33030100 |   28010 |
| 6_mergeAnchors.anchors         |  3556 | 271184729 |   98023 |
| 6_mergeAnchors.others          |  1075 |  33040330 |   28018 |
| tadpole.Q25L60                 |   326 | 330730958 | 1138290 |
| tadpole.Q30L60                 |   337 | 324431548 | 1098778 |
| spades.contig                  |  6027 | 762855022 | 1151658 |
| spades.scaffold                |  7135 | 763499437 | 1143207 |
| spades.non-contained           | 14862 | 526944481 |   83659 |
| platanus.contig                |    87 | 755045375 | 9961318 |
| platanus.scaffold              |   812 | 350960177 | 1074557 |
| platanus.non-contained         |  4544 | 167149337 |   50906 |

# FCM05B

## FCM05B: download

* Illumina

```bash
mkdir -p ${HOME}/data/dna-seq/xjy2/FCM05B/2_illumina
cd ${HOME}/data/dna-seq/xjy2/FCM05B/2_illumina

ln -s ../../data/FCM05_H3T7VDMXX_L1_1.clean.fq.gz R1.fq.gz
ln -s ../../data/FCM05_H3T7VDMXX_L1_2.clean.fq.gz R2.fq.gz

```

## FCM05B: template

* Rsync to hpcc

```bash
rsync -avP \
    ~/data/dna-seq/xjy2/data/ \
    wangq@202.119.37.251:data/dna-seq/xjy2/data

rsync -avP \
    ~/data/dna-seq/xjy2/FCM05B/ \
    wangq@202.119.37.251:data/dna-seq/xjy2/FCM05B

#rsync -avP wangq@202.119.37.251:data/dna-seq/xjy2/FCM05B/ ~/data/dna-seq/xjy2/FCM05B

```

```bash
WORKING_DIR=${HOME}/data/dna-seq/xjy2
BASE_NAME=FCM05B
QUEUE_NAME=largemem

cd ${WORKING_DIR}/${BASE_NAME}

anchr template \
    . \
    --basename ${BASE_NAME} \
    --genome 530000000 \
    --is_euk \
    --trim2 "--uniq --bbduk" \
    --cov2 "all" \
    --qual2 "25 30" \
    --len2 "60" \
    --filter "adapter,phix,artifact" \
    --tadpole \
    --mergereads \
    --tile \
    --ecphase "1,3" \
    --parallel 24

```

## FCM05B: run

| Name     | N50 |    Sum |         # |
|:---------|----:|-------:|----------:|
| Illumina | 150 | 21.18G | 141210762 |
| uniq     | 150 | 20.22G | 134815654 |
| bbduk    | 150 | 20.19G | 134812846 |
| Q25L60   | 150 | 19.63G | 132483396 |
| Q30L60   | 150 | 18.51G | 129153502 |

| Group  |  Mean | Median | STDev | PercentOfPairs |
|:-------|------:|-------:|------:|---------------:|
| Q25L60 | 239.5 |    237 |  52.2 |          8.36% |
| Q30L60 | 239.9 |    237 |  52.2 |          9.10% |

| Name           | N50 |     Sum |         # |
|:---------------|----:|--------:|----------:|
| clumped        | 150 |  19.78G | 131834220 |
| filteredbytile | 150 |   18.9G | 126007332 |
| trimmed        | 150 |  18.67G | 125365952 |
| filtered       | 150 |  18.67G | 125364714 |
| ecco           | 150 |  18.67G | 125364714 |
| ecct           | 150 |   14.3G |  95801430 |
| extended       | 190 |  17.85G |  95801430 |
| merged         | 289 |  13.11G |  46426096 |
| unmerged.raw   | 186 | 514.28M |   2949238 |
| unmerged       | 181 |  425.4M |   2646556 |

| Group            |  Mean | Median | STDev | PercentOfPairs |
|:-----------------|------:|-------:|------:|---------------:|
| ihist.merge1.txt | 226.6 |    230 |  35.0 |         69.60% |
| ihist.merge.txt  | 282.3 |    280 |  51.3 |         96.92% |

```text
#mergeReads
#Matched	692	0.00055%
#Name	Reads	ReadsPct
contam_32	142	0.00011%
Reverse_adapter	135	0.00011%
```

| Name   | CovIn | CovOut | Discard% | AvgRead |  Kmer | RealG |    EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|------:|------:|--------:|---------:|----------:|
| Q25L60 |  37.0 |   29.0 |   21.70% |     148 | "105" |  530M | 662.57M |     1.25 | 0:37'53'' |
| Q30L60 |  34.9 |   28.5 |   18.29% |     144 | "105" |  530M | 652.62M |     1.23 | 0:41'18'' |

| Name           | CovCor | Mapped% | N50Anchor |     Sum |     # | N50Others |    Sum |      # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|--------:|------:|----------:|-------:|-------:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q25L60XallP000 |   29.0 |  47.94% |      3674 |  277.3M | 98760 |      1014 | 16.36M | 228951 |   21.0 | 4.0 |   3.0 |  42.0 | "31,41,51,61,71,81" | 3:16'18'' | 1:39'51'' |
| Q30L60XallP000 |   28.5 |  48.90% |      3716 | 278.56M | 98439 |      1013 |  15.2M | 231098 |   21.0 | 4.0 |   3.0 |  42.0 | "31,41,51,61,71,81" | 3:13'30'' | 1:41'42'' |

| Name           | CovCor | Mapped% | N50Anchor |     Sum |     # | N50Others |    Sum |      # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|--------:|------:|----------:|-------:|-------:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q25L60XallP000 |   29.0 |  51.99% |      3760 | 262.98M | 92529 |      1021 | 24.27M | 229768 |   22.0 | 3.0 |   4.3 |  44.0 | "31,41,51,61,71,81" | 1:54'08'' | 1:33'37'' |
| Q30L60XallP000 |   28.5 |  52.64% |      3710 | 264.76M | 94257 |      1017 | 19.92M | 235820 |   21.0 | 3.0 |   4.0 |  42.0 | "31,41,51,61,71,81" | 1:52'28'' | 1:35'55'' |

| Name                           |   N50 |        Sum |       # |
|:-------------------------------|------:|-----------:|--------:|
| 6_mergeKunitigsAnchors.anchors |  3789 |  282595595 |   98835 |
| 6_mergeKunitigsAnchors.others  |  1037 |   13358375 |   12346 |
| 6_mergeTadpoleAnchors.anchors  |  3865 |  288963542 |  100028 |
| 6_mergeTadpoleAnchors.others   |  1048 |   25934259 |   23584 |
| 6_mergeAnchors.anchors         |  3865 |  288983555 |  100038 |
| 6_mergeAnchors.others          |  1048 |   25938378 |   23588 |
| tadpole.Q25L60                 |   271 |  390486342 | 1442650 |
| tadpole.Q30L60                 |   277 |  383193489 | 1401543 |
| spades.contig                  |  1114 | 1149023785 | 2210954 |
| spades.scaffold                |  1119 | 1149700814 | 2203789 |
| spades.non-contained           | 10634 |  589069452 |  124736 |
| platanus.contig                |    90 |  754846112 | 9790115 |
| platanus.scaffold              |   996 |  356276187 | 1025911 |
| platanus.non-contained         |  3984 |  177930474 |   59216 |


# FCM05C

## FCM05C: download

* Illumina

```bash
mkdir -p ${HOME}/data/dna-seq/xjy2/FCM05C/2_illumina
cd ${HOME}/data/dna-seq/xjy2/FCM05C/2_illumina

ln -s ../../data/FCM05_H3TC3DMXX_L1_1.clean.fq.gz R1.fq.gz
ln -s ../../data/FCM05_H3TC3DMXX_L1_2.clean.fq.gz R2.fq.gz

```

## FCM05C: template

* Rsync to hpcc

```bash
rsync -avP \
    ~/data/dna-seq/xjy2/data/ \
    wangq@202.119.37.251:data/dna-seq/xjy2/data

rsync -avP \
    ~/data/dna-seq/xjy2/FCM05C/ \
    wangq@202.119.37.251:data/dna-seq/xjy2/FCM05C

#rsync -avP wangq@202.119.37.251:data/dna-seq/xjy2/FCM05C/ ~/data/dna-seq/xjy2/FCM05C

```

```bash
WORKING_DIR=${HOME}/data/dna-seq/xjy2
BASE_NAME=FCM05C
QUEUE_NAME=largemem

cd ${WORKING_DIR}/${BASE_NAME}

anchr template \
    . \
    --basename ${BASE_NAME} \
    --genome 530000000 \
    --is_euk \
    --trim2 "--uniq --bbduk" \
    --cov2 "all" \
    --qual2 "25 30" \
    --len2 "60" \
    --filter "adapter,phix,artifact" \
    --tadpole \
    --mergereads \
    --tile \
    --ecphase "1,3" \
    --parallel 24

```

## FCM05C: run

| Name     | N50 |    Sum |         # |
|:---------|----:|-------:|----------:|
| Illumina | 150 |  78.1G | 520659000 |
| uniq     | 150 | 73.33G | 488862228 |
| bbduk    | 150 | 73.24G | 488857586 |
| Q25L60   | 150 | 71.77G | 484415246 |
| Q30L60   | 150 | 68.87G | 477261181 |

| Name           | N50 |    Sum |         # |
|:---------------|----:|-------:|----------:|
| clumped        | 150 | 71.69G | 477958536 |
| filteredbytile | 150 | 68.16G | 454410152 |
| trimmed        | 150 | 67.55G | 453564752 |
| filtered       | 150 | 67.55G | 453559670 |
| ecco           | 150 | 67.55G | 453559670 |
| ecct           | 150 | 54.14G | 362477206 |
| extended       | 190 | 67.56G | 362477206 |
| merged         | 290 | 49.79G | 175770628 |
| unmerged.raw   | 187 |  1.91G |  10935950 |
| unmerged       | 182 |   1.7G |  10561948 |

| Group            |  Mean | Median | STDev | PercentOfPairs |
|:-----------------|------:|-------:|------:|---------------:|
| ihist.merge1.txt | 227.2 |    231 |  34.9 |         70.56% |
| ihist.merge.txt  | 283.3 |    281 |  51.3 |         96.98% |

```text
#mergeReads
#Matched	2726	0.00060%
#Name	Reads	ReadsPct
Reverse_adapter	683	0.00015%
TruSeq_Universal_Adapter	627	0.00014%
contam_32	381	0.00008%
contam_159	167	0.00004%
contam_1	100	0.00002%
```

| Name   | CovIn | CovOut | Discard% | AvgRead |  Kmer | RealG |  EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|------:|------:|------:|---------:|----------:|
| Q25L60 | 135.4 |  112.4 |   16.97% |     147 | "105" |  530M | 1.06G |     2.00 | 2:22'42'' |
| Q30L60 | 130.0 |  111.3 |   14.38% |     144 | "105" |  530M | 1.03G |     1.95 | 2:16'49'' |


# FCM05D

## FCM05D: download

* Illumina

```bash
mkdir -p ${HOME}/data/dna-seq/xjy2/FCM05D/2_illumina
cd ${HOME}/data/dna-seq/xjy2/FCM05D/2_illumina

gzip -d -c \
    ../../FCM05B/2_illumina/R1.fq.gz \
    ../../FCM05C/2_illumina/R1.fq.gz \
    > R1.fq

gzip -d -c \
    ../../FCM05B/2_illumina/R2.fq.gz \
    ../../FCM05C/2_illumina/R2.fq.gz \
    > R2.fq

find . -name "*.fq" | parallel -j 2 pigz -p 8

```

## FCM05D: template

* Rsync to hpcc

```bash
rsync -avP \
    ~/data/dna-seq/xjy2/data/ \
    wangq@202.119.37.251:data/dna-seq/xjy2/data

rsync -avP \
    ~/data/dna-seq/xjy2/FCM05D/ \
    wangq@202.119.37.251:data/dna-seq/xjy2/FCM05D

#rsync -avP wangq@202.119.37.251:data/dna-seq/xjy2/FCM05D/ ~/data/dna-seq/xjy2/FCM05D

```

```bash
WORKING_DIR=${HOME}/data/dna-seq/xjy2
BASE_NAME=FCM05D
QUEUE_NAME=largemem

cd ${WORKING_DIR}/${BASE_NAME}

anchr template \
    . \
    --basename ${BASE_NAME} \
    --genome 530000000 \
    --is_euk \
    --trim2 "--uniq " \
    --cov2 "40 80 all" \
    --qual2 "25" \
    --len2 "60" \
    --parallel 24

```

## FCM05D: run

Same as [FCM05: run](#fcm05-run)


| Name     | N50 |    Sum |         # |
|:---------|----:|-------:|----------:|
| Illumina | 150 | 99.28G | 661869762 |
| uniq     | 150 | 93.38G | 622507614 |
| Q25L60   | 150 | 91.33G | 615818436 |
| Q30L60   | 150 | 87.31G | 605367143 |

| Name   | CovIn | CovOut | Discard% | AvgRead |  Kmer | RealG | EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|------:|------:|-----:|---------:|----------:|
| Q25L60 | 172.3 |  141.3 |   18.03% |     148 | "105" |  530M | 1.2G |     2.26 | 3:24'51'' |

```text

```

# FCM05DSE

## FCM05DSE: download

* Illumina

```bash
mkdir -p ${HOME}/data/dna-seq/xjy2/FCM05DSE/2_illumina
cd ${HOME}/data/dna-seq/xjy2/FCM05DSE/2_illumina

ln -s ../../FCM05D/2_illumina/R1.fq.gz R1.fq.gz

```

## FCM05DSE: template

* Rsync to hpcc

```bash
rsync -avP \
    ~/data/dna-seq/xjy2/data/ \
    wangq@202.119.37.251:data/dna-seq/xjy2/data

rsync -avP \
    ~/data/dna-seq/xjy2/FCM05DSE/ \
    wangq@202.119.37.251:data/dna-seq/xjy2/FCM05DSE

#rsync -avP wangq@202.119.37.251:data/dna-seq/xjy2/FCM05DSE/ ~/data/dna-seq/xjy2/FCM05DSE

```

```bash
WORKING_DIR=${HOME}/data/dna-seq/xjy2
BASE_NAME=FCM05DSE
QUEUE_NAME=largemem

cd ${WORKING_DIR}/${BASE_NAME}

anchr template \
    . \
    --se \
    --basename ${BASE_NAME} \
    --genome 530000000 \
    --is_euk \
    --trim2 "--uniq " \
    --cov2 "40 all" \
    --qual2 "25 30" \
    --len2 "60" \
    --parallel 24

```

## FCM05DSE: run

Same as [FCM05: run](#fcm05-run)

| Name     | N50 |    Sum |         # |
|:---------|----:|-------:|----------:|
| Illumina | 150 | 49.64G | 330934881 |
| uniq     | 150 | 41.08G | 273868105 |
| Q25L60   | 150 |  40.5G | 273078531 |
| Q30L60   | 150 | 38.98G | 267984250 |

| Name   | CovIn | CovOut | Discard% | AvgRead | Kmer | RealG |    EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|-----:|------:|--------:|---------:|----------:|
| Q25L60 |  76.9 |   61.3 |   20.36% |     148 | "31" |  530M | 810.42M |     1.53 | 1:33'00'' |
| Q30L60 |  74.1 |   60.9 |   17.75% |     145 | "31" |  530M | 800.16M |     1.51 | 1:34'58'' |

| Name           | CovCor | Mapped% | N50Anchor |     Sum |      # | N50Others |    Sum |     # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|--------:|-------:|----------:|-------:|------:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q25L60X40P000  |   40.0 |  48.03% |      3551 |  274.6M |  97917 |      1078 | 19.67M | 16545 |   31.0 | 4.0 |   6.3 |  62.0 | "31,41,51,61,71,81" | 4:09'06'' | 1:49'31'' |
| Q25L60XallP000 |   61.3 |  47.33% |      3291 | 272.11M | 101351 |      1181 | 32.23M | 24587 |   48.0 | 6.0 |  10.0 |  96.0 | "31,41,51,61,71,81" | 5:09'40'' | 1:51'52'' |
| Q30L60X40P000  |   40.0 |  48.94% |      3730 | 278.46M |  96393 |      1077 | 18.99M | 16010 |   31.0 | 4.0 |   6.3 |  62.0 | "31,41,51,61,71,81" | 4:08'53'' | 1:37'09'' |
| Q30L60XallP000 |   60.9 |  48.51% |      3542 | 277.83M |  99239 |      1181 | 31.12M | 23781 |   48.0 | 6.0 |  10.0 |  96.0 | "31,41,51,61,71,81" | 5:12'06'' | 1:40'53'' |

| Name                   |  N50 |        Sum |       # |
|:-----------------------|-----:|-----------:|--------:|
| anchors                | 3750 |  283419348 |   97828 |
| others                 | 1188 |   42568787 |   32443 |
| spades.contig          | 1365 | 1267080136 | 1906365 |
| spades.scaffold        | 1382 | 1267825736 | 1898909 |
| spades.non-contained   | 7909 |  690403764 |  166578 |
| platanus.contig        |  316 |  817794289 | 5005046 |
| platanus.non-contained | 4463 |  295914687 |   92873 |

# FCM05DSE2

## FCM05DSE2: download

* Illumina

```bash
mkdir -p ${HOME}/data/dna-seq/xjy2/FCM05DSE2/2_illumina
cd ${HOME}/data/dna-seq/xjy2/FCM05DSE2/2_illumina

ln -s ../../FCM05D/2_illumina/R2.fq.gz R1.fq.gz

```

## FCM05DSE2: template

* Rsync to hpcc

```bash
rsync -avP \
    ~/data/dna-seq/xjy2/data/ \
    wangq@202.119.37.251:data/dna-seq/xjy2/data

rsync -avP \
    ~/data/dna-seq/xjy2/FCM05DSE2/ \
    wangq@202.119.37.251:data/dna-seq/xjy2/FCM05DSE2

#rsync -avP wangq@202.119.37.251:data/dna-seq/xjy2/FCM05DSE2/ ~/data/dna-seq/xjy2/FCM05DSE2

```

```bash
WORKING_DIR=${HOME}/data/dna-seq/xjy2
BASE_NAME=FCM05DSE2
QUEUE_NAME=largemem

cd ${WORKING_DIR}/${BASE_NAME}

anchr template \
    . \
    --se \
    --basename ${BASE_NAME} \
    --genome 530000000 \
    --is_euk \
    --trim2 "--uniq " \
    --cov2 "40 all" \
    --qual2 "25 30" \
    --len2 "60" \
    --parallel 24

```

## FCM05DSE2: run

Same as [FCM05: run](#fcm05-run)

| Name     | N50 |    Sum |         # |
|:---------|----:|-------:|----------:|
| Illumina | 150 | 49.64G | 330934881 |
| uniq     | 150 | 42.04G | 280267601 |
| Q25L60   | 150 | 41.02G | 277539470 |
| Q30L60   | 150 | 38.55G | 269782998 |

| Name   | CovIn | CovOut | Discard% | AvgRead | Kmer | RealG |    EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|-----:|------:|--------:|---------:|----------:|
| Q25L60 |  77.9 |   58.4 |   25.09% |     147 | "31" |  530M |  809.1M |     1.53 | 1:33'40'' |
| Q30L60 |  73.2 |   57.7 |   21.17% |     142 | "31" |  530M | 793.26M |     1.50 | 1:33'44'' |

| Name           | CovCor | Mapped% | N50Anchor |     Sum |      # | N50Others |    Sum |     # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|--------:|-------:|----------:|-------:|------:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q25L60X40P000  |   40.0 |  47.44% |      3527 | 271.68M |  97402 |      1073 | 19.14M | 16306 |   31.0 | 4.0 |   6.3 |  62.0 | "31,41,51,61,71,81" | 4:03'39'' | 1:31'56'' |
| Q25L60XallP000 |   58.4 |  46.60% |      3252 | 269.12M | 101064 |      1151 | 28.68M | 22377 |   45.0 | 6.0 |   9.0 |  90.0 | "31,41,51,61,71,81" | 4:58'09'' | 1:35'42'' |
| Q30L60X40P000  |   40.0 |  48.90% |      3776 | 277.04M |  95354 |      1071 | 18.29M | 15535 |   31.0 | 4.0 |   6.3 |  62.0 | "31,41,51,61,71,81" | 4:03'30'' | 1:38'17'' |
| Q30L60XallP000 |   57.7 |  48.49% |      3581 |  277.3M |  98341 |      1147 |  26.9M | 21059 |   45.0 | 6.0 |   9.0 |  90.0 | "31,41,51,61,71,81" | 4:55'57'' | 1:40'58'' |

| Name                   |  N50 |        Sum |       # |
|:-----------------------|-----:|-----------:|--------:|
| anchors                | 3803 |  283021078 |   96938 |
| others                 | 1158 |   40674081 |   31706 |
| spades.contig          | 1400 | 1249482518 | 1872897 |
| spades.scaffold        | 1419 | 1250186118 | 1865861 |
| spades.non-contained   | 7744 |  684835479 |  166141 |
| platanus.contig        |  319 |  812849257 | 4968008 |
| platanus.non-contained | 4376 |  293419551 |   93316 |


# FCM05E

## FCM05E: download

* Illumina

```bash
mkdir -p ${HOME}/data/dna-seq/xjy2/FCM05E/2_illumina
cd ${HOME}/data/dna-seq/xjy2/FCM05E/2_illumina

ln -s ../../data/FCM05_H5WKJDMXX_L1_1.clean.fq.gz R1.fq.gz
ln -s ../../data/FCM05_H5WKJDMXX_L1_2.clean.fq.gz R2.fq.gz

```

## FCM05E: template

```bash
WORKING_DIR=${HOME}/data/dna-seq/xjy2
BASE_NAME=FCM05E
QUEUE_NAME=largemem

cd ${WORKING_DIR}/${BASE_NAME}

anchr template \
    . \
    --basename ${BASE_NAME} \
    --genome 530000000 \
    --is_euk \
    --trim2 "--uniq --bbduk" \
    --cov2 "all" \
    --qual2 "25" \
    --len2 "60" \
    --filter "adapter,phix,artifact" \
    --mergereads \
    --tile \
    --ecphase "1,2,3" \
    --parallel 16

```

## FCM05E: run

```bash
WORKING_DIR=${HOME}/data/dna-seq/xjy2
BASE_NAME=FCM05E

cd ${WORKING_DIR}/${BASE_NAME}

bash 2_fastqc.sh
bash 2_kmergenie.sh

bash 2_mergereads.sh

```

| Name           | N50 |     Sum |        # |
|:---------------|----:|--------:|---------:|
| clumped        | 150 |   4.96G | 33081122 |
| filteredbytile | 150 |   4.68G | 31218532 |
| trimmed        | 150 |   4.63G | 31008994 |
| filtered       | 150 |   4.63G | 31008642 |
| ecco           | 150 |   4.63G | 31008642 |
| eccc           | 150 |   4.63G | 31008642 |
| ecct           | 150 |   2.17G | 14522722 |
| extended       | 190 |   2.62G | 14522722 |
| merged         | 292 |   1.89G |  6651670 |
| unmerged.raw   | 170 | 203.13M |  1219382 |
| unmerged       | 170 | 178.88M |  1131772 |

| Group            |  Mean | Median | STDev | PercentOfPairs |
|:-----------------|------:|-------:|------:|---------------:|
| ihist.merge1.txt | 235.9 |    241 |  32.6 |         56.96% |
| ihist.merge.txt  | 284.0 |    283 |  52.2 |         91.60% |

```text
#mergeReads
#Matched	187	0.00060%
#Name	Reads	ReadsPct
```

# FCM07, 蜡梅

* *Chimonanthus praecox*
* Taxonomy ID: [13419](https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?mode=Info&id=13419)

## FCM07: download

```bash
mkdir -p ~/data/dna-seq/xjy2/FCM07/2_illumina
cd ~/data/dna-seq/xjy2/FCM07/2_illumina

ln -s ../../data/D7g7512_FCM07_R1_001.fastq.gz R1.fq.gz
ln -s ../../data/D7g7512_FCM07_R2_001.fastq.gz R2.fq.gz

```

## FCM07: template

* Rsync to hpcc

```bash
rsync -avP \
    ~/data/dna-seq/xjy2/data/ \
    wangq@202.119.37.251:data/dna-seq/xjy2/data

rsync -avP \
    ~/data/dna-seq/xjy2/FCM07/ \
    wangq@202.119.37.251:data/dna-seq/xjy2/FCM07

#rsync -avP wangq@202.119.37.251:data/dna-seq/xjy2/FCM07/ ~/data/dna-seq/xjy2/FCM07

```

```bash
WORKING_DIR=${HOME}/data/dna-seq/xjy2
BASE_NAME=FCM07

cd ${WORKING_DIR}/${BASE_NAME}

rm -f *.sh
anchr template \
    . \
    --basename ${BASE_NAME} \
    --queue largemem \
    --is_euk \
    --genome 620_000_000 \
    --fastqc \
    --kmergenie \
    --insertsize \
    --sgapreqc \
    --trim2 "--dedupe --tile" \
    --qual2 "25" \
    --len2 "60" \
    --filter "adapter,phix,artifact" \
    --mergereads \
    --ecphase "1,3" \
    --cov2 "all" \
    --tadpole \
    --fillanchor \
    --xmx 240g \
    --parallel 24

```

## FCM07: run

```bash
WORKING_DIR=${HOME}/data/dna-seq/xjy2
BASE_NAME=FCM07

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
| R.tadpole.bbtools | 309.3 |    307 |  63.5 |                         14.95% |
| R.tadpole.picard  | 305.8 |    305 |  65.5 |                             FR |


Table: statReads

| Name       | N50 |    Sum |         # |
|:-----------|----:|-------:|----------:|
| Illumina.R | 151 | 21.95G | 145382130 |
| trim.R     | 150 | 16.62G | 112798010 |
| Q25L60     | 150 | 16.08G | 110644583 |


Table: statTrimReads

| Name           | N50 |    Sum |         # |
|:---------------|----:|-------:|----------:|
| clumpify       | 151 | 18.07G | 119657944 |
| filteredbytile | 151 | 17.19G | 113845336 |
| trim           | 150 | 16.62G | 112798068 |
| filter         | 150 | 16.62G | 112798010 |
| R1             | 150 |  8.35G |  56399005 |
| R2             | 150 |  8.27G |  56399005 |
| Rs             |   0 |      0 |         0 |


```text
#R.trim
#Matched	819070	0.71946%
#Name	Reads	ReadsPct
Reverse_adapter	308986	0.27141%
TruSeq_Universal_Adapter	143609	0.12614%
pcr_dimer	135574	0.11909%
```

```text
#R.filter
#Matched	29	0.00003%
#Name	Reads	ReadsPct
```

```text
#R.peaks
#k	31
#unique_kmers	1217677377
#main_peak	13
#genome_size	642846516
#haploid_genome_size	642846516
#fold_coverage	13
#haploid_fold_coverage	13
#ploidy	1
#percent_repeat	13.899
#start	center	stop	max	volume
```


Table: statMergeReads

| Name          | N50 |     Sum |         # |
|:--------------|----:|--------:|----------:|
| clumped       | 150 |  16.54G | 112237834 |
| ecco          | 150 |  16.54G | 112237834 |
| ecct          | 150 |  13.12G |  88659300 |
| extended      | 190 |  16.32G |  88659300 |
| merged.raw    | 361 |  13.79G |  38744764 |
| unmerged.raw  | 179 |   1.94G |  11169772 |
| unmerged.trim | 179 |   1.94G |  11169582 |
| M1            | 359 |  12.58G |  35478484 |
| U1            | 180 | 980.93M |   5584791 |
| U2            | 177 | 954.97M |   5584791 |
| Us            |   0 |       0 |         0 |
| M.cor         | 348 |  14.55G |  82126550 |

| Group              |  Mean | Median | STDev | PercentOfPairs |
|:-------------------|------:|-------:|------:|---------------:|
| M.ihist.merge1.txt | 250.1 |    265 |  36.9 |         19.98% |
| M.ihist.merge.txt  | 355.8 |    352 |  58.0 |         87.40% |


Table: statQuorum

| Name     | CovIn | CovOut | Discard% |  Kmer | RealG |    EstG | Est/Real |   RunTime |
|:---------|------:|-------:|---------:|------:|------:|--------:|---------:|----------:|
| Q0L0.R   |  26.8 |   22.7 |   15.24% | "105" |  620M | 603.28M |     0.97 | 0:31'14'' |
| Q25L60.R |  25.9 |   22.8 |   12.08% | "105" |  620M |  600.5M |     0.97 | 0:36'56'' |


Table: statKunitigsAnchors.md

| Name           | CovCor | Mapped% | N50Anchor |     Sum |     # | N50Others |    Sum |      # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|--------:|------:|----------:|-------:|-------:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q0L0XallP000   |   22.7 |  25.55% |      2500 |  150.5M | 67441 |      1038 | 34.46M | 177517 |   17.0 | 2.0 |   3.7 |  34.0 | "31,41,51,61,71,81" | 1:37'57'' | 0:35'07'' |
| Q25L60XallP000 |   22.8 |  26.30% |      2484 | 150.89M | 67846 |      1039 | 34.73M | 178064 |   17.0 | 2.0 |   3.7 |  34.0 | "31,41,51,61,71,81" | 1:37'38'' | 0:35'42'' |


Table: statTadpoleAnchors.md

| Name           | CovCor | Mapped% | N50Anchor |     Sum |     # | N50Others |    Sum |      # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|--------:|------:|----------:|-------:|-------:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q0L0XallP000   |   22.7 |  35.90% |      2434 | 150.17M | 68256 |      1039 | 35.26M | 191617 |   17.0 | 2.0 |   3.7 |  34.0 | "31,41,51,61,71,81" | 0:47'46'' | 0:30'42'' |
| Q25L60XallP000 |   22.8 |  35.79% |      2402 | 149.91M | 68661 |      1040 | 35.96M | 193204 |   17.0 | 2.0 |   3.7 |  34.0 | "31,41,51,61,71,81" | 0:47'37'' | 0:30'51'' |


Table: statMRKunitigsAnchors.md

| Name       | CovCor | Mapped% | N50Anchor |     Sum |     # | N50Others |    Sum |      # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:-----------|-------:|--------:|----------:|--------:|------:|----------:|-------:|-------:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| MRXallP000 |   23.5 |  24.21% |      2662 | 143.89M | 62181 |      1042 | 26.23M | 139078 |   19.0 | 3.0 |   3.3 |  38.0 | "31,41,51,61,71,81" | 1:54'30'' | 0:17'59'' |


Table: statMRTadpoleAnchors.md

| Name       | CovCor | Mapped% | N50Anchor |     Sum |     # | N50Others |    Sum |      # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:-----------|-------:|--------:|----------:|--------:|------:|----------:|-------:|-------:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| MRXallP000 |   23.5 |  30.52% |      2681 | 154.04M | 66023 |      1043 | 27.56M | 144769 |   19.0 | 3.0 |   3.3 |  38.0 | "31,41,51,61,71,81" | 1:00'00'' | 0:19'59'' |


Table: statMergeAnchors.md

| Name                     | Mapped% | N50Anchor |     Sum |     # | N50Others |    Sum |     # | median | MAD | lower | upper | RunTimeAN |
|:-------------------------|--------:|----------:|--------:|------:|----------:|-------:|------:|-------:|----:|------:|------:|----------:|
| 7_mergeAnchors           |   0.00% |      2584 |  181.4M | 78698 |      1085 | 52.18M | 45397 |    0.0 | 0.0 |   0.0 |   0.0 |           |
| 7_mergeKunitigsAnchors   |   0.00% |      2547 | 153.91M | 68214 |      1076 | 29.68M | 26678 |    0.0 | 0.0 |   0.0 |   0.0 |           |
| 7_mergeMRKunitigsAnchors |   0.00% |      2662 | 143.89M | 62181 |      1075 | 20.23M | 18111 |    0.0 | 0.0 |   0.0 |   0.0 |           |
| 7_mergeMRTadpoleAnchors  |   0.00% |      2681 | 154.04M | 66023 |      1073 | 21.57M | 18952 |    0.0 | 0.0 |   0.0 |   0.0 |           |
| 7_mergeTadpoleAnchors    |   0.00% |      2458 | 153.99M | 69561 |      1074 | 30.58M | 26502 |    0.0 | 0.0 |   0.0 |   0.0 |           |


Table: statOtherAnchors.md

| Name         | Mapped% | N50Anchor |     Sum |      # | N50Others |     Sum |      # | median | MAD | lower | upper | RunTimeAN |
|:-------------|--------:|----------:|--------:|-------:|----------:|--------:|-------:|-------:|----:|------:|------:|----------:|
| 8_spades     |  60.02% |      2687 | 394.83M | 167271 |      1274 |  119.3M | 268153 |   14.0 | 3.0 |   3.0 |  28.0 | 1:22'10'' |
| 8_spades_MR  |  64.79% |      3102 | 424.48M | 163010 |      1193 | 107.94M | 275223 |   15.0 | 4.0 |   3.0 |  30.0 | 1:20'09'' |
| 8_megahit    |  53.01% |      2443 | 306.57M | 139298 |      1268 | 114.95M | 240329 |   14.0 | 3.0 |   3.0 |  28.0 | 0:36'56'' |
| 8_megahit_MR |  55.28% |      1920 | 292.32M | 158431 |      1331 | 166.93M | 325112 |   14.0 | 4.0 |   3.0 |  28.0 | 0:57'40'' |
| 8_platanus   |  27.11% |      2357 | 191.34M |  89243 |      1136 |  55.37M | 168542 |   15.0 | 2.0 |   3.0 |  30.0 | 0:16'05'' |


Table: statFinal

| Name                     |   N50 |       Sum |        # |
|:-------------------------|------:|----------:|---------:|
| 7_mergeAnchors.anchors   |  2584 | 181396584 |    78698 |
| 7_mergeAnchors.others    |  1085 |  52181978 |    45397 |
| anchorLong               |  9746 |  19080662 |     3599 |
| anchorFill               | 10561 |  19136608 |     3469 |
| spades.contig            |  3711 | 786495218 |  1894874 |
| spades.scaffold          |  4774 | 788044556 |  1878295 |
| spades.non-contained     |  8750 | 514135296 |   101317 |
| spades_MR.contig         |  6350 | 617624443 |   329136 |
| spades_MR.scaffold       |  8366 | 618915413 |   314277 |
| spades_MR.non-contained  |  8121 | 532428548 |   114119 |
| megahit.contig           |  4320 | 548885033 |   404807 |
| megahit.non-contained    |  6733 | 421525075 |   101613 |
| megahit_MR.contig        |  1806 | 692579840 |   616296 |
| megahit_MR.non-contained |  3240 | 459266725 |   169460 |
| platanus.contig          |    78 | 910829058 | 12081755 |
| platanus.scaffold        |  1861 | 404139188 |   926073 |
| platanus.non-contained   |  3975 | 246715226 |    80095 |


# FCM13, 红楠

* *Machilus thunbergii*
* Taxonomy ID:
  [128685](https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?mode=Info&id=128685)

## FCM13: download

```bash
mkdir -p ~/data/dna-seq/xjy2/FCM13/2_illumina
cd ~/data/dna-seq/xjy2/FCM13/2_illumina

ln -s ../../data/D7g7512_FCM13-BY_R1_001.fastq.gz R1.fq.gz
ln -s ../../data/D7g7512_FCM13-BY_R2_001.fastq.gz R2.fq.gz

```


## FCM13: template

* Rsync to hpcc

```bash
rsync -avP \
    ~/data/dna-seq/xjy2/data/ \
    wangq@202.119.37.251:data/dna-seq/xjy2/data

rsync -avP \
    ~/data/dna-seq/xjy2/FCM13/ \
    wangq@202.119.37.251:data/dna-seq/xjy2/FCM13

#rsync -avP wangq@202.119.37.251:data/dna-seq/xjy2/FCM13/ ~/data/dna-seq/xjy2/FCM13

```

```bash
WORKING_DIR=${HOME}/data/dna-seq/xjy2
BASE_NAME=FCM13

cd ${WORKING_DIR}/${BASE_NAME}

rm -f *.sh
anchr template \
    . \
    --basename ${BASE_NAME} \
    --queue largemem \
    --is_euk \
    --genome 430_000_000 \
    --fastqc \
    --kmergenie \
    --insertsize \
    --sgapreqc \
    --trim2 "--dedupe --tile" \
    --qual2 "25" \
    --len2 "60" \
    --filter "adapter,phix,artifact" \
    --mergereads \
    --ecphase "1,3" \
    --cov2 "all" \
    --tadpole \
    --fillanchor \
    --xmx 240g \
    --parallel 24

```

## FCM13: run

```bash
WORKING_DIR=${HOME}/data/dna-seq/xjy2
BASE_NAME=FCM13

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
| R.tadpole.bbtools | 277.5 |    280 |  76.8 |                          5.69% |
| R.tadpole.picard  | 272.9 |    277 |  79.0 |                             FR |


Table: statReads

| Name       | N50 |    Sum |         # |
|:-----------|----:|-------:|----------:|
| Illumina.R | 151 | 25.33G | 167737630 |
| trim.R     | 150 | 19.46G | 133012222 |
| Q25L60     | 150 | 18.77G | 130024910 |


Table: statTrimReads

| Name           | N50 |    Sum |         # |
|:---------------|----:|-------:|----------:|
| clumpify       | 151 | 21.47G | 142207658 |
| filteredbytile | 151 | 20.36G | 134818556 |
| trim           | 150 | 19.46G | 133012252 |
| filter         | 150 | 19.46G | 133012222 |
| R1             | 150 |  9.79G |  66506111 |
| R2             | 150 |  9.66G |  66506111 |
| Rs             |   0 |      0 |         0 |


```text
#R.trim
#Matched	1969725	1.46102%
#Name	Reads	ReadsPct
Reverse_adapter	690166	0.51192%
pcr_dimer	453494	0.33637%
PCR_Primers	226385	0.16792%
TruSeq_Universal_Adapter	226201	0.16778%
TruSeq_Adapter_Index_1_6	190372	0.14121%
```

```text
#R.filter
#Matched	15	0.00001%
#Name	Reads	ReadsPct
```

```text
#R.peaks
#k	31
#unique_kmers	1940650911
#main_peak	6
#genome_size	988677337
#haploid_genome_size	988677337
#fold_coverage	6
#haploid_fold_coverage	6
#ploidy	1
#percent_repeat	20.828
#start	center	stop	max	volume
```


Table: statMergeReads

| Name          | N50 |    Sum |         # |
|:--------------|----:|-------:|----------:|
| clumped       | 150 | 19.36G | 132339858 |
| ecco          | 150 | 19.36G | 132339858 |
| ecct          | 150 | 12.68G |  86245614 |
| extended      | 189 | 15.38G |  86245614 |
| merged.raw    | 344 | 11.07G |  33201987 |
| unmerged.raw  | 171 |  3.34G |  19841640 |
| unmerged.trim | 171 |  3.34G |  19841310 |
| M1            | 343 | 10.25G |  30809726 |
| U1            | 172 |  1.69G |   9920655 |
| U2            | 170 |  1.65G |   9920655 |
| Us            |   0 |      0 |         0 |
| M.cor         | 322 | 13.63G |  81460762 |

| Group              |  Mean | Median | STDev | PercentOfPairs |
|:-------------------|------:|-------:|------:|---------------:|
| M.ihist.merge1.txt | 237.6 |    256 |  46.5 |         24.61% |
| M.ihist.merge.txt  | 333.3 |    333 |  67.7 |         76.99% |


Table: statQuorum

| Name     | CovIn | CovOut | Discard% |  Kmer | RealG |    EstG | Est/Real |   RunTime |
|:---------|------:|-------:|---------:|------:|------:|--------:|---------:|----------:|
| Q0L0.R   |  45.2 |   36.7 |   18.80% | "103" |  430M | 898.81M |     2.09 | 0:58'22'' |
| Q25L60.R |  43.6 |   36.6 |   16.11% |  "99" |  430M | 890.02M |     2.07 | 1:59'10'' |


Table: statKunitigsAnchors.md

| Name | CovCor | Mapped% | N50Anchor | Sum | # | N50Others | Sum | # | median | MAD | lower | upper | Kmer | RunTimeKU | RunTimeAN |
|:-----|-------:|--------:|----------:|----:|--:|----------:|----:|--:|-------:|----:|------:|------:|-----:|----------:|----------:|


Table: statTadpoleAnchors.md

| Name           | CovCor | Mapped% | N50Anchor |    Sum |     # | N50Others |    Sum |     # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|-------:|------:|----------:|-------:|------:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q0L0XallP000   |   36.7 |   8.30% |      1198 | 14.88M | 11886 |      1089 | 15.87M | 37139 |    9.0 | 1.0 |   3.0 |  18.0 | "31,41,51,61,71,81" | 0:47'31'' | 0:04'46'' |
| Q25L60XallP000 |   36.6 |   8.36% |      1203 | 16.82M | 13369 |      1064 | 12.86M | 37966 |   10.0 | 2.0 |   3.0 |  20.0 | "31,41,51,61,71,81" | 0:45'01'' | 0:04'54'' |


Table: statMRKunitigsAnchors.md

| Name | CovCor | Mapped% | N50Anchor | Sum | # | N50Others | Sum | # | median | MAD | lower | upper | Kmer | RunTimeKU | RunTimeAN |
|:-----|-------:|--------:|----------:|----:|--:|----------:|----:|--:|-------:|----:|------:|------:|-----:|----------:|----------:|


Table: statMRTadpoleAnchors.md

| Name       | CovCor | Mapped% | N50Anchor |    Sum |     # | N50Others |    Sum |     # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:-----------|-------:|--------:|----------:|-------:|------:|----------:|-------:|------:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| MRXallP000 |   31.7 |   9.87% |      1260 | 40.05M | 30566 |      1076 | 29.14M | 81127 |    9.0 | 1.0 |   3.0 |  18.0 | "31,41,51,61,71,81" | 0:44'30'' | 0:06'33'' |


Table: statMergeAnchors.md

| Name                     | Mapped% | N50Anchor |    Sum |     # | N50Others |    Sum |     # | median | MAD | lower | upper | RunTimeAN |
|:-------------------------|--------:|----------:|-------:|------:|----------:|-------:|------:|-------:|----:|------:|------:|----------:|
| 7_mergeAnchors           |   0.00% |      1250 |  48.6M | 37236 |      1089 | 35.72M | 30508 |    0.0 | 0.0 |   0.0 |   0.0 |           |
| 7_mergeKunitigsAnchors   |   0.00% |         0 |      0 |     0 |         0 |      0 |     0 |    0.0 | 0.0 |   0.0 |   0.0 |           |
| 7_mergeMRKunitigsAnchors |   0.00% |         0 |      0 |     0 |      1083 |  1.08K |     1 |    0.0 | 0.0 |   0.0 |   0.0 |           |
| 7_mergeMRTadpoleAnchors  |   0.00% |      1260 | 40.05M | 30566 |      1091 | 26.25M | 22377 |    0.0 | 0.0 |   0.0 |   0.0 |           |
| 7_mergeTadpoleAnchors    |   0.00% |      1205 | 18.19M | 14425 |      1099 | 15.87M | 12948 |    0.0 | 0.0 |   0.0 |   0.0 |           |


Table: statOtherAnchors.md

| Name         | Mapped% | N50Anchor |     Sum |      # | N50Others |     Sum |      # | median | MAD | lower | upper | RunTimeAN |
|:-------------|--------:|----------:|--------:|-------:|----------:|--------:|-------:|-------:|----:|------:|------:|----------:|
| 8_spades_MR  |  35.07% |      1462 | 231.61M | 155934 |      1399 | 281.68M | 406806 |    8.0 | 1.0 |   3.0 |  16.0 | 0:38'51'' |
| 8_megahit    |  25.64% |      1275 |  73.21M |  55702 |      1942 | 332.04M | 239055 |    7.0 | 1.0 |   3.0 |  14.0 | 0:21'02'' |
| 8_megahit_MR |  29.58% |      1285 | 109.91M |  83109 |      1459 | 337.63M | 345749 |    7.0 | 1.0 |   3.0 |  14.0 | 0:27'13'' |
| 8_platanus   |   3.60% |      1296 |  18.31M |  13673 |      1279 |  26.47M |  42580 |   11.0 | 2.0 |   3.0 |  22.0 | 0:04'41'' |


Table: statFinal

| Name                     |  N50 |        Sum |        # |
|:-------------------------|-----:|-----------:|---------:|
| 7_mergeAnchors.anchors   | 1250 |   48600042 |    37236 |
| 7_mergeAnchors.others    | 1089 |   35717457 |    30508 |
| anchorLong               | 1918 |    1163403 |      626 |
| anchorFill               | 1924 |    1162185 |      623 |
| spades.non-contained     |    0 |          0 |        0 |
| spades_MR.contig         | 1097 |  963303377 |  1965344 |
| spades_MR.scaffold       | 1110 |  964435068 |  1951256 |
| spades_MR.non-contained  | 2162 |  513283760 |   253655 |
| megahit.contig           | 1176 |  735922260 |   944870 |
| megahit.non-contained    | 2438 |  405245102 |   183642 |
| megahit_MR.contig        |  983 |  910956650 |  1146574 |
| megahit_MR.non-contained | 1717 |  447541082 |   264262 |
| platanus.contig          |   63 | 1106318496 | 17445197 |
| platanus.scaffold        |  212 |  374696055 |  1774255 |
| platanus.non-contained   | 1507 |   44776228 |    29203 |


# FCM15, 金钱蒲

* *Acorus gramineus*
* Taxonomy ID: [55184](https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?mode=Info&id=55184)

## FCM15: download

```bash
mkdir -p ~/data/dna-seq/xjy2/FCM15/2_illumina
cd ~/data/dna-seq/xjy2/FCM15/2_illumina

ln -s ../../data/FCM15_PE400_R1.fastq.gz R1.fq.gz
ln -s ../../data/FCM15_PE400_R2.fastq.gz R2.fq.gz

```

## FCM15: template

* Rsync to hpcc

```bash
rsync -avP \
    ~/data/dna-seq/xjy2/data/ \
    wangq@202.119.37.251:data/dna-seq/xjy2/data

rsync -avP \
    ~/data/dna-seq/xjy2/FCM15/ \
    wangq@202.119.37.251:data/dna-seq/xjy2/FCM15

#rsync -avP wangq@202.119.37.251:data/dna-seq/xjy2/FCM15/ ~/data/dna-seq/xjy2/FCM15

```

```bash
WORKING_DIR=${HOME}/data/dna-seq/xjy2
BASE_NAME=FCM15

cd ${WORKING_DIR}/${BASE_NAME}

rm -f *.sh
anchr template \
    . \
    --basename ${BASE_NAME} \
    --queue largemem \
    --is_euk \
    --genome 500000000 \
    --fastqc \
    --kmergenie \
    --insertsize \
    --sgapreqc \
    --trim2 "--dedupe --tile" \
    --qual2 "25" \
    --len2 "60" \
    --filter "adapter,phix,artifact" \
    --mergereads \
    --ecphase "1,2,3" \
    --cov2 "all" \
    --tadpole \
    --fillanchor \
    --xmx 240g \
    --parallel 24

```

## FCM15: run

```bash
WORKING_DIR=${HOME}/data/dna-seq/xjy2
BASE_NAME=FCM15

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
| R.tadpole.bbtools | 370.2 |    372 | 104.9 |                          5.42% |
| R.tadpole.picard  | 366.7 |    369 | 107.6 |                             FR |


Table: statReads

| Name       | N50 |    Sum |         # |
|:-----------|----:|-------:|----------:|
| Illumina.R | 150 | 31.13G | 207533606 |
| trim.R     | 150 |  25.8G | 175044606 |
| Q25L60     | 150 | 24.27G | 166013209 |


Table: statTrimReads

| Name           | N50 |    Sum |         # |
|:---------------|----:|-------:|----------:|
| clumpify       | 150 | 28.68G | 191199598 |
| filteredbytile | 150 | 26.86G | 179078300 |
| trim           | 150 |  25.8G | 175044648 |
| filter         | 150 |  25.8G | 175044606 |
| R1             | 150 | 13.03G |  87522303 |
| R2             | 150 | 12.76G |  87522303 |
| Rs             |   0 |      0 |         0 |


```text
#R.trim
#Matched	944882	0.52764%
#Name	Reads	ReadsPct
Reverse_adapter	295969	0.16527%
TruSeq_Universal_Adapter	205733	0.11488%
```

```text
#R.filter
#Matched	21	0.00001%
#Name	Reads	ReadsPct
```

```text
#R.peaks
#k	31
#unique_kmers	1153057043
#main_peak	24
#genome_size	621223028
#haploid_genome_size	310611514
#fold_coverage	24
#haploid_fold_coverage	50
#ploidy	2
#het_rate	0.02666
#percent_repeat	17.106
#start	center	stop	max	volume
```


Table: statMergeReads

| Name          | N50 |    Sum |         # |
|:--------------|----:|-------:|----------:|
| clumped       | 150 | 25.79G | 174976500 |
| ecco          | 150 | 25.79G | 174976500 |
| eccc          | 150 | 25.79G | 174976500 |
| ecct          | 150 | 21.87G | 147875646 |
| extended      | 190 | 27.16G | 147875646 |
| merged.raw    | 424 | 16.95G |  41766924 |
| unmerged.raw  | 190 | 11.57G |  64341798 |
| unmerged.trim | 190 | 11.57G |  64340476 |
| M1            | 424 | 16.45G |  40544737 |
| U1            | 190 |  5.88G |  32170238 |
| U2            | 189 |  5.69G |  32170238 |
| Us            |   0 |      0 |         0 |
| M.cor         | 350 | 28.06G | 145429950 |

| Group              |  Mean | Median | STDev | PercentOfPairs |
|:-------------------|------:|-------:|------:|---------------:|
| M.ihist.merge1.txt | 239.9 |    250 |  39.1 |          6.07% |
| M.ihist.merge.txt  | 405.9 |    413 |  69.0 |         56.49% |


Table: statQuorum

| Name     | CovIn | CovOut | Discard% |  Kmer | RealG |    EstG | Est/Real |   RunTime |
|:---------|------:|-------:|---------:|------:|------:|--------:|---------:|----------:|
| Q0L0.R   |  51.6 |   46.5 |    9.82% | "105" |  500M | 409.48M |     0.82 | 0:46'32'' |
| Q25L60.R |  48.5 |   46.0 |    5.19% | "105" |  500M | 404.32M |     0.81 | 0:43'53'' |


Table: statKunitigsAnchors.md

| Name           | CovCor | Mapped% | N50Anchor |    Sum |     # | N50Others |    Sum |      # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|-------:|------:|----------:|-------:|-------:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q0L0XallP000   |   46.5 |  13.81% |      1526 | 67.84M | 42709 |      1041 | 15.91M |  98920 |   27.0 | 3.0 |   6.0 |  54.0 | "31,41,51,61,71,81" | 2:02'07'' | 0:18'48'' |
| Q25L60XallP000 |   46.0 |  16.01% |      1529 | 69.33M | 43547 |      1043 | 16.17M | 100171 |   27.0 | 3.0 |   6.0 |  54.0 | "31,41,51,61,71,81" | 1:59'58'' | 0:18'38'' |


Table: statTadpoleAnchors.md

| Name           | CovCor | Mapped% | N50Anchor |    Sum |     # | N50Others |    Sum |      # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|-------:|------:|----------:|-------:|-------:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q0L0XallP000   |   46.5 |  21.70% |      1550 | 72.65M | 45119 |      1047 |  17.6M | 104812 |   27.0 | 3.0 |   6.0 |  54.0 | "31,41,51,61,71,81" | 0:39'21'' | 0:20'18'' |
| Q25L60XallP000 |   46.0 |  21.80% |      1550 | 73.08M | 45422 |      1046 | 17.23M | 105424 |   27.0 | 3.0 |   6.0 |  54.0 | "31,41,51,61,71,81" | 0:38'16'' | 0:20'06'' |


Table: statMRKunitigsAnchors.md

| Name       | CovCor | Mapped% | N50Anchor |    Sum |     # | N50Others |    Sum |     # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:-----------|-------:|--------:|----------:|-------:|------:|----------:|-------:|------:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| MRXallP000 |   56.1 |  14.56% |      1509 | 57.21M | 36379 |      1057 | 18.84M | 85663 |   34.0 | 5.0 |   6.3 |  68.0 | "31,41,51,61,71,81" | 2:50'11'' | 0:13'14'' |


Table: statMRTadpoleAnchors.md

| Name       | CovCor | Mapped% | N50Anchor |    Sum |     # | N50Others |    Sum |     # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:-----------|-------:|--------:|----------:|-------:|------:|----------:|-------:|------:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| MRXallP000 |   56.1 |  19.53% |      1546 | 62.98M | 39206 |      1057 | 19.85M | 91365 |   34.0 | 5.0 |   6.3 |  68.0 | "31,41,51,61,71,81" | 0:49'09'' | 0:14'32'' |


Table: statMergeAnchors.md

| Name                     | Mapped% | N50Anchor |    Sum |     # | N50Others |    Sum |     # | median | MAD | lower | upper | RunTimeAN |
|:-------------------------|--------:|----------:|-------:|------:|----------:|-------:|------:|-------:|----:|------:|------:|----------:|
| 7_mergeAnchors           |   0.00% |      1572 | 77.75M | 47710 |      1068 | 21.82M | 17507 |    0.0 | 0.0 |   0.0 |   0.0 |           |
| 7_mergeKunitigsAnchors   |   0.00% |      1534 | 70.04M | 43905 |      1060 | 14.38M | 11591 |    0.0 | 0.0 |   0.0 |   0.0 |           |
| 7_mergeMRKunitigsAnchors |   0.00% |      1509 | 57.21M | 36379 |      1076 |  15.6M | 12458 |    0.0 | 0.0 |   0.0 |   0.0 |           |
| 7_mergeMRTadpoleAnchors  |   0.00% |      1546 | 62.98M | 39206 |      1079 | 16.38M | 12640 |    0.0 | 0.0 |   0.0 |   0.0 |           |
| 7_mergeTadpoleAnchors    |   0.00% |      1554 |    74M | 45870 |      1064 | 15.12M | 11467 |    0.0 | 0.0 |   0.0 |   0.0 |           |


Table: statOtherAnchors.md

| Name         | Mapped% | N50Anchor |     Sum |      # | N50Others |    Sum |      # | median | MAD | lower | upper | RunTimeAN |
|:-------------|--------:|----------:|--------:|-------:|----------:|-------:|-------:|-------:|----:|------:|------:|----------:|
| 8_spades_MR  |  62.39% |      3306 | 316.18M | 116321 |      1118 | 54.23M | 232033 |   37.0 | 5.0 |   7.3 |  74.0 | 0:58'41'' |
| 8_megahit    |  39.31% |      1616 | 136.29M |  83292 |      1542 | 73.14M | 181288 |   29.0 | 5.0 |   4.7 |  58.0 | 0:21'11'' |
| 8_megahit_MR |  61.94% |      2297 | 310.75M | 146995 |      1133 | 65.09M | 310264 |   35.0 | 5.0 |   6.7 |  70.0 | 0:49'10'' |
| 8_platanus   |  41.75% |      3427 |  212.4M |  76264 |      1650 | 49.54M | 124874 |   30.0 | 4.0 |   6.0 |  60.0 | 0:35'06'' |


Table: statFinal

| Name                     |  N50 |       Sum |       # |
|:-------------------------|-----:|----------:|--------:|
| 7_mergeAnchors.anchors   | 1572 |  77752460 |   47710 |
| 7_mergeAnchors.others    | 1068 |  21817227 |   17507 |
| anchorLong               | 3175 |   1402020 |     564 |
| anchorFill               | 3202 |   1399921 |     562 |
| spades.non-contained     |    0 |         0 |       0 |
| spades_MR.contig         | 3132 | 467849865 |  321295 |
| spades_MR.scaffold       | 3559 | 468842984 |  311172 |
| spades_MR.non-contained  | 4173 | 370520775 |  115763 |
| megahit.contig           | 1079 | 397078884 |  521092 |
| megahit.non-contained    | 2331 | 209431192 |   98013 |
| megahit_MR.contig        | 1754 | 549896899 |  503301 |
| megahit_MR.non-contained | 2573 | 376358741 |  163506 |
| platanus.contig          |  371 | 660749405 | 2830253 |
| platanus.scaffold        | 1653 | 490285175 | 1377623 |
| platanus.non-contained   | 9644 | 261937756 |   48616 |


# FCM16, 金鱼藻

* *Ceratophyllum demersum*
* Taxonomy ID: [4428](https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?mode=Info&id=4428)

## FCM16: download

```bash
mkdir -p ~/data/dna-seq/xjy2/FCM16/2_illumina
cd ~/data/dna-seq/xjy2/FCM16/2_illumina

ln -s ../../data/FCM16_PE400_R1.fastq.gz R1.fq.gz
ln -s ../../data/FCM16_PE400_R2.fastq.gz R2.fq.gz

```


## FCM16: template

`2_insertSize.sh`, `2_mergereads.sh` and `4_tadpole.sh` failed in hpcc

* Rsync to hpcc

```bash
rsync -avP \
    ~/data/dna-seq/xjy2/data/ \
    wangq@202.119.37.251:data/dna-seq/xjy2/data

rsync -avP \
    ~/data/dna-seq/xjy2/FCM16/ \
    wangq@202.119.37.251:data/dna-seq/xjy2/FCM16

#rsync -avP wangq@202.119.37.251:data/dna-seq/xjy2/FCM16/ ~/data/dna-seq/xjy2/FCM16

```

```bash
WORKING_DIR=${HOME}/data/dna-seq/xjy2
BASE_NAME=FCM16

cd ${WORKING_DIR}/${BASE_NAME}

rm -f *.sh
anchr template \
    . \
    --basename ${BASE_NAME} \
    --queue largemem \
    --is_euk \
    --genome 500000000 \
    --fastqc \
    --kmergenie \
    --insertsize \
    --sgapreqc \
    --trim2 "--dedupe --tile" \
    --qual2 "25" \
    --len2 "60" \
    --filter "adapter,phix,artifact" \
    --mergereads \
    --ecphase "1,3" \
    --cov2 "all" \
    --tadpole \
    --fillanchor \
    --xmx 240g \
    --parallel 24

```

## FCM16: run

```bash
WORKING_DIR=${HOME}/data/dna-seq/xjy2
BASE_NAME=FCM16

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
| R.tadpole.bbtools | 387.2 |    391 | 109.7 |                          7.65% |
| R.tadpole.picard  | 386.5 |    390 | 109.0 |                             FR |


Table: statReads

| Name       | N50 |    Sum |         # |
|:-----------|----:|-------:|----------:|
| Illumina.R | 150 | 36.13G | 240892396 |
| trim.R     | 150 | 29.27G | 199107774 |
| Q25L60     | 150 | 27.61G | 189392132 |


Table: statTrimReads

| Name           | N50 |    Sum |         # |
|:---------------|----:|-------:|----------:|
| clumpify       | 150 | 32.72G | 218132138 |
| filteredbytile | 150 | 30.56G | 203748956 |
| trim           | 150 | 29.27G | 199107792 |
| filter         | 150 | 29.27G | 199107774 |
| R1             | 150 |  14.8G |  99553887 |
| R2             | 150 | 14.47G |  99553887 |
| Rs             |   0 |      0 |         0 |


```text
#R.trim
#Matched	2119078	1.04004%
#Name	Reads	ReadsPct
Reverse_adapter	528089	0.25919%
pcr_dimer	499083	0.24495%
TruSeq_Universal_Adapter	359064	0.17623%
PCR_Primers	228702	0.11225%
```

```text
#R.filter
#Matched	9	0.00000%
#Name	Reads	ReadsPct
```


Table: statMergeReads

| Name          | N50 |    Sum |         # |
|:--------------|----:|-------:|----------:|
| clumped       | 150 | 29.23G | 198742778 |
| ecco          | 150 | 29.23G | 198742778 |
| ecct          | 150 |  18.3G | 123928092 |
| extended      | 190 | 22.65G | 123928092 |
| merged.raw    | 429 | 13.95G |  34320608 |
| unmerged.raw  | 190 |  9.89G |  55286876 |
| unmerged.trim | 190 |  9.89G |  55285678 |
| M1            | 429 | 13.53G |  33178622 |
| U1            | 190 |  5.02G |  27642839 |
| U2            | 190 |  4.87G |  27642839 |
| Us            |   0 |      0 |         0 |
| M.cor         | 351 | 23.45G | 121642922 |

| Group              |  Mean | Median | STDev | PercentOfPairs |
|:-------------------|------:|-------:|------:|---------------:|
| M.ihist.merge1.txt | 219.7 |    239 |  59.0 |          5.91% |
| M.ihist.merge.txt  | 406.5 |    417 |  78.0 |         55.39% |


Table: statQuorum

| Name     | CovIn | CovOut | Discard% |  Kmer | RealG |  EstG | Est/Real |   RunTime |
|:---------|------:|-------:|---------:|------:|------:|------:|---------:|----------:|
| Q0L0.R   |  58.5 |   45.5 |   22.29% | "105" |  500M | 1.08G |     2.16 | 0:56'09'' |
| Q25L60.R |  55.2 |   44.6 |   19.25% | "105" |  500M | 1.06G |     2.11 | 0:53'39'' |


Table: statKunitigsAnchors.md

| Name | CovCor | Mapped% | N50Anchor | Sum | # | N50Others | Sum | # | median | MAD | lower | upper | Kmer | RunTimeKU | RunTimeAN |
|:-----|-------:|--------:|----------:|----:|--:|----------:|----:|--:|-------:|----:|------:|------:|-----:|----------:|----------:|


Table: statTadpoleAnchors.md

| Name | CovCor | Mapped% | N50Anchor | Sum | # | N50Others | Sum | # | median | MAD | lower | upper | Kmer | RunTimeKU | RunTimeAN |
|:-----|-------:|--------:|----------:|----:|--:|----------:|----:|--:|-------:|----:|------:|------:|-----:|----------:|----------:|


Table: statMRKunitigsAnchors.md

| Name       | CovCor | Mapped% | N50Anchor |   Sum |    # | N50Others |   Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:-----------|-------:|--------:|----------:|------:|-----:|----------:|------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| MRXallP000 |   46.9 |   0.69% |      1169 | 3.57M | 2932 |      1141 | 5.36M | 9893 |   18.0 | 6.0 |   3.0 |  36.0 | "31,41,51,61,71,81" | 2:26'37'' | 0:03'35'' |


Table: statMRTadpoleAnchors.md

| Name       | CovCor | Mapped% | N50Anchor | Sum |     # | N50Others |    Sum |      # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:-----------|-------:|--------:|----------:|----:|------:|----------:|-------:|-------:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| MRXallP000 |   46.9 |  27.03% |      1577 | 96M | 59311 |      1477 | 68.69M | 153043 |   16.0 | 5.0 |   3.0 |  32.0 | "31,41,51,61,71,81" | 1:23'47'' | 0:25'19'' |


Table: statMergeAnchors.md

| Name                     | Mapped% | N50Anchor |    Sum |     # | N50Others |    Sum |     # | median | MAD | lower | upper | RunTimeAN |
|:-------------------------|--------:|----------:|-------:|------:|----------:|-------:|------:|-------:|----:|------:|------:|----------:|
| 7_mergeAnchors           |   0.00% |      1567 | 97.27M | 60381 |      1518 | 66.25M | 41228 |    0.0 | 0.0 |   0.0 |   0.0 |           |
| 7_mergeKunitigsAnchors   |   0.00% |         0 |      0 |     0 |         0 |      0 |     0 |    0.0 | 0.0 |   0.0 |   0.0 |           |
| 7_mergeMRKunitigsAnchors |   0.00% |      1169 |  3.57M |  2932 |      1156 |  5.13M |  4183 |    0.0 | 0.0 |   0.0 |   0.0 |           |
| 7_mergeMRTadpoleAnchors  |   0.00% |      1577 |    96M | 59311 |      1534 |    65M | 40168 |    0.0 | 0.0 |   0.0 |   0.0 |           |
| 7_mergeTadpoleAnchors    |   0.00% |         0 |      0 |     0 |         0 |      0 |     0 |    0.0 | 0.0 |   0.0 |   0.0 |           |


Table: statOtherAnchors.md

| Name         | Mapped% | N50Anchor |     Sum |      # | N50Others |     Sum |      # |  median |     MAD | lower |   upper | RunTimeAN |
|:-------------|--------:|----------:|--------:|-------:|----------:|--------:|-------:|--------:|--------:|------:|--------:|----------:|
| 8_spades     |  53.38% |      2621 | 435.14M | 188801 |      2206 | 326.01M | 347087 |    12.0 |     3.0 |   3.0 |    24.0 | 2:55'47'' |
| 8_spades_MR  |  61.67% |      2287 |  481.9M | 229003 |      1630 | 199.95M | 434016 |    15.0 |     4.0 |   3.0 |    30.0 | 2:48'57'' |
| 8_megahit    |  45.29% |      1614 | 232.66M | 141542 |      1819 | 330.61M | 370159 |    12.0 |     3.0 |   3.0 |    24.0 | 0:58'31'' |
| 8_megahit_MR |  57.58% |      1635 | 340.53M | 207050 |      1562 | 259.66M | 488897 |    14.0 |     4.0 |   3.0 |    28.0 | 1:21'31'' |
| 8_platanus   |  12.76% |     20527 | 163.26K |     19 |      1929 |  24.37K |     16 | 17259.0 | 14680.0 |   3.0 | 34518.0 | 0:03'52'' |


Table: statFinal

| Name                     |   N50 |       Sum |       # |
|:-------------------------|------:|----------:|--------:|
| 7_mergeAnchors.anchors   |  1567 |  97270600 |   60381 |
| 7_mergeAnchors.others    |  1518 |  66253744 |   41228 |
| anchorLong               |  3113 |   1624858 |     572 |
| anchorFill               |  3112 |   1604345 |     566 |
| spades.contig            |  5628 | 997877997 |  840183 |
| spades.scaffold          |  5948 | 998397785 |  813628 |
| spades.non-contained     |  9132 | 761148294 |  158442 |
| spades_MR.contig         |  3397 | 833854631 |  581614 |
| spades_MR.scaffold       |  4440 | 837402729 |  544102 |
| spades_MR.non-contained  |  4369 | 681885765 |  207841 |
| megahit.contig           |  1524 | 909212852 | 1010493 |
| megahit.non-contained    |  2880 | 563284157 |  228824 |
| megahit_MR.contig        |  1327 | 995593434 | 1037418 |
| megahit_MR.non-contained |  2240 | 600359364 |  286767 |
| platanus.contig          |   240 |    639053 |    2312 |
| platanus.scaffold        |   179 |    522447 |    2039 |
| platanus.non-contained   | 23379 |    187630 |      17 |

# Blasia

## Blasia: download

```bash
mkdir -p ~/data/dna-seq/xjy2/Blasia/2_illumina
cd ~/data/dna-seq/xjy2/Blasia/2_illumina

ln -s ../../data/Blasia_H3TK5DMXX_L1_1.fq.gz R1.fq.gz
ln -s ../../data/Blasia_H3TK5DMXX_L1_2.fq.gz R2.fq.gz

```

## Blasia: template

```bash
WORKING_DIR=${HOME}/data/dna-seq/xjy2
BASE_NAME=Blasia

cd ${WORKING_DIR}/${BASE_NAME}

anchr template \
    . \
    --basename ${BASE_NAME} \
    --genome 500000000 \
    --is_euk \
    --trim2 "--dedupe" \
    --cov2 "all" \
    --qual2 "25" \
    --len2 "60" \
    --filter "adapter,phix,artifact" \
    --tadpole \
    --mergereads \
    --prefilter 2 \
    --ecphase "1,2,3" \
    --insertsize \
    --parallel 16

```

## Blasia: run

```bash
bash 2_fastqc.sh
bash 2_kmergenie.sh

bash 2_insertSize.sh

bash 0_master.sh

# bash 0_cleanup.sh

```

Table: statInsertSize

| Group           |  Mean | Median | STDev | PercentOfPairs/PairOrientation |
|:----------------|------:|-------:|------:|-------------------------------:|
| tadpole.bbtools | 272.9 |    270 |  63.1 |                         12.49% |
| tadpole.picard  | 268.3 |    267 |  65.2 |                             FR |


Table: statReads

| Name     | N50 |    Sum |         # |
|:---------|----:|-------:|----------:|
| Illumina | 150 | 41.25G | 274986152 |
| trim     | 150 | 38.45G | 257875238 |
| Q25L60   | 150 | 37.95G | 256344175 |


Table: statTrimReads

| Name     | N50 |    Sum |         # |
|:---------|----:|-------:|----------:|
| clumpify | 150 | 38.84G | 258929014 |
| trim     | 150 | 38.45G | 257877030 |
| filter   | 150 | 38.45G | 257875238 |
| R1       | 150 | 19.23G | 128937619 |
| R2       | 150 | 19.22G | 128937619 |
| Rs       |   0 |      0 |         0 |


```text
#trim
#Matched        602078  0.23253%
#Name   Reads   ReadsPct
Reverse_adapter 139682  0.05395%
TruSeq_Adapter_Index_1_6        109627  0.04234%
pcr_dimer       66545   0.02570%
Nextera_LMP_Read2_External_Adapter      44351   0.01713%
PCR_Primers     38202   0.01475%
I5_Nextera_Transposase_1        35513   0.01372%
I5_Primer_Nextera_XT_and_Nextera_Enrichment_[N/S/E]501  33085   0.01278%
I5_Adapter_Nextera      18071   0.00698%
PhiX_read2_adapter      15286   0.00590%
TruSeq_Universal_Adapter        14373   0.00555%
I7_Primer_Nextera_XT_and_Nextera_Enrichment_N701        13053   0.00504%
I7_Nextera_Transposase_2        13026   0.00503%
I5_Nextera_Transposase_2        12761   0.00493%
RNA_Adapter_(RA5)_part_#_15013205       10492   0.00405%
I7_Adapter_Nextera_No_Barcode   10281   0.00397%
PhiX_read1_adapter      5932    0.00229%
I7_Nextera_Transposase_1        5762    0.00223%
RNA_PCR_Primer_Index_1_(RPI1)_2,9       4160    0.00161%
Nextera_LMP_Read1_External_Adapter      2767    0.00107%
Bisulfite_R1    2231    0.00086%
RNA_PCR_Primer_(RP1)_part_#_15013198    2052    0.00079%
Bisulfite_R2    2048    0.00079%
```

```text
#filter
#Matched        942     0.00037%
#Name   Reads   ReadsPct
TruSeq_Universal_Adapter        199     0.00008%
contam_32       152     0.00006%
Reverse_adapter 110     0.00004%
```


Table: statMergeReads

| Name          | N50 |     Sum |         # |
|:--------------|----:|--------:|----------:|
| clumped       | 150 |  38.45G | 257815542 |
| ecco          | 150 |  38.44G | 257815542 |
| eccc          | 150 |  38.44G | 257815542 |
| ecct          | 150 |  15.78G | 105593852 |
| extended      | 190 |  19.31G | 105593852 |
| merged        | 336 |  15.39G |  46977680 |
| unmerged.raw  | 170 |   1.93G |  11638492 |
| unmerged.trim | 170 |   1.93G |  11638428 |
| U1            | 170 | 970.81M |   5819214 |
| U2            | 170 | 963.83M |   5819214 |
| Us            |   0 |       0 |         0 |
| pe.cor        | 327 |  17.37G | 105593788 |

| Group            |  Mean | Median | STDev | PercentOfPairs |
|:-----------------|------:|-------:|------:|---------------:|
| ihist.merge1.txt | 245.4 |    252 |  30.8 |         35.33% |
| ihist.merge.txt  | 327.6 |    326 |  58.9 |         88.98% |


Table: statQuorum

| Name   | CovIn | CovOut | Discard% | AvgRead |  Kmer | RealG |  EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|------:|------:|------:|---------:|----------:|
| Q0L0   |  76.9 |   39.6 |   48.47% |     148 | "105" |  500M | 2.05G |     4.10 | 1:51'32'' |
| Q25L60 |  75.9 |   39.6 |   47.82% |     147 | "105" |  500M | 2.04G |     4.08 | 1:53'33'' |


Table: statKunitigsAnchors.md

| Name           | CovCor | Mapped% | N50Anchor |     Sum |      # | N50Others |     Sum |      # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|--------:|-------:|----------:|--------:|-------:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q0L0XallP000   |   39.6 |  34.57% |      1567 | 234.05M | 146833 |      1630 | 318.18M | 448878 |    6.0 | 1.0 |   3.0 |  12.0 | "31,41,51,61,71,81" | 4:43'17'' | 0:54'52'' |
| Q25L60XallP000 |   39.6 |  35.03% |      1568 | 234.21M | 146889 |      1652 | 319.52M | 447832 |    6.0 | 1.0 |   3.0 |  12.0 | "31,41,51,61,71,81" | 4:40'31'' | 0:52'43'' |


Table: statTadpoleAnchors.md

| Name           | CovCor | Mapped% | N50Anchor |     Sum |      # | N50Others |     Sum |      # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|--------:|-------:|----------:|--------:|-------:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q0L0XallP000   |   39.6 |  39.59% |      1452 | 152.89M | 102218 |      2689 | 249.91M | 313815 |    7.0 | 2.0 |   3.0 |  14.0 | "31,41,51,61,71,81" | 2:31'38'' | 0:36'54'' |
| Q25L60XallP000 |   39.6 |  39.96% |      1452 | 153.09M | 102364 |      2742 | 251.97M | 314054 |    7.0 | 2.0 |   3.0 |  14.0 | "31,41,51,61,71,81" | 2:28'18'' | 0:36'07'' |


Table: statMRKunitigsAnchors.md

| Name       | CovCor | Mapped% | N50Anchor |  Sum | # | N50Others |   Sum | # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:-----------|-------:|--------:|----------:|-----:|--:|----------:|------:|--:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| MRXallP000 |   34.7 |   0.00% |      1098 | 1.1K | 1 |      1057 | 7.66K | 9 |   10.5 | 3.5 |   3.0 |  21.0 | "31,41,51,61,71,81" | 2:49'58'' | 0:02'27'' |


Table: statMRTadpoleAnchors.md

| Name       | CovCor | Mapped% | N50Anchor |     Sum |     # | N50Others |     Sum |      # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:-----------|-------:|--------:|----------:|--------:|------:|----------:|--------:|-------:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| MRXallP000 |   34.7 |  51.10% |      1435 | 119.18M | 80060 |      4247 | 189.09M | 214178 |    9.0 | 2.0 |   3.0 |  18.0 | "31,41,51,61,71,81" | 1:55'09'' | 0:26'32'' |


Table: statFinal

| Name                             |   N50 |       Sum |      # |
|:---------------------------------|------:|----------:|-------:|
| 7_mergeKunitigsAnchors.anchors   |  1577 | 239202947 | 149125 |
| 7_mergeKunitigsAnchors.others    |  1754 | 299185866 | 163520 |
| 7_mergeTadpoleAnchors.anchors    |  1458 | 156336261 | 104184 |
| 7_mergeTadpoleAnchors.others     |  2980 | 238940022 | 104009 |
| 7_mergeMRKunitigsAnchors.anchors |  1098 |      1098 |      1 |
| 7_mergeMRKunitigsAnchors.others  |  1057 |      7595 |      7 |
| 7_mergeMRTadpoleAnchors.anchors  |  1435 | 119177469 |  80060 |
| 7_mergeMRTadpoleAnchors.others   |  4669 | 180623770 |  66583 |
| 7_mergeAnchors.anchors           |  1616 | 307019050 | 187027 |
| 7_mergeAnchors.others            |  1859 | 412646120 | 214718 |
| spades.non-contained             |     0 |         0 |      0 |
| platanus.contig                  |  1303 |  24595669 |  47105 |
| platanus.scaffold                | 16747 |  20051864 |  10970 |
| platanus.non-contained           | 20470 |  18177776 |   2211 |
| platanus.anchor                  |  7537 |  15895697 |   3339 |


# XIAN01

## XIAN01: download

```bash
mkdir -p ~/data/dna-seq/xjy2/XIAN01/2_illumina
cd ~/data/dna-seq/xjy2/XIAN01/2_illumina

ln -s ../../data/XIAN/CL100036849_L02_9_1.fq.gz R1.fq.gz
ln -s ../../data/XIAN/CL100036849_L02_9_2.fq.gz R2.fq.gz

```

## XIAN01: template

* Rsync to hpcc

```bash
rsync -avP \
    ~/data/dna-seq/xjy2/data/ \
    wangq@202.119.37.251:data/dna-seq/xjy2/data

rsync -avP \
    ~/data/dna-seq/xjy2/XIAN01/ \
    wangq@202.119.37.251:data/dna-seq/xjy2/XIAN01

#rsync -avP wangq@202.119.37.251:data/dna-seq/xjy2/XIAN01/ ~/data/dna-seq/xjy2/XIAN01

```

```bash
WORKING_DIR=${HOME}/data/dna-seq/xjy2
BASE_NAME=XIAN01

cd ${WORKING_DIR}/${BASE_NAME}

anchr template \
    . \
    --basename ${BASE_NAME} \
    --genome 430000000 \
    --is_euk \
    --trim2 "--uniq " \
    --cov2 "all" \
    --qual2 "25" \
    --len2 "60" \
    --parallel 16

```

## XIAN01: run

Same as [FCM05: run](#fcm05-run)

| Name     | N50 |   Sum |        # |
|:---------|----:|------:|---------:|
| Illumina | 100 | 6.38G | 63763512 |
| uniq     | 100 | 6.35G | 63473944 |
| Q25L60   | 100 | 4.59G | 46442650 |

| Group  |  Mean | Median | STDev | PercentOfPairs |
|:-------|------:|-------:|------:|---------------:|
| Q25L60 | 148.1 |    135 |  43.7 |          0.36% |

| Name         | N50 |     Sum |        # |
|:-------------|----:|--------:|---------:|
| clumped      | 100 |   6.32G | 63249872 |
| filterbytile |   0 |       0 |        0 |
| trimmed      | 100 |   5.39G | 55761436 |
| filtered     | 100 |   5.39G | 55761392 |
| ecco         | 100 |   5.39G | 55761392 |
| eccc         | 100 |   5.39G | 55761392 |
| ecct         | 100 | 249.64M |  2610784 |
| extended     | 117 | 291.97M |  2610784 |
| merged       | 179 |   99.8M |   603676 |
| unmerged.raw | 100 | 151.11M |  1403432 |
| unmerged     | 100 | 111.24M |  1060982 |

# Create tarballs

```bash
for BASE_NAME in FCM03 FCM05 FCM07 FCM13; do
    echo >&2 "==> ${BASE_NAME}"
    pushd ${HOME}/data/dna-seq/xjy2/${BASE_NAME}
    
    if [ -e ../${BASE_NAME}.tar.gz ]; then
        echo >&2 "    ${BASE_NAME}.tar.gz exists"
    else
        tar -czvf \
            ../${BASE_NAME}.tar.gz \
            2_illumina/fastqc/*.html \
            8_spades/spades.non-contained.fasta \
            8_platanus/platanus.non-contained.fasta \
            7_mergeAnchors/anchor.merge.fasta \
            7_mergeAnchors/others.non-contained.fasta
    fi

    popd
done

```

