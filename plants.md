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

cd ${WORKING_DIR}/${BASE_NAME}

anchr template \
    . \
    --basename ${BASE_NAME} \
    --queue largemem \
    --genome 346663259 \
    --is_euk \
    --trim2 "--dedupe" \
    --cov2 "40 60 all" \
    --qual2 "25 30" \
    --len2 "60" \
    --filter "adapter,phix,artifact" \
    --tadpole \
    --mergereads \
    --ecphase "1,3" \
    --insertsize \
    --fillanchor \
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

Table: statInsertSize

| Group           |  Mean | Median | STDev | PercentOfPairs/PairOrientation |
|:----------------|------:|-------:|------:|-------------------------------:|
| genome.bbtools  | 314.1 |    289 | 656.5 |                         21.06% |
| tadpole.bbtools | 262.6 |    261 |  65.0 |                          7.58% |
| genome.picard   | 291.9 |    289 |  60.6 |                             FR |
| tadpole.picard  | 257.6 |    258 |  67.8 |                             FR |


Table: statReads

| Name     |   N50 |       Sum |         # |
|:---------|------:|----------:|----------:|
| Genome   | 58864 | 604217145 |     26721 |
| Illumina |   150 |    22.58G | 150520322 |
| uniq     |     0 |         0 |         0 |
| bbduk    |     0 |         0 |         0 |
| Q25L60   |   150 |    20.31G | 137935159 |
| Q30L60   |   150 |    18.34G | 129215286 |

```text
#trimmedReads
#Matched	505147	0.35707%
#Name	Reads	ReadsPct
Reverse_adapter	169194	0.11960%
pcr_dimer	83405	0.05896%
TruSeq_Adapter_Index_1_6	72399	0.05118%
PCR_Primers	47109	0.03330%
PhiX_read2_adapter	34803	0.02460%
Nextera_LMP_Read2_External_Adapter	30626	0.02165%
TruSeq_Universal_Adapter	30170	0.02133%
PhiX_read1_adapter	5524	0.00390%
I5_Nextera_Transposase_1	5426	0.00384%
RNA_Adapter_(RA5)_part_#_15013205	3634	0.00257%
RNA_PCR_Primer_Index_1_(RPI1)_2,9	2446	0.00173%
Nextera_LMP_Read1_External_Adapter	2127	0.00150%
I5_Nextera_Transposase_2	1866	0.00132%
I5_Primer_Nextera_XT_and_Nextera_Enrichment_[N/S/E]501	1810	0.00128%
I7_Primer_Nextera_XT_and_Nextera_Enrichment_N701	1785	0.00126%
I7_Nextera_Transposase_2	1623	0.00115%
Bisulfite_R2	1461	0.00103%
Bisulfite_R1	1419	0.00100%
TruSeq_Adapter_Index_2	1271	0.00090%
I5_Adapter_Nextera	1097	0.00078%
I7_Adapter_Nextera_No_Barcode	1083	0.00077%
TruSeq_Adapter_Index_16	1047	0.00074%
```


Table: statMergeReads

| Name          | N50 |     Sum |         # |
|:--------------|----:|--------:|----------:|
| clumped       | 150 |  21.22G | 141445852 |
| trimmed       | 150 |  20.72G | 139709700 |
| filtered      | 150 |  20.72G | 139707076 |
| ecco          | 150 |  20.72G | 139707076 |
| ecct          | 150 |  12.83G |  86206630 |
| extended      | 190 |  15.68G |  86206630 |
| merged        | 325 |  11.83G |  37466340 |
| unmerged.raw  | 174 |   1.93G |  11273950 |
| unmerged.trim | 170 |   1.63G |  10391020 |
| U1            | 170 | 852.64M |   5195510 |
| U2            | 170 | 781.17M |   5195510 |
| Us            |   0 |       0 |         0 |
| pe.cor        | 316 |   13.5G |  85323700 |

| Group            |  Mean | Median | STDev | PercentOfPairs |
|:-----------------|------:|-------:|------:|---------------:|
| ihist.merge1.txt | 241.3 |    248 |  33.3 |         35.95% |
| ihist.merge.txt  | 315.8 |    315 |  57.6 |         86.92% |

```text
#trimmedReads
#Matched	505107	0.35710%
#Name	Reads	ReadsPct
Reverse_adapter	169185	0.11961%
pcr_dimer	83403	0.05896%
TruSeq_Adapter_Index_1_6	72383	0.05117%
PCR_Primers	47108	0.03330%
PhiX_read2_adapter	34801	0.02460%
Nextera_LMP_Read2_External_Adapter	30620	0.02165%
TruSeq_Universal_Adapter	30170	0.02133%
PhiX_read1_adapter	5523	0.00390%
I5_Nextera_Transposase_1	5423	0.00383%
RNA_Adapter_(RA5)_part_#_15013205	3634	0.00257%
RNA_PCR_Primer_Index_1_(RPI1)_2,9	2446	0.00173%
Nextera_LMP_Read1_External_Adapter	2127	0.00150%
I5_Nextera_Transposase_2	1866	0.00132%
I5_Primer_Nextera_XT_and_Nextera_Enrichment_[N/S/E]501	1810	0.00128%
I7_Primer_Nextera_XT_and_Nextera_Enrichment_N701	1785	0.00126%
I7_Nextera_Transposase_2	1623	0.00115%
Bisulfite_R2	1461	0.00103%
Bisulfite_R1	1419	0.00100%
TruSeq_Adapter_Index_2	1271	0.00090%
I5_Adapter_Nextera	1097	0.00078%
I7_Adapter_Nextera_No_Barcode	1083	0.00077%
TruSeq_Adapter_Index_16	1047	0.00074%
```

```text
#filteredReads
#Matched	1357	0.00097%
#Name	Reads	ReadsPct
contam_43	294	0.00021%
contam_139	216	0.00015%
contam_32	195	0.00014%
Reverse_adapter	158	0.00011%
```


Table: statQuorum

| Name   | CovIn | CovOut | Discard% | AvgRead |  Kmer |   RealG |    EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|------:|--------:|--------:|---------:|----------:|
| Q25L60 |  33.6 |   22.7 |   32.56% |     147 | "105" | 604.22M |    991M |     1.64 | 0:55'06'' |
| Q30L60 |  30.4 |   22.3 |   26.70% |     143 | "105" | 604.22M | 955.33M |     1.58 | 0:51'50'' |


Table: statKunitigsAnchors.md

| Name           | CovCor | Mapped% | N50Anchor |    Sum |     # | N50Others |    Sum |     # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|-------:|------:|----------:|-------:|------:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q25L60XallP000 |   22.7 |   3.10% |      1298 |  13.7M |  9952 |      1251 | 25.47M | 35456 |    7.0 | 2.0 |   3.0 |  14.0 | "31,41,51,61,71,81" | 2:28'55'' | 0:04'11'' |
| Q30L60XallP000 |   22.3 |   3.45% |      1328 | 16.55M | 11733 |      1177 | 21.37M | 37276 |    8.0 | 2.0 |   3.0 |  16.0 | "31,41,51,61,71,81" | 2:22'05'' | 0:04'11'' |


Table: statTadpoleAnchors.md

| Name           | CovCor | Mapped% | N50Anchor |    Sum |    # | N50Others |    Sum |     # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|-------:|-----:|----------:|-------:|------:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q25L60XallP000 |   22.7 |  15.50% |      1542 | 15.11M | 8331 |      1123 | 11.59M | 27137 |   11.0 | 3.0 |   3.0 |  22.0 | "31,41,51,61,71,81" | 0:55'15'' | 0:03'39'' |
| Q30L60XallP000 |   22.3 |  15.94% |      1502 | 16.52M | 9255 |      1109 | 10.43M | 28159 |   12.0 | 3.0 |   3.0 |  24.0 | "31,41,51,61,71,81" | 0:53'53'' | 0:03'43'' |


Table: statMRKunitigsAnchors.md

| Name       | CovCor | Mapped% | N50Anchor |   Sum |    # | N50Others |    Sum |     # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:-----------|-------:|--------:|----------:|------:|-----:|----------:|-------:|------:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| MRXallP000 |   22.3 |   4.56% |      1227 | 7.93M | 6124 |      1257 | 17.84M | 23700 |   10.0 | 4.0 |   3.0 |  20.0 | "31,41,51,61,71,81" | 2:09'18'' | 0:03'01'' |


Table: statMRTadpoleAnchors.md

| Name       | CovCor | Mapped% | N50Anchor |    Sum |     # | N50Others |    Sum |     # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:-----------|-------:|--------:|----------:|-------:|------:|----------:|-------:|------:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| MRXallP000 |   22.3 |  19.56% |      1258 | 19.88M | 15052 |      1198 | 28.12M | 46229 |   10.0 | 3.0 |   3.0 |  20.0 | "31,41,51,61,71,81" | 0:59'18'' | 0:04'28'' |


Table: statFinal

| Name                             |   N50 |        Sum |       # |
|:---------------------------------|------:|-----------:|--------:|
| Genome                           | 58864 |  604217145 |   26721 |
| 7_mergeKunitigsAnchors.anchors   |  1325 |   19307869 |   13717 |
| 7_mergeKunitigsAnchors.others    |  1226 |   27657395 |   19398 |
| 7_mergeTadpoleAnchors.anchors    |  1447 |   18530238 |   10659 |
| 7_mergeTadpoleAnchors.others     |  1128 |   13037722 |   10181 |
| 7_mergeMRKunitigsAnchors.anchors |  1227 |    7925945 |    6124 |
| 7_mergeMRKunitigsAnchors.others  |  1296 |   16471159 |   11368 |
| 7_mergeMRTadpoleAnchors.anchors  |  1258 |   19876598 |   15052 |
| 7_mergeMRTadpoleAnchors.others   |  1224 |   26403917 |   18379 |
| 7_mergeAnchors.anchors           |  1336 |   40368857 |   26616 |
| 7_mergeAnchors.others            |  1183 |   57365421 |   41577 |
| spades.contig                    |  3514 |  964928110 |  936978 |
| spades.scaffold                  |  3561 |  965033788 |  934820 |
| spades.non-contained             |  7007 |  678934105 |  166419 |
| spades.anchor                    |  1036 |       2041 |       2 |
| megahit.contig                   |   668 | 1089592973 | 1960130 |
| megahit.non-contained            |  1648 |  360851537 |  213657 |
| megahit.anchor                   |  1098 |     515903 |     455 |
| platanus.contig                  |   249 |     949774 |    3616 |
| platanus.scaffold                |  5475 |     420306 |     603 |
| platanus.non-contained           |  8176 |     308614 |      69 |
| platanus.anchor                  |  2497 |      86016 |      38 |

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

Table: statInsertSize

| Group           |  Mean | Median | STDev | PercentOfPairs/PairOrientation |
|:----------------|------:|-------:|------:|-------------------------------:|
| genome.bbtools  | 338.4 |    314 | 677.7 |                         21.83% |
| tadpole.bbtools | 281.2 |    281 |  72.1 |                          6.42% |
| genome.picard   | 314.4 |    314 |  66.8 |                             FR |
| tadpole.picard  | 276.2 |    278 |  74.8 |                             FR |


Table: statReads

| Name     |   N50 |       Sum |         # |
|:---------|------:|----------:|----------:|
| Genome   | 58864 | 604217145 |     26721 |
| Illumina |   150 |    22.51G | 150077492 |
| uniq     |     0 |         0 |         0 |
| bbduk    |     0 |         0 |         0 |
| Q25L60   |   150 |    20.18G | 137237156 |
| Q30L60   |   150 |     18.1G | 128092308 |

```text
#trimmedReads
#Matched	587551	0.41694%
#Name	Reads	ReadsPct
Reverse_adapter	209688	0.14880%
pcr_dimer	109524	0.07772%
TruSeq_Adapter_Index_1_6	64750	0.04595%
PCR_Primers	61242	0.04346%
TruSeq_Universal_Adapter	40703	0.02888%
PhiX_read2_adapter	34692	0.02462%
Nextera_LMP_Read2_External_Adapter	29209	0.02073%
PhiX_read1_adapter	5600	0.00397%
I5_Nextera_Transposase_1	5417	0.00384%
RNA_Adapter_(RA5)_part_#_15013205	3572	0.00253%
RNA_PCR_Primer_Index_1_(RPI1)_2,9	2415	0.00171%
Nextera_LMP_Read1_External_Adapter	2235	0.00159%
TruSeq_Adapter_Index_16	1929	0.00137%
TruSeq_Adapter_Index_2	1786	0.00127%
Bisulfite_R2	1724	0.00122%
I7_Primer_Nextera_XT_and_Nextera_Enrichment_N701	1621	0.00115%
I5_Nextera_Transposase_2	1569	0.00111%
Bisulfite_R1	1512	0.00107%
I7_Nextera_Transposase_2	1504	0.00107%
I5_Primer_Nextera_XT_and_Nextera_Enrichment_[N/S/E]501	1349	0.00096%
```


Table: statMergeReads

| Name          | N50 |    Sum |         # |
|:--------------|----:|-------:|----------:|
| clumped       | 150 | 21.13G | 140895462 |
| trimmed       | 150 |  20.6G | 139016610 |
| filtered      | 150 |  20.6G | 139013760 |
| ecco          | 150 |  20.6G | 139013760 |
| ecct          | 150 | 12.77G |  85863784 |
| extended      | 190 |  15.6G |  85863784 |
| merged        | 347 | 11.72G |  35162494 |
| unmerged.raw  | 175 |  2.67G |  15538796 |
| unmerged.trim | 170 |  2.24G |  14333994 |
| U1            | 171 |  1.18G |   7166997 |
| U2            | 168 |  1.07G |   7166997 |
| Us            |   0 |      0 |         0 |
| pe.cor        | 332 |    14G |  84658982 |

| Group            |  Mean | Median | STDev | PercentOfPairs |
|:-----------------|------:|-------:|------:|---------------:|
| ihist.merge1.txt | 240.8 |    249 |  36.5 |         24.43% |
| ihist.merge.txt  | 333.4 |    336 |  62.7 |         81.90% |

```text
#trimmedReads
#Matched	587512	0.41698%
#Name	Reads	ReadsPct
Reverse_adapter	209677	0.14882%
pcr_dimer	109522	0.07773%
TruSeq_Adapter_Index_1_6	64738	0.04595%
PCR_Primers	61240	0.04346%
TruSeq_Universal_Adapter	40703	0.02889%
PhiX_read2_adapter	34689	0.02462%
Nextera_LMP_Read2_External_Adapter	29205	0.02073%
PhiX_read1_adapter	5598	0.00397%
I5_Nextera_Transposase_1	5416	0.00384%
RNA_Adapter_(RA5)_part_#_15013205	3571	0.00253%
RNA_PCR_Primer_Index_1_(RPI1)_2,9	2414	0.00171%
Nextera_LMP_Read1_External_Adapter	2235	0.00159%
TruSeq_Adapter_Index_16	1929	0.00137%
TruSeq_Adapter_Index_2	1786	0.00127%
Bisulfite_R2	1724	0.00122%
I7_Primer_Nextera_XT_and_Nextera_Enrichment_N701	1621	0.00115%
I5_Nextera_Transposase_2	1569	0.00111%
Bisulfite_R1	1512	0.00107%
I7_Nextera_Transposase_2	1504	0.00107%
I5_Primer_Nextera_XT_and_Nextera_Enrichment_[N/S/E]501	1349	0.00096%
```

```text
#filteredReads
#Matched	1447	0.00104%
#Name	Reads	ReadsPct
contam_43	267	0.00019%
contam_32	216	0.00016%
contam_139	211	0.00015%
Reverse_adapter	222	0.00016%
TruSeq_Universal_Adapter	148	0.00011%
contam_158	110	0.00008%
```


Table: statQuorum

| Name   | CovIn | CovOut | Discard% | AvgRead |  Kmer |   RealG |    EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|------:|--------:|--------:|---------:|----------:|
| Q25L60 |  33.4 |   22.5 |   32.69% |     147 | "105" | 604.22M | 944.54M |     1.56 | 0:52'52'' |
| Q30L60 |  30.0 |   22.1 |   26.30% |     142 | "105" | 604.22M | 910.12M |     1.51 | 0:52'18'' |


Table: statKunitigsAnchors.md

| Name           | CovCor | Mapped% | N50Anchor |   Sum |    # | N50Others |    Sum |     # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|------:|-----:|----------:|-------:|------:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q25L60XallP000 |   22.5 |   1.88% |      1208 | 8.27M | 6502 |      1113 | 14.65M | 25321 |    7.0 | 2.0 |   3.0 |  14.0 | "31,41,51,61,71,81" | 2:22'13'' | 0:03'09'' |
| Q30L60XallP000 |   22.1 |   2.09% |      1218 | 9.73M | 7609 |      1097 | 13.15M | 26595 |    8.0 | 2.0 |   3.0 |  16.0 | "31,41,51,61,71,81" | 2:14'01'' | 0:03'09'' |


Table: statTadpoleAnchors.md

| Name           | CovCor | Mapped% | N50Anchor |   Sum |    # | N50Others |   Sum |     # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|------:|-----:|----------:|------:|------:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q25L60XallP000 |   22.5 |  15.75% |      1192 | 8.15M | 6519 |      1125 | 9.23M | 20657 |   12.0 | 4.0 |   3.0 |  24.0 | "31,41,51,61,71,81" | 0:52'14'' | 0:02'54'' |
| Q30L60XallP000 |   22.1 |  15.84% |      1198 |  9.5M | 7572 |      1100 | 8.35M | 22339 |   13.0 | 4.0 |   3.0 |  26.0 | "31,41,51,61,71,81" | 0:52'28'' | 0:03'01'' |


Table: statMRKunitigsAnchors.md

| Name       | CovCor | Mapped% | N50Anchor |   Sum |    # | N50Others |    Sum |     # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:-----------|-------:|--------:|----------:|------:|-----:|----------:|-------:|------:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| MRXallP000 |   23.2 |   4.41% |      1179 | 5.84M | 4758 |      1115 | 13.29M | 20390 |    9.0 | 3.0 |   3.0 |  18.0 | "31,41,51,61,71,81" | 2:11'34'' | 0:02'41'' |


Table: statMRTadpoleAnchors.md

| Name       | CovCor | Mapped% | N50Anchor |    Sum |     # | N50Others |    Sum |     # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:-----------|-------:|--------:|----------:|-------:|------:|----------:|-------:|------:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| MRXallP000 |   23.2 |  19.14% |      1228 | 16.62M | 12948 |      1140 | 23.22M | 42452 |   10.0 | 3.0 |   3.0 |  20.0 | "31,41,51,61,71,81" | 1:00'37'' | 0:04'02'' |


Table: statFinal

| Name                             |   N50 |        Sum |       # |
|:---------------------------------|------:|-----------:|--------:|
| Genome                           | 58864 |  604217145 |   26721 |
| 7_mergeKunitigsAnchors.anchors   |  1216 |   12013129 |    9384 |
| 7_mergeKunitigsAnchors.others    |  1117 |   17655738 |   14888 |
| 7_mergeTadpoleAnchors.anchors    |  1199 |   11138396 |    8858 |
| 7_mergeTadpoleAnchors.others     |  1115 |   10559654 |    8224 |
| 7_mergeMRKunitigsAnchors.anchors |  1179 |    5843636 |    4758 |
| 7_mergeMRKunitigsAnchors.others  |  1125 |   12700439 |   10577 |
| 7_mergeMRTadpoleAnchors.anchors  |  1228 |   16622779 |   12948 |
| 7_mergeMRTadpoleAnchors.others   |  1160 |   21943901 |   17324 |
| 7_mergeAnchors.anchors           |  1222 |   30769302 |   23952 |
| 7_mergeAnchors.others            |  1128 |   44534635 |   36544 |
| spades.contig                    |  4079 |  870140463 |  764186 |
| spades.scaffold                  |  4146 |  870255034 |  760990 |
| spades.non-contained             |  7165 |  637623913 |  152574 |
| spades.anchor                    |  1118 |    1698174 |    1480 |
| megahit.contig                   |   647 | 1031850699 | 1912421 |
| megahit.non-contained            |  1615 |  327096784 |  198445 |
| megahit.anchor                   |  1104 |     430037 |     377 |
| platanus.contig                  |   248 |     898300 |    3396 |
| platanus.scaffold                |  5366 |     395330 |     590 |
| platanus.non-contained           | 10074 |     294428 |      60 |
| platanus.anchor                  |  2300 |      87051 |      43 |

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

Table: statInsertSize

| Group           |  Mean | Median | STDev | PercentOfPairs/PairOrientation |
|:----------------|------:|-------:|------:|-------------------------------:|
| genome.bbtools  | 314.8 |    292 | 620.1 |                         21.09% |
| tadpole.bbtools | 267.8 |    267 |  64.8 |                          8.28% |
| genome.picard   | 294.1 |    292 |  61.1 |                             FR |
| tadpole.picard  | 263.0 |    264 |  67.4 |                             FR |


Table: statReads

| Name     |   N50 |       Sum |         # |
|:---------|------:|----------:|----------:|
| Genome   | 58864 | 604217145 |     26721 |
| Illumina |   150 |    22.55G | 150343844 |
| uniq     |     0 |         0 |         0 |
| bbduk    |     0 |         0 |         0 |
| Q25L60   |   150 |    20.38G | 138546900 |
| Q30L60   |   150 |    18.24G | 129227627 |

```text
#trimmedReads
#Matched	554608	0.39027%
#Name	Reads	ReadsPct
Reverse_adapter	184504	0.12983%
pcr_dimer	98675	0.06944%
TruSeq_Adapter_Index_1_6	78781	0.05544%
PCR_Primers	53910	0.03794%
PhiX_read2_adapter	36445	0.02565%
TruSeq_Universal_Adapter	34447	0.02424%
Nextera_LMP_Read2_External_Adapter	32984	0.02321%
PhiX_read1_adapter	5492	0.00386%
I5_Nextera_Transposase_1	5403	0.00380%
RNA_Adapter_(RA5)_part_#_15013205	3490	0.00246%
RNA_PCR_Primer_Index_1_(RPI1)_2,9	2607	0.00183%
I5_Primer_Nextera_XT_and_Nextera_Enrichment_[N/S/E]501	1932	0.00136%
Nextera_LMP_Read1_External_Adapter	1925	0.00135%
I5_Nextera_Transposase_2	1753	0.00123%
I7_Primer_Nextera_XT_and_Nextera_Enrichment_N701	1706	0.00120%
Bisulfite_R2	1572	0.00111%
I7_Nextera_Transposase_2	1504	0.00106%
Bisulfite_R1	1476	0.00104%
```


Table: statMergeReads

| Name          | N50 |     Sum |         # |
|:--------------|----:|--------:|----------:|
| clumped       | 150 |  21.31G | 142085446 |
| trimmed       | 150 |  20.79G | 140271898 |
| filtered      | 150 |  20.79G | 140269050 |
| ecco          | 150 |  20.79G | 140269050 |
| ecct          | 150 |  12.92G |  86861118 |
| extended      | 190 |  15.81G |  86861118 |
| merged        | 329 |  12.01G |  37738127 |
| unmerged.raw  | 173 |   1.95G |  11384864 |
| unmerged.trim | 170 |   1.63G |  10436948 |
| U1            | 170 |  850.8M |   5218474 |
| U2            | 168 | 776.65M |   5218474 |
| Us            |   0 |       0 |         0 |
| pe.cor        | 319 |  13.67G |  85913202 |

| Group            |  Mean | Median | STDev | PercentOfPairs |
|:-----------------|------:|-------:|------:|---------------:|
| ihist.merge1.txt | 240.6 |    247 |  34.4 |         33.57% |
| ihist.merge.txt  | 318.1 |    319 |  58.6 |         86.89% |

```text
#trimmedReads
#Matched	554563	0.39030%
#Name	Reads	ReadsPct
Reverse_adapter	184490	0.12984%
pcr_dimer	98670	0.06944%
TruSeq_Adapter_Index_1_6	78770	0.05544%
PCR_Primers	53908	0.03794%
PhiX_read2_adapter	36439	0.02565%
TruSeq_Universal_Adapter	34447	0.02424%
Nextera_LMP_Read2_External_Adapter	32981	0.02321%
PhiX_read1_adapter	5490	0.00386%
I5_Nextera_Transposase_1	5403	0.00380%
RNA_Adapter_(RA5)_part_#_15013205	3490	0.00246%
RNA_PCR_Primer_Index_1_(RPI1)_2,9	2605	0.00183%
I5_Primer_Nextera_XT_and_Nextera_Enrichment_[N/S/E]501	1932	0.00136%
Nextera_LMP_Read1_External_Adapter	1925	0.00135%
I5_Nextera_Transposase_2	1753	0.00123%
I7_Primer_Nextera_XT_and_Nextera_Enrichment_N701	1706	0.00120%
Bisulfite_R2	1572	0.00111%
I7_Nextera_Transposase_2	1504	0.00106%
Bisulfite_R1	1476	0.00104%
```

```text
#filteredReads
#Matched	1466	0.00105%
#Name	Reads	ReadsPct
contam_43	403	0.00029%
contam_32	230	0.00016%
contam_139	204	0.00015%
TruSeq_Universal_Adapter	132	0.00009%
Reverse_adapter	104	0.00007%
```


Table: statQuorum

| Name   | CovIn | CovOut | Discard% | AvgRead |  Kmer |   RealG |    EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|------:|--------:|--------:|---------:|----------:|
| Q25L60 |  33.7 |   22.6 |   33.09% |     147 | "105" | 604.22M | 960.36M |     1.59 | 0:54'11'' |
| Q30L60 |  30.2 |   22.1 |   26.67% |     143 | "105" | 604.22M | 924.41M |     1.53 | 0:52'06'' |


Table: statKunitigsAnchors.md

| Name           | CovCor | Mapped% | N50Anchor |    Sum |     # | N50Others |    Sum |     # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|-------:|------:|----------:|-------:|------:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q25L60XallP000 |   22.6 |   3.23% |      1242 | 11.37M |  8666 |      1352 |  27.3M | 32508 |    7.0 | 2.0 |   3.0 |  14.0 | "31,41,51,61,71,81" | 2:23'57'' | 0:04'08'' |
| Q30L60XallP000 |   22.1 |   3.48% |      1253 | 13.62M | 10249 |      1313 | 24.01M | 34225 |    8.0 | 2.0 |   3.0 |  16.0 | "31,41,51,61,71,81" | 2:15'16'' | 0:04'08'' |


Table: statTadpoleAnchors.md

| Name           | CovCor | Mapped% | N50Anchor |    Sum |    # | N50Others |   Sum |     # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|-------:|-----:|----------:|------:|------:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q25L60XallP000 |   22.6 |  18.53% |      1465 | 15.83M | 8552 |      1099 | 9.57M | 26069 |   12.0 | 3.0 |   3.0 |  24.0 | "31,41,51,61,71,81" | 0:52'20'' | 0:03'43'' |
| Q30L60XallP000 |   22.1 |  18.85% |      1436 | 16.01M | 8817 |      1119 | 9.84M | 26540 |   12.0 | 3.0 |   3.0 |  24.0 | "31,41,51,61,71,81" | 0:53'44'' | 0:03'43'' |


Table: statMRKunitigsAnchors.md

| Name       | CovCor | Mapped% | N50Anchor |   Sum |    # | N50Others |    Sum |     # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:-----------|-------:|--------:|----------:|------:|-----:|----------:|-------:|------:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| MRXallP000 |   22.6 |   5.81% |      1193 | 7.75M | 6172 |      1387 | 22.27M | 25942 |   10.0 | 4.0 |   3.0 |  20.0 | "31,41,51,61,71,81" | 2:10'54'' | 0:03'18'' |


Table: statMRTadpoleAnchors.md

| Name       | CovCor | Mapped% | N50Anchor |    Sum |     # | N50Others |    Sum |     # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:-----------|-------:|--------:|----------:|-------:|------:|----------:|-------:|------:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| MRXallP000 |   22.6 |  23.02% |      1253 | 20.15M | 15391 |      1209 | 30.45M | 48677 |   10.0 | 3.0 |   3.0 |  20.0 | "31,41,51,61,71,81" | 1:00'12'' | 0:04'39'' |


Table: statFinal

| Name                             |   N50 |        Sum |       # |
|:---------------------------------|------:|-----------:|--------:|
| Genome                           | 58864 |  604217145 |   26721 |
| 7_mergeKunitigsAnchors.anchors   |  1252 |   16488807 |   12409 |
| 7_mergeKunitigsAnchors.others    |  1286 |   29881635 |   18564 |
| 7_mergeTadpoleAnchors.anchors    |  1394 |   18534128 |   10619 |
| 7_mergeTadpoleAnchors.others     |  1115 |   11548261 |    8933 |
| 7_mergeMRKunitigsAnchors.anchors |  1193 |    7753782 |    6172 |
| 7_mergeMRKunitigsAnchors.others  |  1445 |   21169583 |   13139 |
| 7_mergeMRTadpoleAnchors.anchors  |  1253 |   20148761 |   15391 |
| 7_mergeMRTadpoleAnchors.others   |  1239 |   28648806 |   19136 |
| 7_mergeAnchors.anchors           |  1307 |   41689168 |   28001 |
| 7_mergeAnchors.others            |  1183 |   58960273 |   41418 |
| spades.contig                    |  3953 |  908926035 |  833244 |
| spades.scaffold                  |  4005 |  909023518 |  831225 |
| spades.non-contained             |  7258 |  653096982 |  154947 |
| spades.anchor                    |  1119 |    2098036 |    1825 |
| megahit.contig                   |   662 | 1050741155 | 1905262 |
| megahit.non-contained            |  1650 |  344932434 |  204043 |
| megahit.anchor                   |  1100 |     523358 |     460 |
| platanus.contig                  |   248 |     747093 |    2748 |
| platanus.scaffold                |  6986 |     330655 |     405 |
| platanus.non-contained           | 10947 |     257634 |      45 |
| platanus.anchor                  |  2492 |      85661 |      36 |


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

Table: statInsertSize

| Group           |  Mean | Median | STDev | PercentOfPairs/PairOrientation |
|:----------------|------:|-------:|------:|-------------------------------:|
| genome.bbtools  | 317.0 |    291 | 686.0 |                         22.23% |
| tadpole.bbtools | 264.1 |    263 |  61.2 |                          6.24% |
| genome.picard   | 293.5 |    291 |  56.3 |                             FR |
| tadpole.picard  | 258.7 |    260 |  65.0 |                             FR |


Table: statReads

| Name     |   N50 |       Sum |         # |
|:---------|------:|----------:|----------:|
| Genome   | 58864 | 604217145 |     26721 |
| Illumina |   150 |    25.54G | 170279154 |
| uniq     |     0 |         0 |         0 |
| bbduk    |     0 |         0 |         0 |
| Q25L60   |   150 |    23.02G | 156549219 |
| Q30L60   |   150 |    20.58G | 145817769 |

```text
#trimmedReads
#Matched	503831	0.31332%
#Name	Reads	ReadsPct
Reverse_adapter	175894	0.10938%
pcr_dimer	89228	0.05549%
PCR_Primers	50672	0.03151%
TruSeq_Adapter_Index_1_6	49095	0.03053%
PhiX_read2_adapter	40853	0.02541%
TruSeq_Universal_Adapter	36022	0.02240%
Nextera_LMP_Read2_External_Adapter	22730	0.01414%
PhiX_read1_adapter	6554	0.00408%
I5_Nextera_Transposase_1	5554	0.00345%
RNA_Adapter_(RA5)_part_#_15013205	3890	0.00242%
TruSeq_Adapter_Index_2	3759	0.00234%
RNA_PCR_Primer_Index_1_(RPI1)_2,9	2771	0.00172%
Nextera_LMP_Read1_External_Adapter	2378	0.00148%
Bisulfite_R2	1624	0.00101%
Bisulfite_R1	1619	0.00101%
I7_Primer_Nextera_XT_and_Nextera_Enrichment_N701	1599	0.00099%
I7_Nextera_Transposase_2	1596	0.00099%
I5_Nextera_Transposase_2	1485	0.00092%
I5_Primer_Nextera_XT_and_Nextera_Enrichment_[N/S/E]501	1105	0.00069%
RNA_PCR_Primer_(RP1)_part_#_15013198	1034	0.00064%
```


Table: statMergeReads

| Name          | N50 |     Sum |         # |
|:--------------|----:|--------:|----------:|
| clumped       | 150 |  24.12G | 160779070 |
| trimmed       | 150 |  23.52G | 158678358 |
| filtered      | 150 |  23.52G | 158675072 |
| ecco          | 150 |  23.52G | 158675072 |
| ecct          | 150 |  15.33G | 103044196 |
| extended      | 190 |  18.77G | 103044196 |
| merged        | 327 |  14.31G |  44899434 |
| unmerged.raw  | 175 |   2.27G |  13245328 |
| unmerged.trim | 170 |   1.89G |  12072916 |
| U1            | 172 | 993.88M |   6036458 |
| U2            | 169 | 895.74M |   6036458 |
| Us            |   0 |       0 |         0 |
| pe.cor        | 318 |  16.25G | 101871784 |

| Group            |  Mean | Median | STDev | PercentOfPairs |
|:-----------------|------:|-------:|------:|---------------:|
| ihist.merge1.txt | 244.7 |    251 |  31.6 |         33.91% |
| ihist.merge.txt  | 318.8 |    318 |  54.1 |         87.15% |

```text
#trimmedReads
#Matched	503795	0.31335%
#Name	Reads	ReadsPct
Reverse_adapter	175888	0.10940%
pcr_dimer	89225	0.05550%
PCR_Primers	50672	0.03152%
TruSeq_Adapter_Index_1_6	49085	0.03053%
PhiX_read2_adapter	40847	0.02541%
TruSeq_Universal_Adapter	36022	0.02240%
Nextera_LMP_Read2_External_Adapter	22723	0.01413%
PhiX_read1_adapter	6554	0.00408%
I5_Nextera_Transposase_1	5554	0.00345%
RNA_Adapter_(RA5)_part_#_15013205	3888	0.00242%
TruSeq_Adapter_Index_2	3759	0.00234%
RNA_PCR_Primer_Index_1_(RPI1)_2,9	2771	0.00172%
Nextera_LMP_Read1_External_Adapter	2378	0.00148%
Bisulfite_R2	1624	0.00101%
Bisulfite_R1	1619	0.00101%
I7_Primer_Nextera_XT_and_Nextera_Enrichment_N701	1599	0.00099%
I7_Nextera_Transposase_2	1596	0.00099%
I5_Nextera_Transposase_2	1485	0.00092%
I5_Primer_Nextera_XT_and_Nextera_Enrichment_[N/S/E]501	1105	0.00069%
RNA_PCR_Primer_(RP1)_part_#_15013198	1034	0.00064%
```

```text
#filteredReads
#Matched	1688	0.00106%
#Name	Reads	ReadsPct
contam_43	448	0.00028%
contam_32	262	0.00017%
contam_139	229	0.00014%
Reverse_adapter	219	0.00014%
contam_158	101	0.00006%
```


Table: statQuorum

| Name   | CovIn | CovOut | Discard% | AvgRead |  Kmer |   RealG |   EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|------:|--------:|-------:|---------:|----------:|
| Q25L60 |  38.1 |   26.4 |   30.67% |     147 | "105" | 604.22M |  1.02G |     1.68 | 1:02'48'' |
| Q30L60 |  34.1 |   26.1 |   23.50% |     144 | "105" | 604.22M | 981.6M |     1.62 | 0:59'09'' |


Table: statKunitigsAnchors.md

| Name           | CovCor | Mapped% | N50Anchor |    Sum |    # | N50Others |    Sum |     # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|-------:|-----:|----------:|-------:|------:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q25L60XallP000 |   26.4 |   1.88% |      1241 | 12.17M | 9317 |      1087 | 13.61M | 30704 |    8.0 | 2.0 |   3.0 |  16.0 | "31,41,51,61,71,81" | 2:44'44'' | 0:03'36'' |
| Q30L60XallP000 |   26.1 |   1.29% |      1231 |  6.52M | 5031 |      1104 |  8.22M | 16737 |    8.0 | 2.0 |   3.0 |  16.0 | "31,41,51,61,71,81" | 2:37'52'' | 0:02'52'' |


Table: statTadpoleAnchors.md

| Name           | CovCor | Mapped% | N50Anchor |   Sum |    # | N50Others |   Sum |     # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|------:|-----:|----------:|------:|------:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q30L60XallP000 |   26.1 |  13.51% |      1203 | 9.65M | 7643 |      1118 | 9.49M | 23608 |   13.0 | 4.0 |   3.0 |  26.0 | "31,41,51,61,71,81" | 0:57'45'' | 0:03'02'' |


Table: statMRKunitigsAnchors.md

| Name       | CovCor | Mapped% | N50Anchor |    Sum |   # | N50Others |   Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:-----------|-------:|--------:|----------:|-------:|----:|----------:|------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| MRXallP000 |   26.9 |   0.65% |      1128 | 484.1K | 411 |      1105 | 1.57M | 2116 |   10.0 | 4.0 |   3.0 |  20.0 | "31,41,51,61,71,81" | 2:31'09'' | 0:01'49'' |


Table: statMRTadpoleAnchors.md

| Name       | CovCor | Mapped% | N50Anchor |    Sum |     # | N50Others |    Sum |     # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:-----------|-------:|--------:|----------:|-------:|------:|----------:|-------:|------:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| MRXallP000 |   26.9 |  15.81% |      1262 | 17.65M | 13343 |      1121 | 21.79M | 42418 |   10.0 | 3.0 |   3.0 |  20.0 | "31,41,51,61,71,81" | 1:06'08'' | 0:04'13'' |


Table: statFinal

| Name                             |   N50 |        Sum |       # |
|:---------------------------------|------:|-----------:|--------:|
| Genome                           | 58864 |  604217145 |   26721 |
| 7_mergeKunitigsAnchors.anchors   |  1239 |   13484227 |   10330 |
| 7_mergeKunitigsAnchors.others    |  1101 |   15556378 |   13267 |
| 7_mergeTadpoleAnchors.anchors    |  1203 |    9647285 |    7643 |
| 7_mergeTadpoleAnchors.others     |  1143 |    8911414 |    6940 |
| 7_mergeMRKunitigsAnchors.anchors |  1128 |     484103 |     411 |
| 7_mergeMRKunitigsAnchors.others  |  1109 |    1517662 |    1293 |
| 7_mergeMRTadpoleAnchors.anchors  |  1262 |   17647023 |   13343 |
| 7_mergeMRTadpoleAnchors.others   |  1138 |   20399101 |   16422 |
| 7_mergeAnchors.anchors           |  1247 |   29714579 |   22581 |
| 7_mergeAnchors.others            |  1116 |   36209236 |   29900 |
| spades.contig                    |  1003 | 1219772088 | 2756900 |
| spades.scaffold                  |  1006 | 1221103365 | 2742531 |
| spades.non-contained             |  2594 |  610951573 |  264987 |
| spades.anchor                    |  1110 |    1568436 |    1370 |
| megahit.contig                   |   612 | 1082511061 | 2074950 |
| megahit.non-contained            |  1582 |  313643176 |  192893 |
| megahit.anchor                   |  1107 |     433550 |     382 |
| platanus.contig                  |   216 |    1401058 |    5808 |
| platanus.scaffold                |  4542 |     540712 |     806 |
| platanus.non-contained           |  7505 |     392828 |      88 |
| platanus.anchor                  |  3907 |     143037 |      57 |

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

Table: statInsertSize

| Group           |  Mean | Median | STDev | PercentOfPairs/PairOrientation |
|:----------------|------:|-------:|------:|-------------------------------:|
| genome.bbtools  | 327.3 |    299 | 672.8 |                         20.97% |
| tadpole.bbtools | 274.3 |    273 |  68.0 |                          7.63% |
| genome.picard   | 302.4 |    299 |  63.0 |                             FR |
| tadpole.picard  | 269.2 |    270 |  70.5 |                             FR |


Table: statReads

| Name     |   N50 |       Sum |         # |
|:---------|------:|----------:|----------:|
| Genome   | 58864 | 604217145 |     26721 |
| Illumina |   150 |    20.98G | 139887246 |
| uniq     |   150 |    19.83G | 132201062 |
| bbduk    |   150 |    19.79G | 132200412 |
| Q25L60   |   150 |    18.97G | 128872684 |
| Q30L60   |   150 |    17.06G | 120447531 |

```text
#trimmedReads
#Matched	402665	0.30459%
#Name	Reads	ReadsPct
Reverse_adapter	137229	0.10380%
pcr_dimer	66524	0.05032%
TruSeq_Adapter_Index_1_6	48424	0.03663%
PCR_Primers	37762	0.02856%
PhiX_read2_adapter	34495	0.02609%
TruSeq_Universal_Adapter	24711	0.01869%
Nextera_LMP_Read2_External_Adapter	21687	0.01640%
PhiX_read1_adapter	5144	0.00389%
I5_Nextera_Transposase_1	4902	0.00371%
RNA_Adapter_(RA5)_part_#_15013205	3287	0.00249%
RNA_PCR_Primer_Index_1_(RPI1)_2,9	2264	0.00171%
TruSeq_Adapter_Index_2	1973	0.00149%
Nextera_LMP_Read1_External_Adapter	1943	0.00147%
I7_Primer_Nextera_XT_and_Nextera_Enrichment_N701	1501	0.00114%
I5_Nextera_Transposase_2	1332	0.00101%
Bisulfite_R1	1297	0.00098%
I7_Nextera_Transposase_2	1296	0.00098%
Bisulfite_R2	1248	0.00094%
I5_Primer_Nextera_XT_and_Nextera_Enrichment_[N/S/E]501	1239	0.00094%
```


Table: statMergeReads

| Name          | N50 |     Sum |         # |
|:--------------|----:|--------:|----------:|
| clumped       | 150 |  19.83G | 132179286 |
| trimmed       | 150 |  19.37G | 130583630 |
| filtered      | 150 |  19.37G | 130581134 |
| ecco          | 150 |  19.37G | 130581134 |
| ecct          | 150 |  11.92G |  80031076 |
| extended      | 190 |  14.56G |  80031076 |
| merged        | 334 |  11.06G |  34031182 |
| unmerged.raw  | 174 |   2.05G |  11968712 |
| unmerged.trim | 170 |   1.73G |  11035352 |
| U1            | 170 | 905.51M |   5517676 |
| U2            | 168 | 824.93M |   5517676 |
| Us            |   0 |       0 |         0 |
| pe.cor        | 323 |  12.82G |  79097716 |

| Group            |  Mean | Median | STDev | PercentOfPairs |
|:-----------------|------:|-------:|------:|---------------:|
| ihist.merge1.txt | 243.8 |    250 |  32.7 |         30.26% |
| ihist.merge.txt  | 324.9 |    325 |  58.5 |         85.05% |

```text
#trimmedReads
#Matched	402629	0.30461%
#Name	Reads	ReadsPct
Reverse_adapter	137219	0.10381%
pcr_dimer	66522	0.05033%
TruSeq_Adapter_Index_1_6	48413	0.03663%
PCR_Primers	37760	0.02857%
PhiX_read2_adapter	34494	0.02610%
TruSeq_Universal_Adapter	24711	0.01870%
Nextera_LMP_Read2_External_Adapter	21681	0.01640%
PhiX_read1_adapter	5143	0.00389%
I5_Nextera_Transposase_1	4902	0.00371%
RNA_Adapter_(RA5)_part_#_15013205	3287	0.00249%
RNA_PCR_Primer_Index_1_(RPI1)_2,9	2263	0.00171%
TruSeq_Adapter_Index_2	1973	0.00149%
Nextera_LMP_Read1_External_Adapter	1943	0.00147%
I7_Primer_Nextera_XT_and_Nextera_Enrichment_N701	1501	0.00114%
I5_Nextera_Transposase_2	1332	0.00101%
Bisulfite_R1	1297	0.00098%
I7_Nextera_Transposase_2	1295	0.00098%
Bisulfite_R2	1248	0.00094%
I5_Primer_Nextera_XT_and_Nextera_Enrichment_[N/S/E]501	1238	0.00094%
```

```text
#filteredReads
#Matched	1279	0.00098%
#Name	Reads	ReadsPct
contam_43	336	0.00026%
contam_139	219	0.00017%
contam_32	209	0.00016%
Reverse_adapter	121	0.00009%
```


Table: statQuorum

| Name   | CovIn | CovOut | Discard% | AvgRead |  Kmer |   RealG |    EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|------:|--------:|--------:|---------:|----------:|
| Q25L60 |  31.4 |   21.1 |   32.77% |     147 | "105" | 604.22M | 928.94M |     1.54 | 0:43'14'' |
| Q30L60 |  28.2 |   20.7 |   26.69% |     143 | "105" | 604.22M | 895.22M |     1.48 | 0:39'38'' |


Table: statKunitigsAnchors.md

| Name           | CovCor | Mapped% | N50Anchor |    Sum |     # | N50Others |    Sum |     # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|-------:|------:|----------:|-------:|------:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q25L60XallP000 |   21.1 |   2.52% |      1224 | 11.09M |  8661 |      1119 | 18.49M | 32656 |    7.0 | 1.0 |   3.0 |  14.0 | "31,41,51,61,71,81" | 2:15'39'' | 0:03'34'' |
| Q30L60XallP000 |   20.7 |   2.84% |      1223 | 12.97M | 10104 |      1098 | 16.04M | 34045 |    8.0 | 2.0 |   3.0 |  16.0 | "31,41,51,61,71,81" | 2:07'42'' | 0:03'36'' |


Table: statTadpoleAnchors.md

| Name           | CovCor | Mapped% | N50Anchor |   Sum |    # | N50Others |    Sum |     # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|--------:|----------:|------:|-----:|----------:|-------:|------:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q25L60XallP000 |   21.1 |  17.96% |      1211 | 9.92M | 7806 |      1113 | 10.42M | 24505 |   11.0 | 3.0 |   3.0 |  22.0 | "31,41,51,61,71,81" | 0:49'53'' | 0:03'03'' |
| Q30L60XallP000 |   20.7 |  18.66% |      1216 | 11.4M | 8940 |      1087 |  9.17M | 26067 |   12.0 | 3.0 |   3.0 |  24.0 | "31,41,51,61,71,81" | 0:47'58'' | 0:03'07'' |


Table: statMRKunitigsAnchors.md

| Name       | CovCor | Mapped% | N50Anchor |   Sum |    # | N50Others |   Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:-----------|-------:|--------:|----------:|------:|-----:|----------:|------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| MRXallP000 |   21.2 |   3.04% |      1191 | 2.38M | 1901 |      1145 | 5.98M | 8322 |    9.0 | 3.0 |   3.0 |  18.0 | "31,41,51,61,71,81" | 2:04'01'' | 0:01'58'' |


Table: statMRTadpoleAnchors.md

| Name       | CovCor | Mapped% | N50Anchor | Sum | # | N50Others | Sum | # | median | MAD | lower | upper |      Kmer | RunTimeKU | RunTimeAN |
|:-----------|-------:|--------:|----------:|----:|--:|----------:|----:|--:|-------:|----:|------:|------:|----------:|----------:|----------:|
| MRXallP000 |   21.2 |   0.00% |         0 |   0 | 0 |         0 |   0 | 0 |    0.0 | 3.0 |   0.0 |  51.0 | 1:28'15'' | 0:00'09'' |           |


Table: statFinal

| Name                             |   N50 |        Sum |       # |
|:---------------------------------|------:|-----------:|--------:|
| Genome                           | 58864 |  604217145 |   26721 |
| 7_mergeKunitigsAnchors.anchors   |  1230 |   16022973 |   12406 |
| 7_mergeKunitigsAnchors.others    |  1125 |   21967857 |   18371 |
| 7_mergeTadpoleAnchors.anchors    |  1217 |   13474470 |   10547 |
| 7_mergeTadpoleAnchors.others     |  1105 |   11944859 |    9447 |
| 7_mergeMRKunitigsAnchors.anchors |  1191 |    2376256 |    1901 |
| 7_mergeMRKunitigsAnchors.others  |  1155 |    5751322 |    4630 |
| 7_mergeMRTadpoleAnchors.anchors  |     0 |          0 |       0 |
| 7_mergeMRTadpoleAnchors.others   |     0 |          0 |       0 |
| 7_mergeAnchors.anchors           |  1228 |   25237150 |   19539 |
| 7_mergeAnchors.others            |  1130 |   32871641 |   26743 |
| spades.contig                    |  4319 |  863328214 |  727976 |
| spades.scaffold                  |  4381 |  863429540 |  725764 |
| spades.non-contained             |  7226 |  643412711 |  152573 |
| spades.anchor                    |  1119 |    2454045 |    2131 |
| megahit.contig                   |   688 | 1021352329 | 1809662 |
| megahit.non-contained            |  1655 |  350782136 |  209429 |
| megahit.anchor                   |  1110 |     556254 |     486 |
| platanus.contig                  |   255 |     835162 |    3093 |
| platanus.scaffold                |  4837 |     374572 |     525 |
| platanus.non-contained           |  8833 |     283701 |      59 |
| platanus.anchor                  |  1753 |      71161 |      39 |

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
