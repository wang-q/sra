# Magnoliids: anchr + spades + platanus

[TOC levels=1-3]: # " "
- [Magnoliids: anchr + spades + platanus](#magnoliids-anchr--spades--platanus)
- [FCM03](#fcm03)
    - [FCM03: download](#fcm03-download)
    - [FCM03: template](#fcm03-template)
    - [FCM03: run](#fcm03-run)
- [FCM05](#fcm05)
    - [FCM05: download](#fcm05-download)
    - [FCM05: template](#fcm05-template)
    - [FCM05: run](#fcm05-run)
- [FCM05B](#fcm05b)
    - [FCM05B: download](#fcm05b-download)
    - [FCM05B: reads stats](#fcm05b-reads-stats)
- [FCM05C](#fcm05c)
    - [FCM05C: download](#fcm05c-download)
    - [FCM05C: reads stats](#fcm05c-reads-stats)
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
- [FCM07](#fcm07)
    - [FCM07: download](#fcm07-download)
    - [FCM07: template](#fcm07-template)
    - [FCM07: run](#fcm07-run)
- [FCM13](#fcm13)
    - [FCM13: download](#fcm13-download)
    - [FCM13: template](#fcm13-template)
    - [FCM13: run](#fcm13-run)
- [XIAN01](#xian01)
    - [XIAN01: download](#xian01-download)
    - [XIAN01: template](#xian01-template)
    - [XIAN01: run](#xian01-run)
- [Create tarballs](#create-tarballs)


# FCM03

* *Piper longum L.*
* 荜菝
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

anchr template \
    . \
    --basename ${BASE_NAME} \
    --genome 550000000 \
    --is_euk \
    --trim2 "--uniq " \
    --cov2 "all" \
    --qual2 "25 30" \
    --len2 "60" \
    --parallel 24

```

## FCM03: run

Same as [FCM05: run](#fcm05-run)

| Name     | N50 |         Sum |         # |
|:---------|----:|------------:|----------:|
| Illumina | 151 | 23454552764 | 155328164 |
| uniq     | 151 | 19303241134 | 127836034 |
| Q25L60   | 151 | 17442922681 | 120543118 |
| Q30L60   | 151 | 16704570709 | 118992276 |


| Name   |  SumIn | CovIn | SumOut | CovOut | Discard% | AvgRead |  Kmer | RealG |    EstG | Est/Real |   RunTime |
|:-------|-------:|------:|-------:|-------:|---------:|--------:|------:|------:|--------:|---------:|----------:|
| Q25L60 | 17.44G |  31.7 | 14.84G |   27.0 |  14.905% |     144 | "105" |  550M | 544.02M |     0.99 | 0:51'09'' |
| Q30L60 | 16.71G |  30.4 | 14.84G |   27.0 |  11.200% |     140 |  "97" |  550M | 540.34M |     0.98 | 0:55'01'' |

| Name          | SumCor | CovCor | N50SR |     Sum |      # | N50Anchor |     Sum |     # | N50Others |     Sum |      # |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|-------:|-------:|------:|--------:|-------:|----------:|--------:|------:|----------:|--------:|-------:|--------------------:|----------:|:----------|
| Q25L60X10P000 |   5.5G |   10.0 |   871 |  255.3M | 294060 |      1598 |  91.24M | 56071 |       690 | 164.06M | 237989 | "31,41,51,61,71,81" | 3:09'45'' | 0:17'37'' |
| Q25L60X10P001 |   5.5G |   10.0 |   871 | 255.25M | 294138 |      1601 |  91.08M | 55937 |       689 | 164.18M | 238201 | "31,41,51,61,71,81" | 3:13'05'' | 0:17'37'' |
| Q25L60X20P000 |    11G |   20.0 |   965 | 281.94M | 300082 |      1694 | 125.86M | 73365 |       692 | 156.08M | 226717 | "31,41,51,61,71,81" | 4:35'51'' | 0:24'44'' |
| Q25L60X25P000 | 13.75G |   25.0 |   985 | 280.44M | 293516 |      1708 | 130.35M | 75264 |       692 | 150.09M | 218252 | "31,41,51,61,71,81" | 5:02'23'' | 0:25'51'' |
| Q30L60X10P000 |   5.5G |   10.0 |   870 | 253.75M | 292252 |      1598 |  90.87M | 55802 |       688 | 162.88M | 236450 | "31,41,51,61,71,81" | 3:04'03'' | 0:17'39'' |
| Q30L60X10P001 |   5.5G |   10.0 |   871 | 254.12M | 292751 |      1605 |  90.88M | 55808 |       689 | 163.24M | 236943 | "31,41,51,61,71,81" | 2:32'31'' | 0:17'52'' |
| Q30L60X20P000 |    11G |   20.0 |   964 | 281.41M | 299387 |      1694 |  125.8M | 73373 |       692 | 155.61M | 226014 | "31,41,51,61,71,81" | 2:57'27'' | 0:24'25'' |
| Q30L60X25P000 | 13.75G |   25.0 |   986 |  280.1M | 292855 |      1707 | 130.48M | 75447 |       693 | 149.62M | 217408 | "31,41,51,61,71,81" | 3:10'28'' | 0:26'39'' |


| Name                   |  N50 |       Sum |       # |
|:-----------------------|-----:|----------:|--------:|
| anchor.merge           | 1762 | 185901183 |  104610 |
| others.merge           | 1055 |  50591371 |   46126 |
| spades.contig          | 4073 | 691875031 | 1465734 |
| spades.non-contained   | 9477 | 460154902 |   88826 |
| platanus.scaffold      |  401 | 345280915 | 1171002 |
| platanus.non-contained | 2381 | 128103732 |   58367 |

# FCM05

* *Saururus chinensis*
* 三白草
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
#bash 9_statFinal.sh

#bash 0_cleanup.sh

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

* Settings

```bash
WORKING_DIR=${HOME}/data/dna-seq/xjy2
BASE_NAME=FCM05B

```

* Illumina

```bash
mkdir -p ${HOME}/data/dna-seq/xjy2/FCM05B/2_illumina
cd ${HOME}/data/dna-seq/xjy2/FCM05B/2_illumina

ln -s ../../data/FCM05_H3T7VDMXX_L1_1.clean.fq.gz R1.fq.gz
ln -s ../../data/FCM05_H3T7VDMXX_L1_2.clean.fq.gz R2.fq.gz

```

* FastQC

* kmergenie

## FCM05B: reads stats

| Name     | N50 |         Sum |         # |
|:---------|----:|------------:|----------:|
| Illumina | 150 | 21181614300 | 141210762 |

# FCM05C

## FCM05C: download

* Settings

```bash
WORKING_DIR=${HOME}/data/dna-seq/xjy2
BASE_NAME=FCM05C

```

* Illumina

```bash
mkdir -p ${HOME}/data/dna-seq/xjy2/FCM05C/2_illumina
cd ${HOME}/data/dna-seq/xjy2/FCM05C/2_illumina

ln -s ../../data/FCM05_H3TC3DMXX_L1_1.clean.fq.gz R1.fq.gz
ln -s ../../data/FCM05_H3TC3DMXX_L1_2.clean.fq.gz R2.fq.gz

```

* FastQC

* kmergenie

## FCM05C: reads stats

| Name     | N50 |         Sum |         # |
|:---------|----:|------------:|----------:|
| Illumina | 150 | 78098850000 | 520659000 |

# FCM05D

## FCM05D: download

* Settings

```bash
WORKING_DIR=${HOME}/data/dna-seq/xjy2
BASE_NAME=FCM05D
REAL_G=530000000
IS_EUK="true"
COVERAGE2="40 80"
READ_QUAL="25 30"
READ_LEN="60"

```

* Illumina

```bash
mkdir -p ${WORKING_DIR}/${BASE_NAME}/2_illumina
cd ${WORKING_DIR}/${BASE_NAME}/2_illumina

gzip -d -c \
    ${WORKING_DIR}/FCM05B/2_illumina/R1.fq.gz \
    ${WORKING_DIR}/FCM05C/2_illumina/R1.fq.gz \
    > R1.fq

gzip -d -c \
    ${WORKING_DIR}/FCM05B/2_illumina/R2.fq.gz \
    ${WORKING_DIR}/FCM05C/2_illumina/R2.fq.gz \
    > R2.fq

find . -name "*.fq" | parallel -j 2 pigz -p 8

```

## FCM05D: preprocess Illumina reads

## FCM05D: reads stats

| Name     | N50 |         Sum |         # |
|:---------|----:|------------:|----------:|
| Illumina | 150 | 99280464300 | 661869762 |
| uniq     | 150 | 93376142100 | 622507614 |
| Q25L60   | 150 | 91328055756 | 615818436 |
| Q30L60   | 150 | 87307736280 | 605367143 |

## FCM05D: spades

## FCM05D: platanus

## FCM05D: quorum

| Name   |  SumIn | CovIn | SumOut | CovOut | Discard% | AvgRead |  Kmer | RealG |  EstG | Est/Real |    RunTime |
|:-------|-------:|------:|-------:|-------:|---------:|--------:|------:|------:|------:|---------:|-----------:|
| Q25L60 | 91.33G | 172.3 | 74.88G |  141.3 |  18.015% |     148 | "105" |  530M |  1.2G |     2.26 |  9:09'49'' |
| Q30L60 | 87.32G | 164.8 |    74G |  139.6 |  15.253% |     144 | "105" |  530M | 1.16G |     2.20 | 10:31'08'' |

## FCM05D: down sampling

## FCM05D: k-unitigs and anchors (sampled)


# FCM05SE

## FCM05SE: download

* Settings

```bash
WORKING_DIR=${HOME}/data/dna-seq/xjy2
BASE_NAME=FCM05SE
REAL_G=530000000
IS_EUK="true"
COVERAGE2="30 60"
READ_QUAL="25 30"
READ_LEN="60"

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


    if [ ! -e R1.sickle.fq.gz ]; then
        echo >&2 '    R1.sickle.fq.gz not exists'
        exit;
    fi

    if [ -e pe.cor.fa ]; then
        echo >&2 '    pe.cor.fa exists'
        exit;
    fi

    anchr quorum \
        R1.sickle.fq.gz \
        -p 16 \
        -o quorum.sh

    bash quorum.sh
    
    echo >&2
    " ::: ${READ_QUAL} ::: ${READ_LEN}

# Stats of processed reads
bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 1 header \
    > stat1.md

parallel --no-run-if-empty -k -j 3 "
    if [ ! -d 2_illumina/Q{1}L{2} ]; then
        exit;
    fi

    bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 1 2_illumina/Q{1}L{2} ${REAL_G}
    " ::: ${READ_QUAL} ::: ${READ_LEN} \
     >> stat1.md

cat stat1.md

```

| Name   |  SumIn | CovIn | SumOut | CovOut | Discard% | AvgRead | Kmer | RealG |    EstG | Est/Real |   RunTime |
|:-------|-------:|------:|-------:|-------:|---------:|--------:|-----:|------:|--------:|---------:|----------:|
| Q25L60 | 40.77G |  76.9 | 32.48G |   61.3 |  20.338% |     148 | "31" |  530M | 810.42M |     1.53 | 3:29'58'' |
| Q30L60 | 39.25G |  74.1 | 32.29G |   60.9 |  17.727% |     145 | "31" |  530M | 800.16M |     1.51 | 4:10'15'' |

## FCM05SE: down sampling

## FCM05SE: k-unitigs and anchors (sampled)

| Name          | SumCor | CovCor | N50Anchor |     Sum |     # | N50Others |     Sum |      # | median |  MAD | lower | upper |                Kmer |  RunTimeKU | RunTimeAN |
|:--------------|-------:|-------:|----------:|--------:|------:|----------:|--------:|-------:|-------:|-----:|------:|------:|--------------------:|-----------:|----------:|
| Q25L60X30P000 |  15.9G |   30.0 |      2868 | 226.12M | 91314 |       735 | 152.64M | 204739 |   18.0 |  6.0 |   2.0 |  36.0 | "31,41,51,61,71,81" | 16:27'17'' | 1:54'57'' |
| Q25L60X30P001 |  15.9G |   30.0 |      2229 | 174.52M | 82305 |       775 | 173.81M | 217933 |   17.0 |  6.0 |   2.0 |  34.0 | "31,41,51,61,71,81" | 16:22'52'' | 1:37'04'' |
| Q25L60X60P000 |  31.8G |   60.0 |      2093 |  85.78M | 42183 |      1353 | 373.14M | 315128 |   27.0 | 18.0 |   2.0 |  54.0 | "31,41,51,61,71,81" | 11:48'22'' | 1:14'10'' |
| Q30L60X30P000 |  15.9G |   30.0 |      2088 | 155.06M | 76399 |       799 | 180.76M | 218328 |   17.0 |  6.0 |   2.0 |  34.0 | "31,41,51,61,71,81" |  9:45'34'' | 1:24'51'' |
| Q30L60X30P001 |  15.9G |   30.0 |      2216 | 169.85M | 80345 |       778 | 174.47M | 217654 |   17.0 |  6.0 |   2.0 |  34.0 | "31,41,51,61,71,81" |  9:36'27'' | 1:28'13'' |
| Q30L60X60P000 |  31.8G |   60.0 |      2124 |  86.06M | 41891 |      1433 | 374.89M | 309034 |   27.0 | 18.0 |   2.0 |  54.0 | "31,41,51,61,71,81" | 10:57'54'' | 1:10'24'' |

## FCM05SE: merge anchors

## FCM05SE: final stats

## FCM05SE: clear intermediate files

# FCM07

* *Chimonanthus praecox*
* 蜡梅
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

#rsync -avP wangq@202.119.37.251:data/dna-seq/xjy2/FCM03/ ~/data/dna-seq/xjy2/FCM03

```

```bash
WORKING_DIR=${HOME}/data/dna-seq/xjy2
BASE_NAME=FCM07

cd ${WORKING_DIR}/${BASE_NAME}

anchr template \
    . \
    --basename ${BASE_NAME} \
    --genome 620000000 \
    --is_euk \
    --trim2 "--uniq " \
    --cov2 "all" \
    --qual2 "25 30" \
    --len2 "60" \
    --parallel 24

```

## FCM07: run

Same as [FCM05: run](#fcm05-run)

| Name     | N50 |         Sum |         # |
|:---------|----:|------------:|----------:|
| Illumina | 151 | 21952701630 | 145382130 |
| uniq     | 151 | 18070341234 | 119671134 |
| Q25L60   | 151 | 16564808588 | 113839810 |
| Q30L60   | 151 | 15904066489 | 112329431 |

| Name   |  SumIn | CovIn | SumOut | CovOut | Discard% | AvgRead |  Kmer | RealG |    EstG | Est/Real |   RunTime |
|:-------|-------:|------:|-------:|-------:|---------:|--------:|------:|------:|--------:|---------:|----------:|
| Q25L60 | 16.56G |  26.7 | 14.18G |   22.9 |  14.368% |     144 | "105" |  620M | 602.28M |     0.97 | 1:24'19'' |
| Q30L60 | 15.91G |  25.7 | 14.16G |   22.8 |  10.973% |     142 | "105" |  620M | 598.68M |     0.97 | 2:31'10'' |


| Name          | SumCor | CovCor | N50SR |     Sum |      # | N50Anchor |     Sum |     # | N50Others |     Sum |      # |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|-------:|-------:|------:|--------:|-------:|----------:|--------:|------:|----------:|--------:|-------:|--------------------:|----------:|:----------|
| Q25L60X10P000 |   6.2G |   10.0 |   984 | 326.31M | 334367 |      2074 | 145.03M | 71476 |       688 | 181.28M | 262891 | "31,41,51,61,71,81" | 6:11'46'' | 0:24'19'' |
| Q25L60X10P001 |   6.2G |   10.0 |   983 | 325.65M | 334063 |      2071 | 144.59M | 71302 |       688 | 181.05M | 262761 | "31,41,51,61,71,81" | 4:34'08'' | 0:24'09'' |
| Q25L60X20P000 |  12.4G |   20.0 |  1098 | 336.31M | 310513 |      2775 | 172.81M | 71066 |       682 |  163.5M | 239447 | "31,41,51,61,71,81" | 5:24'29'' | 0:29'23'' |
| Q30L60X10P000 |   6.2G |   10.0 |   986 | 324.22M | 332021 |      2069 | 144.51M | 71458 |       688 | 179.71M | 260563 | "31,41,51,61,71,81" | 3:39'43'' | 0:30'17'' |
| Q30L60X10P001 |   6.2G |   10.0 |   986 | 323.44M | 331666 |      2066 | 143.76M | 71050 |       687 | 179.69M | 260616 | "31,41,51,61,71,81" | 4:16'51'' | 0:31'27'' |
| Q30L60X20P000 |  12.4G |   20.0 |  1100 |  336.9M | 310523 |      2774 | 173.47M | 71406 |       683 | 163.43M | 239117 | "31,41,51,61,71,81" | 4:01'53'' | 0:29'03'' |


| Name                   |   N50 |       Sum |       # |
|:-----------------------|------:|----------:|--------:|
| anchor.merge           |  2394 | 226651719 |   98385 |
| others.merge           |  1061 |  52662986 |   46920 |
| spades.contig          |  6652 | 736473733 | 1252160 |
| spades.non-contained   | 12861 | 528958723 |   82401 |
| platanus.scaffold      |  1551 | 394046181 |  975205 |
| platanus.non-contained |  3757 | 227288969 |   76987 |

# FCM13

* *Machilus thunbergii*
* 红楠
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

#rsync -avP wangq@202.119.37.251:data/dna-seq/xjy2/FCM03/ ~/data/dna-seq/xjy2/FCM03

```

```bash
WORKING_DIR=${HOME}/data/dna-seq/xjy2
BASE_NAME=FCM13

cd ${WORKING_DIR}/${BASE_NAME}

anchr template \
    . \
    --basename ${BASE_NAME} \
    --genome 430000000 \
    --is_euk \
    --trim2 "--uniq " \
    --cov2 "all" \
    --qual2 "25 30" \
    --len2 "60" \
    --parallel 24

```

## FCM13: run

Same as [FCM05: run](#fcm05-run)

| Name     | N50 |         Sum |         # |
|:---------|----:|------------:|----------:|
| Illumina | 151 | 25328382130 | 167737630 |
| uniq     | 151 | 21475363752 | 142220952 |
| Q25L60   | 151 | 19383906193 | 133949012 |
| Q30L60   | 151 | 18623646006 | 132409641 |


| Name   |  SumIn | CovIn | SumOut | CovOut | Discard% | AvgRead |  Kmer | RealG |    EstG | Est/Real |   RunTime |
|:-------|-------:|------:|-------:|-------:|---------:|--------:|------:|------:|--------:|---------:|----------:|
| Q25L60 | 19.38G |  45.1 | 15.81G |   36.8 |  18.428% |     144 | "105" |  430M | 898.48M |     2.09 | 1:02'01'' |
| Q30L60 | 18.63G |  43.3 |  15.7G |   36.5 |  15.704% |     141 |  "99" |  430M | 885.66M |     2.06 | 1:05'09'' |


| Name          | SumCor | CovCor | N50SR |     Sum |      # | N50Anchor |    Sum |     # | N50Others |     Sum |      # |                Kmer |  RunTimeKU | RunTimeAN |
|:--------------|-------:|-------:|------:|--------:|-------:|----------:|-------:|------:|----------:|--------:|-------:|--------------------:|-----------:|:----------|
| Q25L60X10P000 |   4.3G |   10.0 |   605 |  61.82M |  97880 |      1214 |  1.66M |  1323 |       601 |  60.15M |  96557 | "31,41,51,61,71,81" |  1:25'50'' | 0:06'58'' |
| Q25L60X10P001 |   4.3G |   10.0 |   605 |  62.37M |  98733 |      1227 |  1.71M |  1348 |       601 |  60.66M |  97385 | "31,41,51,61,71,81" |  5:06'20'' | 0:06'44'' |
| Q25L60X10P002 |   4.3G |   10.0 |   605 |  61.69M |  97629 |      1233 |   1.7M |  1335 |       601 |  59.99M |  96294 | "31,41,51,61,71,81" |  2:40'55'' | 0:05'57'' |
| Q25L60X20P000 |   8.6G |   20.0 |   643 | 206.59M | 308983 |      1258 | 15.95M | 12176 |       627 | 190.64M | 296807 | "31,41,51,61,71,81" |  3:08'00'' | 0:17'15'' |
| Q25L60X25P000 | 10.75G |   25.0 |   663 |  263.9M | 382272 |      1303 | 29.65M | 21882 |       636 | 234.25M | 360390 | "31,41,51,61,71,81" | 21:24'23'' | 0:23'23'' |
| Q25L60X30P000 |  12.9G |   30.0 |   682 |  306.5M | 431011 |      1344 | 44.56M | 31859 |       644 | 261.94M | 399152 | "31,41,51,61,71,81" |  4:43'48'' | 0:24'34'' |
| Q30L60X10P000 |   4.3G |   10.0 |   604 |  60.84M |  96331 |      1217 |   1.7M |  1349 |       600 |  59.15M |  94982 | "31,41,51,61,71,81" |  1:04'12'' | 0:04'00'' |
| Q30L60X10P001 |   4.3G |   10.0 |   605 |  61.36M |  97058 |      1221 |  1.72M |  1361 |       601 |  59.64M |  95697 | "31,41,51,61,71,81" |  1:24'51'' | 0:04'03'' |
| Q30L60X10P002 |   4.3G |   10.0 |   604 |  60.38M |  95650 |      1228 |  1.65M |  1300 |       600 |  58.73M |  94350 | "31,41,51,61,71,81" |  1:13'43'' | 0:05'04'' |
| Q30L60X20P000 |   8.6G |   20.0 |   642 | 202.33M | 302950 |      1257 | 15.41M | 11775 |       626 | 186.92M | 291175 | "31,41,51,61,71,81" |  3:43'17'' | 0:19'14'' |
| Q30L60X25P000 | 10.75G |   25.0 |   661 | 258.28M | 375114 |      1297 | 28.32M | 20981 |       635 | 229.96M | 354133 | "31,41,51,61,71,81" |  5:19'18'' | 0:30'49'' |
| Q30L60X30P000 |  12.9G |   30.0 |   680 | 298.59M | 421566 |      1336 | 42.37M | 30472 |       643 | 256.22M | 391094 | "31,41,51,61,71,81" | 12:11'08'' | 0:47'48'' |


| Name                   |  N50 |       Sum |      # |
|:-----------------------|-----:|----------:|-------:|
| anchor.merge           | 1315 |  66842601 |  48521 |
| others.merge           | 1052 |  35360272 |  32084 |
| spades.contig          | 5558 | 794532947 | 683063 |
| spades.non-contained   | 8410 | 621971771 | 131159 |
| platanus.scaffold      | 1487 |    665925 |   1867 |
| platanus.non-contained | 4281 |    371926 |    108 |
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
            8_spades/contigs.non-contained.fasta \
            8_platanus/gapClosed.non-contained.fasta \
            merge/anchor.merge.fasta \
            merge/others.merge.fasta
    fi

    popd
done

```

