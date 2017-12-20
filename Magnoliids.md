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
    - [FCM05D: preprocess Illumina reads](#fcm05d-preprocess-illumina-reads)
    - [FCM05D: reads stats](#fcm05d-reads-stats)
    - [FCM05D: spades](#fcm05d-spades)
    - [FCM05D: platanus](#fcm05d-platanus)
    - [FCM05D: quorum](#fcm05d-quorum)
    - [FCM05D: down sampling](#fcm05d-down-sampling)
    - [FCM05D: k-unitigs and anchors (sampled)](#fcm05d-k-unitigs-and-anchors-sampled)
- [FCM05SE](#fcm05se)
    - [FCM05SE: download](#fcm05se-download)
    - [FCM05SE: preprocess Illumina reads](#fcm05se-preprocess-illumina-reads)
    - [FCM05SE: reads stats](#fcm05se-reads-stats)
    - [FCM05SE: spades](#fcm05se-spades)
    - [FCM05SE: platanus](#fcm05se-platanus)
    - [FCM05SE: quorum](#fcm05se-quorum)
    - [FCM05SE: down sampling](#fcm05se-down-sampling)
    - [FCM05SE: k-unitigs and anchors (sampled)](#fcm05se-k-unitigs-and-anchors-sampled)
    - [FCM05SE: merge anchors](#fcm05se-merge-anchors)
    - [FCM05SE: final stats](#fcm05se-final-stats)
    - [FCM05SE: clear intermediate files](#fcm05se-clear-intermediate-files)
- [FCM07](#fcm07)
    - [FCM07: download](#fcm07-download)
    - [FCM07: template](#fcm07-template)
    - [FCM03: run](#fcm03-run)
- [FCM13](#fcm13)
    - [FCM13: download](#fcm13-download)
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

cd ${WORKING_DIR}/${BASE_NAME}

anchr template \
    . \
    --basename ${BASE_NAME} \
    --genome 530000000 \
    --is_euk \
    --trim2 "--uniq " \
    --cov2 "all" \
    --qual2 "25 30" \
    --len2 "60" \
    --parallel 24

```

## FCM05: run

```bash
# Illumina QC
bsub -q mpi -n 24 -J "${BASE_NAME}-2_fastqc" "bash 2_fastqc.sh"
bsub -q mpi -n 24 -J "${BASE_NAME}-2_kmergenie" "bash 2_kmergenie.sh"

# preprocess Illumina reads
bsub -q mpi -n 24 -J "${BASE_NAME}-2_trim" "bash 2_trim.sh"

# reads stats
bsub -w "done(${BASE_NAME}-2_trim)" \
    -q mpi -n 24 -J "${BASE_NAME}-9_statReads" "bash 9_statReads.sh"

# spades and platanus
bsub -w "done(${BASE_NAME}-2_trim)" \
    -q mpi -n 24 -J "${BASE_NAME}-8_spades" "bash 8_spades.sh"

bsub -w "done(${BASE_NAME}-2_trim)" \
    -q mpi -n 24 -J "${BASE_NAME}-8_platanus" "bash 8_platanus.sh"

# quorum
bsub -w "done(${BASE_NAME}-2_trim)" \
    -q mpi -n 24 -J "${BASE_NAME}-2_quorum" "bash 2_quorum.sh"
bsub -w "done(${BASE_NAME}-2_quorum)" \
    -q mpi -n 24 -J "${BASE_NAME}-9_statQuorum" "bash 9_statQuorum.sh"

# down sampling, k-unitigs and anchors
bsub -w "done(${BASE_NAME}-2_quorum)" \
    -q mpi -n 24 -J "${BASE_NAME}-4_downSampling" "bash 4_downSampling.sh"
bsub -w "done(${BASE_NAME}-4_downSampling)" \
    -q mpi -n 24 -J "${BASE_NAME}-4_kunitigs" "bash 4_kunitigs.sh"
bsub -w "done(${BASE_NAME}-4_kunitigs)" \
    -q mpi -n 24 -J "${BASE_NAME}-4_anchors" "bash 4_anchors.sh"
bsub -w "done(${BASE_NAME}-4_anchors)" \
    -q mpi -n 24 -J "${BASE_NAME}-9_statAnchors" "bash 9_statAnchors.sh"

# merge anchors
bsub -w "done(${BASE_NAME}-4_anchors)" \
    -q mpi -n 24 -J "${BASE_NAME}-6_mergeAnchors" "bash 6_mergeAnchors.sh 4_kunitigs"

# stats
#bash 9_statFinal.sh

#bash 0_cleanup.sh

```

| Name     | N50 |    Sum |         # |
|:---------|----:|-------:|----------:|
| Illumina | 151 | 24.45G | 161903886 |
| uniq     | 151 | 19.93G | 131977706 |
| Q25L60   | 151 | 18.13G | 124923112 |
| Q30L60   | 151 | 17.39G | 123304964 |


| Name   |  SumIn | CovIn | SumOut | CovOut | Discard% | AvgRead |  Kmer | RealG |    EstG | Est/Real |   RunTime |
|:-------|-------:|------:|-------:|-------:|---------:|--------:|------:|------:|--------:|---------:|----------:|
| Q25L60 | 18.13G |  34.2 | 14.98G |   28.3 |  17.362% |     144 | "105" |  530M | 576.61M |     1.09 | 1:04'59'' |
| Q30L60 | 17.39G |  32.8 |    15G |   28.3 |  13.773% |     141 |  "97" |  530M | 571.31M |     1.08 | 1:15'59'' |

```text
#File	pe.cor.raw
#Total	102536720
#Matched	35065	0.03420%
#Name	Reads	ReadsPct
Reverse_adapter	34827	0.03397%


```

| Name          | CovCor | N50Anchor |     Sum |     # | N50Others |     Sum |      # |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|-------:|----------:|--------:|------:|----------:|--------:|-------:|--------------------:|----------:|:----------|
| Q25L60X10P000 |   10.0 |      2598 | 207.47M | 88793 |       701 | 140.07M | 200351 | "31,41,51,61,71,81" | 6:16'04'' | 0:24'18'' |
| Q25L60X10P001 |   10.0 |      2596 | 207.21M | 88511 |       701 | 139.99M | 200184 | "31,41,51,61,71,81" | 7:51'15'' | 0:24'29'' |
| Q25L60X20P000 |   20.0 |      3532 | 265.47M | 94266 |       701 |  122.6M | 175984 | "31,41,51,61,71,81" | 6:57'52'' | 0:30'08'' |
| Q25L60X25P000 |   25.0 |      3553 | 272.95M | 97034 |       700 |  117.2M | 168667 | "31,41,51,61,71,81" | 8:00'14'' | 0:32'29'' |
| Q30L60X10P000 |   10.0 |      2599 | 206.37M | 88254 |       700 | 139.55M | 199676 | "31,41,51,61,71,81" | 4:39'45'' | 0:22'52'' |
| Q30L60X10P001 |   10.0 |      2605 | 206.37M | 87946 |       701 | 140.02M | 200081 | "31,41,51,61,71,81" | 4:42'44'' | 0:23'28'' |
| Q30L60X20P000 |   20.0 |      3563 | 264.98M | 93626 |       700 | 122.09M | 175257 | "31,41,51,61,71,81" | 5:15'02'' | 0:30'49'' |
| Q30L60X25P000 |   25.0 |      3604 | 272.61M | 96160 |       700 | 116.61M | 167771 | "31,41,51,61,71,81" | 5:46'20'' | 0:33'21'' |


| Name                   |   N50 |       Sum |       # |
|:-----------------------|------:|----------:|--------:|
| anchor.merge           |  3716 | 314168144 |  109058 |
| others.merge           |  1067 |  49908970 |   44031 |
| spades.contig          |  5617 | 765386700 | 1179340 |
| spades.non-contained   | 14367 | 524827717 |   85289 |
| platanus.scaffold      |   844 | 351522180 | 1069499 |
| platanus.non-contained |  4577 | 168928590 |   51243 |

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

* Illumina

```bash
mkdir -p ${WORKING_DIR}/${BASE_NAME}/2_illumina
cd ${WORKING_DIR}/${BASE_NAME}/2_illumina

ln -s ${WORKING_DIR}/FCM05D/2_illumina/R1.fq.gz R1.fq.gz

```

## FCM05SE: preprocess Illumina reads

```bash
cd ${WORKING_DIR}/${BASE_NAME}

cd 2_illumina

anchr trim \
    --uniq \
    --nosickle \
    R1.fq.gz \
    -o trim.sh
bash trim.sh

parallel --no-run-if-empty --linebuffer -k -j 3 "
    mkdir -p Q{1}L{2}
    cd Q{1}L{2}
    
    if [ -e R1.fq.gz ]; then
        echo '    R1.fq.gz already presents'
        exit;
    fi

    anchr trim \
        -q {1} -l {2} \
        \$(
            if [ -e ../R1.scythe.fq.gz ]; then
                echo '../R1.scythe.fq.gz'
            elif [ -e ../R1.sample.fq.gz ]; then
                echo '../R1.sample.fq.gz'
            elif [ -e ../R1.shuffle.fq.gz ]; then
                echo '../R1.shuffle.fq.gz'
            elif [ -e ../R1.uniq.fq.gz ]; then
                echo '../R1.uniq.fq.gz'
            else
                echo '../R1.fq.gz'
            fi
        ) \
         \
        -o stdout \
        | bash
    " ::: ${READ_QUAL} ::: ${READ_LEN}

```

## FCM05SE: reads stats

```bash
cd ${WORKING_DIR}/${BASE_NAME}

printf "| %s | %s | %s | %s |\n" \
    "Name" "N50" "Sum" "#" \
    > stat.md
printf "|:--|--:|--:|--:|\n" >> stat.md

printf "| %s | %s | %s | %s |\n" \
    $(echo "Illumina"; faops n50 -H -S -C 2_illumina/R1.fq.gz;) >> stat.md
if [ -e 2_illumina/R1.uniq.fq.gz ]; then
    printf "| %s | %s | %s | %s |\n" \
        $(echo "uniq";    faops n50 -H -S -C 2_illumina/R1.uniq.fq.gz;) >> stat.md
fi
if [ -e 2_illumina/R1.shuffle.fq.gz ]; then
    printf "| %s | %s | %s | %s |\n" \
        $(echo "shuffle"; faops n50 -H -S -C 2_illumina/R1.shuffle.fq.gz;) >> stat.md
fi
if [ -e 2_illumina/R1.sample.fq.gz ]; then
    printf "| %s | %s | %s | %s |\n" \
        $(echo "sample";   faops n50 -H -S -C 2_illumina/R1.sample.fq.gz;) >> stat.md
fi
if [ -e 2_illumina/R1.scythe.fq.gz ]; then
    printf "| %s | %s | %s | %s |\n" \
        $(echo "scythe";  faops n50 -H -S -C 2_illumina/R1.scythe.fq.gz;) >> stat.md
fi

parallel --no-run-if-empty -k -j 3 "
    printf \"| %s | %s | %s | %s |\n\" \
        \$( 
            echo Q{1}L{2};
            faops n50 -H -S -C \
                2_illumina/Q{1}L{2}/R1.sickle.fq.gz;
        )
    " ::: ${READ_QUAL} ::: ${READ_LEN} \
    >> stat.md

cat stat.md

```

| Name     | N50 |         Sum |         # |
|:---------|----:|------------:|----------:|
| Illumina | 150 | 49640232150 | 330934881 |
| uniq     | 150 | 41080215750 | 273868105 |
| Q25L60   | 150 | 40496607839 | 273078531 |
| Q30L60   | 150 | 38980229662 | 267984250 |

## FCM05SE: spades

```bash
cd ${WORKING_DIR}/${BASE_NAME}

spades.py \
    -t 16 \
    -k 21,33,55,77 \
    --only-assembler \
    -s 2_illumina/Q30L60/R1.sickle.fq.gz \
    -o 8_spades

anchr contained \
    8_spades/contigs.fasta \
    --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
    -o stdout \
    | faops filter -a 1000 -l 0 stdin 8_spades/contigs.non-contained.fasta

```

## FCM05SE: platanus

```bash
cd ${WORKING_DIR}/${BASE_NAME}

mkdir -p 8_platanus
cd 8_platanus

if [ ! -e se.fa ]; then
    faops interleave \
        -p se \
        ../2_illumina/Q30L60/R1.sickle.fq.gz \
        > se.fa
fi

platanus assemble -t 16 -m 100 \
    -f se.fa \
    2>&1 | tee ass_log.txt

anchr contained \
    out_contig.fa out_contigBubble.fa \
    --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
    -o stdout \
    | faops filter -a 1000 -l 0 stdin platanus.non-contained.fasta

```

## FCM05SE: quorum

```bash
cd ${WORKING_DIR}/${BASE_NAME}

parallel --no-run-if-empty --linebuffer -k -j 1 "
    cd 2_illumina/Q{1}L{2}
    echo >&2 '==> Group Q{1}L{2} <=='

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

