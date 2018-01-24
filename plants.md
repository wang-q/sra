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
    * ENA hasn't synced with SRA for SRX1639981 (SRR3234372), download
      from NCBI ftp.
    * `ftp://ftp-trace.ncbi.nih.gov`
    * `/sra/sra-instant/reads/ByRun/sra/{SRR|ERR|DRR}/<first 6
      characters of accession>/<accession>/<accession>.sra`

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
    --insertsize \
    --parallel 24

```

## ZS97: run

```bash
# Illumina QC
bsub -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-2_fastqc" "bash 2_fastqc.sh"
bsub -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-2_kmergenie" "bash 2_kmergenie.sh"

# insert size
bsub -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-2_insertSize" "bash 2_insertSize.sh"

# preprocess Illumina reads
bsub -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-2_trim" "bash 2_trim.sh"

# reads stats
bsub -w "ended(${BASE_NAME}-2_trim)" \
    -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-9_statReads" "bash 9_statReads.sh"

# merge reads
bsub -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-2_mergereads" "bash 2_mergereads.sh"

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

# down sampling mergereads
bsub -w "done(${BASE_NAME}-2_mergereads)" \
    -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-6_downSampling" "bash 6_downSampling.sh"

bsub -w "done(${BASE_NAME}-6_downSampling)" \
    -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-6_kunitigs" "bash 6_kunitigs.sh"
bsub -w "done(${BASE_NAME}-6_kunitigs)" \
    -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-6_anchors" "bash 6_anchors.sh"
bsub -w "done(${BASE_NAME}-6_anchors)" \
    -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-9_statAnchors_6_kunitigs" "bash 9_statMRAnchors.sh 6_kunitigs statMRKunitigsAnchors.md"

bsub -w "done(${BASE_NAME}-6_downSampling)" \
    -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-6_tadpole" "bash 6_tadpole.sh"
bsub -w "done(${BASE_NAME}-6_tadpole)" \
    -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-6_tadpoleAnchors" "bash 6_tadpoleAnchors.sh"
bsub -w "done(${BASE_NAME}-6_tadpoleAnchors)" \
    -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-9_statAnchors_6_tadpole" "bash 9_statMRAnchors.sh 6_tadpole statMRTadpoleAnchors.md"

# merge anchors
bsub -w "done(${BASE_NAME}-4_anchors)" \
    -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-7_mergeAnchors_4_kunitigs" "bash 7_mergeAnchors.sh 4_kunitigs 7_mergeKunitigsAnchors"
bsub -w "done(${BASE_NAME}-4_tadpoleAnchors)" \
    -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-7_mergeAnchors_4_tadpole" "bash 7_mergeAnchors.sh 4_tadpole 7_mergeTadpoleAnchors"
bsub -w "done(${BASE_NAME}-6_anchors)" \
    -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-7_mergeAnchors_6_kunitigs" "bash 7_mergeAnchors.sh 6_kunitigs 7_mergeMRKunitigsAnchors"
bsub -w "done(${BASE_NAME}-6_tadpoleAnchors)" \
    -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-7_mergeAnchors_6_tadpole" "bash 7_mergeAnchors.sh 6_tadpole 7_mergeMRTadpoleAnchors"

bsub -w "done(${BASE_NAME}-7_mergeAnchors_4_kunitigs) && done(${BASE_NAME}-7_mergeAnchors_4_tadpole) && done(${BASE_NAME}-7_mergeAnchors_6_kunitigs) && done(${BASE_NAME}-7_mergeAnchors_6_tadpole)" \
    -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-7_mergeAnchors" "bash 7_mergeAnchors.sh 7_merge 7_mergeAnchors"

# quast
bsub -w "ended(${BASE_NAME}-7_mergeAnchors)" \
    -q ${QUEUE_NAME} -n 24 -J "${BASE_NAME}-9_quast" "bash 9_quast.sh"

# stats
#bash 9_statFinal.sh

#bash 0_cleanup.sh

```


Table: statInsertSize

| Group           |  Mean | Median |  STDev | PercentOfPairs/PairOrientation |
|:----------------|------:|-------:|-------:|-------------------------------:|
| genome.bbtools  | 410.5 |    275 | 2076.3 |                         42.23% |
| tadpole.bbtools | 276.8 |    264 |   86.6 |                         20.21% |
| genome.picard   | 290.8 |    275 |   88.1 |                             FR |
| tadpole.picard  | 275.6 |    263 |   84.6 |                             FR |

Table: statReads

| Name     |      N50 |       Sum |         # |
|:---------|---------:|----------:|----------:|
| Genome   | 27449063 | 346663259 |        12 |
| Illumina |      101 |    34.17G | 338293782 |
| uniq     |      101 |    33.82G | 334877960 |
| bbduk    |      100 |    33.16G | 331892946 |
| Q25L60   |      100 |    28.23G | 288860270 |
| Q30L60   |      100 |    25.77G | 268373759 |

```text
#trimmedReads
#Matched	2817355	0.84131%
#Name	Reads	ReadsPct
Reverse_adapter	1549468	0.46270%
TruSeq_Universal_Adapter	793969	0.23709%
pcr_dimer	101067	0.03018%
TruSeq_Adapter_Index_1_6	79842	0.02384%
PhiX_read2_adapter	52789	0.01576%
TruSeq_Adapter_Index_7	44198	0.01320%
PCR_Primers	41056	0.01226%
Nextera_LMP_Read2_External_Adapter	36022	0.01076%
I5_Nextera_Transposase_1	12936	0.00386%
PhiX_read1_adapter	12520	0.00374%
RNA_Adapter_(RA5)_part_#_15013205	9365	0.00280%
I5_Nextera_Transposase_2	7565	0.00226%
RNA_PCR_Primer_Index_1_(RPI1)_2,9	7055	0.00211%
TruSeq_Adapter_Index_2	5066	0.00151%
I5_Primer_Nextera_XT_and_Nextera_Enrichment_[N/S/E]501	4939	0.00147%
I7_Nextera_Transposase_2	4558	0.00136%
I7_Primer_Nextera_XT_and_Nextera_Enrichment_N701	4142	0.00124%
Nextera_LMP_Read1_External_Adapter	4025	0.00120%
I7_Nextera_Transposase_1	3833	0.00114%
Bisulfite_R1	2814	0.00084%
Bisulfite_R2	2671	0.00080%
I5_Adapter_Nextera	2536	0.00076%
RNA_PCR_Primer_(RP1)_part_#_15013198	2067	0.00062%
I7_Adapter_Nextera_No_Barcode	1868	0.00056%
RNA_PCR_Primer_Index_35_(RPI35)	1624	0.00048%
RNA_PCR_Primer_Index_14_(RPI14)	1095	0.00033%
```

Table: statMergeReads

| Name          | N50 |     Sum |         # |
|:--------------|----:|--------:|----------:|
| clumped       | 101 |  29.62G | 293293306 |
| trimmed       | 100 |  25.97G | 265114916 |
| filtered      | 100 |  25.97G | 265113983 |
| ecco          | 100 |  25.92G | 265113982 |
| ecct          | 100 |  24.72G | 252646762 |
| extended      | 140 |  33.96G | 252646762 |
| merged        | 141 | 804.95M |   5772282 |
| unmerged.raw  | 140 |  32.41G | 241102198 |
| unmerged.trim | 140 |  31.02G | 235237769 |
| U1            | 140 |  12.24G |  91927833 |
| U2            | 140 |  12.24G |  91927833 |
| Us            | 140 |   6.54G |  51382103 |
| pe.cor        | 140 |  31.88G | 298164436 |

| Group            |  Mean | Median | STDev | PercentOfPairs |
|:-----------------|------:|-------:|------:|---------------:|
| ihist.merge1.txt | 100.8 |    101 |  17.1 |          4.33% |
| ihist.merge.txt  | 139.4 |    140 |  26.8 |          4.57% |

```text
#trimmedReads
#Matched	2796177	0.95337%
#Name	Reads	ReadsPct
Reverse_adapter	1546422	0.52726%
TruSeq_Universal_Adapter	793174	0.27044%
pcr_dimer	100582	0.03429%
TruSeq_Adapter_Index_1_6	78498	0.02676%
PhiX_read2_adapter	47534	0.01621%
TruSeq_Adapter_Index_7	43570	0.01486%
PCR_Primers	40906	0.01395%
Nextera_LMP_Read2_External_Adapter	35482	0.01210%
I5_Nextera_Transposase_1	11711	0.00399%
PhiX_read1_adapter	11510	0.00392%
RNA_Adapter_(RA5)_part_#_15013205	8440	0.00288%
I5_Nextera_Transposase_2	7157	0.00244%
RNA_PCR_Primer_Index_1_(RPI1)_2,9	5699	0.00194%
TruSeq_Adapter_Index_2	5053	0.00172%
I5_Primer_Nextera_XT_and_Nextera_Enrichment_[N/S/E]501	4568	0.00156%
I7_Nextera_Transposase_2	4074	0.00139%
I7_Primer_Nextera_XT_and_Nextera_Enrichment_N701	3782	0.00129%
I7_Nextera_Transposase_1	3524	0.00120%
Nextera_LMP_Read1_External_Adapter	3467	0.00118%
Bisulfite_R1	2609	0.00089%
Bisulfite_R2	2342	0.00080%
I5_Adapter_Nextera	2280	0.00078%
RNA_PCR_Primer_(RP1)_part_#_15013198	1867	0.00064%
I7_Adapter_Nextera_No_Barcode	1765	0.00060%
RNA_PCR_Primer_Index_35_(RPI35)	1481	0.00050%
RNA_PCR_Primer_Index_14_(RPI14)	1081	0.00037%
```

```text
#filteredReads
#Matched	933	0.00035%
#Name	Reads	ReadsPct
TruSeq_Universal_Adapter	175	0.00007%
contam_32	104	0.00004%
```

Table: statQuorum

| Name   | CovIn | CovOut | Discard% | AvgRead | Kmer |   RealG |    EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|-----:|--------:|--------:|---------:|----------:|
| Q25L60 |  81.5 |   75.2 |    7.68% |      98 | "71" | 346.66M | 299.29M |     0.86 | 1:04'30'' |
| Q30L60 |  74.4 |   69.6 |    6.53% |      96 | "71" | 346.66M | 295.47M |     0.85 | 1:01'58'' |

Table: statKunitigsAnchors.md

| Name           | CovCor | Mapped% | N50Anchor |     Sum |     # | N50Others |    Sum |      # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|--------:|------:|----------:|-------:|-------:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q25L60X40P000  |   40.0 |  76.58% |      4263 | 242.33M | 76190 |      1006 | 25.74M | 300192 |   35.0 | 4.0 |   7.7 |  70.0 | "31,41,51,61,71,81" | 1:47'39'' | 2:10'56'' |
| Q25L60X60P000  |   60.0 |  77.72% |      4776 | 249.53M | 71836 |      1001 | 25.62M | 287842 |   51.0 | 6.0 |  11.0 | 102.0 | "31,41,51,61,71,81" | 2:19'03'' | 2:19'21'' |
| Q25L60XallP000 |   75.2 |  77.81% |      4994 | 251.96M | 69962 |      1000 | 24.36M | 275670 |   63.0 | 8.0 |  13.0 | 126.0 | "31,41,51,61,71,81" | 2:41'44'' | 2:20'23'' |
| Q30L60X40P000  |   40.0 |  75.77% |      3747 |  229.8M | 79040 |      1010 | 26.05M | 300025 |   36.0 | 4.0 |   8.0 |  72.0 | "31,41,51,61,71,81" | 1:40'18'' | 2:00'20'' |
| Q30L60X60P000  |   60.0 |  77.33% |      4139 | 237.96M | 75916 |      1009 |  27.9M | 300981 |   53.0 | 7.0 |  10.7 | 106.0 | "31,41,51,61,71,81" | 2:11'33'' | 2:16'40'' |
| Q30L60XallP000 |   69.6 |  77.61% |      4237 | 238.62M | 74696 |      1010 | 29.93M | 296937 |   61.0 | 8.0 |  12.3 | 122.0 | "31,41,51,61,71,81" | 2:24'20'' | 2:14'07'' |


Table: statTadpoleAnchors.md

| Name           | CovCor | Mapped% | N50Anchor |     Sum |     # | N50Others |    Sum |      # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|--------:|------:|----------:|-------:|-------:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q25L60X40P000  |   40.0 |  77.74% |      3745 | 231.17M | 80018 |      1005 | 21.05M | 302871 |   35.0 | 4.0 |   7.7 |  70.0 | "31,41,51,61,71,81" | 0:51'03'' | 1:56'11'' |
| Q25L60X60P000  |   60.0 |  80.48% |      4324 | 243.06M | 75709 |      1004 | 26.51M | 314191 |   52.0 | 6.0 |  11.3 | 104.0 | "31,41,51,61,71,81" | 1:12'05'' | 2:28'19'' |
| Q25L60XallP000 |   75.2 |  81.24% |      4644 | 248.15M | 72987 |      1002 |  25.9M | 306753 |   64.0 | 8.0 |  13.3 | 128.0 | "31,41,51,61,71,81" | 1:20'58'' | 2:35'03'' |
| Q30L60X40P000  |   40.0 |  76.56% |      3351 | 214.79M | 80045 |      1010 | 23.86M | 295395 |   37.0 | 4.0 |   8.3 |  73.5 | "31,41,51,61,71,81" | 0:47'30'' | 1:39'37'' |
| Q30L60X60P000  |   60.0 |  79.49% |      3747 | 229.79M | 78930 |      1009 | 26.53M | 316164 |   54.0 | 6.0 |  12.0 | 108.0 | "31,41,51,61,71,81" | 1:05'47'' | 2:15'01'' |
| Q30L60XallP000 |   69.6 |  80.24% |      3904 | 234.48M | 78209 |      1008 | 26.09M | 318055 |   62.0 | 8.0 |  12.7 | 124.0 | "31,41,51,61,71,81" | 1:10'57'' | 2:20'12'' |

Table: statMRKunitigsAnchors.md

| Name       | CovCor | Mapped% | N50Anchor |     Sum |     # | N50Others |    Sum |      # | median |  MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:-----------|-------:|--------:|----------:|--------:|------:|----------:|-------:|-------:|-------:|-----:|------:|------:|--------------------:|----------:|----------:|
| MRX40P000  |   40.0 |  77.56% |      4553 |  241.5M | 70819 |       941 | 15.72M | 190022 |   37.0 |  5.0 |   7.3 |  74.0 | "31,41,51,61,71,81" | 2:07'06'' | 0:58'05'' |
| MRX40P001  |   40.0 |  77.51% |      4569 | 241.34M | 70663 |       896 | 15.68M | 189558 |   37.0 |  5.0 |   7.3 |  74.0 | "31,41,51,61,71,81" | 2:07'12'' | 0:58'00'' |
| MRX60P000  |   60.0 |  77.04% |      4503 | 243.14M | 71637 |       846 | 13.31M | 184720 |   56.0 |  8.0 |  10.7 | 112.0 | "31,41,51,61,71,81" | 2:37'16'' | 0:57'31'' |
| MRXallP000 |   92.0 |  76.45% |      4344 | 241.98M | 73057 |       812 |  13.3M | 183226 |   86.0 | 12.0 |  16.7 | 172.0 | "31,41,51,61,71,81" | 3:25'29'' | 0:57'29'' |

Table: statMRTadpoleAnchors.md

| Name       | CovCor | Mapped% | N50Anchor |     Sum |     # | N50Others |    Sum |      # | median |  MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:-----------|-------:|--------:|----------:|--------:|------:|----------:|-------:|-------:|-------:|-----:|------:|------:|--------------------:|----------:|----------:|
| MRX40P000  |   40.0 |  79.41% |      4652 | 242.15M | 70387 |       789 | 15.44M | 212690 |   37.0 |  5.0 |   7.3 |  74.0 | "31,41,51,61,71,81" | 1:12'29'' | 1:10'54'' |
| MRX40P001  |   40.0 |  79.39% |      4668 |  242.3M | 70170 |       639 | 14.78M | 211867 |   38.0 |  5.0 |   7.7 |  76.0 | "31,41,51,61,71,81" | 1:12'26'' | 1:11'28'' |
| MRX60P000  |   60.0 |  79.18% |      4850 | 244.24M | 68644 |       766 | 14.91M | 193820 |   56.0 |  7.0 |  11.7 | 112.0 | "31,41,51,61,71,81" | 1:20'44'' | 1:06'20'' |
| MRXallP000 |   92.0 |  78.97% |      4903 | 246.15M | 68669 |       698 |    13M | 187545 |   86.0 | 12.0 |  16.7 | 172.0 | "31,41,51,61,71,81" | 1:32'21'' | 1:05'54'' |


Table: statFinal

| Name                             |      N50 |       Sum |       # |
|:---------------------------------|---------:|----------:|--------:|
| Genome                           | 27449063 | 346663259 |      12 |
| 7_mergeKunitigsAnchors.anchors   |     5202 | 254759651 |   68862 |
| 7_mergeKunitigsAnchors.others    |     1081 |  43543952 |   39006 |
| 7_mergeTadpoleAnchors.anchors    |     4695 | 250036556 |   73094 |
| 7_mergeTadpoleAnchors.others     |     1060 |  43141307 |   38651 |
| 7_mergeMRKunitigsAnchors.anchors |     5158 | 249918447 |   67109 |
| 7_mergeMRKunitigsAnchors.others  |     1085 |  16505542 |   14963 |
| 7_mergeMRTadpoleAnchors.anchors  |     5062 | 249502144 |   68008 |
| 7_mergeMRTadpoleAnchors.others   |     1070 |  15910348 |   14446 |
| 7_mergeAnchors.anchors           |     5855 | 262843845 |   64842 |
| 7_mergeAnchors.others            |     1070 |  71389392 |   63817 |
| spades.contig                    |    11495 | 356732192 |  522159 |
| spades.scaffold                  |    12074 | 356757610 |  520764 |
| spades.non-contained             |    14866 | 291946827 |   34248 |
| spades.anchor                    |     6637 | 265879012 |   56518 |
| megahit.contig                   |     6329 | 311632902 |  150108 |
| megahit.non-contained            |     7458 | 272700006 |   55953 |
| megahit.anchor                   |     4746 | 244692400 |   68677 |
| platanus.contig                  |     1355 | 426620446 | 1614003 |
| platanus.scaffold                |     7547 | 326320668 |  416433 |
| platanus.non-contained           |     9508 | 268787420 |   43446 |
| platanus.anchor                  |     6722 | 254084936 |   54252 |


# JDM

* *Actinidia chinensis*
* 猕猴桃
* Taxonomy ID:
  [3625](https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?mode=Info&id=3625)

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
ln -s ../../RawData/JDM003_2.fq.gz R2.fq.gz

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
    --trim2 "--uniq --bbduk" \
    --cov2 "all" \
    --qual2 "25 30" \
    --len2 "60" \
    --filter "adapter,phix,artifact" \
    --tadpole \
    --mergereads \
    --ecphase "1,3" \
    --insertsize \
    --parallel 24

```

## JDM003: run

Same as [ZS97: run](#zs97-run)

* Mapping reads against reference genome

```bash
WORKING_DIR=${HOME}/data/dna-seq/chara
BASE_NAME=JDM003

cd ${WORKING_DIR}/${BASE_NAME}

cd 2_illumina

bbmap.sh \
    in=R1.fq.gz \
    in2=R2.fq.gz \
    out=pe.sam.gz \
    ref=../1_genome/genome.fa \
    threads=16 \
    fast nodisk overwrite

# with picard
# bam need to be sorted
picard SortSam \
    I=pe.sam.gz \
    O=pe.sort.bam \
    SORT_ORDER=coordinate \
    VALIDATION_STRINGENCY=LENIENT

picard CollectInsertSizeMetrics \
    I=pe.sort.bam \
    O=insert_size.metrics.txt \
    HISTOGRAM_FILE=insert_size.metrics.pdf

# with bbtools
reformat.sh \
    in=pe.sam.gz \
    ihist=ihist.genome.txt \
    overwrite

# bwa
bwa index -a bwtsw ../1_genome/genome.fa
samtools faidx ../1_genome/genome.fa
bwa mem -M -t 16 \
    ../1_genome/genome.fa \
    R1.fq.gz \
    R2.fq.gz \
    | pigz -3 > bwa.sam.gz

picard SortSam \
    I=bwa.sam.gz \
    O=bwa.sort.bam \
    SORT_ORDER=coordinate \
    VALIDATION_STRINGENCY=LENIENT

picard CollectInsertSizeMetrics \
    I=bwa.sort.bam \
    O=bwa.insert_size.txt \
    HISTOGRAM_FILE=bwa.insert_size.pdf

```

* Sam to fastq

```bash
cd ~/data/dna-seq/chara/novo

# from novo
reformat.sh \
    in=NDSW08998_L1.sam.gz \
    ihist=NDSW08998_L1.ihist.txt \
    overwrite

picard SortSam \
    I=NDSW08998_L1.sam.gz \
    O=NDSW08998_L1.sort.bam \
    SORT_ORDER=coordinate

picard CollectInsertSizeMetrics \
    I=NDSW08998_L1.sort.bam \
    O=NDSW08998_L1.insert_size.txt \
    HISTOGRAM_FILE=NDSW08998_L1.insert_size.pdf

picard SamToFastq \
    I=NDSW08998_L1.sam.gz \
    FASTQ=NDSW08998_L1.fq.gz \
    INTERLEAVE=True

fastqc NDSW08998_L1.fq.gz

# bbmap
bbmap.sh \
    in=NDSW08998_L1.fq.gz \
    out=pe.sam.gz \
    ref=../JDM/1_genome/genome.fa \
    threads=16 \
    fast nodisk overwrite

picard SortSam \
    I=pe.sam.gz \
    O=pe.sort.bam \
    SORT_ORDER=coordinate \
    VALIDATION_STRINGENCY=LENIENT

picard CollectInsertSizeMetrics \
    I=pe.sort.bam \
    O=remap.insert_size.txt \
    HISTOGRAM_FILE=remap.insert_size.pdf

reformat.sh \
    in=pe.sam.gz \
    ihist=remap.ihist.txt \
    overwrite

# bwa
bwa index -a bwtsw ../JDM/1_genome/genome.fa
bwa mem -M -t 16 -p \
    ../JDM/1_genome/genome.fa \
    NDSW08998_L1.fq.gz \
    | pigz -3 > bwa.sam.gz

picard SortSam \
    I=bwa.sam.gz \
    O=bwa.sort.bam \
    SORT_ORDER=coordinate \
    VALIDATION_STRINGENCY=LENIENT

picard CollectInsertSizeMetrics \
    I=bwa.sort.bam \
    O=bwa.insert_size.txt \
    HISTOGRAM_FILE=bwa.insert_size.pdf

```

Table: statInsertSize

| Group           |  Mean | Median | STDev | PercentOfPairs/PairOrientation |
|:----------------|------:|-------:|------:|-------------------------------:|
| genome.bbtools  | 312.8 |    287 | 676.4 |                         22.16% |
| tadpole.bbtools | 267.8 |    267 |  63.0 |                          9.36% |
| genome.picard   | 289.5 |    287 |  58.0 |                             FR |
| tadpole.picard  | 263.2 |    264 |  65.0 |                             FR |


Table: statReads

| Name     |   N50 |       Sum |         # |
|:---------|------:|----------:|----------:|
| Genome   | 58864 | 604217145 |     26721 |
| Illumina |   150 |    21.26G | 141737926 |
| uniq     |   150 |       20G | 133348308 |
| bbduk    |   150 |    19.95G | 133347134 |
| Q25L60   |   150 |    19.14G | 130035594 |
| Q30L60   |   150 |    17.22G | 121620602 |

```text
#trimmedReads
#Matched	431421	0.32353%
#Name	Reads	ReadsPct
Reverse_adapter	146908	0.11017%
pcr_dimer	70889	0.05316%
TruSeq_Adapter_Index_1_6	53750	0.04031%
PCR_Primers	40546	0.03041%
PhiX_read2_adapter	33846	0.02538%
TruSeq_Universal_Adapter	28488	0.02136%
Nextera_LMP_Read2_External_Adapter	23635	0.01772%
PhiX_read1_adapter	5421	0.00407%
I5_Nextera_Transposase_1	4507	0.00338%
RNA_Adapter_(RA5)_part_#_15013205	3246	0.00243%
RNA_PCR_Primer_Index_1_(RPI1)_2,9	2398	0.00180%
Nextera_LMP_Read1_External_Adapter	1962	0.00147%
TruSeq_Adapter_Index_16	1841	0.00138%
Bisulfite_R2	1387	0.00104%
I7_Primer_Nextera_XT_and_Nextera_Enrichment_N701	1353	0.00101%
TruSeq_Adapter_Index_2	1289	0.00097%
Bisulfite_R1	1266	0.00095%
I7_Nextera_Transposase_2	1265	0.00095%
I5_Nextera_Transposase_2	1064	0.00080%
```


Table: statMergeReads

| Name          | N50 |     Sum |         # |
|:--------------|----:|--------:|----------:|
| clumped       | 150 |     20G | 133325258 |
| trimmed       | 150 |  19.53G | 131679856 |
| filtered      | 150 |  19.53G | 131677212 |
| ecco          | 150 |  19.53G | 131677212 |
| ecct          | 150 |   12.3G |  82632248 |
| extended      | 190 |  15.07G |  82632248 |
| merged        | 324 |   11.5G |  36459533 |
| unmerged.raw  | 173 |   1.66G |   9713182 |
| unmerged.trim | 170 |   1.39G |   8902444 |
| U1            | 170 | 727.47M |   4451222 |
| U2            | 169 | 665.12M |   4451222 |
| Us            |   0 |       0 |         0 |
| pe.cor        | 316 |  12.93G |  81821510 |

| Group            |  Mean | Median | STDev | PercentOfPairs |
|:-----------------|------:|-------:|------:|---------------:|
| ihist.merge1.txt | 242.4 |    248 |  32.4 |         36.68% |
| ihist.merge.txt  | 315.4 |    315 |  56.0 |         88.25% |

```text
#trimmedReads
#Matched	431381	0.32356%
#Name	Reads	ReadsPct
Reverse_adapter	146900	0.11018%
pcr_dimer	70886	0.05317%
TruSeq_Adapter_Index_1_6	53741	0.04031%
PCR_Primers	40544	0.03041%
PhiX_read2_adapter	33837	0.02538%
TruSeq_Universal_Adapter	28488	0.02137%
Nextera_LMP_Read2_External_Adapter	23630	0.01772%
PhiX_read1_adapter	5421	0.00407%
I5_Nextera_Transposase_1	4506	0.00338%
RNA_Adapter_(RA5)_part_#_15013205	3246	0.00243%
RNA_PCR_Primer_Index_1_(RPI1)_2,9	2398	0.00180%
Nextera_LMP_Read1_External_Adapter	1960	0.00147%
TruSeq_Adapter_Index_16	1841	0.00138%
Bisulfite_R2	1387	0.00104%
I7_Primer_Nextera_XT_and_Nextera_Enrichment_N701	1353	0.00101%
TruSeq_Adapter_Index_2	1289	0.00097%
Bisulfite_R1	1266	0.00095%
I7_Nextera_Transposase_2	1264	0.00095%
I5_Nextera_Transposase_2	1064	0.00080%
```

```text
#filteredReads
#Matched	1364	0.00104%
#Name	Reads	ReadsPct
contam_43	335	0.00025%
contam_139	211	0.00016%
contam_32	205	0.00016%
Reverse_adapter	178	0.00014%
```


Table: statQuorum

| Name   | CovIn | CovOut | Discard% | AvgRead |  Kmer |   RealG |    EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|------:|--------:|--------:|---------:|----------:|
| Q25L60 |  31.7 |   21.5 |   32.14% |     147 | "105" | 604.22M | 885.79M |     1.47 | 0:49'17'' |
| Q30L60 |  28.5 |   21.1 |   26.06% |     143 | "105" | 604.22M | 854.65M |     1.41 | 0:44'28'' |


Table: statKunitigsAnchors.md

| Name           | CovCor | Mapped% | N50Anchor |    Sum |    # | N50Others |    Sum |     # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|-------:|-----:|----------:|-------:|------:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q25L60XallP000 |   21.5 |   2.14% |      1214 | 10.46M | 8198 |      1093 | 13.63M | 28151 |    8.0 | 2.0 |   3.0 |  16.0 | "31,41,51,61,71,81" | 2:12'40'' | 0:03'17'' |
| Q30L60XallP000 |   21.1 |   2.37% |      1208 |  9.93M | 7858 |      1108 | 14.65M | 28248 |    8.0 | 2.0 |   3.0 |  16.0 | "31,41,51,61,71,81" | 2:05'33'' | 0:03'16'' |


Table: statTadpoleAnchors.md

| Name           | CovCor | Mapped% | N50Anchor |    Sum |    # | N50Others |   Sum |     # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|-------:|-----:|----------:|------:|------:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q25L60XallP000 |   21.5 |  20.76% |      1208 | 10.19M | 8020 |      1085 |  8.7M | 23641 |   12.0 | 3.0 |   3.0 |  24.0 | "31,41,51,61,71,81" | 0:49'21'' | 0:03'03'' |
| Q30L60XallP000 |   21.1 |  22.38% |      1203 | 10.49M | 8294 |      1097 | 9.22M | 24695 |   12.0 | 3.0 |   3.0 |  24.0 | "31,41,51,61,71,81" | 0:48'19'' | 0:03'07'' |


Table: statMRKunitigsAnchors.md

| Name       | CovCor | Mapped% | N50Anchor |   Sum |    # | N50Others |    Sum |     # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:-----------|-------:|--------:|----------:|------:|-----:|----------:|-------:|------:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| MRXallP000 |   21.4 |   6.74% |      1189 | 7.68M | 6225 |      1150 | 19.85M | 27871 |    8.0 | 2.0 |   3.0 |  16.0 | "31,41,51,61,71,81" | 2:02'53'' | 0:03'07'' |


Table: statMRTadpoleAnchors.md

| Name       | CovCor | Mapped% | N50Anchor |   Sum |     # | N50Others |    Sum |     # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:-----------|-------:|--------:|----------:|------:|------:|----------:|-------:|------:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| MRXallP000 |   21.4 |  26.29% |      1242 | 19.5M | 15003 |      1132 | 25.28M | 48071 |   10.0 | 3.0 |   3.0 |  20.0 | "31,41,51,61,71,81" | 0:55'16'' | 0:04'23'' |


Table: statFinal

| Name                             |   N50 |       Sum |       # |
|:---------------------------------|------:|----------:|--------:|
| Genome                           | 58864 | 604217145 |   26721 |
| 7_mergeKunitigsAnchors.anchors   |  1213 |  13034663 |   10229 |
| 7_mergeKunitigsAnchors.others    |  1108 |  17432525 |   14794 |
| 7_mergeTadpoleAnchors.anchors    |  1210 |  12770292 |   10043 |
| 7_mergeTadpoleAnchors.others     |  1094 |  10705702 |    8384 |
| 7_mergeMRKunitigsAnchors.anchors |  1189 |   7681952 |    6225 |
| 7_mergeMRKunitigsAnchors.others  |  1162 |  18961721 |   15172 |
| 7_mergeMRTadpoleAnchors.anchors  |  1242 |  19496744 |   15003 |
| 7_mergeMRTadpoleAnchors.others   |  1152 |  23695658 |   18778 |
| 7_mergeAnchors.anchors           |  1232 |  35052087 |   27074 |
| 7_mergeAnchors.others            |  1132 |  49015675 |   39974 |
| spades.contig                    |  4533 | 818938221 |  693926 |
| spades.scaffold                  |  4590 | 819022629 |  692367 |
| spades.non-contained             |  7458 | 610018396 |  140016 |
| spades.anchor                    |  1117 |   2170804 |    1891 |
| megahit.contig                   |   705 | 982975032 | 1709468 |
| megahit.non-contained            |  1674 | 349302930 |  206914 |
| megahit.anchor                   |  1105 |    451668 |     398 |
| platanus.contig                  |   285 |    585870 |    1924 |
| platanus.scaffold                |  7916 |    292928 |     302 |
| platanus.non-contained           | 20483 |    239506 |      41 |
| platanus.anchor                  |  2808 |     70678 |      30 |

# JDM006

## JDM006: download

```bash
mkdir -p ~/data/dna-seq/chara/JDM006/1_genome
cd ~/data/dna-seq/chara/JDM006/1_genome

ln -s ../../JDM/1_genome/genome.fa genome.fa

mkdir -p ~/data/dna-seq/chara/JDM006/2_illumina
cd ~/data/dna-seq/chara/JDM006/2_illumina

ln -s ../../RawData/JDM006_1.fq.gz R1.fq.gz
ln -s ../../RawData/JDM006_2.fq.gz R2.fq.gz

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
    --trim2 "--uniq --bbduk" \
    --cov2 "all" \
    --qual2 "25 30" \
    --len2 "60" \
    --filter "adapter,phix,artifact" \
    --tadpole \
    --mergereads \
    --ecphase "1,3" \
    --insertsize \
    --parallel 24

```

## JDM006: run

Same as [ZS97: run](#zs97-run)

| Name     |   N50 |       Sum |         # |
|:---------|------:|----------:|----------:|
| Genome   | 58864 | 604217145 |     26721 |
| Illumina |   150 |    22.58G | 150520322 |
| uniq     |   150 |    18.97G | 126484946 |
| bbduk    |   150 |    18.95G | 126484018 |
| Q25L60   |   150 |    18.28G | 123795068 |
| Q30L60   |   150 |    16.84G | 116878858 |

```text
#trimmedReads
#Matched	486740	0.38482%
#Name	Reads	ReadsPct
Reverse_adapter	312428	0.24701%
TruSeq_Adapter_Index_1_6	103150	0.08155%
PhiX_read2_adapter	30488	0.02410%
PhiX_read1_adapter	4950	0.00391%
I5_Nextera_Transposase_1	4694	0.00371%
RNA_Adapter_(RA5)_part_#_15013205	3320	0.00262%
Nextera_LMP_Read2_External_Adapter	2978	0.00235%
TruSeq_Adapter_Index_2	2542	0.00201%
Nextera_LMP_Read1_External_Adapter	2354	0.00186%
TruSeq_Adapter_Index_16	2094	0.00166%
RNA_PCR_Primer_Index_1_(RPI1)_2,9	1934	0.00153%
I5_Nextera_Transposase_2	1780	0.00141%
Bisulfite_R1	1730	0.00137%
I7_Primer_Nextera_XT_and_Nextera_Enrichment_N701	1612	0.00127%
I7_Nextera_Transposase_2	1558	0.00123%
I5_Primer_Nextera_XT_and_Nextera_Enrichment_[N/S/E]501	1554	0.00123%
TruSeq_Universal_Adapter	1090	0.00086%
```

| Group  |  Mean | Median | STDev | PercentOfPairs |
|:-------|------:|-------:|------:|---------------:|
| Q25L60 | 148.2 |    150 |  10.4 |          5.70% |
| Q30L60 | 142.6 |    150 |  20.0 |          7.00% |

| Name         | N50 |     Sum |        # |
|:-------------|----:|--------:|---------:|
| clumped      | 150 |   9.12G | 60778008 |
| trimmed      | 150 |   8.97G | 60402159 |
| filtered     | 150 |   8.97G | 60400287 |
| ecco         | 150 |   8.89G | 60400286 |
| ecct         | 150 |   4.78G | 32513042 |
| extended     | 186 |   5.71G | 32513042 |
| merged       | 181 | 345.19M |  1995589 |
| unmerged.raw | 187 |   5.04G | 28521864 |
| unmerged     | 182 |   4.69G | 27868846 |

| Group            |  Mean | Median | STDev | PercentOfPairs |
|:-----------------|------:|-------:|------:|---------------:|
| ihist.merge1.txt | 148.3 |    149 |  37.8 |          9.22% |
| ihist.merge.txt  | 173.0 |    174 |  38.3 |         12.28% |

```text
#trimmedReads
#Matched	238937	0.39313%
#Name	Reads	ReadsPct
Reverse_adapter	154139	0.25361%
TruSeq_Adapter_Index_1_6	50497	0.08308%
PhiX_read2_adapter	14639	0.02409%
PhiX_read1_adapter	2362	0.00389%
I5_Nextera_Transposase_1	2235	0.00368%
RNA_Adapter_(RA5)_part_#_15013205	1580	0.00260%
Nextera_LMP_Read2_External_Adapter	1447	0.00238%
TruSeq_Adapter_Index_2	1267	0.00208%
Nextera_LMP_Read1_External_Adapter	1146	0.00189%
TruSeq_Adapter_Index_16	1047	0.00172%
```

```text
#filteredReads
#Matched	1872	0.00310%
#Name	Reads	ReadsPct
Reverse_adapter	1253	0.00207%
contam_43	132	0.00022%
contam_139	108	0.00018%
```


| Name   | CovIn | CovOut | Discard% | AvgRead |  Kmer |   RealG |  EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|------:|--------:|------:|---------:|----------:|
| Q25L60 |  30.2 |   22.6 |   25.38% |     147 | "105" | 604.22M | 1.11G |     1.84 | 0:40'40'' |
| Q30L60 |  27.9 |   22.1 |   20.74% |     144 | "105" | 604.22M | 1.07G |     1.77 | 0:36'39'' |


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
mkdir -p ~/data/dna-seq/chara/JDM008/1_genome
cd ~/data/dna-seq/chara/JDM008/1_genome

ln -s ../../JDM/1_genome/genome.fa genome.fa

mkdir -p ~/data/dna-seq/chara/JDM008/2_illumina
cd ~/data/dna-seq/chara/JDM008/2_illumina

ln -s ../../RawData/JDM008_1.fq.gz R1.fq.gz
ln -s ../../RawData/JDM008_2.fq.gz R2.fq.gz

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
    --trim2 "--uniq --bbduk" \
    --cov2 "all" \
    --qual2 "25 30" \
    --len2 "60" \
    --filter "adapter,phix,artifact" \
    --tadpole \
    --mergereads \
    --ecphase "1,3" \
    --insertsize \
    --parallel 24

```

## JDM008: run

Same as [FCM05: run](#zs97-run)

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
mkdir -p ~/data/dna-seq/chara/JDM009/1_genome
cd ~/data/dna-seq/chara/JDM009/1_genome

ln -s ../../JDM/1_genome/genome.fa genome.fa

mkdir -p ~/data/dna-seq/chara/JDM009/2_illumina
cd ~/data/dna-seq/chara/JDM009/2_illumina

ln -s ../../RawData/JDM009_1.fq.gz R1.fq.gz
ln -s ../../RawData/JDM009_2.fq.gz R2.fq.gz

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
    --trim2 "--uniq --bbduk" \
    --cov2 "all" \
    --qual2 "25 30" \
    --len2 "60" \
    --filter "adapter,phix,artifact" \
    --tadpole \
    --mergereads \
    --ecphase "1,3" \
    --insertsize \
    --parallel 24

```

## JDM009: run

Same as [FCM05: run](#zs97-run)

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
mkdir -p ~/data/dna-seq/chara/JDM016/1_genome
cd ~/data/dna-seq/chara/JDM016/1_genome

ln -s ../../JDM/1_genome/genome.fa genome.fa

mkdir -p ~/data/dna-seq/chara/JDM016/2_illumina
cd ~/data/dna-seq/chara/JDM016/2_illumina

ln -s ../../RawData/JDM016_1.fq.gz R1.fq.gz
ln -s ../../RawData/JDM016_2.fq.gz R2.fq.gz

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
    --trim2 "--uniq --bbduk" \
    --cov2 "all" \
    --qual2 "25 30" \
    --len2 "60" \
    --filter "adapter,phix,artifact" \
    --tadpole \
    --mergereads \
    --ecphase "1,3" \
    --insertsize \
    --parallel 24

```

## JDM016: run

Same as [FCM05: run](#zs97-run)

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
mkdir -p ~/data/dna-seq/chara/JDM018/1_genome
cd ~/data/dna-seq/chara/JDM018/1_genome

ln -s ../../JDM/1_genome/genome.fa genome.fa

mkdir -p ~/data/dna-seq/chara/JDM018/2_illumina
cd ~/data/dna-seq/chara/JDM018/2_illumina

ln -s ../../RawData/JDM018_1.fq.gz R1.fq.gz
ln -s ../../RawData/JDM018_2.fq.gz R2.fq.gz

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
    --trim2 "--uniq --bbduk" \
    --cov2 "all" \
    --qual2 "25 30" \
    --len2 "60" \
    --filter "adapter,phix,artifact" \
    --tadpole \
    --mergereads \
    --ecphase "1,3" \
    --insertsize \
    --parallel 24

```

## JDM018: run

Same as [FCM05: run](#zs97-run)

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

SR had failed twice due to the calculating results from awk were larger
than the MAX_INT

* for jellyfish
* for --number-reads of
  `getSuperReadInsertCountsFromReadPlacementFileTwoPasses`

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
