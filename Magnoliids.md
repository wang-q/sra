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
- [FCM07](#fcm07)
    - [FCM07: download](#fcm07-download)
    - [FCM07: template](#fcm07-template)
    - [FCM07: run](#fcm07-run)
- [FCM13](#fcm13)
    - [FCM13: download](#fcm13-download)
    - [FCM13: template](#fcm13-template)
    - [FCM13: run](#fcm13-run)
- [Blasia](#blasia)
    - [Blasia: download](#blasia-download)
    - [Blasia: template](#blasia-template)
    - [Blasia: run](#blasia-run)
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
QUEUE_NAME=largemem

cd ${WORKING_DIR}/${BASE_NAME}

anchr template \
    . \
    --basename ${BASE_NAME} \
    --genome 550000000 \
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

## FCM03: run

Same as [FCM05: run](#fcm05-run)

| Name     | N50 |    Sum |         # |
|:---------|----:|-------:|----------:|
| Illumina | 151 | 23.45G | 155328164 |
| uniq     | 151 |  19.3G | 127836034 |
| bbduk    | 150 | 19.08G | 127628760 |
| Q25L60   | 150 | 17.31G | 120249536 |
| Q30L60   | 150 | 16.59G | 118666308 |

| Group  |  Mean | Median | STDev | PercentOfPairs |
|:-------|------:|-------:|------:|---------------:|
| Q25L60 | 332.0 |    340 |  71.9 |          4.33% |
| Q30L60 | 332.6 |    341 |  71.9 |          4.78% |

| Name           | N50 |    Sum |         # |
|:---------------|----:|-------:|----------:|
| clumped        | 151 | 17.69G | 117149176 |
| filteredbytile | 151 | 16.77G | 111083018 |
| trimmed        | 150 |  16.1G | 109848094 |
| filtered       | 150 |  16.1G | 109845134 |
| ecco           | 150 |  16.1G | 109845134 |
| eccc           | 150 |  16.1G | 109845134 |
| ecct           | 150 | 12.48G |  84760194 |
| extended       | 190 | 15.51G |  84760194 |
| merged         | 387 | 12.52G |  33652070 |
| unmerged.raw   | 179 |  3.02G |  17456054 |
| unmerged       | 175 |  2.66G |  16414560 |

| Group            |  Mean | Median | STDev | PercentOfPairs |
|:-----------------|------:|-------:|------:|---------------:|
| ihist.merge1.txt | 227.3 |    231 |  38.0 |         14.01% |
| ihist.merge.txt  | 372.0 |    379 |  67.3 |         79.41% |

```text
#mergeReads
#Matched	1490	0.00136%
#Name	Reads	ReadsPct
TruSeq_Universal_Adapter	531	0.00048%
contam_256	219	0.00020%
contam_129	159	0.00014%
PhiX_read2_adapter	131	0.00012%
```

| Name   | CovIn | CovOut | Discard% | AvgRead |  Kmer | RealG |    EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|------:|------:|--------:|---------:|----------:|
| Q25L60 |  31.5 |   27.2 |   13.62% |     143 | "105" |  550M | 543.83M |     0.99 | 0:32'55'' |
| Q30L60 |  30.2 |   27.1 |   10.23% |     140 |  "99" |  550M | 540.14M |     0.98 | 0:34'59'' |


| Name           | CovCor | Mapped% | N50Anchor |     Sum |     # | N50Others |    Sum |     # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|--------:|------:|----------:|-------:|------:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q25L60XallP000 |   27.0 |  21.27% |      1645 | 113.71M | 67685 |      1206 | 21.23M | 16808 |   18.0 | 5.0 |   2.0 |  36.0 | "31,41,51,61,71,81" | 1:54'47'' | 0:26'14'' |
| Q30L60XallP000 |   27.0 |  21.80% |      1635 | 112.54M | 67305 |      1220 | 22.22M | 17438 |   18.0 | 5.0 |   2.0 |  36.0 | "31,41,51,61,71,81" | 1:53'03'' | 0:25'57'' |

| Name                           |  N50 |       Sum |        # |
|:-------------------------------|-----:|----------:|---------:|
| 6_mergeKunitigsAnchors.anchors | 1651 | 129067164 |    76897 |
| 6_mergeKunitigsAnchors.others  | 1084 |  39480152 |    33841 |
| 6_mergeTadpoleAnchors.anchors  | 1591 | 114706228 |    70610 |
| 6_mergeTadpoleAnchors.others   | 1071 |  24493606 |    21239 |
| 6_mergeAnchors.anchors         | 1651 | 129063933 |    76894 |
| 6_mergeAnchors.others          | 1084 |  39486706 |    33847 |
| tadpole.Q25L60                 |  265 | 269294361 |  1068895 |
| tadpole.Q30L60                 |  266 | 268181459 |  1061328 |
| spades.contig                  | 3500 | 715063366 |  1629119 |
| spades.scaffold                | 4148 | 715983793 |  1618660 |
| spades.non-contained           | 8927 | 460553220 |    92153 |
| platanus.contig                |   77 | 792545775 | 10966995 |
| platanus.scaffold              |  387 | 344965047 |  1175883 |
| platanus.non-contained         | 2363 | 126282645 |    57856 |

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

#rsync -avP wangq@202.119.37.251:data/dna-seq/xjy2/FCM07/ ~/data/dna-seq/xjy2/FCM07

```

```bash
WORKING_DIR=${HOME}/data/dna-seq/xjy2
BASE_NAME=FCM07
QUEUE_NAME=mpi

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

| Name     | N50 |    Sum |         # |
|:---------|----:|-------:|----------:|
| Illumina | 151 | 21.95G | 145382130 |
| uniq     | 151 | 18.07G | 119671134 |
| Q25L60   | 151 | 16.56G | 113839810 |
| Q30L60   | 151 |  15.9G | 112329431 |

| Name   | CovIn | CovOut | Discard% | AvgRead |  Kmer | RealG |    EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|------:|------:|--------:|---------:|----------:|
| Q25L60 |  26.7 |   22.9 |   14.39% |     144 | "105" |  620M | 602.28M |     0.97 | 0:35'36'' |
| Q30L60 |  25.7 |   22.8 |   11.00% |     142 | "105" |  620M | 598.68M |     0.97 | 0:36'43'' |

```text
#File	pe.cor.raw
#Total	96840849
#Matched	30289	0.03128%
#Name	Reads	ReadsPct
Reverse_adapter	30128	0.03111%

#File	pe.cor.raw
#Total	99623778
#Matched	37007	0.03715%
#Name	Reads	ReadsPct
Reverse_adapter	36779	0.03692%

```

| Name           | CovCor | Mapped% | N50Anchor |     Sum |     # | N50Others |    Sum |     # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|--------:|------:|----------:|-------:|------:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q25L60XallP000 |   22.9 |  28.03% |      2898 | 152.75M | 62569 |      1085 | 22.25M | 18936 |   16.0 | 2.0 |   3.3 |  32.0 | "31,41,51,61,71,81" | 2:04'46'' | 0:37'25'' |
| Q30L60XallP000 |   22.8 |  29.52% |      2878 | 153.44M | 63042 |      1090 | 22.78M | 19191 |   16.0 | 2.0 |   3.3 |  32.0 | "31,41,51,61,71,81" | 2:03'11'' | 0:39'00'' |

| Name                   |   N50 |       Sum |        # |
|:-----------------------|------:|----------:|---------:|
| anchors                |  2937 | 160757336 |    65160 |
| others                 |  1092 |  28992092 |    24413 |
| spades.contig          | 10552 | 706852007 |  1044436 |
| spades.scaffold        | 12370 | 707342249 |  1039001 |
| spades.non-contained   | 17914 | 534928515 |    68485 |
| platanus.contig        |    80 | 879005310 | 11702597 |
| platanus.scaffold      |  1551 | 394047530 |   975210 |
| platanus.non-contained |  3757 | 227288114 |    76986 |

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

#rsync -avP wangq@202.119.37.251:data/dna-seq/xjy2/FCM13/ ~/data/dna-seq/xjy2/FCM13

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

| Name     | N50 |    Sum |         # |
|:---------|----:|-------:|----------:|
| Illumina | 151 | 25.33G | 167737630 |
| uniq     | 151 | 21.48G | 142220952 |
| Q25L60   | 151 | 19.38G | 133949012 |
| Q30L60   | 151 | 18.62G | 132409641 |

| Name   | CovIn | CovOut | Discard% | AvgRead |  Kmer | RealG |    EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|------:|------:|--------:|---------:|----------:|
| Q25L60 |  45.1 |   36.7 |   18.54% |     144 | "105" |  430M | 898.48M |     2.09 | 0:44'39'' |
| Q30L60 |  43.3 |   36.5 |   15.82% |     141 |  "99" |  430M | 885.66M |     2.06 | 0:42'03'' |

```text
#File	pe.cor.raw
#Total	108698349
#Matched	154000	0.14168%
#Name	Reads	ReadsPct
Reverse_adapter	152904	0.14067%

#File	pe.cor.raw
#Total	111353862
#Matched	151173	0.13576%
#Name	Reads	ReadsPct
Reverse_adapter	150123	0.13482%

```

| Name           | CovCor | Mapped% | N50Anchor |    Sum |     # | N50Others |    Sum |     # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|-------:|------:|----------:|-------:|------:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q25L60XallP000 |   36.7 |   5.75% |      1294 | 49.43M | 36446 |      1118 | 23.84M | 19922 |    8.0 | 1.0 |   2.0 |  16.0 | "31,41,51,61,71,81" | 2:32'05'' | 0:10'14'' |
| Q30L60XallP000 |   36.5 |   5.75% |      1279 | 43.08M | 32117 |      1132 | 22.98M | 19031 |    8.0 | 1.0 |   2.0 |  16.0 | "31,41,51,61,71,81" | 2:25'39'' | 0:09'00'' |

| Name                   |  N50 |       Sum |      # |
|:-----------------------|-----:|----------:|-------:|
| anchors                | 1298 |  56173493 |  41265 |
| others                 | 1119 |  31404863 |  26161 |
| spades.contig          | 5481 | 821293493 | 633731 |
| spades.scaffold        | 5657 | 821482035 | 630055 |
| spades.non-contained   | 7990 | 650897244 | 140785 |
| platanus.contig        |  188 |   2687244 |  12956 |
| platanus.scaffold      | 1298 |    703697 |   1960 |
| platanus.non-contained | 5575 |    384225 |    104 |

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
| clumpify | 150 | 38.84G | 258929014 |
| trim     | 150 | 38.45G | 257877030 |
| filter   | 150 | 38.45G | 257875238 |
| trimmed  | 150 | 38.45G | 257875238 |
| Q25L60   | 150 | 37.95G | 256344175 |

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
| ecct          | 150 |  15.78G | 105594028 |
| extended      | 190 |  19.31G | 105594028 |
| merged        | 336 |  15.39G |  46977655 |
| unmerged.raw  | 170 |   1.93G |  11638718 |
| unmerged.trim | 170 |   1.93G |  11638654 |
| U1            | 170 | 970.83M |   5819327 |
| U2            | 170 | 963.84M |   5819327 |
| Us            |   0 |       0 |         0 |
| pe.cor        | 327 |  17.37G | 105593964 |

| Group            |  Mean | Median | STDev | PercentOfPairs |
|:-----------------|------:|-------:|------:|---------------:|
| ihist.merge1.txt | 245.4 |    252 |  30.8 |         35.33% |
| ihist.merge.txt  | 327.6 |    326 |  58.9 |         88.98% |


Table: statQuorum

| Name   | CovIn | CovOut | Discard% | AvgRead |  Kmer | RealG |  EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|------:|------:|------:|---------:|----------:|
| Q25L60 |  75.9 |   39.6 |   47.82% |     147 | "105" |  500M | 2.04G |     4.08 | 1:54'56'' |


Table: statKunitigsAnchors.md

| Name           | CovCor | Mapped% | N50Anchor |     Sum |      # | N50Others |     Sum |      # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|--------:|-------:|----------:|--------:|-------:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q25L60XallP000 |   39.6 |  35.03% |      1568 | 234.21M | 146889 |      1652 | 319.52M | 447840 |    6.0 | 1.0 |   3.0 |  12.0 | "31,41,51,61,71,81" | 4:36'18'' | 0:52'06'' |


Table: statTadpoleAnchors.md

| Name           | CovCor | Mapped% | N50Anchor |     Sum |      # | N50Others |     Sum |      # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|--------:|-------:|----------:|--------:|-------:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q25L60XallP000 |   39.6 |  39.96% |      1452 | 153.09M | 102364 |      2742 | 251.97M | 314053 |    7.0 | 2.0 |   3.0 |  14.0 | "31,41,51,61,71,81" | 2:31'38'' | 0:37'04'' |


Table: statMRKunitigsAnchors.md

| Name       | CovCor | Mapped% | N50Anchor |  Sum | # | N50Others |   Sum | # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:-----------|-------:|--------:|----------:|-----:|--:|----------:|------:|--:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| MRXallP000 |   34.7 |   0.00% |      1098 | 1.1K | 1 |      1057 | 7.66K | 9 |   10.5 | 3.5 |   3.0 |  21.0 | "31,41,51,61,71,81" | 2:50'11'' | 0:04'03'' |


Table: statMRTadpoleAnchors.md

| Name       | CovCor | Mapped% | N50Anchor |     Sum |     # | N50Others |     Sum |      # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:-----------|-------:|--------:|----------:|--------:|------:|----------:|--------:|-------:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| MRXallP000 |   34.7 |  51.09% |      1435 | 119.14M | 80025 |      4252 | 189.14M | 214157 |    9.0 | 2.0 |   3.0 |  18.0 | "31,41,51,61,71,81" | 1:53'06'' | 0:27'09'' |


Table: statFinal

| Name                             |   N50 |       Sum |      # |
|:---------------------------------|------:|----------:|-------:|
| 7_mergeKunitigsAnchors.anchors   |  1568 | 234209380 | 146889 |
| 7_mergeKunitigsAnchors.others    |  1792 | 289834250 | 156783 |
| 7_mergeTadpoleAnchors.anchors    |  1452 | 153090140 | 102364 |
| 7_mergeTadpoleAnchors.others     |  3012 | 234752121 | 101544 |
| 7_mergeMRKunitigsAnchors.anchors |  1098 |      1098 |      1 |
| 7_mergeMRKunitigsAnchors.others  |  1057 |      7595 |      7 |
| 7_mergeMRTadpoleAnchors.anchors  |  1435 | 119137282 |  80025 |
| 7_mergeMRTadpoleAnchors.others   |  4672 | 180682428 |  66589 |
| 7_mergeAnchors.anchors           |  1608 | 302957766 | 185436 |
| 7_mergeAnchors.others            |  1904 | 402520272 | 207343 |
| spades.non-contained             |     0 |         0 |      0 |
| platanus.contig                  |  1322 |  24712868 |  47402 |
| platanus.scaffold                | 17270 |  20078385 |  10550 |
| platanus.non-contained           | 20717 |  18259155 |   2167 |
| platanus.anchor                  |  7812 |  16004544 |   3311 |


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

