# Plants 2+3

[TOC levels=1-3]: # " "
- [Plants 2+3](#plants-23)
- [ZS97, *Oryza sativa* Indica Group, Zhenshan 97](#zs97-oryza-sativa-indica-group-zhenshan-97)
    - [ZS97: download](#zs97-download)
    - [ZS97: template](#zs97-template)
    - [ZS97: run](#zs97-run)
- [JDM](#jdm)
    - [JDM: download](#jdm-download)
- [JDM003](#jdm003)
    - [JDM003: download](#jdm003-download)
    - [JDM003: template](#jdm003-template)
    - [JDM003: run](#jdm003-run)
- [JDM006](#jdm006)
    - [JDM006: download](#jdm006-download)
    - [JDM006: template](#jdm006-template)
    - [JDM006: run](#jdm006-run)
- [JDM008](#jdm008)
    - [JDM008: download](#jdm008-download)
    - [JDM008: template](#jdm008-template)
    - [JDM008: run](#jdm008-run)
- [JDM009](#jdm009)
    - [JDM009: download](#jdm009-download)
    - [JDM009: template](#jdm009-template)
    - [JDM009: run](#jdm009-run)
- [JDM016](#jdm016)
    - [JDM016: download](#jdm016-download)
    - [JDM016: template](#jdm016-template)
    - [JDM016: run](#jdm016-run)
- [JDM018](#jdm018)
    - [JDM018: download](#jdm018-download)
    - [JDM018: template](#jdm018-template)
    - [JDM018: run](#jdm018-run)
- [CgiA, Cercis gigantea, 巨紫荆 A](#cgia-cercis-gigantea-巨紫荆-a)
    - [CgiA: download](#cgia-download)
    - [CgiA: combinations of different quality values and read lengths](#cgia-combinations-of-different-quality-values-and-read-lengths)
    - [CgiA: spades](#cgia-spades)
    - [CgiA: platanus](#cgia-platanus)
    - [CgiA: quorum](#cgia-quorum)
    - [CgiA: down sampling](#cgia-down-sampling)
    - [CgiA: k-unitigs and anchors (sampled)](#cgia-k-unitigs-and-anchors-sampled)
    - [CgiA: merge anchors](#cgia-merge-anchors)
    - [CgiA: final stats](#cgia-final-stats)
- [CgiB, Cercis gigantea](#cgib-cercis-gigantea)
    - [CgiB: download](#cgib-download)
    - [CgiB: combinations of different quality values and read lengths](#cgib-combinations-of-different-quality-values-and-read-lengths)
    - [CgiB: spades](#cgib-spades)
    - [CgiB: platanus](#cgib-platanus)
    - [CgiB: final stats](#cgib-final-stats)
    - [Merge CgiA and CgiB](#merge-cgia-and-cgib)
- [CgiC, Cercis gigantea](#cgic-cercis-gigantea)
    - [CgiC: download](#cgic-download)
    - [CgiC: combinations of different quality values and read lengths](#cgic-combinations-of-different-quality-values-and-read-lengths)
    - [CgiC: spades](#cgic-spades)
    - [CgiC: platanus](#cgic-platanus)
    - [CgiC: final stats](#cgic-final-stats)
- [CgiD, Cercis gigantea](#cgid-cercis-gigantea)
    - [CgiD: download](#cgid-download)
    - [CgiD: combinations of different quality values and read lengths](#cgid-combinations-of-different-quality-values-and-read-lengths)
    - [CgiD: spades](#cgid-spades)
    - [CgiD: platanus](#cgid-platanus)
    - [CgiD: final stats](#cgid-final-stats)
    - [Merge CgiC and CgiD](#merge-cgic-and-cgid)
- [Cgi](#cgi)
    - [Cgi: Merge CgiAB and CgiCD](#cgi-merge-cgiab-and-cgicd)
    - [Cgi: preprocess PacBio reads](#cgi-preprocess-pacbio-reads)
    - [Cgi: 3GS](#cgi-3gs)
- [moli, 茉莉](#moli-茉莉)
    - [moli: download](#moli-download)
    - [moli: combinations of different quality values and read lengths](#moli-combinations-of-different-quality-values-and-read-lengths)
    - [moli: down sampling](#moli-down-sampling)
    - [moli: generate super-reads](#moli-generate-super-reads)
    - [moli: create anchors](#moli-create-anchors)
    - [moli: results](#moli-results)
    - [moli: merge anchors](#moli-merge-anchors)


# ZS97, *Oryza sativa* Indica Group, Zhenshan 97

## ZS97: download

* Reference genome

    * GenBank assembly accession: GCA_001623345.1
    * Assembly name: ZS97RS1

```bash
mkdir -p ~/data/dna-seq/chara/ZS97/1_genome
cd ~/data/dna-seq/chara/ZS97/1_genome

aria2c -x 9 -s 3 -c ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/001/623/345/GCA_001623345.1_ZS97RS1/GCA_001623345.1_ZS97RS1_genomic.fna.gz

TAB=$'\t'
cat <<EOF > replace.tsv
CM003910.1${TAB}1
CM003911.1${TAB}2
CM003912.1${TAB}3
CM003913.1${TAB}4
CM003914.1${TAB}5
CM003915.1${TAB}6
CM003916.1${TAB}7
CM003917.1${TAB}8
CM003918.1${TAB}9
CM003919.1${TAB}10
CM003920.1${TAB}11
CM003921.1${TAB}12
EOF

faops replace GCA_001623345.1_ZS97RS1_genomic.fna.gz replace.tsv stdout \
    | faops some stdin <(for chr in $(seq 1 1 12); do echo $chr; done) \
        genome.fa

```

* Illumina

    * small-insert (~300 bp) pair-end WGS (2x100 bp read length)
    * ENA hasn't synced with SRA for SRX1639981 (SRR3234372), download from NCBI ftp.
    * `ftp://ftp-trace.ncbi.nih.gov`
    * `/sra/sra-instant/reads/ByRun/sra/{SRR|ERR|DRR}/<first 6 characters of
      accession>/<accession>/<accession>.sra`

```bash
mkdir -p ~/data/dna-seq/chara/ZS97/2_illumina
cd ~/data/dna-seq/chara/ZS97/2_illumina

aria2c -x 9 -s 3 -c ftp://ftp-trace.ncbi.nih.gov/sra/sra-instant/reads/ByRun/sra/SRR/SRR323/SRR3234372/SRR3234372.sra

fastq-dump --split-files ./SRR3234372.sra  
find . -name "*.fastq" | parallel -j 2 pigz -p 4

ln -s SRR3234372_1.fastq.gz R1.fq.gz
ln -s SRR3234372_2.fastq.gz R2.fq.gz
```

## ZS97: template

* Rsync to hpcc

```bash
rsync -avP \
    ~/data/dna-seq/chara/ZS97/ \
    wangq@202.119.37.251:data/dna-seq/chara/ZS97

#rsync -avP wangq@202.119.37.251:data/dna-seq/chara/ZS97/ ~/data/dna-seq/chara/ZS97

```

```bash
WORKING_DIR=${HOME}/data/dna-seq/chara
BASE_NAME=ZS97
QUEUE_NAME=largemem

cd ${WORKING_DIR}/${BASE_NAME}

anchr template \
    . \
    --basename ${BASE_NAME} \
    --genome 346663259 \
    --is_euk \
    --trim2 "--uniq --bbduk" \
    --cov2 "40 60 all" \
    --qual2 "25 30" \
    --len2 "60" \
    --filter "adapter,phix,artifact" \
    --tadpole \
    --mergereads \
    --ecphase "1,3" \
    --parallel 24

```

## ZS97: run

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

# spades, megahit, and platanus
bsub -w "done(${BASE_NAME}-2_trim)" \
    -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-8_spades" "bash 8_spades.sh"

bsub -w "done(${BASE_NAME}-2_trim)" \
    -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-8_megahit" "bash 8_megahit.sh"

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

# quast
bsub -w "ended(${BASE_NAME}-6_mergeAnchors)" \
    -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-9_quast" "bash 9_quast.sh"

# stats
#bash 9_statFinal.sh

#bash 0_cleanup.sh

```

| Name     |      N50 |       Sum |         # |
|:---------|---------:|----------:|----------:|
| Genome   | 27449063 | 346663259 |        12 |
| Illumina |      101 |    34.17G | 338293782 |
| uniq     |      101 |    33.82G | 334877960 |
| Q25L60   |      101 |    27.11G | 273940552 |
| Q30L60   |      101 |    26.04G | 269603470 |

| Group  |  Mean | Median | STDev | PercentOfPairs |
|:-------|------:|-------:|------:|---------------:|
| Q25L60 | 279.7 |    267 |  81.6 |         18.16% |
| Q30L60 | 278.9 |    266 |  80.8 |         19.10% |

| Name   | CovIn | CovOut | Discard% | AvgRead | Kmer |   RealG |    EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|-----:|--------:|--------:|---------:|----------:|
| Q25L60 |  78.2 |   71.3 |    8.82% |      99 | "71" | 346.66M | 298.24M |     0.86 | 0:58'15'' |
| Q30L60 |  75.2 |   69.5 |    7.55% |      97 | "71" | 346.66M | 295.54M |     0.85 | 0:59'40'' |

```text
#File	pe.cor.raw
#Total	249508723
#Matched	11742	0.00471%
#Name	Reads	ReadsPct
Reverse_adapter	11636	0.00466%

#File	pe.cor.raw
#Total	249284069
#Matched	38058	0.01527%
#Name	Reads	ReadsPct
Reverse_adapter	37412	0.01501%

```

| Name          | SumCor | CovCor | N50SR |     Sum |      # | N50Anchor |     Sum |     # | N50Others |    Sum |     # |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|-------:|-------:|------:|--------:|-------:|----------:|--------:|------:|----------:|-------:|------:|--------------------:|----------:|:----------|
| Q25L60X10P000 |  3.47G |   10.0 |  1734 | 215.63M | 157603 |      2488 | 148.25M | 65347 |       745 | 67.38M | 92256 | "31,41,51,61,71,81" | 2:41'43'' | 0:16'53'' |
| Q25L60X10P001 |  3.47G |   10.0 |  1772 |  218.3M | 157502 |      2526 | 151.62M | 66090 |       743 | 66.68M | 91412 | "31,41,51,61,71,81" | 2:49'55'' | 0:17'23'' |
| Q25L60X10P002 |  3.47G |   10.0 |  1766 |  218.1M | 157413 |      2528 | 151.46M | 66094 |       743 | 66.64M | 91319 | "31,41,51,61,71,81" | 2:40'11'' | 0:17'08'' |
| Q25L60X10P003 |  3.47G |   10.0 |  1765 | 218.07M | 157686 |      2519 | 150.98M | 65848 |       743 | 67.09M | 91838 | "31,41,51,61,71,81" | 2:42'55'' | 0:16'03'' |
| Q25L60X10P004 |  3.47G |   10.0 |  1792 | 220.37M | 157947 |      2544 | 153.69M | 66591 |       743 | 66.68M | 91356 | "31,41,51,61,71,81" | 2:45'08'' | 0:17'19'' |
| Q25L60X10P005 |  3.47G |   10.0 |  1794 | 220.51M | 157850 |      2540 | 154.13M | 66831 |       742 | 66.38M | 91019 | "31,41,51,61,71,81" | 2:53'41'' | 0:17'23'' |
| Q25L60X10P006 |  3.47G |   10.0 |  1797 | 220.35M | 157663 |      2558 | 153.67M | 66385 |       743 | 66.67M | 91278 | "31,41,51,61,71,81" | 3:01'24'' | 0:15'18'' |
| Q25L60X20P000 |  6.93G |   20.0 |  2938 | 263.02M | 138459 |      3687 | 213.25M | 70953 |       744 | 49.77M | 67506 | "31,41,51,61,71,81" | 5:58'50'' | 0:22'50'' |
| Q25L60X20P001 |  6.93G |   20.0 |  2965 | 263.54M | 137933 |      3713 | 214.17M | 71011 |       744 | 49.38M | 66922 | "31,41,51,61,71,81" | 5:19'06'' | 0:22'45'' |
| Q25L60X20P002 |  6.93G |   20.0 |  3037 |  265.7M | 137188 |      3780 | 216.78M | 70876 |       743 | 48.92M | 66312 | "31,41,51,61,71,81" | 6:04'38'' | 0:20'45'' |
| Q25L60X30P000 |  10.4G |   30.0 |  3625 | 276.72M | 126387 |      4333 | 234.84M | 69684 |       743 | 41.88M | 56703 | "31,41,51,61,71,81" | 6:54'23'' | 0:26'32'' |
| Q25L60X30P001 |  10.4G |   30.0 |  3726 | 278.13M | 124559 |      4422 | 237.42M | 69427 |       742 | 40.71M | 55132 | "31,41,51,61,71,81" | 7:32'01'' | 0:27'35'' |
| Q25L60X60P000 |  20.8G |   60.0 |  4668 | 286.82M | 108526 |      5297 | 254.88M | 65645 |       745 | 31.94M | 42881 | "31,41,51,61,71,81" | 6:50'07'' | 0:30'15'' |
| Q30L60X10P000 |  3.47G |   10.0 |  1688 |  207.1M | 153919 |      2444 | 140.91M | 63040 |       742 | 66.19M | 90879 | "31,41,51,61,71,81" | 1:54'28'' | 0:14'21'' |
| Q30L60X10P001 |  3.47G |   10.0 |  1718 | 209.22M | 153772 |      2471 | 143.55M | 63517 |       741 | 65.67M | 90255 | "31,41,51,61,71,81" | 2:32'13'' | 0:15'11'' |
| Q30L60X10P002 |  3.47G |   10.0 |  1713 | 209.32M | 154062 |      2474 | 143.43M | 63612 |       741 | 65.88M | 90450 | "31,41,51,61,71,81" | 2:45'35'' | 0:14'40'' |
| Q30L60X10P003 |  3.47G |   10.0 |  1730 | 210.42M | 154189 |      2475 |  144.9M | 64182 |       740 | 65.52M | 90007 | "31,41,51,61,71,81" | 2:27'07'' | 0:16'02'' |
| Q30L60X10P004 |  3.47G |   10.0 |  1742 | 212.49M | 155081 |      2490 | 146.67M | 64564 |       741 | 65.82M | 90517 | "31,41,51,61,71,81" | 2:36'29'' | 0:16'46'' |
| Q30L60X10P005 |  3.47G |   10.0 |  1746 | 212.27M | 154436 |      2503 | 146.74M | 64495 |       740 | 65.53M | 89941 | "31,41,51,61,71,81" | 2:55'20'' | 0:14'40'' |
| Q30L60X20P000 |  6.93G |   20.0 |  2644 | 252.33M | 141816 |      3386 | 200.23M | 70927 |       743 |  52.1M | 70889 | "31,41,51,61,71,81" | 5:15'24'' | 0:21'05'' |
| Q30L60X20P001 |  6.93G |   20.0 |  2681 | 253.65M | 141370 |      3435 | 201.84M | 71072 |       747 | 51.81M | 70298 | "31,41,51,61,71,81" | 5:12'12'' | 0:22'02'' |
| Q30L60X20P002 |  6.93G |   20.0 |  2744 | 255.92M | 140438 |      3490 | 204.86M | 71123 |       745 | 51.06M | 69315 | "31,41,51,61,71,81" | 5:33'02'' | 0:19'55'' |
| Q30L60X30P000 |  10.4G |   30.0 |  3154 | 266.57M | 133166 |      3849 | 221.21M | 71631 |       744 | 45.36M | 61535 | "31,41,51,61,71,81" | 6:23'08'' | 0:24'50'' |
| Q30L60X30P001 |  10.4G |   30.0 |  3268 | 269.51M | 131494 |      3966 |    225M | 71243 |       744 | 44.51M | 60251 | "31,41,51,61,71,81" | 7:07'54'' | 0:27'36'' |
| Q30L60X60P000 |  20.8G |   60.0 |  3977 |  280.5M | 118592 |      4598 | 244.18M | 69643 |       745 | 36.32M | 48949 | "31,41,51,61,71,81" | 6:53'31'' | 0:31'33'' |


| Name                   |      N50 |       Sum |       # |
|:-----------------------|---------:|----------:|--------:|
| Genome                 | 27449063 | 346663259 |      12 |
| anchor.merge           |     5533 | 262303705 |   66077 |
| others.merge           |     1158 | 103014560 |   85485 |
| spades.contig          |    12421 | 343065556 |  246828 |
| spades.scaffold        |    13039 | 343127110 |  245326 |
| spades.non-contained   |    14589 | 300686248 |   37507 |
| platanus.contig        |     1419 | 422154233 | 1526431 |
| platanus.scaffold      |     7687 | 325245861 |  396499 |
| platanus.non-contained |     9554 | 270282635 |   43521 |


# JDM

* *Actinidia chinensis*
* 猕猴桃
* Taxonomy ID: [3625](https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?mode=Info&id=3625)

## JDM: download

* Reference genome

    * GenBank assembly accession: GCA_000467755.1
    * Assembly name: Kiwifruit_v1

```bash
mkdir -p ~/data/dna-seq/chara/JDM/1_genome
cd ~/data/dna-seq/chara/JDM/1_genome

aria2c -x 9 -s 3 -c ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/000/467/755/GCA_000467755.1_Kiwifruit_v1/GCA_000467755.1_Kiwifruit_v1_genomic.fna.gz

gzip -d -c GCA_000467755.1_Kiwifruit_v1_genomic.fna.gz \
    | perl -nl -e '
        /^>(\w+)/ and print qq{>$1} and next;
        print;
    ' \
    > genome.fa

```

# JDM003

## JDM003: download

```bash
mkdir -p ~/data/dna-seq/chara/JDM003/1_genome
cd ~/data/dna-seq/chara/JDM003/1_genome

ln -s ../../JDM/1_genome/genome.fa genome.fa

mkdir -p ~/data/dna-seq/chara/JDM003/2_illumina
cd ~/data/dna-seq/chara/JDM003/2_illumina

ln -s ../../RawData/JDM003_1.fq.gz R1.fq.gz
ln -s ../../RawData/JDM003_1.fq.gz R2.fq.gz

```

## JDM003: template

* Rsync to hpcc

```bash
rsync -avP \
    ~/data/dna-seq/chara/RawData/ \
    wangq@202.119.37.251:data/dna-seq/chara/RawData

rsync -avP \
    ~/data/dna-seq/chara/JDM003/ \
    wangq@202.119.37.251:data/dna-seq/chara/JDM003

#rsync -avP wangq@202.119.37.251:data/dna-seq/chara/JDM003/ ~/data/dna-seq/chara/JDM003

```

```bash
WORKING_DIR=${HOME}/data/dna-seq/chara
BASE_NAME=JDM003
QUEUE_NAME=largemem

cd ${WORKING_DIR}/${BASE_NAME}

anchr template \
    . \
    --basename ${BASE_NAME} \
    --genome 604217145 \
    --is_euk \
    --trim2 "--uniq " \
    --cov2 "all" \
    --qual2 "25 30" \
    --len2 "60" \
    --mergereads \
    --ecphase "1,3" \
    --parallel 24

```

## JDM003: run

Same as [FCM05: run](plants.md#zs97-run)

* Mapping reads against reference genome

```bash
WORKING_DIR=${HOME}/data/dna-seq/chara
BASE_NAME=JDM003

cd ${WORKING_DIR}/${BASE_NAME}

cd 2_illumina/Q25L60

bbmap.sh \
    in=R1.sickle.fq.gz \
    in2=R2.sickle.fq.gz \
    out=pe.sam.gz \
    ref=../../1_genome/genome.fa \
    threads=16 \
    reads=2000000 \
    nodisk overwrite

reformat.sh \
    in=pe.sam.gz \
    ihist=ihist.genome.txt \
    overwrite

```

* Sam to fastq

```bash
cd ~/data/dna-seq/chara/novo

pigz -d -c NDSW08998_L1.sam.gz > NDSW08998_L1.sam

reformat.sh \
    in=NDSW08998_L1.sam \
    ihist=ihist.novo.txt \
    overwrite

picard SortSam \
    I=NDSW08998_L1.sam \
    O=NDSW08998_L1.sort.sam \
    SORT_ORDER=coordinate

picard CollectInsertSizeMetrics \
    I=NDSW08998_L1.sort.sam \
    O=insert_size.metrics.txt \
    HISTOGRAM_FILE=insert_size.metrics.pdf

picard SamToFastq \
    I=NDSW08998_L1.sam \
    FASTQ=output.fq \
    INTERLEAVE=True

fastqc output.fq

bbmap.sh \
    in=output.fq \
    out=pe.sam.gz \
    ref=../JDM/1_genome/genome.fa \
    threads=16 \
    nodisk overwrite

reformat.sh \
    in=pe.sam.gz \
    ihist=ihist.remap.txt \
    overwrite

```

| Name     | N50 |    Sum |         # |
|:---------|----:|-------:|----------:|
| Illumina | 150 | 21.26G | 141737926 |
| uniq     | 150 | 17.25G | 115023970 |
| Q25L60   | 150 | 16.62G | 112626762 |
| Q30L60   | 150 | 15.27G | 106192466 |

| Name         | N50 |     Sum |        # |
|:-------------|----:|--------:|---------:|
| clumped      | 150 |   8.24G | 54933768 |
| trimmed      | 150 |   8.07G | 54583321 |
| filtered     | 150 |   8.07G | 54581358 |
| ecco         | 150 |      8G | 54581358 |
| ecct         | 150 |   3.26G | 22246571 |
| extended     | 183 |    3.9G | 22246571 |
| merged       | 179 | 228.41M |  1321567 |
| unmerged.raw | 184 |   3.46G | 19603436 |
| unmerged     | 182 |    3.2G | 19092451 |

| Group            |  Mean | Median | STDev | PercentOfPairs |
|:-----------------|------:|-------:|------:|---------------:|
| ihist.merge1.txt | 148.3 |    149 |  38.1 |          9.26% |
| ihist.merge.txt  | 172.8 |    174 |  36.5 |         11.88% |

```text
#mergeReads
#Matched	1963	0.00360%
#Name	Reads	ReadsPct
contam_27	1337	0.00245%
contam_43	160	0.00029%
contam_139	103	0.00019%
```

| Group  |  Mean | Median | STDev | PercentOfPairs |
|:-------|------:|-------:|------:|---------------:|
| Q25L60 | 148.0 |    150 |  10.9 |          5.39% |
| Q30L60 | 141.9 |    150 |  20.9 |          6.69% |

| Name   | CovIn | CovOut | Discard% | AvgRead |  Kmer |   RealG |    EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|------:|--------:|--------:|---------:|----------:|
| Q25L60 |  27.5 |   20.4 |   25.86% |     148 | "105" | 604.22M | 983.47M |     1.63 | 0:31'42'' |
| Q30L60 |  25.3 |   20.0 |   21.03% |     144 | "105" | 604.22M | 951.09M |     1.57 | 0:31'38'' |

```text
#File	pe.cor.raw
#Total	83340704
#Matched	93346	0.11201%
#Name	Reads	ReadsPct
Reverse_adapter	93020	0.11161%

#File	pe.cor.raw
#Total	83796924
#Matched	56020	0.06685%
#Name	Reads	ReadsPct
Reverse_adapter	55954	0.06677%

```

| Name           | CovCor | Mapped% | N50Anchor |   Sum |    # | N50Others |   Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|------:|-----:|----------:|------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q25L60XallP000 |   20.4 |   0.50% |      1166 | 1.95M | 1598 |      1142 | 1.88M | 1567 |   11.0 | 3.0 |   2.0 |  22.0 | "31,41,51,61,71,81" | 2:01'52'' | 0:01'37'' |
| Q30L60XallP000 |   20.0 |   0.56% |      1165 | 2.27M | 1846 |      1147 | 1.82M | 1511 |   12.0 | 3.0 |   2.0 |  24.0 | "31,41,51,61,71,81" | 1:54'06'' | 0:01'35'' |

| Name                   |  N50 |        Sum |        # |
|:-----------------------|-----:|-----------:|---------:|
| anchors                | 1171 |    2652062 |     2158 |
| others                 | 1146 |    2317623 |     1922 |
| tadpole.Q25L60         |  167 |  219200568 |  1255408 |
| tadpole.Q30L60         |  169 |  230766012 |  1311969 |
| spades.contig          |  508 | 1116104293 |  3783739 |
| spades.non-contained   | 1816 |  331656423 |   185103 |
| platanus.contig        |   68 | 1204577582 | 18195614 |
| platanus.non-contained |    0 |          0 |        0 |

# JDM006

## JDM006: download

```bash
mkdir -p ~/data/dna-seq/chara/JDM006/2_illumina
cd ~/data/dna-seq/chara/JDM006/2_illumina

ln -s ../../RawData/JDM006_1.fq.gz R1.fq.gz
ln -s ../../RawData/JDM006_1.fq.gz R2.fq.gz

```

## JDM006: template

* Rsync to hpcc

```bash
rsync -avP \
    ~/data/dna-seq/chara/RawData/ \
    wangq@202.119.37.251:data/dna-seq/chara/RawData

rsync -avP \
    ~/data/dna-seq/chara/JDM006/ \
    wangq@202.119.37.251:data/dna-seq/chara/JDM006

#rsync -avP wangq@202.119.37.251:data/dna-seq/chara/JDM006/ ~/data/dna-seq/chara/JDM006

```

```bash
WORKING_DIR=${HOME}/data/dna-seq/chara
BASE_NAME=JDM006
QUEUE_NAME=largemem

cd ${WORKING_DIR}/${BASE_NAME}

anchr template \
    . \
    --basename ${BASE_NAME} \
    --genome 604217145 \
    --is_euk \
    --trim2 "--uniq " \
    --cov2 "all" \
    --qual2 "25 30" \
    --len2 "60" \
    --mergereads \
    --ecphase "1,3" \
    --parallel 24

```

## JDM006: run

Same as [FCM05: run](plants.md#zs97-run)

| Name     | N50 |    Sum |         # |
|:---------|----:|-------:|----------:|
| Illumina | 150 | 22.58G | 150520322 |
| uniq     | 150 | 18.97G | 126484946 |
| Q25L60   | 150 | 18.29G | 123845644 |
| Q30L60   | 150 | 16.85G | 116917126 |

| Name         | N50 |     Sum |        # |
|:-------------|----:|--------:|---------:|
| clumped      | 150 |   9.12G | 60778008 |
| trimmed      | 150 |   8.94G | 60402525 |
| filtered     | 150 |   8.94G | 60400665 |
| ecco         | 150 |   8.86G | 60400664 |
| ecct         | 150 |   3.64G | 24837499 |
| extended     | 184 |   4.37G | 24837499 |
| merged       | 180 | 258.78M |  1491693 |
| unmerged.raw | 185 |   3.86G | 21854112 |
| unmerged     | 183 |   3.59G | 21322835 |

| Group            |  Mean | Median | STDev | PercentOfPairs |
|:-----------------|------:|-------:|------:|---------------:|
| ihist.merge1.txt | 148.3 |    149 |  37.8 |          9.24% |
| ihist.merge.txt  | 173.5 |    175 |  36.1 |         12.01% |

```text
#mergeReads
#Matched	1860	0.00308%
#Name	Reads	ReadsPct
contam_27	1247	0.00206%
contam_43	130	0.00022%
contam_139	108	0.00018%
```

| Group  |  Mean | Median | STDev | PercentOfPairs |
|:-------|------:|-------:|------:|---------------:|
| Q25L60 | 148.3 |    150 |  10.3 |          5.68% |
| Q30L60 | 142.7 |    150 |  20.0 |          6.98% |

| Name   | CovIn | CovOut | Discard% | AvgRead |  Kmer |   RealG |  EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|------:|--------:|------:|---------:|----------:|
| Q25L60 |  30.3 |   22.5 |   25.54% |     147 | "105" | 604.22M | 1.11G |     1.84 | 0:40'07'' |
| Q30L60 |  27.9 |   22.1 |   20.88% |     144 | "105" | 604.22M | 1.07G |     1.78 | 0:38'10'' |

```text
#Q25L60
#Matched	103806	0.11281%
#Name	Reads	ReadsPct
contam_27	103026	0.11196%
contam_139	144	0.00016%
contam_43	134	0.00015%
contam_175	106	0.00012%

#Q30L60
#Matched	63108	0.06828%
#Name	Reads	ReadsPct
contam_27	62448	0.06757%
contam_139	146	0.00016%
contam_43	128	0.00014%

```

| Name           | CovCor | Mapped% | N50Anchor |   Sum |    # | N50Others |   Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|------:|-----:|----------:|------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q25L60XallP000 |   22.5 |   1.15% |      1445 | 6.78M | 4421 |      1251 | 2.88M | 2165 |   11.0 | 2.0 |   2.0 |  22.0 | "31,41,51,61,71,81" | 2:21'07'' | 0:02'10'' |
| Q30L60XallP000 |   22.1 |   1.27% |      1491 | 6.93M | 4354 |      1265 | 3.09M | 2287 |   11.0 | 3.0 |   2.0 |  22.0 | "31,41,51,61,71,81" | 2:13'56'' | 0:02'10'' |

| Name                   |  N50 |        Sum |        # |
|:-----------------------|-----:|-----------:|---------:|
| anchors                | 1500 |    7973331 |     4982 |
| others                 | 1278 |    3882465 |     2852 |
| tadpole.Q25L60         |  178 |  278979484 |  1500703 |
| tadpole.Q30L60         |  179 |  290288863 |  1550302 |
| spades.contig          |  494 | 1232457684 |  4121439 |
| spades.non-contained   | 1807 |  348837928 |   194494 |
| platanus.contig        |   66 | 1333438154 | 20228974 |
| platanus.non-contained |    0 |          0 |        0 |


# JDM008

## JDM008: download

```bash
mkdir -p ~/data/dna-seq/chara/JDM008/2_illumina
cd ~/data/dna-seq/chara/JDM008/2_illumina

ln -s ../../RawData/JDM008_1.fq.gz R1.fq.gz
ln -s ../../RawData/JDM008_1.fq.gz R2.fq.gz

```

## JDM008: template

* Rsync to hpcc

```bash
rsync -avP \
    ~/data/dna-seq/chara/RawData/ \
    wangq@202.119.37.251:data/dna-seq/chara/RawData

rsync -avP \
    ~/data/dna-seq/chara/JDM008/ \
    wangq@202.119.37.251:data/dna-seq/chara/JDM008

#rsync -avP wangq@202.119.37.251:data/dna-seq/chara/JDM008/ ~/data/dna-seq/chara/JDM008

```

```bash
WORKING_DIR=${HOME}/data/dna-seq/chara
BASE_NAME=JDM008
QUEUE_NAME=largemem

cd ${WORKING_DIR}/${BASE_NAME}

anchr template \
    . \
    --basename ${BASE_NAME} \
    --genome 604217145 \
    --is_euk \
    --trim2 "--uniq " \
    --cov2 "all" \
    --qual2 "25 30" \
    --len2 "60" \
    --mergereads \
    --ecphase "1,3" \
    --parallel 24

```

## JDM008: run

Same as [FCM05: run](plants.md#zs97-run)

| Name     | N50 |    Sum |         # |
|:---------|----:|-------:|----------:|
| Illumina | 150 | 22.51G | 150077492 |
| uniq     | 150 | 18.79G | 125253930 |
| Q25L60   | 150 | 18.08G | 122597730 |
| Q30L60   | 150 | 16.59G | 115506944 |

| Name         | N50 |     Sum |        # |
|:-------------|----:|--------:|---------:|
| clumped      | 150 |      9G | 59997353 |
| trimmed      | 150 |   8.81G | 59585788 |
| filtered     | 150 |   8.81G | 59583285 |
| ecco         | 150 |   8.73G | 59583284 |
| ecct         | 150 |   3.75G | 25629337 |
| extended     | 185 |   4.51G | 25629337 |
| merged       | 181 | 261.03M |  1499529 |
| unmerged.raw | 186 |      4G | 22630278 |
| unmerged     | 183 |    3.7G | 22057741 |

| Group            |  Mean | Median | STDev | PercentOfPairs |
|:-----------------|------:|-------:|------:|---------------:|
| ihist.merge1.txt | 148.3 |    149 |  37.6 |          9.06% |
| ihist.merge.txt  | 174.1 |    175 |  36.1 |         11.70% |

```text
#mergeReads
#Matched	2503	0.00420%
#Name	Reads	ReadsPct
contam_27	1862	0.00312%
contam_43	139	0.00023%
contam_175	134	0.00022%
contam_32	101	0.00017%
```

| Group  |  Mean | Median | STDev | PercentOfPairs |
|:-------|------:|-------:|------:|---------------:|
| Q25L60 | 148.0 |    150 |  11.0 |          4.97% |
| Q30L60 | 141.8 |    150 |  21.0 |          6.22% |

| Name   | CovIn | CovOut | Discard% | AvgRead |  Kmer |   RealG |  EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|------:|--------:|------:|---------:|----------:|
| Q25L60 |  29.9 |   22.3 |   25.57% |     147 | "105" | 604.22M | 1.05G |     1.74 | 0:34'50'' |
| Q30L60 |  27.5 |   21.8 |   20.57% |     143 | "105" | 604.22M | 1.01G |     1.67 | 0:31'28'' |

```text
#Q25L60
#Matched	148646	0.16316%
#Name	Reads	ReadsPct
contam_27	147734	0.16216%
contam_43	162	0.00018%
contam_32	140	0.00015%
contam_139	134	0.00015%
contam_175	126	0.00014%
TruSeq_Adapter_Index_16	104	0.00011%

#Q30L60
#Matched	85306	0.09305%
#Name	Reads	ReadsPct
contam_27	84638	0.09232%
contam_43	144	0.00016%
contam_32	144	0.00016%
contam_139	132	0.00014%

```

| Name           | CovCor | Mapped% | N50Anchor |   Sum |    # | N50Others |   Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|------:|-----:|----------:|------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q25L60XallP000 |   22.3 |   0.46% |      1176 | 2.02M | 1647 |      1146 | 1.94M | 1614 |   11.0 | 3.0 |   2.0 |  22.0 | "31,41,51,61,71,81" | 2:12'04'' | 0:01'43'' |
| Q30L60XallP000 |   21.8 |   0.53% |      1173 | 2.29M | 1870 |      1147 | 1.92M | 1584 |   12.0 | 4.0 |   2.0 |  24.0 | "31,41,51,61,71,81" | 2:07'45'' | 0:01'41'' |

| Name                   |  N50 |        Sum |        # |
|:-----------------------|-----:|-----------:|---------:|
| anchors                | 1176 |    2684597 |     2188 |
| others                 | 1146 |    2438734 |     2013 |
| tadpole.Q25L60         |  169 |  233889899 |  1325523 |
| tadpole.Q30L60         |  171 |  245658800 |  1381700 |
| spades.contig          |  490 | 1179183220 |  4043921 |
| spades.non-contained   | 1794 |  331971570 |   187024 |
| platanus.contig        |   65 | 1295903737 | 19893464 |
| platanus.non-contained |    0 |          0 |        0 |

# JDM009

## JDM009: download

```bash
mkdir -p ~/data/dna-seq/chara/JDM009/2_illumina
cd ~/data/dna-seq/chara/JDM009/2_illumina

ln -s ../../RawData/JDM009_1.fq.gz R1.fq.gz
ln -s ../../RawData/JDM009_1.fq.gz R2.fq.gz

```

## JDM009: template

* Rsync to hpcc

```bash
rsync -avP \
    ~/data/dna-seq/chara/RawData/ \
    wangq@202.119.37.251:data/dna-seq/chara/RawData

rsync -avP \
    ~/data/dna-seq/chara/JDM009/ \
    wangq@202.119.37.251:data/dna-seq/chara/JDM009

#rsync -avP wangq@202.119.37.251:data/dna-seq/chara/JDM009/ ~/data/dna-seq/chara/JDM009

```

```bash
WORKING_DIR=${HOME}/data/dna-seq/chara
BASE_NAME=JDM009
QUEUE_NAME=largemem

cd ${WORKING_DIR}/${BASE_NAME}

anchr template \
    . \
    --basename ${BASE_NAME} \
    --genome 604217145 \
    --is_euk \
    --trim2 "--uniq " \
    --cov2 "all" \
    --qual2 "25 30" \
    --len2 "60" \
    --mergereads \
    --ecphase "1,3" \
    --parallel 24

```

## JDM009: run

Same as [FCM05: run](plants.md#zs97-run)

| Name     | N50 |    Sum |         # |
|:---------|----:|-------:|----------:|
| Illumina | 150 | 22.55G | 150343844 |
| uniq     | 150 | 18.81G | 125379732 |
| Q25L60   | 150 |  18.1G | 122745054 |
| Q30L60   | 150 | 16.54G | 115362118 |

| Name         | N50 |     Sum |        # |
|:-------------|----:|--------:|---------:|
| clumped      | 150 |      9G | 59997867 |
| trimmed      | 150 |   8.81G | 59616253 |
| filtered     | 150 |   8.81G | 59614611 |
| ecco         | 150 |   8.73G | 59614610 |
| ecct         | 150 |    3.6G | 24632806 |
| extended     | 183 |   4.33G | 24632806 |
| merged       | 180 | 254.59M |  1469355 |
| unmerged.raw | 185 |   3.83G | 21694096 |
| unmerged     | 182 |   3.53G | 21115365 |

| Group            |  Mean | Median | STDev | PercentOfPairs |
|:-----------------|------:|-------:|------:|---------------:|
| ihist.merge1.txt | 148.1 |    149 |  37.9 |          9.15% |
| ihist.merge.txt  | 173.3 |    174 |  36.4 |         11.93% |

```text
#mergeReads
#Matched	1642	0.00275%
#Name	Reads	ReadsPct
contam_27	1041	0.00175%
contam_43	209	0.00035%
```

| Group  |  Mean | Median | STDev | PercentOfPairs |
|:-------|------:|-------:|------:|---------------:|
| Q25L60 | 148.1 |    150 |  10.7 |          5.60% |
| Q30L60 | 141.9 |    150 |  20.9 |          7.00% |

| Name   | CovIn | CovOut | Discard% | AvgRead |  Kmer |   RealG |  EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|------:|--------:|------:|---------:|----------:|
| Q25L60 |  30.0 |   22.0 |   26.52% |     147 | "105" | 604.22M | 1.07G |     1.77 | 0:35'01'' |
| Q30L60 |  27.4 |   21.5 |   21.34% |     144 | "105" | 604.22M | 1.03G |     1.71 | 0:31'23'' |

```text
#Q25L60
#Matched	110340	0.12259%
#Name	Reads	ReadsPct
contam_27	109630	0.12180%
contam_43	268	0.00030%
contam_139	124	0.00014%

#Q30L60
#Matched	61706	0.06806%
#Name	Reads	ReadsPct
contam_27	61076	0.06737%
contam_43	264	0.00029%
contam_139	116	0.00013%

```

| Name                   |  N50 |        Sum |        # |
|:-----------------------|-----:|-----------:|---------:|
| anchors                | 2157 |    8630604 |     4218 |
| others                 | 1188 |    2326752 |     1831 |
| tadpole.Q25L60         |  173 |  249717930 |  1376811 |
| tadpole.Q30L60         |  174 |  262341035 |  1435298 |
| spades.contig          |  498 | 1202053892 |  4071644 |
| spades.non-contained   | 1812 |  347053383 |   192618 |
| platanus.contig        |   66 | 1311171609 | 19953535 |
| platanus.non-contained |    0 |          0 |        0 |

# JDM016

## JDM016: download

```bash
mkdir -p ~/data/dna-seq/chara/JDM016/2_illumina
cd ~/data/dna-seq/chara/JDM016/2_illumina

ln -s ../../RawData/JDM016_1.fq.gz R1.fq.gz
ln -s ../../RawData/JDM016_1.fq.gz R2.fq.gz

```

## JDM016: template

* Rsync to hpcc

```bash
rsync -avP \
    ~/data/dna-seq/chara/RawData/ \
    wangq@202.119.37.251:data/dna-seq/chara/RawData

rsync -avP \
    ~/data/dna-seq/chara/JDM016/ \
    wangq@202.119.37.251:data/dna-seq/chara/JDM016

#rsync -avP wangq@202.119.37.251:data/dna-seq/chara/JDM016/ ~/data/dna-seq/chara/JDM016

```

```bash
WORKING_DIR=${HOME}/data/dna-seq/chara
BASE_NAME=JDM016
QUEUE_NAME=largemem

cd ${WORKING_DIR}/${BASE_NAME}

anchr template \
    . \
    --basename ${BASE_NAME} \
    --genome 604217145 \
    --is_euk \
    --trim2 "--uniq " \
    --cov2 "all" \
    --qual2 "25 30" \
    --len2 "60" \
    --mergereads \
    --ecphase "1,3" \
    --parallel 24

```

## JDM016: run

Same as [FCM05: run](plants.md#zs97-run)

| Name     | N50 |    Sum |         # |
|:---------|----:|-------:|----------:|
| Illumina | 150 | 25.54G | 170279154 |
| uniq     | 150 | 21.49G | 143290894 |
| Q25L60   | 150 | 20.73G | 140399388 |
| Q30L60   | 150 | 19.09G | 132624128 |

| Name         | N50 |     Sum |        # |
|:-------------|----:|--------:|---------:|
| clumped      | 150 |   10.3G | 68684337 |
| trimmed      | 150 |  10.09G | 68243010 |
| filtered     | 150 |  10.09G | 68240358 |
| ecco         | 150 |  10.01G | 68240358 |
| ecct         | 150 |   4.87G | 33188143 |
| extended     | 187 |   5.88G | 33188143 |
| merged       | 182 | 333.79M |  1900104 |
| unmerged.raw | 188 |   5.23G | 29387934 |
| unmerged     | 183 |   4.85G | 28700939 |

| Group            |  Mean | Median | STDev | PercentOfPairs |
|:-----------------|------:|-------:|------:|---------------:|
| ihist.merge1.txt | 148.3 |    149 |  36.4 |          9.01% |
| ihist.merge.txt  | 175.7 |    177 |  35.4 |         11.45% |

```text
#mergeReads
#Matched	2652	0.00389%
#Name	Reads	ReadsPct
contam_27	1817	0.00266%
contam_43	247	0.00036%
contam_32	114	0.00017%
contam_139	109	0.00016%
contam_175	116	0.00017%
```

| Group  |  Mean | Median | STDev | PercentOfPairs |
|:-------|------:|-------:|------:|---------------:|
| Q25L60 | 148.3 |    150 |  10.3 |          4.19% |
| Q30L60 | 142.5 |    150 |  20.3 |          5.16% |

| Name   | CovIn | CovOut | Discard% | AvgRead |  Kmer |   RealG |  EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|------:|--------:|------:|---------:|----------:|
| Q25L60 |  34.3 |   26.3 |   23.19% |     147 | "105" | 604.22M |  1.1G |     1.82 | 0:40'09'' |
| Q30L60 |  31.6 |   25.9 |   18.05% |     144 | "105" | 604.22M | 1.06G |     1.76 | 0:36'08'' |

```text
#Q25L60
#Matched	119296	0.11088%
#Name	Reads	ReadsPct
contam_27	117996	0.10967%
contam_43	318	0.00030%
contam_176	236	0.00022%
contam_139	160	0.00015%
contam_32	146	0.00014%
contam_175	178	0.00017%

#Q30L60
#Matched	71796	0.06617%
#Name	Reads	ReadsPct
contam_27	70858	0.06530%
contam_43	316	0.00029%
contam_139	156	0.00014%
contam_32	138	0.00013%

```

| Name           | CovCor | Mapped% | N50Anchor |   Sum |    # | N50Others |   Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|------:|-----:|----------:|------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q25L60XallP000 |   26.3 |   0.49% |      1187 | 2.48M | 2004 |      1141 | 2.22M | 1853 |   11.0 | 3.0 |   2.0 |  22.0 | "31,41,51,61,71,81" | 2:31'04'' | 0:01'55'' |
| Q30L60XallP000 |   25.9 |   0.56% |      1196 | 2.88M | 2308 |      1140 | 2.19M | 1835 |   12.0 | 3.0 |   2.0 |  24.0 | "31,41,51,61,71,81" | 2:23'21'' | 0:01'58'' |

| Name                   |  N50 |        Sum |        # |
|:-----------------------|-----:|-----------:|---------:|
| anchors                | 1198 |    3356856 |     2692 |
| others                 | 1140 |    2798615 |     2344 |
| tadpole.Q25L60         |  168 |  216698860 |  1233874 |
| tadpole.Q30L60         |  169 |  227859064 |  1289407 |
| spades.contig          |  462 | 1286561733 |  4675119 |
| spades.non-contained   | 1771 |  338522265 |   192345 |
| platanus.contig        |   63 | 1503634982 | 24152905 |
| platanus.non-contained |    0 |          0 |        0 |

# JDM018

## JDM018: download

```bash
mkdir -p ~/data/dna-seq/chara/JDM018/2_illumina
cd ~/data/dna-seq/chara/JDM018/2_illumina

ln -s ../../RawData/JDM018_1.fq.gz R1.fq.gz
ln -s ../../RawData/JDM018_1.fq.gz R2.fq.gz

```

## JDM018: template

* Rsync to hpcc

```bash
rsync -avP \
    ~/data/dna-seq/chara/RawData/ \
    wangq@202.119.37.251:data/dna-seq/chara/RawData

rsync -avP \
    ~/data/dna-seq/chara/JDM018/ \
    wangq@202.119.37.251:data/dna-seq/chara/JDM018

#rsync -avP wangq@202.119.37.251:data/dna-seq/chara/JDM018/ ~/data/dna-seq/chara/JDM018

```

```bash
WORKING_DIR=${HOME}/data/dna-seq/chara
BASE_NAME=JDM018
QUEUE_NAME=largemem

cd ${WORKING_DIR}/${BASE_NAME}

anchr template \
    . \
    --basename ${BASE_NAME} \
    --genome 604217145 \
    --is_euk \
    --trim2 "--uniq " \
    --cov2 "all" \
    --qual2 "25 30" \
    --len2 "60" \
    --mergereads \
    --ecphase "1,3" \
    --parallel 24

```

## JDM018: run

Same as [FCM05: run](plants.md#zs97-run)

| Name     | N50 |    Sum |         # |
|:---------|----:|-------:|----------:|
| Illumina | 150 | 20.98G | 139887246 |
| uniq     | 150 | 17.53G | 116853548 |
| Q25L60   | 150 | 16.91G | 114491980 |
| Q30L60   | 150 | 15.57G | 108124660 |

| Name         | N50 |     Sum |        # |
|:-------------|----:|--------:|---------:|
| clumped      | 150 |   8.42G | 56122727 |
| trimmed      | 150 |   8.26G | 55789050 |
| filtered     | 150 |   8.25G | 55787450 |
| ecco         | 150 |   8.18G | 55787450 |
| ecct         | 150 |   3.25G | 22230011 |
| extended     | 183 |   3.89G | 22230011 |
| merged       | 179 | 233.94M |  1356645 |
| unmerged.raw | 183 |   3.44G | 19516720 |
| unmerged     | 181 |   3.19G | 19036569 |

| Group            |  Mean | Median | STDev | PercentOfPairs |
|:-----------------|------:|-------:|------:|---------------:|
| ihist.merge1.txt | 148.3 |    149 |  38.1 |          9.40% |
| ihist.merge.txt  | 172.4 |    173 |  36.4 |         12.21% |

```text
#mergeReads
#Matched	1600	0.00287%
#Name	Reads	ReadsPct
contam_27	1004	0.00180%
contam_43	171	0.00031%
contam_139	119	0.00021%
```

| Group  |  Mean | Median | STDev | PercentOfPairs |
|:-------|------:|-------:|------:|---------------:|
| Q25L60 | 148.1 |    150 |  10.8 |          5.19% |
| Q30L60 | 142.1 |    150 |  20.6 |          6.43% |

| Name   | CovIn | CovOut | Discard% | AvgRead |  Kmer |   RealG |    EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|------:|--------:|--------:|---------:|----------:|
| Q25L60 |  28.0 |   20.8 |   25.57% |     147 | "105" | 604.22M |   1.03G |     1.71 | 0:32'28'' |
| Q30L60 |  25.8 |   20.4 |   20.81% |     144 | "105" | 604.22M | 997.75M |     1.65 | 0:29'20'' |

```text
#Q25L60
#Matched	83608	0.09834%
#Name	Reads	ReadsPct
contam_27	82704	0.09728%
contam_43	210	0.00025%
contam_175	232	0.00027%
contam_139	168	0.00020%
contam_32	106	0.00012%

#Q30L60
#Matched	49302	0.05765%
#Name	Reads	ReadsPct
contam_27	48592	0.05682%
contam_43	210	0.00025%
contam_139	160	0.00019%

```

| Name           | CovCor | Mapped% | N50Anchor |   Sum |    # | N50Others |   Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|------:|-----:|----------:|------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q25L60XallP000 |   20.8 |   0.56% |      1180 | 2.59M | 2097 |      1146 | 2.02M | 1667 |   11.0 | 3.0 |   2.0 |  22.0 | "31,41,51,61,71,81" | 2:07'56'' | 0:01'41'' |
| Q30L60XallP000 |   20.4 |   0.62% |      1178 | 2.56M | 2064 |      1154 | 2.25M | 1848 |   11.0 | 3.0 |   2.0 |  22.0 | "31,41,51,61,71,81" | 2:00'43'' | 0:01'41'' |

| Name                   |  N50 |        Sum |        # |
|:-----------------------|-----:|-----------:|---------:|
| anchors                | 1181 |    3107209 |     2504 |
| others                 | 1145 |    2597900 |     2145 |
| tadpole.Q25L60         |  170 |  242369531 |  1365894 |
| tadpole.Q30L60         |  172 |  254111528 |  1421879 |
| spades.contig          |  514 | 1157647446 |  3815742 |
| spades.non-contained   | 1795 |  341146096 |   191848 |
| platanus.contig        |   68 | 1253459699 | 18917682 |
| platanus.non-contained |    0 |          0 |        0 |

# CgiA, Cercis gigantea, 巨紫荆 A

## CgiA: download

```bash
BASE_NAME=CgiA
mkdir -p ${HOME}/data/dna-seq/chara/${BASE_NAME}
cd ${HOME}/data/dna-seq/chara/${BASE_NAME}

mkdir -p 2_illumina
cd 2_illumina

ln -s ../../medfood/Cgi_R1_head50.fastq.gz R1.fq.gz
ln -s ../../medfood/Cgi_R2_head50.fastq.gz R2.fq.gz
```

* FastQC

* kmergenie

## CgiA: combinations of different quality values and read lengths

* qual: 20, 25, and 30
* len: 60

```bash
BASE_NAME=CgiA
cd ${HOME}/data/dna-seq/chara/${BASE_NAME}

if [ ! -e 2_illumina/R1.uniq.fq.gz ]; then
    tally \
        --pair-by-offset --with-quality --nozip --unsorted \
        -i 2_illumina/R1.fq.gz \
        -j 2_illumina/R2.fq.gz \
        -o 2_illumina/R1.uniq.fq \
        -p 2_illumina/R2.uniq.fq
    
    parallel --no-run-if-empty -j 2 "
            pigz -p 8 2_illumina/{}.uniq.fq
        " ::: R1 R2
fi

cat ${HOME}/.plenv/versions/5.18.4/lib/perl5/site_perl/5.18.4/auto/share/dist/App-Anchr/illumina_adapters.fa \
    > 2_illumina/illumina_adapters.fa
echo ">TruSeq_Adapter_Index_15" >> 2_illumina/illumina_adapters.fa
echo "GATCGGAAGAGCACACGTCTGAACTCCAGTCACACGCTCGAATCTCGTAT" >> 2_illumina/illumina_adapters.fa
echo ">Illumina_Single_End_PCR_Primer_1" >> 2_illumina/illumina_adapters.fa
echo "GATCGGAAGAGCGTCGTGTAGGGAAAGAGTGTAGATCTCGGTGGTCGCCG" >> 2_illumina/illumina_adapters.fa

if [ ! -e 2_illumina/R1.scythe.fq.gz ]; then
    parallel --no-run-if-empty -j 2 "
        scythe \
            2_illumina/{}.uniq.fq.gz \
            -q sanger \
            -a 2_illumina/illumina_adapters.fa \
            --quiet \
            | pigz -p 4 -c \
            > 2_illumina/{}.scythe.fq.gz
        " ::: R1 R2
fi

parallel --no-run-if-empty -j 3 "
    mkdir -p 2_illumina/Q{1}L{2}
    cd 2_illumina/Q{1}L{2}
    
    if [ -e R1.fq.gz ]; then
        echo '    R1.fq.gz already presents'
        exit;
    fi

    anchr trim \
        --noscythe \
        -q {1} -l {2} \
        ../R1.scythe.fq.gz ../R2.scythe.fq.gz \
        -o stdout \
        | bash
    " ::: 20 25 30 ::: 60

# Stats
printf "| %s | %s | %s | %s |\n" \
    "Name" "N50" "Sum" "#" \
    > stat.md
printf "|:--|--:|--:|--:|\n" >> stat.md

printf "| %s | %s | %s | %s |\n" \
    $(echo "Illumina"; faops n50 -H -S -C 2_illumina/R1.fq.gz 2_illumina/R2.fq.gz;) >> stat.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "uniq";     faops n50 -H -S -C 2_illumina/R1.uniq.fq.gz 2_illumina/R2.uniq.fq.gz;) >> stat.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "scythe";   faops n50 -H -S -C 2_illumina/R1.scythe.fq.gz 2_illumina/R2.scythe.fq.gz;) >> stat.md

parallel -k --no-run-if-empty -j 3 "
    printf \"| %s | %s | %s | %s |\n\" \
        \$( 
            echo Q{1}L{2};
            if [[ {1} -ge '30' ]]; then
                faops n50 -H -S -C \
                    2_illumina/Q{1}L{2}/R1.fq.gz \
                    2_illumina/Q{1}L{2}/R2.fq.gz \
                    2_illumina/Q{1}L{2}/Rs.fq.gz;
            else
                faops n50 -H -S -C \
                    2_illumina/Q{1}L{2}/R1.fq.gz \
                    2_illumina/Q{1}L{2}/R2.fq.gz;
            fi
        )
    " ::: 20 25 30 ::: 60 \
    >> stat.md

cat stat.md
```

| Name     | N50 |         Sum |         # |
|:---------|----:|------------:|----------:|
| Illumina | 151 | 58890000000 | 390000000 |
| uniq     | 151 | 57639361828 | 381717628 |
| scythe   | 151 | 56855792587 | 381717628 |
| Q20L60   | 151 | 47181285790 | 332231596 |
| Q25L60   | 151 | 39049905338 | 284195248 |
| Q30L60   | 151 | 37761899864 | 286580535 |

## CgiA: spades

## CgiA: platanus

```text
#### PROCESS INFORMATION ####
VmPeak:         158.718 GByte
VmHWM:           62.453 GByte
```

## CgiA: quorum

| Name   |  SumIn | CovIn | SumOut | CovOut | Discard% | AvgRead | Kmer | RealG |    EstG | Est/Real |   RunTime |
|:-------|-------:|------:|-------:|-------:|---------:|--------:|-----:|------:|--------:|---------:|----------:|
| Q25L60 | 39.05G |  78.1 | 33.11G |   66.2 |  15.211% |     137 | "91" |  500M | 368.39M |     0.74 | 2:59'12'' |
| Q30L60 | 37.82G |  75.6 | 34.74G |   69.5 |   8.147% |     132 | "81" |  500M | 355.97M |     0.71 | 1:59'00'' |

## CgiA: down sampling

## CgiA: k-unitigs and anchors (sampled)

| Name          | SumCor | CovCor | N50SR |     Sum |      # | N50Anchor |    Sum |     # | N50Others |    Sum |      # |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|-------:|-------:|------:|--------:|-------:|----------:|-------:|------:|----------:|-------:|-------:|--------------------:|----------:|:----------|
| Q25L60X30P000 |    15G |   30.0 |   839 | 138.13M | 157958 |      1747 | 51.85M | 28791 |       665 | 86.29M | 129167 | "31,41,51,61,71,81" | 2:38'40'' | 0:16'03'' |
| Q25L60X30P001 |    15G |   30.0 |   840 | 138.22M | 158010 |      1746 | 51.94M | 28839 |       665 | 86.28M | 129171 | "31,41,51,61,71,81" | 2:35'17'' | 0:15'34'' |
| Q25L60X60P000 |    30G |   60.0 |   828 | 134.34M | 155963 |      1683 | 49.63M | 28646 |       662 | 84.71M | 127317 | "31,41,51,61,71,81" | 4:10'17'' | 0:28'06'' |
| Q30L60X30P000 |    15G |   30.0 |   841 | 139.25M | 158884 |      1766 |  52.4M | 28832 |       665 | 86.85M | 130052 | "31,41,51,61,71,81" | 2:29'24'' | 0:16'41'' |
| Q30L60X30P001 |    15G |   30.0 |   842 | 139.56M | 159066 |      1758 | 52.69M | 28965 |       665 | 86.87M | 130101 | "31,41,51,61,71,81" | 2:31'05'' | 0:16'40'' |
| Q30L60X60P000 |    30G |   60.0 |   843 |  138.4M | 158013 |      1719 | 53.13M | 29953 |       663 | 85.27M | 128060 | "31,41,51,61,71,81" | 4:00'07'' | 0:29'19'' |

## CgiA: merge anchors

## CgiA: final stats

* Stats

| Name               |  N50 |       Sum |       # |
|:-------------------|-----:|----------:|--------:|
| anchor.merge       | 1779 |  61598601 |   33537 |
| others.merge       | 1034 |   6873722 |    6352 |
| spades.contig      | 1620 | 435929605 |  673266 |
| spades.scaffold    | 1761 | 439173057 |  662729 |
| platanus.contig    |  565 | 592588841 | 1792829 |
| platanus.gapClosed | 5499 | 414129420 |  901777 |

# CgiB, Cercis gigantea

## CgiB: download

```bash
BASE_NAME=CgiB
mkdir -p ${HOME}/data/dna-seq/chara/${BASE_NAME}
cd ${HOME}/data/dna-seq/chara/${BASE_NAME}

mkdir -p 2_illumina
cd 2_illumina

ln -s ../../medfood/Cgi_R1_tail50.fastq.gz R1.fq.gz
ln -s ../../medfood/Cgi_R2_tail50.fastq.gz R2.fq.gz
```

* FastQC

## CgiB: combinations of different quality values and read lengths

* qual: 25
* len: 60

```bash
BASE_NAME=CgiB
cd ${HOME}/data/dna-seq/chara/${BASE_NAME}

if [ ! -e 2_illumina/R1.uniq.fq.gz ]; then
    tally \
        --pair-by-offset --with-quality --nozip --unsorted \
        -i 2_illumina/R1.fq.gz \
        -j 2_illumina/R2.fq.gz \
        -o 2_illumina/R1.uniq.fq \
        -p 2_illumina/R2.uniq.fq
    
    parallel --no-run-if-empty -j 2 "
            pigz -p 8 2_illumina/{}.uniq.fq
        " ::: R1 R2
fi

cat ${HOME}/.plenv/versions/5.18.4/lib/perl5/site_perl/5.18.4/auto/share/dist/App-Anchr/illumina_adapters.fa \
    > 2_illumina/illumina_adapters.fa
echo ">TruSeq_Adapter_Index_15" >> 2_illumina/illumina_adapters.fa
echo "GATCGGAAGAGCACACGTCTGAACTCCAGTCACACGCTCGAATCTCGTAT" >> 2_illumina/illumina_adapters.fa
echo ">Illumina_Single_End_PCR_Primer_1" >> 2_illumina/illumina_adapters.fa
echo "GATCGGAAGAGCGTCGTGTAGGGAAAGAGTGTAGATCTCGGTGGTCGCCG" >> 2_illumina/illumina_adapters.fa

if [ ! -e 2_illumina/R1.scythe.fq.gz ]; then
    parallel --no-run-if-empty -j 2 "
        scythe \
            2_illumina/{}.uniq.fq.gz \
            -q sanger \
            -a 2_illumina/illumina_adapters.fa \
            --quiet \
            | pigz -p 4 -c \
            > 2_illumina/{}.scythe.fq.gz
        " ::: R1 R2
fi

parallel --no-run-if-empty -j 3 "
    mkdir -p 2_illumina/Q{1}L{2}
    cd 2_illumina/Q{1}L{2}
    
    if [ -e R1.fq.gz ]; then
        echo '    R1.fq.gz already presents'
        exit;
    fi

    anchr trim \
        --noscythe \
        -q {1} -l {2} \
        ../R1.scythe.fq.gz ../R2.scythe.fq.gz \
        -o stdout \
        | bash
    " ::: 25 ::: 60

# Stats
printf "| %s | %s | %s | %s |\n" \
    "Name" "N50" "Sum" "#" \
    > stat.md
printf "|:--|--:|--:|--:|\n" >> stat.md

printf "| %s | %s | %s | %s |\n" \
    $(echo "Illumina"; faops n50 -H -S -C 2_illumina/R1.fq.gz 2_illumina/R2.fq.gz;) >> stat.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "uniq";     faops n50 -H -S -C 2_illumina/R1.uniq.fq.gz 2_illumina/R2.uniq.fq.gz;) >> stat.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "scythe";   faops n50 -H -S -C 2_illumina/R1.scythe.fq.gz 2_illumina/R2.scythe.fq.gz;) >> stat.md

parallel -k --no-run-if-empty -j 3 "
    printf \"| %s | %s | %s | %s |\n\" \
        \$( 
            echo Q{1}L{2};
            if [[ {1} -ge '30' ]]; then
                faops n50 -H -S -C \
                    2_illumina/Q{1}L{2}/R1.fq.gz \
                    2_illumina/Q{1}L{2}/R2.fq.gz \
                    2_illumina/Q{1}L{2}/Rs.fq.gz;
            else
                faops n50 -H -S -C \
                    2_illumina/Q{1}L{2}/R1.fq.gz \
                    2_illumina/Q{1}L{2}/R2.fq.gz;
            fi
        )
    " ::: 25 ::: 60 \
    >> stat.md

cat stat.md
```

| Name     | N50 |         Sum |         # |
|:---------|----:|------------:|----------:|
| Illumina | 151 | 58890000000 | 390000000 |
| uniq     | 151 | 57719368574 | 382247474 |
| scythe   | 151 | 56959610487 | 382247474 |
| Q25L60   | 151 | 39466026049 | 289798244 |

## CgiB: spades

## CgiB: platanus

## CgiB: final stats

* Stats

| Name              |  N50 |       Sum |       # |
|:------------------|-----:|----------:|--------:|
| spades.contig     | 1526 | 451828980 |  705723 |
| spades.scaffold   | 1633 | 454928469 |  695914 |
| platanus.contig   |  562 | 592944982 | 1795551 |
| platanus.scaffold | 6298 | 417471995 |  941034 |

## Merge CgiA and CgiB

```bash
cd ${HOME}/data/dna-seq/chara/CgiB

# merge anchors
mkdir -p merge
anchr contained \
    ../CgiA/8_spades/scaffolds.fasta \
    8_spades/scaffolds.fasta \
    ../CgiA/8_platanus/out_gapClosed.fa \
    8_platanus/out_gapClosed.fa \
    --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
    -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/anchor.contained.fasta
anchr orient merge/anchor.contained.fasta \
    --len 1000 --idt 0.98 --parallel 16 \
    -o merge/anchor.orient.fasta
anchr merge merge/anchor.orient.fasta \
    --len 1000 --idt 0.999 --parallel 16 \
    -o merge/anchor.merge0.fasta
anchr contained merge/anchor.merge0.fasta \
    --len 1000 --idt 0.98 --proportion 0.99 --parallel 16 -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/anchor.merge.fasta

rm -fr 9_qa
quast --no-check --threads 16 \
    --eukaryote \
    --no-icarus \
    ../CgiA/8_spades/scaffolds.fasta \
    8_spades/scaffolds.fasta \
    ../CgiA/8_platanus/out_gapClosed.fa \
    8_platanus/out_gapClosed.fa \
    merge/anchor.merge.fasta \
    --label "spades.CgiA,spades.CgiB,platanus.CgiA,platanus.CgiB,merge" \
    -o 9_qa

```

# CgiC, Cercis gigantea

## CgiC: download

```bash
BASE_NAME=CgiC
mkdir -p ${HOME}/data/dna-seq/chara/${BASE_NAME}
cd ${HOME}/data/dna-seq/chara/${BASE_NAME}

mkdir -p 2_illumina
cd 2_illumina

ln -s ../../medfood/CgiC_R1.fq.gz R1.fq.gz
ln -s ../../medfood/CgiC_R2.fq.gz R2.fq.gz
```

## CgiC: combinations of different quality values and read lengths

* qual: 25
* len: 60

```bash
BASE_NAME=CgiC
cd ${HOME}/data/dna-seq/chara/${BASE_NAME}

if [ ! -e 2_illumina/R1.uniq.fq.gz ]; then
    tally \
        --pair-by-offset --with-quality --nozip --unsorted \
        -i 2_illumina/R1.fq.gz \
        -j 2_illumina/R2.fq.gz \
        -o 2_illumina/R1.uniq.fq \
        -p 2_illumina/R2.uniq.fq
    
    parallel --no-run-if-empty -j 2 "
            pigz -p 8 2_illumina/{}.uniq.fq
        " ::: R1 R2
fi

cat ${HOME}/.plenv/versions/5.18.4/lib/perl5/site_perl/5.18.4/auto/share/dist/App-Anchr/illumina_adapters.fa \
    > 2_illumina/illumina_adapters.fa
echo ">TruSeq_Adapter_Index_15" >> 2_illumina/illumina_adapters.fa
echo "GATCGGAAGAGCACACGTCTGAACTCCAGTCACACGCTCGAATCTCGTAT" >> 2_illumina/illumina_adapters.fa
echo ">Illumina_Single_End_PCR_Primer_1" >> 2_illumina/illumina_adapters.fa
echo "GATCGGAAGAGCGTCGTGTAGGGAAAGAGTGTAGATCTCGGTGGTCGCCG" >> 2_illumina/illumina_adapters.fa

if [ ! -e 2_illumina/R1.scythe.fq.gz ]; then
    parallel --no-run-if-empty -j 2 "
        scythe \
            2_illumina/{}.uniq.fq.gz \
            -q sanger \
            -a 2_illumina/illumina_adapters.fa \
            --quiet \
            | pigz -p 4 -c \
            > 2_illumina/{}.scythe.fq.gz
        " ::: R1 R2
fi

parallel --no-run-if-empty -j 3 "
    mkdir -p 2_illumina/Q{1}L{2}
    cd 2_illumina/Q{1}L{2}
    
    if [ -e R1.fq.gz ]; then
        echo '    R1.fq.gz already presents'
        exit;
    fi

    anchr trim \
        --noscythe \
        -q {1} -l {2} \
        ../R1.scythe.fq.gz ../R2.scythe.fq.gz \
        -o stdout \
        | bash
    " ::: 25 ::: 60

# Stats
printf "| %s | %s | %s | %s |\n" \
    "Name" "N50" "Sum" "#" \
    > stat.md
printf "|:--|--:|--:|--:|\n" >> stat.md

printf "| %s | %s | %s | %s |\n" \
    $(echo "Illumina"; faops n50 -H -S -C 2_illumina/R1.fq.gz 2_illumina/R2.fq.gz;) >> stat.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "uniq";     faops n50 -H -S -C 2_illumina/R1.uniq.fq.gz 2_illumina/R2.uniq.fq.gz;) >> stat.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "scythe";   faops n50 -H -S -C 2_illumina/R1.scythe.fq.gz 2_illumina/R2.scythe.fq.gz;) >> stat.md

parallel -k --no-run-if-empty -j 3 "
    printf \"| %s | %s | %s | %s |\n\" \
        \$( 
            echo Q{1}L{2};
            if [[ {1} -ge '30' ]]; then
                faops n50 -H -S -C \
                    2_illumina/Q{1}L{2}/R1.fq.gz \
                    2_illumina/Q{1}L{2}/R2.fq.gz \
                    2_illumina/Q{1}L{2}/Rs.fq.gz;
            else
                faops n50 -H -S -C \
                    2_illumina/Q{1}L{2}/R1.fq.gz \
                    2_illumina/Q{1}L{2}/R2.fq.gz;
            fi
        )
    " ::: 25 ::: 60 \
    >> stat.md

cat stat.md
```

| Name     | N50 |         Sum |         # |
|:---------|----:|------------:|----------:|
| Illumina | 150 | 45000000000 | 300000000 |
| uniq     | 150 | 42202865700 | 281352438 |
| scythe   | 150 | 41628539307 | 281352438 |
| Q25L60   | 150 | 34914644451 | 245278936 |

## CgiC: spades

## CgiC: platanus

## CgiC: final stats

* Stats

| Name              |  N50 |       Sum |       # |
|:------------------|-----:|----------:|--------:|
| spades.contig     | 1529 | 453999116 |  718189 |
| spades.scaffold   | 1640 | 457087770 |  708368 |
| platanus.contig   |  553 | 586857429 | 1819727 |
| platanus.scaffold | 5238 | 432432679 | 1120978 |

# CgiD, Cercis gigantea

## CgiD: download

```bash
BASE_NAME=CgiD
mkdir -p ${HOME}/data/dna-seq/chara/${BASE_NAME}
cd ${HOME}/data/dna-seq/chara/${BASE_NAME}

mkdir -p 2_illumina
cd 2_illumina

ln -s ../../medfood/CgiD_R1.fq.gz R1.fq.gz
ln -s ../../medfood/CgiD_R2.fq.gz R2.fq.gz
```

## CgiD: combinations of different quality values and read lengths

* qual: 25
* len: 60

```bash
BASE_NAME=CgiD
cd ${HOME}/data/dna-seq/chara/${BASE_NAME}

if [ ! -e 2_illumina/R1.uniq.fq.gz ]; then
    tally \
        --pair-by-offset --with-quality --nozip --unsorted \
        -i 2_illumina/R1.fq.gz \
        -j 2_illumina/R2.fq.gz \
        -o 2_illumina/R1.uniq.fq \
        -p 2_illumina/R2.uniq.fq
    
    parallel --no-run-if-empty -j 2 "
            pigz -p 8 2_illumina/{}.uniq.fq
        " ::: R1 R2
fi

cat ${HOME}/.plenv/versions/5.18.4/lib/perl5/site_perl/5.18.4/auto/share/dist/App-Anchr/illumina_adapters.fa \
    > 2_illumina/illumina_adapters.fa
echo ">TruSeq_Adapter_Index_15" >> 2_illumina/illumina_adapters.fa
echo "GATCGGAAGAGCACACGTCTGAACTCCAGTCACACGCTCGAATCTCGTAT" >> 2_illumina/illumina_adapters.fa
echo ">Illumina_Single_End_PCR_Primer_1" >> 2_illumina/illumina_adapters.fa
echo "GATCGGAAGAGCGTCGTGTAGGGAAAGAGTGTAGATCTCGGTGGTCGCCG" >> 2_illumina/illumina_adapters.fa

if [ ! -e 2_illumina/R1.scythe.fq.gz ]; then
    parallel --no-run-if-empty -j 2 "
        scythe \
            2_illumina/{}.uniq.fq.gz \
            -q sanger \
            -a 2_illumina/illumina_adapters.fa \
            --quiet \
            | pigz -p 4 -c \
            > 2_illumina/{}.scythe.fq.gz
        " ::: R1 R2
fi

parallel --no-run-if-empty -j 3 "
    mkdir -p 2_illumina/Q{1}L{2}
    cd 2_illumina/Q{1}L{2}
    
    if [ -e R1.fq.gz ]; then
        echo '    R1.fq.gz already presents'
        exit;
    fi

    anchr trim \
        --noscythe \
        -q {1} -l {2} \
        ../R1.scythe.fq.gz ../R2.scythe.fq.gz \
        -o stdout \
        | bash
    " ::: 25 ::: 60

# Stats
printf "| %s | %s | %s | %s |\n" \
    "Name" "N50" "Sum" "#" \
    > stat.md
printf "|:--|--:|--:|--:|\n" >> stat.md

printf "| %s | %s | %s | %s |\n" \
    $(echo "Illumina"; faops n50 -H -S -C 2_illumina/R1.fq.gz 2_illumina/R2.fq.gz;) >> stat.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "uniq";     faops n50 -H -S -C 2_illumina/R1.uniq.fq.gz 2_illumina/R2.uniq.fq.gz;) >> stat.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "scythe";   faops n50 -H -S -C 2_illumina/R1.scythe.fq.gz 2_illumina/R2.scythe.fq.gz;) >> stat.md

parallel -k --no-run-if-empty -j 3 "
    printf \"| %s | %s | %s | %s |\n\" \
        \$( 
            echo Q{1}L{2};
            if [[ {1} -ge '30' ]]; then
                faops n50 -H -S -C \
                    2_illumina/Q{1}L{2}/R1.fq.gz \
                    2_illumina/Q{1}L{2}/R2.fq.gz \
                    2_illumina/Q{1}L{2}/Rs.fq.gz;
            else
                faops n50 -H -S -C \
                    2_illumina/Q{1}L{2}/R1.fq.gz \
                    2_illumina/Q{1}L{2}/R2.fq.gz;
            fi
        )
    " ::: 25 ::: 60 \
    >> stat.md

cat stat.md
```

| Name     | N50 |         Sum |         # |
|:---------|----:|------------:|----------:|
| Illumina | 150 | 45000000000 | 300000000 |
| uniq     | 150 | 42802892700 | 285352618 |
| scythe   | 150 | 42149668084 | 285352618 |
| Q25L60   | 150 | 35083711046 | 245385420 |

## CgiD: spades

## CgiD: platanus

## CgiD: final stats

* Stats

| Name              |  N50 |       Sum |       # |
|:------------------|-----:|----------:|--------:|
| spades.contig     | 1500 | 456253937 |  737180 |
| spades.scaffold   | 1603 | 459347483 |  727395 |
| platanus.contig   |  533 | 592606020 | 1851674 |
| platanus.scaffold | 4839 | 434810119 | 1135031 |

## Merge CgiC and CgiD

```bash
cd ${HOME}/data/dna-seq/chara/CgiD

# merge anchors
mkdir -p merge
anchr contained \
    ../CgiC/8_spades/scaffolds.fasta \
    8_spades/scaffolds.fasta \
    ../CgiC/8_platanus/out_gapClosed.fa \
    8_platanus/out_gapClosed.fa \
    --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
    -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/anchor.contained.fasta
anchr orient merge/anchor.contained.fasta \
    --len 1000 --idt 0.98 --parallel 16 \
    -o merge/anchor.orient.fasta
anchr merge merge/anchor.orient.fasta \
    --len 1000 --idt 0.999 --parallel 16 \
    -o merge/anchor.merge0.fasta
anchr contained merge/anchor.merge0.fasta \
    --len 1000 --idt 0.98 --proportion 0.99 --parallel 16 -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/anchor.merge.fasta

rm -fr 9_qa
quast --no-check --threads 16 \
    --eukaryote \
    --no-icarus \
    ../CgiC/8_spades/scaffolds.fasta \
    8_spades/scaffolds.fasta \
    ../CgiC/8_platanus/out_gapClosed.fa \
    8_platanus/out_gapClosed.fa \
    merge/anchor.merge.fasta \
    --label "spades.CgiC,spades.CgiD,platanus.CgiC,platanus.CgiD,merge" \
    -o 9_qa

```

# Cgi

## Cgi: Merge CgiAB and CgiCD

```bash
cd ${HOME}/data/dna-seq/chara/Cgi

# merge anchors
mkdir -p merge
anchr contained \
    ../CgiB/merge/anchor.merge.fasta \
    ../CgiD/merge/anchor.merge.fasta \
    --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
    -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/anchor.contained.fasta
anchr orient merge/anchor.contained.fasta \
    --len 1000 --idt 0.98 --parallel 16 \
    -o merge/anchor.orient.fasta
anchr merge merge/anchor.orient.fasta \
    --len 1000 --idt 0.999 --parallel 16 \
    -o merge/anchor.merge0.fasta
anchr contained merge/anchor.merge0.fasta \
    --len 1000 --idt 0.98 --proportion 0.99 --parallel 16 -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/anchor.merge.fasta

rm -fr 9_qa
quast --no-check --threads 16 \
    --eukaryote \
    --no-icarus \
    ../CgiB/merge/anchor.merge.fasta \
    ../CgiD/merge/anchor.merge.fasta \
    merge/anchor.merge.fasta \
    --label "CgiAB,CgiCD,merge" \
    -o 9_qa

```

## Cgi: preprocess PacBio reads

```bash
cd ${HOME}/data/dna-seq/chara/Cgi

mkdir -p 3_pacbio

samtools fasta \
    ${HOME}/data/dna-seq/chara/CgiSequel/54167_2_B01/m54167_170825_204337.subreads.bam \
    > 3_pacbio/m54167.fasta
samtools fasta \
    ${HOME}/data/dna-seq/chara/CgiSequel/r54172_20170821_090202_1_A01/m54172_170821_091102.subreads.bam \
    > 3_pacbio/m54172.fasta

cat 3_pacbio/m54167.fasta 3_pacbio/m54172.fasta \
    | faops filter -l 0 -a 1000 stdin 3_pacbio/pacbio.fasta

# minimap: Real time: 2522.743 sec; CPU: 33237.704 sec. 72G .paf file
# jrange: about 2 hours
# faops: real    2m18.233s
anchr trimlong --parallel 16 -v \
    --jvm '-d64 -server -Xms1g -Xmx64g -XX:-UseGCOverheadLimit' \
    3_pacbio/pacbio.fasta \
    -o 3_pacbio/pacbio.trim.fasta

```

## Cgi: 3GS

```bash
BASE_NAME=Cgi
REAL_G=500000000
cd ${HOME}/data/dna-seq/chara/Cgi

canu \
    -p ${BASE_NAME} -d canu-raw \
    gnuplot=$(brew --prefix)/Cellar/$(brew list --versions gnuplot | sed 's/ /\//')/bin/gnuplot \
    genomeSize=${REAL_G} \
    -pacbio-raw 3_pacbio/pacbio.fasta

canu \
    -p ${BASE_NAME} -d canu-trim \
    gnuplot=$(brew --prefix)/Cellar/$(brew list --versions gnuplot | sed 's/ /\//')/bin/gnuplot \
    genomeSize=${REAL_G} \
    -pacbio-raw 3_pacbio/pacbio.trim.fasta

rm -fr canu-raw/correction
rm -fr canu-trim/correction

printf "| %s | %s | %s | %s |\n" \
    "Name" "N50" "Sum" "#" \
    > stat.md
printf "|:--|--:|--:|--:|\n" >> stat.md

printf "| %s | %s | %s | %s |\n" \
    $(echo "PacBio";      faops n50 -H -S -C 3_pacbio/pacbio.fasta;) >> stat.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "PacBio.trim"; faops n50 -H -S -C 3_pacbio/pacbio.trim.fasta;) >> stat.md

printf "| %s | %s | %s | %s |\n" \
    $(echo "correctedReads";      faops n50 -H -S -C canu-raw/${BASE_NAME}.correctedReads.fasta.gz;) >> stat.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "correctedReads.trim"; faops n50 -H -S -C canu-trim/${BASE_NAME}.correctedReads.fasta.gz;) >> stat.md

printf "| %s | %s | %s | %s |\n" \
    $(echo "trimmedReads";      faops n50 -H -S -C canu-raw/${BASE_NAME}.trimmedReads.fasta.gz;) >> stat.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "trimmedReads.trim"; faops n50 -H -S -C canu-trim/${BASE_NAME}.trimmedReads.fasta.gz;) >> stat.md

printf "| %s | %s | %s | %s |\n" \
    $(echo "contigs";      faops n50 -H -S -C canu-raw/${BASE_NAME}.contigs.fasta;) >> stat.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "contigs.trim"; faops n50 -H -S -C canu-trim/${BASE_NAME}.contigs.fasta;) >> stat.md

```

| Name                |   N50 |         Sum |      # |
|:--------------------|------:|------------:|-------:|
| PacBio              | 16814 | 11647545821 | 990085 |
| PacBio.trim         | 14117 |  8181836779 | 835086 |
| correctedReads      |  8102 |  1632889184 | 289312 |
| correctedReads.trim | 14234 |  7894714239 | 782147 |
| trimmedReads        |  6896 |  1035588316 | 212397 |
| trimmedReads.trim   |  7215 |  1610374094 | 308121 |
| contigs             | 18506 |    14781217 |   1029 |
| contigs.trim        | 17224 |    22371544 |   1553 |

# moli, 茉莉

SR had failed twice due to the calculating results from awk were larger than the MAX_INT

* for jellyfish
* for --number-reads of `getSuperReadInsertCountsFromReadPlacementFileTwoPasses`

```bash
mkdir -p ~/data/dna-seq/chara/medfood
cd ~/data/dna-seq/chara/medfood

# 200 M Reads
zcat ~/zlc/medfood/moli/lane5ml_R1.fq.gz \
    | head -n 800000000 \
    | pigz -p 4 -c \
    > R1.fq.gz

zcat ~/zlc/medfood/moli/lane5ml_R2.fq.gz \
    | head -n 800000000 \
    | gzip > R2.fq.gz

perl ~/Scripts/sra/superreads.pl \
    R1.fq.gz \
    R2.fq.gz \
    -s 300 -d 30 -p 16 --jf 10_000_000_000
```


## moli: download

```bash
mkdir -p ~/data/dna-seq/chara/moli/2_illumina
cd ~/data/dna-seq/chara/moli/2_illumina

ln -s ~/data/dna-seq/chara/medfood/lane5ml_R1.fq.gz R1.fq.gz
ln -s ~/data/dna-seq/chara/medfood/lane5ml_R2.fq.gz R2.fq.gz
```

## moli: combinations of different quality values and read lengths

* qual: 20 and 25
* len: 100, 120, and 140

```bash
BASE_DIR=$HOME/data/dna-seq/chara/moli

cd ${BASE_DIR}
tally \
    --pair-by-offset --with-quality --nozip --unsorted \
    -sumstat 2_illumina/tally.sumstat.txt \
    -i 2_illumina/R1.fq.gz \
    -j 2_illumina/R2.fq.gz \
    -o 2_illumina/R1.uniq.fq \
    -p 2_illumina/R2.uniq.fq

parallel --no-run-if-empty -j 2 "
    pigz -p 4 2_illumina/{}.uniq.fq
    " ::: R1 R2

cd ${BASE_DIR}
parallel --no-run-if-empty -j 4 "
    mkdir -p 2_illumina/Q{1}L{2}
    cd 2_illumina/Q{1}L{2}
    
    if [ -e R1.fq.gz ]; then
        echo '    R1.fq.gz already presents'
        exit;
    fi

    anchr trim \
        --noscythe \
        -q {1} -l {2} \
        ../R1.uniq.fq.gz ../R2.uniq.fq.gz \
        -o stdout \
        | bash
    " ::: 20 25 ::: 100 120 140

```

* Stats

| Name     | N50 |          Sum |         # |
|:---------|----:|-------------:|----------:|
| Illumina | 150 | 131208907200 | 874726048 |
| uniq     | 150 | 108022731300 | 720151542 |
| Q20L100  | 150 |  99447660517 | 669337434 |
| Q20L120  | 150 |  96283521937 | 644827784 |
| Q20L140  | 150 |  90797417755 | 605412990 |
| Q25L100  | 150 |  89342502638 | 605173772 |
| Q25L120  | 150 |  84446237212 | 567043586 |
| Q25L140  | 150 |  76712262430 | 511489372 |

## moli: down sampling

## moli: generate super-reads

## moli: create anchors

## moli: results

* Stats of super-reads

* Stats of anchors

## moli: merge anchors

* Clear QxxLxxx.

* Stats
