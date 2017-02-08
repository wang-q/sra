# [MaSuRCA](http://www.genome.umd.edu/masurca.html) 安装与样例

doi:10.1093/bioinformatics/btt476

[MaSuRCA_QuickStartGuide](ftp://ftp.genome.umd.edu/pub/MaSuRCA/MaSuRCA_QuickStartGuide.pdf)


[TOC levels=1-3]: #

# Table of Contents
- [[MaSuRCA](http://www.genome.umd.edu/masurca.html) 安装与样例](#masurca-安装与样例)
- [特点](#特点)
- [版本](#版本)
- [依赖](#依赖)
- [安装](#安装)
- [样例数据](#样例数据)
    - [Rhodobacter sphaeroides (球形红细菌)](#rhodobacter-sphaeroides-球形红细菌)
        - [Illumina PE, Short Jump and Sanger4](#illumina-pe-short-jump-and-sanger4)
        - [Rhodobacter sphaeroides with `superreads.pl`](#rhodobacter-sphaeroides-with-superreadspl)
        - [结果比较](#结果比较)
- [Super-reads and anchors](#super-reads-and-anchors)
    - [E. coli sampling](#e-coli-sampling)
        - [E. coli: Down sampling](#e-coli-down-sampling)
        - [E. coli: Generate super-reads](#e-coli-generate-super-reads)
        - [E. coli: Create anchors](#e-coli-create-anchors)
    - [Scer S288c](#scer-s288c)
        - [S288c: Down sampling](#s288c-down-sampling)
        - [S288c: Generate super-reads](#s288c-generate-super-reads)
        - [S288c: Create anchors](#s288c-create-anchors)
        - [Results of S288c](#results-of-s288c)
    - [Dmel](#dmel)
    - [Atha Ler-0-2, SRR611087](#atha-ler-0-2-srr611087)
        - [atha_ler_0: Down sampling](#atha_ler_0-down-sampling)
        - [atha_ler_0: Generate super-reads](#atha_ler_0-generate-super-reads)
        - [atha_ler_0: Create anchors](#atha_ler_0-create-anchors)
        - [Results of Ler-0-2 SRR611087](#results-of-ler-0-2-srr611087)
    - [Cele N2, SRR065390](#cele-n2-srr065390)
        - [cele_n2: Down sampling](#cele_n2-down-sampling)
        - [cele_n2: Generate super-reads](#cele_n2-generate-super-reads)
        - [cele_n2: Create anchors](#cele_n2-create-anchors)
        - [Results of SRR065390](#results-of-srr065390)
        - [Results of SRX770040](#results-of-srx770040)
        - [Results of ERR1039478](#results-of-err1039478)
        - [Results of DRR008443](#results-of-drr008443)


# 特点

De novo 基因组序列的拼接有以下几种主流的策略:

1. Overlap–layout–consensus (OLC) assembly

    * 主要用于长 reads, 在 Sanger 测序时代就基本发展完备, 三代时代又重新发展
    * 代表: Celera Assembler, PCAP, Canu

2. de Bruijn graph (德布鲁因图)

    * 二代测序的主流
    * 代表: Velvet, SOAPdenovo, Allpaths-LG

3. String graph

    * 使用 FM-index/Burrows-Wheeler transform, 较为节省内存
    * 代表: SGA

MaSuRCA 提出了一种新的策略, Super-reads. 主要思想是将多个短 reads 按 1 bp 延伸, 合并得到数量少得多的长 reads.
在单倍体基因组的情况下, 无论覆盖度是多少 (50, 100), 最终的 super-reads 覆盖度都趋向于 2x. 高杂合基因组则趋向于 4x.

合并后的 super-reads 的 N50 约为 2-4 kbp.

# 版本

version 3.1.3.

homebrew-science 里的版本是 2.3.2b, 3.1.3 的
[PR](https://github.com/Homebrew/homebrew-science/pull/3802) 也有了, 但没合并.

九月 UMD 的 ftp 上有了 3.2.1 版, 多了 CA8, MUMmer 和 PacBio 三个目录, 还末详细研究.

http://ccb.jhu.edu/software.shtml

> New modules coming soon include methods to create hybrid assemblies using both Illumina and PacBio
> data.

# 依赖

外部

* gcc-4: macOS 下的 clang 无法编译
* m4: 宏语言, 远离
* swig: for Perl binding of jellyfish

自带

* Celera Assembler
* [jellyfish](https://github.com/gmarcais/Jellyfish): k-mer counting
* prepare: 无文档, 看起来是预处理数据用的.
* [Quorum](https://github.com/gmarcais/Quorum): Error correction for Illumina reads.
* samtools
* SOAPdenovo2
* SuperReads: masurca 的主程序. 这个是我们所需要的, 合并 reads 的功能就在这里. 源码约五万行.
* ufasta: UMD 的操作 fasta 的工具, 未在其它地方发现相关信息. 里面的 tests 写得不错, 值得借鉴.

# 安装

```bash
echo "==> MaSuRCA"
cd /prepare/resource/
wget -N ftp://ftp.genome.umd.edu/pub/MaSuRCA/MaSuRCA-3.1.3.tar.gz

if [ -d $HOME/share/MaSuRCA ];
then
    rm -fr $HOME/share/MaSuRCA
fi

cd $HOME/share/
tar xvfz /prepare/resource/MaSuRCA-3.1.3.tar.gz

mv MaSuRCA-* MaSuRCA
cd MaSuRCA
sh install.sh

```

编译完成后, 会生成 `bin` 目录, 里面是可执行文件, `tree bin`.

```text
bin
├── add_missing_mates.pl
├── addSurrogatesToFrgCtgFile
├── addSurrogatesToFrgctg.perl
├── bloom_query
├── closeGapsInScaffFastaFile.perl
├── closeGapsLocally.perl
├── closeGaps.oneDirectory.fromMinKmerLen.perl
├── closeGaps.oneDirectory.perl
├── closeGaps.perl
├── close_gaps.sh
├── collectReadSequencesForLocalGapClosing
├── compute_sr_cov.pl
├── compute_sr_cov.revisedForGCContig.pl
├── create_end_pairs.perl
├── create_end_pairs.pl
├── createFastaSuperReadSequences
├── createKUnitigMaxOverlaps
├── create_k_unitigs_large_k
├── create_k_unitigs_large_k2
├── create_sr_frg
├── create_sr_frg.pl
├── createSuperReadSequenceAndPlacementFileFromCombined.perl
├── createSuperReadsForDirectory.perl
├── eliminateBadSuperReadsUsingList
├── error_corrected2frg
├── expand_fastq
├── extendSuperReadsBasedOnUniqueExtensions
├── extendSuperReadsForUniqueKmerNeighbors
├── extractJoinableAndNextPassReadsFromJoinKUnitigs.perl
├── extractreads_not.pl
├── extractreads.pl
├── extract_unjoined_pairs.pl
├── fasta2frg_m.pl
├── fasta2frg.pl
├── filter_alt.pl
├── filter_library.sh
├── filter_overlap_file
├── filter_redundancy.pl
├── finalFusion
├── findMatchesBetweenKUnitigsAndReads
├── findReversePointingJumpingReads_bigGenomes.perl
├── findReversePointingJumpingReads.perl
├── fix_unitigs.sh
├── getATBiasInCoverageForIllumina_v2
├── getEndSequencesOfContigs.perl
├── getGCBiasStatistics.perl
├── getLengthStatisticsForKUnitigsFile.perl
├── getMeanAndStdevByGCCount.perl
├── getMeanAndStdevForGapsByGapNumUsingCeleraAsmFile.perl
├── getMeanAndStdevForGapsByGapNumUsingCeleraTerminatorDirectory.perl
├── getNumBasesPerReadInFastaFile.perl
├── getSequenceForClosedGaps.perl
├── getSequenceForLocallyClosedGaps.perl
├── getSuperReadInsertCountsFromReadPlacementFile
├── getSuperReadInsertCountsFromReadPlacementFileTwoPasses
├── getSuperReadPlacements.perl
├── getUnitigTypeFromAsmFile.perl
├── homo_trim
├── jellyfish
├── joinKUnitigs_v3
├── killBadKUnitigs
├── makeAdjustmentFactorsForNumReadsForAStatBasedOnGC
├── makeAdjustmentFactorsForNumReadsForAStatBasedOnGC_v2
├── masurca
├── MasurcaCelera.pm
├── MasurcaCommon.pm
├── MasurcaConf.pm
├── MasurcaSoap.pm
├── masurca-superreads
├── MasurcaSuperReads.pm
├── mergeSuperReadsUniquely.pl
├── outputAlekseysJellyfishReductionFile.perl
├── outputJoinedPairs.perl
├── outputMatedReadsAsReverseComplement.perl
├── outputRecordsNotOnList
├── parallel
├── putReadsIntoGroupsBasedOnSuperReads
├── quorum
├── quorum_create_database
├── quorum_error_correct_reads
├── recompute_astat_superreads.sh
├── reduce_sr
├── rename_filter_fastq
├── rename_filter_fastq.pl
├── reportReadsToExclude.perl
├── restore_ns.pl
├── reverse_complement
├── runByDirectory
├── run_ECR.sh
├── runSRCA.pl
├── sample_mate_pairs.pl
├── samtools
├── semaphore
├── SOAPdenovo-127mer
├── SOAPdenovo-63mer
├── sorted_merge
├── splitFileAtNs
├── splitFileByPrefix.pl
├── translateReduceFile.perl
└── ufasta

0 directories, 100 files
```

同时还生成一个配置文件样例, `sr_config_example.txt`.

# 样例数据

MaSuRCA 发表在 Bioinformatics 时自带的测试数据.

> IMPORTANT! Do not pre‐process Illumina data before providing it to MaSuRCA. Do not do any
> trimming, cleaning or error correction. This WILL deteriorate the assembly

Super-reads在 `work1/superReadSequences.fasta`, `work2/` 和 `work2.1/` 是 short jump 的处理, 不用管.
`superReadSequences_shr.frg` 里面的 super-reads 是作过截断处理的, 数量不对.

> Assembly result. The final assembly files are under CA/10-gapclose and named 'genome.ctg.fasta'
> for the contig sequences and 'genome.scf.fasta' for the scaffold sequences.

MaSuRCA-3.1.3 supports gzipped fastq files while MaSuRCA-2.1.0 doesn't.

## Rhodobacter sphaeroides (球形红细菌)

高 GC 原核生物 (68%), 基因组 4.5 Mbp.

```bash
mkdir -p ~/data/test
cd ~/data/test

wget -m ftp://ftp.genome.umd.edu/pub/MaSuRCA/test_data/rhodobacter .

mv ftp.genome.umd.edu/pub/MaSuRCA/test_data/rhodobacter .
rm -fr ftp.genome.umd.edu
find . -name ".listing" | xargs rm
```

### Illumina PE, Short Jump and Sanger4

```bash
cd ~/data/test

cat <<EOF > sr_config.txt
PARAMETERS
CA_PARAMETERS = ovlMerSize=30 cgwErrorRate=0.25 merylMemory=8192 ovlMemory=4GB 
LIMIT_JUMP_COVERAGE = 60
KMER_COUNT_THRESHOLD = 1
EXTEND_JUMP_READS = 0
NUM_THREADS = 16
JF_SIZE = 50000000
END

EOF

# Illumina PE, Short Jump and Sanger4
mkdir -p rhodobacter_PE_SJ_Sanger4
cp sr_config.txt rhodobacter_PE_SJ_Sanger4/
cat <<EOF >> rhodobacter_PE_SJ_Sanger4/sr_config.txt
DATA
PE=  pe 180 20 /home/wangq/data/test/rhodobacter/PE/frag_1.fastq /home/wangq/data/test/rhodobacter/PE/frag_2.fastq
JUMP= sj 3600 200  /home/wangq/data/test/rhodobacter/SJ/short_1.fastq  /home/wangq/data/test/rhodobacter/SJ/short_2.fastq
OTHER=/home/wangq/data/test/rhodobacter/Sanger/rhodobacter_sphaeroides_2_4_1.4x.frg
END

EOF

# Illumina PE, Short Jump and Sanger
mkdir -p rhodobacter_PE_SJ_Sanger
cp sr_config.txt rhodobacter_PE_SJ_Sanger/
cat <<EOF >> rhodobacter_PE_SJ_Sanger/sr_config.txt
DATA
PE=  pe 180 20 /home/wangq/data/test/rhodobacter/PE/frag_1.fastq /home/wangq/data/test/rhodobacter/PE/frag_2.fastq
JUMP= sj 3600 200  /home/wangq/data/test/rhodobacter/SJ/short_1.fastq  /home/wangq/data/test/rhodobacter/SJ/short_2.fastq
OTHER=/home/wangq/data/test/rhodobacter/Sanger/rhodobacter_sphaeroides_2_4_1.1x.frg
END

EOF

# Illumina PE and Short Jump
mkdir -p rhodobacter_PE_SJ
cp sr_config.txt rhodobacter_PE_SJ/
cat <<EOF >> rhodobacter_PE_SJ/sr_config.txt
DATA
PE=  pe 180 20 /home/wangq/data/test/rhodobacter/PE/frag_1.fastq /home/wangq/data/test/rhodobacter/PE/frag_2.fastq
JUMP= sj 3600 200  /home/wangq/data/test/rhodobacter/SJ/short_1.fastq  /home/wangq/data/test/rhodobacter/SJ/short_2.fastq
END

EOF

# Illumina PE, and Sanger4
mkdir -p rhodobacter_PE_Sanger4
cp sr_config.txt rhodobacter_PE_Sanger4/
cat <<EOF >> rhodobacter_PE_Sanger4/sr_config.txt
DATA
PE=  pe 180 20 /home/wangq/data/test/rhodobacter/PE/frag_1.fastq /home/wangq/data/test/rhodobacter/PE/frag_2.fastq
OTHER=/home/wangq/data/test/rhodobacter/Sanger/rhodobacter_sphaeroides_2_4_1.4x.frg
END

EOF

# Illumina PE, and Sanger
mkdir -p rhodobacter_PE_Sanger
cp sr_config.txt rhodobacter_PE_Sanger/
cat <<EOF >> rhodobacter_PE_Sanger/sr_config.txt
DATA
PE=  pe 180 20 /home/wangq/data/test/rhodobacter/PE/frag_1.fastq /home/wangq/data/test/rhodobacter/PE/frag_2.fastq
OTHER=/home/wangq/data/test/rhodobacter/Sanger/rhodobacter_sphaeroides_2_4_1.1x.frg
END

EOF


# Illumina PE
mkdir -p rhodobacter_PE_Sanger
cp sr_config.txt rhodobacter_PE_Sanger/
cat <<EOF >> rhodobacter_PE_Sanger/sr_config.txt
DATA
PE=  pe 180 20 /home/wangq/data/test/rhodobacter/PE/frag_1.fastq /home/wangq/data/test/rhodobacter/PE/frag_2.fastq
END

EOF

# Run
cd ~/data/test

for d in rhodobacter_PE_SJ_Sanger4 rhodobacter_PE_SJ_Sanger rhodobacter_PE_SJ rhodobacter_PE_Sanger4 rhodobacter_PE_Sanger rhodobacter_PE rhodobacter_superreads;
do
    echo "==> ${d}"
    if [ -e ${d}/work1/superReadSequences.fasta ];
    then
        continue     
    fi

    pushd ~/data/test/rhodobacter_PE_SJ_Sanger4 > /dev/null
    $HOME/share/MaSuRCA/bin/masurca sr_config.txt
    bash assemble.sh
    popd > /dev/null
done

```

### Rhodobacter sphaeroides with `superreads.pl`

```bash
# gzip original fastq
mkdir -p ~/data/test/rhodobacter/PEgz
gzip -c ~/data/test/rhodobacter/PE/frag_1.fastq > ~/data/test/rhodobacter/PEgz/frag_1.fq.gz
gzip -c ~/data/test/rhodobacter/PE/frag_2.fastq > ~/data/test/rhodobacter/PEgz/frag_2.fq.gz

mkdir -p ~/data/test/rhodobacter_superreads
cd ~/data/test/rhodobacter_superreads

perl ~/Scripts/sra/superreads.pl \
    ~/data/test/rhodobacter/PEgz/frag_1.fq.gz \
    ~/data/test/rhodobacter/PEgz/frag_2.fq.gz \
    -s 180 -d 20

```

Coverages on super-reads.

```bash
cd ~/data/test/rhodobacter_superreads

mkdir -p sr

# 0       1     2        3
# read_id sr_id position orientation
#cat work1/readPlacementsInSuperReads.final.read.superRead.offset.ori.txt \
#    | perl -nl -e '
#        my ( $read_id, $sr_id, $position, $orientation ) = split /\s+/, $_;
#        $orientation =~ /F|R/ or next;
#        my ($s, $e);
#        $orientation eq qq{F}
#            ? ($s = $position, $e = $s + 100 )
#            : ($e = $position, $s = $e - 100 );
#        print qq{$sr_id:$s-$e};
#    ' \
#    > sr/sr.pos.txt
#cat work1/readPlacementsInSuperReads.final.read.superRead.offset.ori.txt \
#    | perl -nl -e '
#        my ( $read_id, $sr_id, $position, $orientation ) = split /\s+/, $_;
#        $orientation =~ /F|R/ or next;
#        my $s = $position;
#        my $e = $s + 100 - 1;
#        print qq{$sr_id:$s-$e};
#    ' \
#    > sr/sr.pos.txt
#
#faops size work1/superReadSequences.fasta > sr/sr.chr.sizes
#head -n 100 sr/sr.chr.sizes  > sr/sr100.chr.sizes
#runlist coverage sr/sr.pos.txt -s sr/sr100.chr.sizes -m 5 -o sr/sr.depth5.yml
#runlist stat sr/sr.depth5.yml -s sr/sr100.chr.sizes --mk --all -o sr/depth5.csv
#
#runlist coverage sr/sr.pos.txt -s sr/sr100.chr.sizes -m 50 -o sr/sr.depth50.yml
#runlist stat sr/sr.depth50.yml -s sr/sr100.chr.sizes --mk --all -o sr/depth50.csv
#
#runlist coverage sr/sr.pos.txt -s sr/sr100.chr.sizes -m 200 -o sr/sr.depth200.yml
#runlist stat sr/sr.depth200.yml -s sr/sr100.chr.sizes --mk --all -o sr/depth200.csv

```

### 结果比较

```bash
cd ~/data/test/

printf "| %s | %s | %s | %s | %s | %s | %s | %s |\n" \
    "Name" "N50 SR" "#SR" "N50 Contig" "#Contig" "N50 Scaffold" "#Scaffold" "EstG" \
    > stat.md
printf "|:--|--:|--:|--:|--:|--:|--:|--:|\n" >> stat.md

for d in rhodobacter_PE_SJ_Sanger4 rhodobacter_PE_SJ_Sanger rhodobacter_PE_SJ rhodobacter_PE_Sanger4 rhodobacter_PE_Sanger rhodobacter_PE rhodobacter_superreads;
do
    printf "| %s | %s | %s | %s | %s | %s | %s | %s |\n" \
        ${d} \
        $( faops n50 -H -N 50 -C ${d}/work1/superReadSequences.fasta ) \
        $( faops n50 -H -N 50 -C ${d}/CA/10-gapclose/genome.ctg.fasta ) \
        $( faops n50 -H -N 50 -C ${d}/CA/10-gapclose/genome.scf.fasta ) \
        $( cat ${d}/environment.sh \
            | perl -n -e '/ESTIMATED_GENOME_SIZE=\"(\d+)\"/ and print $1' )
done >> stat.md

cat stat.md
```

| name          | N50 SR |  #SR | N50 Contig | #Contig | N50 Scaffold | #Scaffold |    EstG |
|:--------------|-------:|-----:|-----------:|--------:|-------------:|----------:|--------:|
| PE_SJ_Sanger4 |   4586 | 4187 |     205225 |      69 |      3196849 |        35 | 4602968 |
| PE_SJ_Sanger  |   4586 | 4187 |      63274 |     141 |      3070846 |        28 | 4602968 |
| PE_SJ         |   4586 | 4187 |      43125 |     219 |      3058404 |        59 | 4602968 |
| PE_Sanger4    |   4705 | 4042 |     125228 |      67 |       534852 |        30 | 4595684 |
| PE_Sanger     |   4705 | 4042 |      19435 |     412 |        21957 |       359 | 4595684 |
| PE            |   4705 | 4043 |      20826 |     407 |        34421 |       278 | 4595684 |
| superreads    |   4705 | 4043 |            |         |              |           | 4595684 |

* 有足够多的 long reads 支持下, 不需要 short jump.

# Super-reads and anchors

## E. coli sampling

Escherichia coli str. K-12 substr. MG1655 的 paralog 比例为 0.0323.

* Real:

    * S: 4,641,652

* Original:

    * N50: 151
    * S: 865,149,970
    * C: 5,729,470

* Filter, 151 bp

    * N50: 151
    * S: 371,039,918
    * C: 2,457,218

* Trimmed, 120-151 bp

    * N50: 151
    * S: 577,027,508
    * C: 3,871,323

```bash
mkdir -p ~/data/dna-seq/e_coli/superreads/MiSeq
cd ~/data/dna-seq/e_coli/superreads/MiSeq

curl -s "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nucleotide&id=NC_000913.3&rettype=fasta&retmode=txt" \
    > NC_000913.fa
faops n50 -N 0 -S NC_000913.fa

wget ftp://webdata:webdata@ussd-ftp.illumina.com/Data/SequencingRuns/MG1655/MiSeq_Ecoli_MG1655_110721_PF_R1.fastq.gz
wget ftp://webdata:webdata@ussd-ftp.illumina.com/Data/SequencingRuns/MG1655/MiSeq_Ecoli_MG1655_110721_PF_R2.fastq.gz

faops n50 -S -C MiSeq_Ecoli_MG1655_110721_PF_R1.fastq.gz

fastqc -t 8 \
    MiSeq_Ecoli_MG1655_110721_PF_R1.fastq.gz \
    MiSeq_Ecoli_MG1655_110721_PF_R2.fastq.gz
```

```bash
cd ~/data/dna-seq/e_coli/superreads/MiSeq

cat <<EOF > illumina_adapters.fa
>multiplexing-forward
GATCGGAAGAGCACACGTCT
>solexa-forward
AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT
>truseq-forward-contam
AGATCGGAAGAGCACACGTCTGAACTCCAGTCAC
>truseq-reverse-contam
AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGTA
>nextera-forward-read-contam
CTGTCTCTTATACACATCTCCGAGCCCACGAGAC
>nextera-reverse-read-contam
CTGTCTCTTATACACATCTGACGCTGCCGACGA
>solexa-reverse
AGATCGGAAGAGCGGTTCAGCAGGAATGCCGAG

EOF

mkdir trimmed

# scythe (pair end)
scythe \
    MiSeq_Ecoli_MG1655_110721_PF_R1.fastq.gz \
    -q sanger \
    -M 20 \
    -a illumina_adapters.fa \
    -m trimmed/R1.matches.txt \
    --quiet \
    | gzip -c \
    > trimmed/R1.scythe.fq.gz

scythe \
    MiSeq_Ecoli_MG1655_110721_PF_R2.fastq.gz \
    -q sanger \
    -M 20 \
    -a illumina_adapters.fa \
    -m trimmed/R2.matches.txt \
    --quiet \
    | gzip -c \
    > trimmed/R2.scythe.fq.gz

# sickle (pair end)
sickle pe \
    -t sanger -l 120 -q 20 \
    -f trimmed/R1.scythe.fq.gz \
    -r trimmed/R2.scythe.fq.gz \
    -o trimmed/R1.sickle.fq \
    -p trimmed/R2.sickle.fq \
    -s trimmed/single.sickle.fq

find . -type f -name "*.sickle.fq" | xargs pigz

fastqc -t 8 \
    trimmed/R1.sickle.fq.gz \
    trimmed/R2.sickle.fq.gz \
    trimmed/single.sickle.fq.gz

faops n50 -S -C trimmed/R1.sickle.fq.gz
```

```bash
cd ~/data/dna-seq/e_coli/superreads/MiSeq

mkdir filter

# sickle (pair end)
sickle pe \
    -t sanger -l 151 -q 20 \
    -f trimmed/R1.scythe.fq.gz \
    -r trimmed/R2.scythe.fq.gz \
    -o filter/R1.sickle.fq \
    -p filter/R2.sickle.fq \
    -s filter/single.sickle.fq

find . -type f -name "*.sickle.fq" | xargs pigz

fastqc -t 8 \
    filter/R1.sickle.fq.gz \
    filter/R2.sickle.fq.gz \
    filter/single.sickle.fq.gz

faops n50 -S -C filter/R1.sickle.fq.gz

find . -type d -name "*fastqc" | sort | xargs rm -fr
find . -type f -name "*_fastqc.zip" | sort | xargs rm
find . -type f -name "*matches.txt" | sort | xargs rm
```

### E. coli: Down sampling

过高的 coverage 会造成不好的影响. SGA 的文档里也说了类似的事情.

> Very highly-represented sequences (>1000X) can cause problems for SGA... In these cases, it is
> worth considering pre-filtering the data...

* Original

```bash
cd ~/data/dna-seq/e_coli/superreads/

for count in 50000 100000 150000 200000 300000 400000 500000 600000 700000 800000 900000 1000000 1200000 1400000 1600000 1800000 2000000 3000000 4000000 5000000;
do
    echo
    echo "==> Reads ${count}"
    DIR_COUNT="$HOME/data/dna-seq/e_coli/superreads/MiSeq_${count}/"
    mkdir -p ${DIR_COUNT}
    
    if [ -e ${DIR_COUNT}/R1.fq.gz ];
    then
        continue     
    fi
    
    seqtk sample -s${count} \
        ~/data/dna-seq/e_coli/superreads/MiSeq/MiSeq_Ecoli_MG1655_110721_PF_R1.fastq.gz ${count} \
        | gzip > ${DIR_COUNT}/R1.fq.gz
    seqtk sample -s${count} \
        ~/data/dna-seq/e_coli/superreads/MiSeq/MiSeq_Ecoli_MG1655_110721_PF_R2.fastq.gz ${count} \
        | gzip > ${DIR_COUNT}/R2.fq.gz
done
```

* Filter

```bash
cd ~/data/dna-seq/e_coli/superreads/

for count in 50000 100000 150000 200000 300000 400000 500000 600000 700000 800000 900000 1000000 1200000 1400000 1600000 1800000 2000000 3000000;
do
    echo
    echo "==> Reads ${count}"
    DIR_COUNT="$HOME/data/dna-seq/e_coli/superreads/filter_${count}/"
    mkdir -p ${DIR_COUNT}
    
    if [ -e ${DIR_COUNT}/R1.fq.gz ];
    then
        continue     
    fi
    
    seqtk sample -s${count} \
        ~/data/dna-seq/e_coli/superreads/MiSeq/filter/R1.sickle.fq.gz ${count} \
        | gzip > ${DIR_COUNT}/R1.fq.gz
    seqtk sample -s${count} \
        ~/data/dna-seq/e_coli/superreads/MiSeq/filter/R2.sickle.fq.gz ${count} \
        | gzip > ${DIR_COUNT}/R2.fq.gz
done
```

* Trimmed

```bash
cd ~/data/dna-seq/e_coli/superreads/

for count in 50000 100000 150000 200000 300000 400000 500000 600000 700000 800000 900000 1000000 1200000 1400000 1600000 1800000 2000000 3000000;
do
    echo
    echo "==> Reads ${count}"
    DIR_COUNT="$HOME/data/dna-seq/e_coli/superreads/trimmed_${count}/"
    mkdir -p ${DIR_COUNT}
    
    if [ -e ${DIR_COUNT}/R1.fq.gz ];
    then
        continue     
    fi
    
    seqtk sample -s${count} \
        ~/data/dna-seq/e_coli/superreads/MiSeq/trimmed/R1.sickle.fq.gz ${count} \
        | gzip > ${DIR_COUNT}/R1.fq.gz
    seqtk sample -s${count} \
        ~/data/dna-seq/e_coli/superreads/MiSeq/trimmed/R2.sickle.fq.gz ${count} \
        | gzip > ${DIR_COUNT}/R2.fq.gz
done
```

### E. coli: Generate super-reads

```bash
cd ~/data/dna-seq/e_coli/superreads/

for d in {MiSeq,trimmed,filter}_{50000,100000,150000,200000,300000,400000,500000,600000,700000,800000,900000,1000000,1200000,1400000,1600000,1800000,2000000,3000000,4000000,5000000};
do
    echo
    echo "==> Reads ${d}"
    DIR_COUNT="$HOME/data/dna-seq/e_coli/superreads/${d}/"

    if [ ! -d ${DIR_COUNT} ]; then
        echo "${DIR_COUNT} doesn't exist"
        continue
    fi
    
    if [ -e ${DIR_COUNT}/pe.cor.fa ]; then
        echo "pe.cor.fa already presents"
        continue
    fi
    
    pushd ${DIR_COUNT} > /dev/null
    perl ~/Scripts/sra/superreads.pl \
        R1.fq.gz \
        R2.fq.gz \
        -s 300 -d 30 -p 8
    popd > /dev/null
done
```

Stats of super-reads

```bash
cd ~/data/dna-seq/e_coli/superreads/

bash ~/Scripts/sra/sr_stat.sh 1 header \
    > ~/data/dna-seq/e_coli/superreads/stat1.md

for d in {MiSeq,trimmed,filter}_{50000,100000,150000,200000,300000,400000,500000,600000,700000,800000,900000,1000000,1200000,1400000,1600000,1800000,2000000,3000000,4000000,5000000};
do
    DIR_COUNT="$HOME/data/dna-seq/e_coli/superreads/${d}/"

    if [ ! -d ${DIR_COUNT} ]; then
        continue     
    fi

    bash ~/Scripts/sra/sr_stat.sh 1 ${DIR_COUNT} \
        >> ~/data/dna-seq/e_coli/superreads/stat1.md
done

cat stat1.md
```

| Name            | fqSize | faSize | Length | Kmer |    EstG | #reads |   RunTime |    SumSR | SR/EstG |
|:----------------|-------:|-------:|-------:|-----:|--------:|-------:|----------:|---------:|--------:|
| MiSeq_50000     |    31M |    15M |    151 |   75 | 2848356 |  15009 | 0:00'56'' |  2432529 |    0.85 |
| MiSeq_100000    |    61M |    33M |    151 |   75 | 4283432 |  23894 | 0:01'19'' |  4442346 |    1.04 |
| MiSeq_150000    |    91M |    49M |    151 |   75 | 4525464 |  18242 | 0:01'38'' |  4880895 |    1.08 |
| MiSeq_200000    |   121M |    66M |    151 |   75 | 4570010 |  14079 | 0:01'24'' |  5740960 |    1.26 |
| MiSeq_300000    |   181M |    98M |    151 |   75 | 4604273 |  14619 | 0:01'39'' |  9248681 |    2.01 |
| MiSeq_400000    |   241M |   131M |    151 |   75 | 4637990 |  15852 | 0:01'56'' | 10223031 |    2.20 |
| MiSeq_500000    |   302M |   164M |    151 |   75 | 4673825 |  17386 | 0:02'17'' | 10663685 |    2.28 |
| MiSeq_600000    |   362M |   197M |    151 |   75 | 4720834 |  19576 | 0:02'31'' | 10996696 |    2.33 |
| MiSeq_700000    |   423M |   229M |    151 |   75 | 4769693 |  21103 | 0:04'09'' | 11244264 |    2.36 |
| MiSeq_800000    |   483M |   262M |    151 |   75 | 4819275 |  23685 | 0:03'00'' | 11668035 |    2.42 |
| MiSeq_900000    |   544M |   295M |    151 |   75 | 4869460 |  25744 | 0:03'11'' | 11959177 |    2.46 |
| MiSeq_1000000   |   604M |   328M |    151 |   75 | 4933858 |  28278 | 0:03'33'' | 12271938 |    2.49 |
| MiSeq_1200000   |   725M |   393M |    151 |   75 | 5052478 |  33423 | 0:04'09'' | 12929921 |    2.56 |
| MiSeq_1400000   |   846M |   459M |    151 |   75 | 5183791 |  39503 | 0:04'22'' | 13405411 |    2.59 |
| MiSeq_1600000   |   967M |   525M |    151 |   75 | 5326650 |  46014 | 0:04'58'' | 14100368 |    2.65 |
| MiSeq_1800000   |   1.1G |   590M |    151 |   75 | 5460717 |  54170 | 0:05'34'' | 14724645 |    2.70 |
| MiSeq_2000000   |   1.2G |   656M |    151 |   75 | 5621863 |  62178 | 0:06'16'' | 15468429 |    2.75 |
| MiSeq_3000000   |   1.8G |   983M |    151 |   75 | 6490892 | 107693 | 0:10'39'' | 18695968 |    2.88 |
| MiSeq_4000000   |   2.4G |   1.3G |    151 |   75 | 7492813 | 159719 | 0:12'15'' | 22406939 |    2.99 |
| MiSeq_5000000   |   3.0G |   1.6G |    151 |   75 | 8630397 | 215063 | 0:18'20'' | 26685370 |    3.09 |
| trimmed_50000   |    30M |    15M |    147 |  105 | 2815462 |  23025 | 0:01'00'' |  1673901 |    0.59 |
| trimmed_100000  |    59M |    31M |    147 |  105 | 4117614 |  73236 | 0:01'23'' |  4174701 |    1.01 |
| trimmed_150000  |    89M |    46M |    147 |  105 | 4399723 |  87117 | 0:01'26'' |  4939094 |    1.12 |
| trimmed_200000  |   118M |    62M |    147 |  105 | 4488349 |  81921 | 0:01'25'' |  5113050 |    1.14 |
| trimmed_300000  |   177M |    93M |    147 |  105 | 4532122 |  57240 | 0:01'52'' |  4998054 |    1.10 |
| trimmed_400000  |   235M |   123M |    147 |  105 | 4542605 |  41436 | 0:02'06'' |  4896464 |    1.08 |
| trimmed_500000  |   294M |   154M |    146 |  105 | 4548727 |  31785 | 0:02'21'' |  4891545 |    1.08 |
| trimmed_600000  |   353M |   185M |    146 |  105 | 4553623 |  29191 | 0:02'31'' |  4898849 |    1.08 |
| trimmed_700000  |   412M |   216M |    146 |  105 | 4555074 |  26639 | 0:02'54'' |  5013590 |    1.10 |
| trimmed_800000  |   471M |   247M |    146 |  105 | 4555651 |  24169 | 0:02'55'' |  4959830 |    1.09 |
| trimmed_900000  |   530M |   278M |    146 |  105 | 4557764 |  24696 | 0:02'52'' |  5019700 |    1.10 |
| trimmed_1000000 |   589M |   309M |    146 |  105 | 4559632 |  24724 | 0:03'01'' |  5115098 |    1.12 |
| trimmed_1200000 |   707M |   371M |    146 |  105 | 4563512 |  25670 | 0:03'34'' |  5159538 |    1.13 |
| trimmed_1400000 |   825M |   433M |    146 |  105 | 4568746 |  27259 | 0:04'07'' |  5629312 |    1.23 |
| trimmed_1600000 |   942M |   495M |    146 |  105 | 4571296 |  28568 | 0:04'36'' |  5879184 |    1.29 |
| trimmed_1800000 |   1.1G |   557M |    146 |  105 | 4578131 |  29706 | 0:04'58'' |  6320459 |    1.38 |
| trimmed_2000000 |   1.2G |   619M |    146 |  105 | 4583027 |  31621 | 0:05'33'' |  6658064 |    1.45 |
| trimmed_3000000 |   1.8G |   928M |    145 |  101 | 4621800 |  40327 | 0:07'59'' |  8503135 |    1.84 |
| filter_50000    |    31M |    15M |    151 |  105 | 2697651 |  25485 | 0:01'01'' |  1880026 |    0.70 |
| filter_100000   |    61M |    32M |    151 |  105 | 3865587 |  55415 | 0:01'09'' |  3856581 |    1.00 |
| filter_150000   |    91M |    48M |    151 |  105 | 4214432 |  57749 | 0:01'29'' |  4531014 |    1.08 |
| filter_200000   |   121M |    63M |    151 |  105 | 4363423 |  50687 | 0:01'35'' |  4728385 |    1.08 |
| filter_300000   |   181M |    95M |    151 |  105 | 4459989 |  37112 | 0:01'54'' |  4820562 |    1.08 |
| filter_400000   |   241M |   127M |    151 |  105 | 4494070 |  28238 | 0:02'08'' |  4809291 |    1.07 |
| filter_500000   |   302M |   158M |    151 |  105 | 4514824 |  24364 | 0:02'22'' |  4815359 |    1.07 |
| filter_600000   |   362M |   190M |    151 |  105 | 4524047 |  21975 | 0:02'34'' |  4819308 |    1.07 |
| filter_700000   |   423M |   222M |    151 |  105 | 4532843 |  20642 | 0:03'11'' |  4842355 |    1.07 |
| filter_800000   |   483M |   253M |    151 |  105 | 4535889 |  20038 | 0:03'01'' |  4874718 |    1.07 |
| filter_900000   |   544M |   285M |    151 |  105 | 4538470 |  19424 | 0:03'07'' |  4909160 |    1.08 |
| filter_1000000  |   604M |   317M |    151 |  105 | 4544112 |  20151 | 0:03'19'' |  4939608 |    1.09 |
| filter_1200000  |   725M |   380M |    151 |  105 | 4549663 |  19864 | 0:03'58'' |  5005087 |    1.10 |
| filter_1400000  |   846M |   444M |    151 |  105 | 4553081 |  21377 | 0:04'25'' |  5119952 |    1.12 |
| filter_1600000  |   967M |   507M |    151 |  105 | 4557128 |  21813 | 0:04'53'' |  5280512 |    1.16 |
| filter_1800000  |   1.1G |   571M |    151 |  105 | 4562660 |  22796 | 0:05'07'' |  5547849 |    1.22 |
| filter_2000000  |   1.2G |   634M |    151 |  105 | 4566970 |  24304 | 0:05'39'' |  5752657 |    1.26 |
| filter_3000000  |   1.5G |   779M |    151 |  105 | 4577674 |  26573 | 0:07'00'' |  6513055 |    1.42 |

Columns:

* fqSize - pe.renamed.fastq
* faSize - pe.cor.fa
* Length (PE_AVG_READ_LENGTH), Kmer, EstG (ESTIMATED_GENOME_SIZE), and #reads (TOTAL_READS) from
  `environment.sh`

```bash
cd ~/data/dna-seq/e_coli/superreads/

REAL_G=4641652

bash ~/Scripts/sra/sr_stat.sh 2 header \
    > ~/data/dna-seq/e_coli/superreads/stat2.md

for d in {MiSeq,trimmed,filter}_{50000,100000,150000,200000,300000,400000,500000,600000,700000,800000,900000,1000000,1200000,1400000,1600000,1800000,2000000,3000000,4000000,5000000};
do
    DIR_COUNT="$HOME/data/dna-seq/e_coli/superreads/${d}/"
    
    if [ ! -d ${DIR_COUNT} ]; then
        continue     
    fi
    
    bash ~/Scripts/sra/sr_stat.sh 2 ${DIR_COUNT} ${REAL_G} \
        >> ~/data/dna-seq/e_coli/superreads/stat2.md
done

cat stat2.md
```

| Name            | TotalFq | TotalFa | RatioDiscard | TotalSubs | RatioSubs | RealG | CovFq | CovFa |  EstG |  SumSR | Est/Real | SumSR/Real | N50SR |
|:----------------|--------:|--------:|-------------:|----------:|----------:|------:|------:|------:|------:|-------:|---------:|-----------:|------:|
| MiSeq_50000     |   14.4M |  12.87M |       0.1061 |    57.03K |    0.0043 | 4.43M |   3.3 |   2.9 | 2.72M |  2.32M |     0.61 |       0.52 |   375 |
| MiSeq_100000    |   28.8M |  28.12M |       0.0238 |   154.15K |    0.0054 | 4.43M |   6.5 |   6.4 | 4.08M |  4.24M |     0.92 |       0.96 |   874 |
| MiSeq_150000    |   43.2M |  42.28M |       0.0212 |   245.39K |    0.0057 | 4.43M |   9.8 |   9.6 | 4.32M |  4.65M |     0.97 |       1.05 |  2366 |
| MiSeq_200000    |   57.6M |  56.42M |       0.0205 |   328.01K |    0.0057 | 4.43M |  13.0 |  12.7 | 4.36M |  5.48M |     0.98 |       1.24 |  5885 |
| MiSeq_300000    |   86.4M |  84.66M |       0.0202 |   495.96K |    0.0057 | 4.43M |  19.5 |  19.1 | 4.39M |  8.82M |     0.99 |       1.99 |  7066 |
| MiSeq_400000    |  115.2M | 112.89M |       0.0201 |    654.4K |    0.0057 | 4.43M |  26.0 |  25.5 | 4.42M |  9.75M |     1.00 |       2.20 |  5514 |
| MiSeq_500000    |    144M |  141.2M |       0.0195 |   818.88K |    0.0057 | 4.43M |  32.5 |  31.9 | 4.46M | 10.17M |     1.01 |       2.30 |  4200 |
| MiSeq_600000    | 172.81M | 169.44M |       0.0195 |   977.41K |    0.0056 | 4.43M |  39.0 |  38.3 |  4.5M | 10.49M |     1.02 |       2.37 |  3423 |
| MiSeq_700000    | 201.61M | 197.72M |       0.0193 |     1.11M |    0.0056 | 4.43M |  45.5 |  44.7 | 4.55M | 10.72M |     1.03 |       2.42 |  2922 |
| MiSeq_800000    | 230.41M | 225.95M |       0.0194 |     1.26M |    0.0056 | 4.43M |  52.1 |  51.0 |  4.6M | 11.13M |     1.04 |       2.51 |  2583 |
| MiSeq_900000    | 259.21M | 254.27M |       0.0190 |     1.41M |    0.0056 | 4.43M |  58.6 |  57.4 | 4.64M | 11.41M |     1.05 |       2.58 |  2330 |
| MiSeq_1000000   | 288.01M | 282.53M |       0.0190 |     1.57M |    0.0056 | 4.43M |  65.1 |  63.8 | 4.71M |  11.7M |     1.06 |       2.64 |  2057 |
| MiSeq_1200000   | 345.61M | 339.12M |       0.0188 |     1.87M |    0.0055 | 4.43M |  78.1 |  76.6 | 4.82M | 12.33M |     1.09 |       2.79 |  1796 |
| MiSeq_1400000   | 403.21M | 395.72M |       0.0186 |     2.17M |    0.0055 | 4.43M |  91.1 |  89.4 | 4.94M | 12.78M |     1.12 |       2.89 |  1528 |
| MiSeq_1600000   | 460.82M | 452.32M |       0.0184 |     2.47M |    0.0055 | 4.43M | 104.1 | 102.2 | 5.08M | 13.45M |     1.15 |       3.04 |  1377 |
| MiSeq_1800000   | 518.42M |  508.9M |       0.0184 |     2.76M |    0.0054 | 4.43M | 117.1 | 115.0 | 5.21M | 14.04M |     1.18 |       3.17 |  1233 |
| MiSeq_2000000   | 576.02M | 565.54M |       0.0182 |     3.06M |    0.0054 | 4.43M | 130.1 | 127.8 | 5.36M | 14.75M |     1.21 |       3.33 |  1117 |
| MiSeq_3000000   | 864.03M | 848.73M |       0.0177 |     4.48M |    0.0053 | 4.43M | 195.2 | 191.7 | 6.19M | 17.83M |     1.40 |       4.03 |   730 |
| MiSeq_4000000   |   1.13G |   1.11G |       0.0173 |     5.88M |    0.0052 | 4.43M | 260.3 | 255.8 | 7.15M | 21.37M |     1.61 |       4.83 |   543 |
| MiSeq_5000000   |   1.41G |   1.38G |       0.0170 |     7.22M |    0.0051 | 4.43M | 325.3 | 319.8 | 8.23M | 25.45M |     1.86 |       5.75 |   439 |
| trimmed_50000   |  14.01M |  12.79M |       0.0871 |    11.11K |    0.0008 | 4.43M |   3.2 |   2.9 | 2.69M |   1.6M |     0.61 |       0.36 |   194 |
| trimmed_100000  |  28.03M |  27.77M |       0.0094 |       28K |    0.0010 | 4.43M |   6.3 |   6.3 | 3.93M |  3.98M |     0.89 |       0.90 |   250 |
| trimmed_150000  |  42.05M |  41.91M |       0.0035 |    42.35K |    0.0010 | 4.43M |   9.5 |   9.5 |  4.2M |  4.71M |     0.95 |       1.06 |   441 |
| trimmed_200000  |  56.07M |  55.93M |       0.0024 |    56.66K |    0.0010 | 4.43M |  12.7 |  12.6 | 4.28M |  4.88M |     0.97 |       1.10 |   688 |
| trimmed_300000  |  84.11M |  83.93M |       0.0021 |    84.96K |    0.0010 | 4.43M |  19.0 |  19.0 | 4.32M |  4.77M |     0.98 |       1.08 |  1581 |
| trimmed_400000  | 112.15M | 111.93M |       0.0020 |   112.94K |    0.0010 | 4.43M |  25.3 |  25.3 | 4.33M |  4.67M |     0.98 |       1.05 |  2905 |
| trimmed_500000  | 140.17M |  139.9M |       0.0020 |   140.88K |    0.0010 | 4.43M |  31.7 |  31.6 | 4.34M |  4.66M |     0.98 |       1.05 |  4531 |
| trimmed_600000  | 168.21M | 167.87M |       0.0020 |   169.22K |    0.0010 | 4.43M |  38.0 |  37.9 | 4.34M |  4.67M |     0.98 |       1.06 |  5889 |
| trimmed_700000  | 196.25M | 195.87M |       0.0020 |   197.01K |    0.0010 | 4.43M |  44.3 |  44.2 | 4.34M |  4.78M |     0.98 |       1.08 |  7308 |
| trimmed_800000  | 224.28M | 223.83M |       0.0020 |   225.13K |    0.0010 | 4.43M |  50.7 |  50.6 | 4.34M |  4.73M |     0.98 |       1.07 |  8727 |
| trimmed_900000  | 252.32M | 251.83M |       0.0019 |   254.04K |    0.0010 | 4.43M |  57.0 |  56.9 | 4.35M |  4.79M |     0.98 |       1.08 |  9795 |
| trimmed_1000000 | 280.37M | 279.83M |       0.0019 |   282.25K |    0.0010 | 4.43M |  63.3 |  63.2 | 4.35M |  4.88M |     0.98 |       1.10 | 10326 |
| trimmed_1200000 | 336.45M | 335.82M |       0.0019 |   338.65K |    0.0010 | 4.43M |  76.0 |  75.9 | 4.35M |  4.92M |     0.98 |       1.11 | 11697 |
| trimmed_1400000 | 392.51M | 391.75M |       0.0019 |   394.88K |    0.0010 | 4.43M |  88.7 |  88.5 | 4.36M |  5.37M |     0.98 |       1.21 | 11782 |
| trimmed_1600000 | 448.59M | 447.74M |       0.0019 |   449.84K |    0.0010 | 4.43M | 101.3 | 101.1 | 4.36M |  5.61M |     0.98 |       1.27 | 12378 |
| trimmed_1800000 | 504.65M | 503.71M |       0.0019 |   506.26K |    0.0010 | 4.43M | 114.0 | 113.8 | 4.37M |  6.03M |     0.99 |       1.36 | 12613 |
| trimmed_2000000 | 560.73M | 559.69M |       0.0019 |   561.47K |    0.0010 | 4.43M | 126.7 | 126.4 | 4.37M |  6.35M |     0.99 |       1.43 | 10670 |
| trimmed_3000000 |  841.1M |  839.6M |       0.0018 |   836.89K |    0.0010 | 4.43M | 190.0 | 189.7 | 4.41M |  8.11M |     1.00 |       1.83 |  6347 |
| filter_50000    |   14.4M |  13.18M |       0.0849 |    11.56K |    0.0009 | 4.43M |   3.3 |   3.0 | 2.57M |  1.79M |     0.58 |       0.41 |   210 |
| filter_100000   |   28.8M |   28.4M |       0.0141 |    27.72K |    0.0010 | 4.43M |   6.5 |   6.4 | 3.69M |  3.68M |     0.83 |       0.83 |   342 |
| filter_150000   |   43.2M |  42.99M |       0.0049 |    43.05K |    0.0010 | 4.43M |   9.8 |   9.7 | 4.02M |  4.32M |     0.91 |       0.98 |   543 |
| filter_200000   |   57.6M |  57.44M |       0.0028 |    57.41K |    0.0010 | 4.43M |  13.0 |  13.0 | 4.16M |  4.51M |     0.94 |       1.02 |   810 |
| filter_300000   |   86.4M |  86.24M |       0.0019 |    86.23K |    0.0010 | 4.43M |  19.5 |  19.5 | 4.25M |   4.6M |     0.96 |       1.04 |  1548 |
| filter_400000   |  115.2M | 115.02M |       0.0016 |   114.67K |    0.0010 | 4.43M |  26.0 |  26.0 | 4.29M |  4.59M |     0.97 |       1.04 |  2439 |
| filter_500000   |    144M | 143.77M |       0.0016 |   143.94K |    0.0010 | 4.43M |  32.5 |  32.5 | 4.31M |  4.59M |     0.97 |       1.04 |  3359 |
| filter_600000   | 172.81M | 172.53M |       0.0016 |   173.49K |    0.0010 | 4.43M |  39.0 |  39.0 | 4.31M |   4.6M |     0.97 |       1.04 |  4142 |
| filter_700000   | 201.61M | 201.29M |       0.0016 |   201.69K |    0.0010 | 4.43M |  45.5 |  45.5 | 4.32M |  4.62M |     0.98 |       1.04 |  4796 |
| filter_800000   | 230.41M | 230.06M |       0.0015 |   230.59K |    0.0010 | 4.43M |  52.1 |  52.0 | 4.33M |  4.65M |     0.98 |       1.05 |  5724 |
| filter_900000   | 259.21M | 258.82M |       0.0015 |   258.94K |    0.0010 | 4.43M |  58.6 |  58.5 | 4.33M |  4.68M |     0.98 |       1.06 |  6159 |
| filter_1000000  | 288.01M | 287.58M |       0.0015 |   287.57K |    0.0010 | 4.43M |  65.1 |  65.0 | 4.33M |  4.71M |     0.98 |       1.06 |  6436 |
| filter_1200000  | 345.61M |  345.1M |       0.0015 |   345.87K |    0.0010 | 4.43M |  78.1 |  78.0 | 4.34M |  4.77M |     0.98 |       1.08 |  7493 |
| filter_1400000  | 403.21M | 402.62M |       0.0015 |   402.09K |    0.0010 | 4.43M |  91.1 |  91.0 | 4.34M |  4.88M |     0.98 |       1.10 |  7834 |
| filter_1600000  | 460.82M | 460.14M |       0.0015 |   459.62K |    0.0010 | 4.43M | 104.1 | 103.9 | 4.35M |  5.04M |     0.98 |       1.14 |  8246 |
| filter_1800000  | 518.42M | 517.67M |       0.0014 |   516.93K |    0.0010 | 4.43M | 117.1 | 116.9 | 4.35M |  5.29M |     0.98 |       1.20 |  8730 |
| filter_2000000  | 576.02M | 575.19M |       0.0014 |   573.15K |    0.0010 | 4.43M | 130.1 | 129.9 | 4.36M |  5.49M |     0.98 |       1.24 |  7981 |
| filter_3000000  |  707.7M |  706.7M |       0.0014 |    702.2K |    0.0010 | 4.43M | 159.9 | 159.6 | 4.37M |  6.21M |     0.99 |       1.40 |  7532 |

* Illumina reads 的分布是有偏性的. 极端 GC 区域, 结构复杂区域都会得到较低的 fq 分值, 本应被 trim 掉.
  但覆盖度过高时, 这些区域之间的 reads 相互支持, 被保留下来的概率大大增加.
    * RatioDiscard 在 CovFq 大于 100 倍时, 快速下降.
* Illumina reads 错误率约为 1% 不到一点. 当覆盖度过高时, 错误的点重复出现的概率要比完全无偏性的情况大一些.
    * 理论上 RatioSubs 应该是恒定值, 但当 CovFq 大于 100 倍时, 这个值在下降, 也就是这些错误的点相互支持, 躲过了
      Kmer 纠错.
* 直接的反映就是 EstG 过大, SumSR 过大.
* 留下的错误片段, 会形成 **伪独立** 片段, 降低 N50 SR
* 留下的错误位点, 会形成 **伪杂合** 位点, 降低 N50 SR
* trim 的效果比 filter 好. 可能是留下了更多二代测序效果较差的位置. 最大的 EstG, trim 的更接近真实值
    * Real - 4641652
    * Trimmed - 4621800 (EstG)
    * Filter - 4577674 (EstG)

### E. coli: Create anchors

```bash
cd ~/data/dna-seq/e_coli/superreads/

for d in {MiSeq,trimmed,filter}_{50000,100000,150000,200000,300000,400000,500000,600000,700000,800000,900000,1000000,1200000,1400000,1600000,1800000,2000000,3000000,4000000,5000000};
do
    echo
    echo "==> Reads ${d}"
    DIR_COUNT="$HOME/data/dna-seq/e_coli/superreads/${d}/"

    if [ -e ${DIR_COUNT}/sr/pe.anchor.fa ]; then
        continue     
    fi
    
    rm -fr ${DIR_COUNT}/sr
    bash ~/Scripts/sra/anchor.sh ${DIR_COUNT} 8 false 120
done

```

Stats of anchors

```bash
cd ~/data/dna-seq/e_coli/superreads/

bash ~/Scripts/sra/sr_stat.sh 3 header \
    > ~/data/dna-seq/e_coli/superreads/stat3.md

for d in {MiSeq,trimmed,filter}_{50000,100000,150000,200000,300000,400000,500000,600000,700000,800000,900000,1000000,1200000,1400000,1600000,1800000,2000000,3000000,4000000,5000000};
do
    DIR_COUNT="$HOME/data/dna-seq/e_coli/superreads/${d}/"
    
    if [ ! -e ${DIR_COUNT}/sr/pe.anchor.fa ]; then
        continue     
    fi
    
    bash ~/Scripts/sra/sr_stat.sh 3 ${DIR_COUNT} \
        >> ~/data/dna-seq/e_coli/superreads/stat3.md
done

cat stat3.md
```

```bash
cd ~/data/dna-seq/e_coli/superreads/

bash ~/Scripts/sra/sr_stat.sh 4 header \
    > ~/data/dna-seq/e_coli/superreads/stat4.md

for d in {MiSeq,trimmed,filter}_{50000,100000,150000,200000,300000,400000,500000,600000,700000,800000,900000,1000000,1200000,1400000,1600000,1800000,2000000,3000000,4000000,5000000};
do
    DIR_COUNT="$HOME/data/dna-seq/e_coli/superreads/${d}/"
    
    if [ ! -e ${DIR_COUNT}/sr/pe.anchor.fa ]; then
        continue     
    fi
    
    bash ~/Scripts/sra/sr_stat.sh 4 ${DIR_COUNT} \
        >> ~/data/dna-seq/e_coli/superreads/stat4.md
done

cat stat4.md
```

| Name            |  #cor.fa | #strict.fa | strict/cor | N50SRclean | SumSRclean | #SRclean |   RunTime |
|:----------------|---------:|-----------:|-----------:|-----------:|-----------:|---------:|----------:|
| MiSeq_50000     |   100000 |      63759 |     0.6376 |        654 |     680991 |     1007 | 0:00'21'' |
| MiSeq_100000    |   200000 |     128831 |     0.6442 |       1102 |    3304547 |     3250 | 0:00'25'' |
| MiSeq_150000    |   300000 |     189938 |     0.6331 |       2493 |    4393819 |     2253 | 0:00'28'' |
| MiSeq_200000    |   400000 |     252968 |     0.6324 |       6236 |    4832792 |     1167 | 0:00'32'' |
| MiSeq_300000    |   600000 |     378411 |     0.6307 |       7798 |    5898580 |     1015 | 0:00'39'' |
| MiSeq_400000    |   800000 |     506260 |     0.6328 |       5891 |    6570560 |     1472 | 0:00'43'' |
| MiSeq_500000    |  1000000 |     632749 |     0.6327 |       4483 |    6731573 |     1916 | 0:00'49'' |
| MiSeq_600000    |  1200000 |     760223 |     0.6335 |       3582 |    6670045 |     2321 | 0:00'54'' |
| MiSeq_700000    |  1400000 |     888543 |     0.6347 |       3024 |    6851883 |     2777 | 0:00'58'' |
| MiSeq_800000    |  1600000 |    1016289 |     0.6352 |       2657 |    6824939 |     3102 | 0:01'02'' |
| MiSeq_900000    |  1800000 |    1145616 |     0.6365 |       2434 |    6890842 |     3377 | 0:01'05'' |
| MiSeq_1000000   |  2000000 |    1272659 |     0.6363 |       2174 |    6874935 |     3733 | 0:01'12'' |
| MiSeq_1200000   |  2400000 |    1531171 |     0.6380 |       1889 |    6818611 |     4228 | 0:01'19'' |
| MiSeq_1400000   |  2800000 |    1789790 |     0.6392 |       1673 |    6965783 |     4800 | 0:01'25'' |
| MiSeq_1600000   |  3200000 |    2047410 |     0.6398 |       1518 |    6891620 |     5196 | 0:01'35'' |
| MiSeq_1800000   |  3600000 |    2308458 |     0.6412 |       1384 |    6912514 |     5614 | 0:01'40'' |
| MiSeq_2000000   |  4000000 |    2567733 |     0.6419 |       1269 |    6881332 |     5967 | 0:01'48'' |
| MiSeq_3000000   |  6000000 |    3882603 |     0.6471 |        916 |    6902967 |     7689 | 0:02'25'' |
| MiSeq_4000000   |  8000000 |    5213266 |     0.6517 |        762 |    6608794 |     8539 | 0:02'55'' |
| MiSeq_5000000   | 10000000 |    6561333 |     0.6561 |        677 |    6004084 |     8581 | 0:03'46'' |
| trimmed_50000   |   100000 |      81290 |     0.8129 |        587 |      37176 |       57 | 0:00'18'' |
| trimmed_100000  |   200000 |     173159 |     0.8658 |        646 |     728070 |     1085 | 0:00'23'' |
| trimmed_150000  |   300000 |     260730 |     0.8691 |        796 |    2140563 |     2674 | 0:00'29'' |
| trimmed_200000  |   400000 |     347905 |     0.8698 |       1040 |    3223243 |     3306 | 0:00'31'' |
| trimmed_300000  |   600000 |     521757 |     0.8696 |       1929 |    4219608 |     2807 | 0:00'38'' |
| trimmed_400000  |   800000 |     696091 |     0.8701 |       3217 |    4489686 |     2015 | 0:00'45'' |
| trimmed_500000  |  1000000 |     870219 |     0.8702 |       4826 |    4593095 |     1466 | 0:00'51'' |
| trimmed_600000  |  1200000 |    1044371 |     0.8703 |       6204 |    4635123 |     1234 | 0:00'54'' |
| trimmed_700000  |  1400000 |    1218533 |     0.8704 |       7446 |    4672184 |     1018 | 0:01'00'' |
| trimmed_800000  |  1600000 |    1392905 |     0.8706 |       9128 |    4632718 |      856 | 0:01'04'' |
| trimmed_900000  |  1800000 |    1566381 |     0.8702 |      10259 |    4673694 |      791 | 0:01'11'' |
| trimmed_1000000 |  2000000 |    1740419 |     0.8702 |      10559 |    4733976 |      763 | 0:01'33'' |
| trimmed_1200000 |  2400000 |    2088409 |     0.8702 |      12027 |    4710164 |      667 | 0:01'56'' |
| trimmed_1400000 |  2800000 |    2436968 |     0.8703 |      12340 |    4863197 |      656 | 0:01'56'' |
| trimmed_1600000 |  3200000 |    2786123 |     0.8707 |      13165 |    4993748 |      626 | 0:02'10'' |
| trimmed_1800000 |  3600000 |    3134393 |     0.8707 |      13196 |    5154972 |      633 | 0:02'20'' |
| trimmed_2000000 |  4000000 |    3483619 |     0.8709 |      11633 |    5415874 |      707 | 0:02'51'' |
| trimmed_3000000 |  6000000 |    5230146 |     0.8717 |       6875 |    6492636 |     1273 | 0:03'32'' |
| filter_50000    |   100000 |      81131 |     0.8113 |        595 |     122206 |      195 | 0:00'18'' |
| filter_100000   |   200000 |     172366 |     0.8618 |        721 |    1150044 |     1543 | 0:00'25'' |
| filter_150000   |   300000 |     259771 |     0.8659 |        914 |    2395399 |     2651 | 0:00'30'' |
| filter_200000   |   400000 |     347132 |     0.8678 |       1168 |    3273585 |     3044 | 0:00'33'' |
| filter_300000   |   600000 |     521019 |     0.8684 |       1888 |    4041838 |     2670 | 0:00'37'' |
| filter_400000   |   800000 |     694980 |     0.8687 |       2742 |    4333664 |     2173 | 0:00'46'' |
| filter_500000   |  1000000 |     868212 |     0.8682 |       3695 |    4450384 |     1815 | 0:00'55'' |
| filter_600000   |  1200000 |    1041182 |     0.8677 |       4406 |    4504192 |     1583 | 0:01'00'' |
| filter_700000   |  1400000 |    1215366 |     0.8681 |       5086 |    4566808 |     1414 | 0:01'06'' |
| filter_800000   |  1600000 |    1388985 |     0.8681 |       5949 |    4581590 |     1279 | 0:01'11'' |
| filter_900000   |  1800000 |    1562937 |     0.8683 |       6350 |    4583115 |     1176 | 0:01'18'' |
| filter_1000000  |  2000000 |    1736651 |     0.8683 |       6778 |    4606031 |     1113 | 0:01'28'' |
| filter_1200000  |  2400000 |    2083345 |     0.8681 |       7672 |    4625916 |     1002 | 0:01'45'' |
| filter_1400000  |  2800000 |    2431625 |     0.8684 |       7950 |    4683836 |      959 | 0:01'57'' |
| filter_1600000  |  3200000 |    2779359 |     0.8685 |       8483 |    4767330 |      920 | 0:02'14'' |
| filter_1800000  |  3600000 |    3126804 |     0.8686 |       9071 |    4889774 |      894 | 0:02'19'' |
| filter_2000000  |  4000000 |    3475124 |     0.8688 |       8564 |    4961809 |      915 | 0:02'39'' |
| filter_3000000  |  4914436 |    4271274 |     0.8691 |       7813 |    5293577 |     1019 | 0:03'04'' |

| Name            | N50Anchor | SumAnchor | #anchor | N50Anchor2 | SumAnchor2 | #anchor2 | N50Others | SumOthers | #others |
|:----------------|----------:|----------:|--------:|-----------:|-----------:|---------:|----------:|----------:|--------:|
| MiSeq_50000     |      1541 |      9603 |       7 |       1608 |      12535 |        8 |       649 |    658853 |     992 |
| MiSeq_100000    |      1727 |    600907 |     350 |       1656 |     601579 |      362 |       851 |   2102061 |    2538 |
| MiSeq_150000    |      3308 |   2336702 |     813 |       2421 |    1190194 |      522 |       961 |    866923 |     918 |
| MiSeq_200000    |      6827 |   3046171 |     588 |       6052 |    1296177 |      290 |      2717 |    490444 |     289 |
| MiSeq_300000    |      9071 |   1423880 |     194 |       8458 |    2512566 |      355 |      6342 |   1962134 |     466 |
| MiSeq_400000    |      7464 |    948435 |     154 |       7034 |    2370673 |      387 |      4640 |   3251452 |     931 |
| MiSeq_500000    |      6413 |    826660 |     156 |       5680 |    2008443 |      405 |      3545 |   3896470 |    1355 |
| MiSeq_600000    |      6155 |    898061 |     188 |       4727 |    1737843 |      410 |      2895 |   4034141 |    1723 |
| MiSeq_700000    |      4970 |    657968 |     161 |       4620 |    1568844 |      392 |      2517 |   4625071 |    2224 |
| MiSeq_800000    |      4187 |    609676 |     182 |       3797 |    1529719 |      448 |      2239 |   4685544 |    2472 |
| MiSeq_900000    |      3644 |    644239 |     209 |       3680 |    1355569 |      414 |      2082 |   4891034 |    2754 |
| MiSeq_1000000   |      4179 |    561229 |     174 |       3181 |    1174796 |      402 |      1924 |   5138910 |    3157 |
| MiSeq_1200000   |      3236 |    588160 |     228 |       2911 |    1006353 |      370 |      1660 |   5224098 |    3630 |
| MiSeq_1400000   |      2841 |    474673 |     195 |       2712 |     830875 |      338 |      1503 |   5660235 |    4267 |
| MiSeq_1600000   |      2495 |    489866 |     226 |       2442 |     716456 |      301 |      1354 |   5685298 |    4669 |
| MiSeq_1800000   |      1980 |    445549 |     224 |       2288 |     664075 |      292 |      1256 |   5802890 |    5098 |
| MiSeq_2000000   |      1846 |    335185 |     185 |       2291 |     500547 |      220 |      1179 |   6045600 |    5562 |
| MiSeq_3000000   |      1480 |    201344 |     135 |       1973 |     240206 |      118 |       879 |   6461417 |    7436 |
| MiSeq_4000000   |      1233 |    106980 |      82 |       1844 |      95541 |       52 |       750 |   6406273 |    8405 |
| MiSeq_5000000   |      1144 |     45286 |      36 |       1921 |      34043 |       18 |       674 |   5924755 |    8527 |
| trimmed_50000   |      1341 |      2427 |       2 |          0 |          0 |        0 |       582 |     34749 |      55 |
| trimmed_100000  |      1210 |     41758 |      33 |       1145 |       7530 |        6 |       634 |    678782 |    1046 |
| trimmed_150000  |      1323 |    558694 |     405 |       1335 |      44877 |       32 |       689 |   1536992 |    2237 |
| trimmed_200000  |      1490 |   1489066 |     964 |       1876 |     116851 |       67 |       722 |   1617326 |    2275 |
| trimmed_300000  |      2339 |   3050835 |    1427 |       2956 |     202637 |       74 |       767 |    966136 |    1306 |
| trimmed_400000  |      3597 |   3740248 |    1297 |       4327 |     237291 |       68 |       799 |    512147 |     650 |
| trimmed_500000  |      5048 |   3983657 |    1046 |       5228 |     307715 |       73 |       835 |    301723 |     347 |
| trimmed_600000  |      6586 |   4075101 |     893 |       5669 |     287087 |       62 |       875 |    272935 |     279 |
| trimmed_700000  |      7751 |   4044093 |     756 |       7137 |     400749 |       69 |       976 |    227342 |     193 |
| trimmed_800000  |      9660 |   4213439 |     654 |       5229 |     267686 |       58 |       938 |    151593 |     144 |
| trimmed_900000  |     10546 |   4159868 |     607 |       9323 |     369695 |       54 |       964 |    144131 |     130 |
| trimmed_1000000 |     10622 |   4006432 |     559 |      10768 |     560599 |       72 |      1303 |    166945 |     132 |
| trimmed_1200000 |     12127 |   4122218 |     507 |       9570 |     408593 |       59 |      8696 |    179353 |     101 |
| trimmed_1400000 |     11951 |   3531473 |     435 |      14136 |    1067727 |      109 |      6703 |    263997 |     112 |
| trimmed_1600000 |     12947 |   3417092 |     389 |      13469 |    1115760 |      111 |     14881 |    460896 |     126 |
| trimmed_1800000 |     13129 |   3039405 |     350 |      13463 |    1660072 |      151 |     11415 |    455495 |     132 |
| trimmed_2000000 |     12940 |   2644582 |     309 |      10843 |    1832260 |      200 |     10479 |    939032 |     198 |
| trimmed_3000000 |      7936 |   1294991 |     215 |       8079 |    2558717 |      389 |      5265 |   2638928 |     669 |
| filter_50000    |      1522 |      2822 |       2 |          0 |          0 |        0 |       592 |    119384 |     193 |
| filter_100000   |      1382 |    199541 |     142 |       1362 |      30418 |       22 |       663 |    920085 |    1379 |
| filter_150000   |      1522 |    891141 |     576 |       1407 |      87219 |       55 |       712 |   1417039 |    2020 |
| filter_200000   |      1752 |   1653897 |     947 |       1725 |     174379 |       97 |       737 |   1445309 |    2000 |
| filter_300000   |      2413 |   2814425 |    1278 |       2917 |     273811 |      113 |       765 |    953602 |    1279 |
| filter_400000   |      3226 |   3415619 |    1267 |       4025 |     298284 |       96 |       781 |    619761 |     810 |
| filter_500000   |      4090 |   3722090 |    1182 |       4562 |     284397 |       84 |       824 |    443897 |     549 |
| filter_600000   |      4857 |   3914527 |    1085 |       4150 |     252759 |       75 |       801 |    336906 |     423 |
| filter_700000   |      5532 |   3968864 |     982 |       4723 |     278249 |       71 |       843 |    319695 |     361 |
| filter_800000   |      6316 |   4007930 |     907 |       4971 |     292877 |       68 |       863 |    280783 |     304 |
| filter_900000   |      6811 |   4004008 |     850 |       5842 |     333083 |       72 |       897 |    246024 |     254 |
| filter_1000000  |      7186 |   4070900 |     810 |       5631 |     290939 |       62 |       892 |    244192 |     241 |
| filter_1200000  |      8246 |   4106301 |     745 |       5712 |     303164 |       60 |       954 |    216451 |     197 |
| filter_1400000  |      8396 |   3988094 |     696 |       7121 |     463475 |       80 |      1299 |    232267 |     183 |
| filter_1600000  |      8532 |   3744388 |     638 |       8539 |     746461 |      109 |      3984 |    276481 |     173 |
| filter_1800000  |      8766 |   3551383 |     585 |      10858 |    1031334 |      128 |      3987 |    307057 |     181 |
| filter_2000000  |      8462 |   3381543 |     559 |      10571 |    1152486 |      147 |      4628 |    427780 |     209 |
| filter_3000000  |      8144 |   2719069 |     475 |       8639 |    1713732 |      247 |      5672 |    860776 |     297 |

Clear intermediate files.

```bash
# masurca
find . -type f -name "quorum_mer_db.jf" | xargs rm
find . -type f -name "k_u_hash_0" | xargs rm
#find . -type f -name "pe.linking.fa" | xargs rm
find . -type f -name "pe.linking.frg" | xargs rm
find . -type f -name "superReadSequences_shr.frg" | xargs rm
find . -type f -name "readPositionsInSuperReads" | xargs rm
find . -type f -name "*.tmp" | xargs rm
#find . -type f -name "pe.renamed.fastq" | xargs rm

```

### E. coli: Quality assessment

http://www.opiniomics.org/generate-a-single-contig-hybrid-assembly-of-e-coli-using-miseq-and-minion-data/

```bash
cd ~/data/dna-seq/e_coli/superreads/

# simplify header
cat MiSeq/NC_000913.fa \
    | perl -nl -e '
        /^>(\w+)/ and print qq{>$1} and next;
        print;
    ' \
    > NC_000913.fa

for part in anchor anchor2 others;
do 
    bash ~/Scripts/sra/sort_on_ref.sh trimmed_800000/sr/pe.${part}.fa NC_000913.fa pe.${part}
    nucmer -l 200 NC_000913.fa pe.${part}.fa
    mummerplot -png out.delta -p pe.${part} --medium
done

#brew install mummer
#brew install homebrew/versions/gnuplot4

cp ~/data/pacbio/ecoli_p6c4/2-asm-falcon/p_ctg.fa falcon.fa

nucmer -l 200 NC_000913.fa falcon.fa
mummerplot -png out.delta -p falcon --medium

# mummerplot files
rm *.[fr]plot
rm out.delta
rm *.gp
```

Overlap--Layout of anchors

```bash
cd ~/data/dna-seq/e_coli/superreads/

faops filter -a 500 -l 0 trimmed_800000/sr/superReadSequences.fasta SR.filter.fasta
bash ~/Scripts/sra/overlap.sh SR.filter.fasta 500 .96 SR.ovlp.tsv
#faops some -i -l 0 SR.filter.fasta SR.discard.txt SR.discard.fasta
#bash ~/Scripts/sra/overlap.sh SR.discard.fasta 500 .96 SR.ovlp.tsv

bash ~/Scripts/sra/overlap.sh trimmed_800000/sr/pe.anchor.fa 500 .96 overlap.anchor.ovlp.tsv
bash ~/Scripts/sra/overlap.sh trimmed_800000/sr/pe.anchor2.fa 500 .96 overlap.anchor2.ovlp.tsv
bash ~/Scripts/sra/overlap.sh trimmed_800000/sr/pe.others.fa 500 0.96 overlap.others.ovlp.tsv

cat trimmed_800000/sr/pe.anchor.fa trimmed_800000/sr/pe.others.fa > temp.fasta
bash ~/Scripts/sra/overlap.sh temp.fasta 500 .96 overlap.anchor_others.ovlp.tsv
rm temp.fasta

cat trimmed_800000/sr/pe.anchor.fa trimmed_800000/sr/pe.anchor2.fa > temp.fasta
bash ~/Scripts/sra/overlap.sh temp.fasta 500 .96 overlap.anchor_anchor2.ovlp.tsv
rm temp.fasta

cat trimmed_800000/sr/pe.anchor2.fa trimmed_800000/sr/pe.others.fa > temp.fasta
bash ~/Scripts/sra/overlap.sh temp.fasta 500 .96 overlap.anchor2_others.ovlp.tsv
rm temp.fasta

```

### E. coli: link anchors

```bash
cd ~/zlc/Ecoli/anchorAlign

bash ~/Scripts/sra/link_anchor.sh 1_4.anchor.fasta 1_4.pac.fasta 1_4
bash ~/Scripts/sra/link_anchor.sh 0_11.anchor.fasta 0_11.pac.fasta 0_11
bash ~/Scripts/sra/link_anchor.sh 6_56.anchor.fasta 6_56.pac.fasta 6_56

# Exceeded memory bound: 502169772
#poa -preserve_seqorder -read_fasta 9_2.renamed.fasta -clustal 9_2.aln -hb ~/Scripts/sra/poa-blosum80.mat 

#cp 9_2.renamed.fasta myDB.pp.fasta
#
#DBrm myDB
#fasta2DB myDB myDB.pp.fasta
#DBdust myDB
#
#if [ -e myDB.las ]; then
#    rm myDB.las
#fi
#HPC.daligner myDB -v -M4 -e.70 -l1000 -s1000 -mdust > job.sh
#bash job.sh
#rm job.sh
#
#LA4Falcon -o myDB.db myDB.las 1-2
#
#perl ~/Scripts/sra/las2ovlp.pl 9_2.renamed.fasta <(LAshow -o myDB.db myDB.las 1)
#
#perl ~/Scripts/sra/las2ovlp.pl 9_2.renamed.fasta 9_2.show.txt -r 9_2.replace.tsv


perl ~/Scripts/sra/las2ovlp.pl 1_4.renamed.fasta 1_4.show.txt > 1_4.ovlp.tsv
perl ~/Scripts/sra/ovlp_layout.pl 1_4.ovlp.tsv --range 1-4

# 3 5 10 8 4 9 7 2 11 6 1
perl ~/Scripts/egaz/sparsemem_exact.pl \
    -f 0_11.renamed.fasta -g ~/data/dna-seq/e_coli/superreads/NC_000913.fa \
    --length 500 -o 0_11.chr.tsv
perl ~/Scripts/sra/las2ovlp.pl 0_11.renamed.fasta 0_11.show.txt > 0_11.ovlp.tsv
perl ~/Scripts/sra/ovlp_layout.pl 0_11.ovlp.tsv --range 1-11

# 16 47 19 51 28 22 15 11 43 5 34 44 4 37 6 9 53 24 40 52 46 23 32 38 55 54 18 31 10 26 2 8 48 36 27 29 30 45 50 33 35 42 41 3 25 20 17 14 7 56 21 13 39 49 12 1
perl ~/Scripts/egaz/sparsemem_exact.pl \
    -f 6_56.renamed.fasta -g ~/data/dna-seq/e_coli/superreads/NC_000913.fa \
    --length 500 -o 6_56.chr.tsv
perl ~/Scripts/sra/las2ovlp.pl 6_56.renamed.fasta 6_56.show.txt > 6_56.ovlp.tsv
perl ~/Scripts/sra/ovlp_layout.pl 6_56.ovlp.tsv --range 1-56



# pip install pysam biopython
python ~/Scripts/sra/nanocorrect.py myDB all > corrected.fasta

```

## Scer S288c

酿酒酵母的 paralog 比例为 0.058.

* Real:

    * S: 12,157,105

* Original:

    * N50: 151
    * S: 1,469,540,607
    * C: 9,732,057

* Trimmed:

    * N50: 151
    * S: 1,336,727,027
    * C: 8,884,270

```bash
# genome
mkdir -p ~/data/dna-seq/scer_yjx_2016/ref
cat ~/data/alignment/Ensembl/S288c/{I,II,III,IV,V,VI,VII,VIII,IX,X,XI,XII,XIII,XIV,XV,XVI}.fa \
    ~/data/alignment/Ensembl/S288c/Mito.fa.skip \
    > ~/data/dna-seq/scer_yjx_2016/ref/genome.fa
faops size ~/data/dna-seq/scer_yjx_2016/ref/genome.fa \
    > ~/data/dna-seq/scer_yjx_2016/ref/chr.sizes

faops n50 -S -C ~/data/dna-seq/scer_yjx_2016/ref/genome.fa

# ENA hasn't synced with SRA for PRJNA340312
# Downloading with prefetch from sratoolkit
mkdir -p ~/data/dna-seq/scer_yjx_2016/sra
cd ~/data/dna-seq/scer_yjx_2016/sra
prefetch --progress 0.5 SRR4074255

mkdir -p ~/data/dna-seq/scer_yjx_2016/process/S288c
fastq-dump SRR4074255 \
    --split-files \
    -O ~/data/dna-seq/scer_yjx_2016/process/S288c/SRR4074255

find ~/data/dna-seq/scer_yjx_2016/process/ -type f -name "*.fastq" | parallel -j 1 pigz -p 8

cd ~/data/dna-seq/scer_yjx_2016/process/S288c/SRR4074255
fastqc -t 8 \
    SRR4074255_1.fastq.gz \
    SRR4074255_2.fastq.gz

# trim
cat <<EOF > ~/data/dna-seq/scer_yjx_2016/ref/illumina_adapters.fa
>multiplexing-forward
GATCGGAAGAGCACACGTCT
>solexa-forward
AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT
>truseq-forward-contam
AGATCGGAAGAGCACACGTCTGAACTCCAGTCAC
>truseq-reverse-contam
AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGTA
>nextera-forward-read-contam
CTGTCTCTTATACACATCTCCGAGCCCACGAGAC
>nextera-reverse-read-contam
CTGTCTCTTATACACATCTGACGCTGCCGACGA
>solexa-reverse
AGATCGGAAGAGCGGTTCAGCAGGAATGCCGAG

EOF

mkdir -p ~/data/dna-seq/scer_yjx_2016/process/S288c/SRR4074255/trimmed
cd ~/data/dna-seq/scer_yjx_2016/process/S288c/SRR4074255

# scythe (pair end)
scythe \
    SRR4074255_1.fastq.gz \
    -q sanger \
    -M 20 \
    -a ~/data/dna-seq/scer_yjx_2016/ref/illumina_adapters.fa \
    -m trimmed/R1.matches.txt \
    --quiet \
    | pigz -p 8 -c \
    > trimmed/R1.scythe.fq.gz

scythe \
    SRR4074255_2.fastq.gz \
    -q sanger \
    -M 20 \
    -a ~/data/dna-seq/scer_yjx_2016/ref/illumina_adapters.fa \
    -m trimmed/R2.matches.txt \
    --quiet \
    | pigz -p 8 -c \
    > trimmed/R2.scythe.fq.gz

# sickle (pair end)
#FastQ paired records kept: 17768540 (8884270 pairs)
#FastQ single records kept: 488931 (from PE1: 443998, from PE2: 44933)
#FastQ paired records discarded: 717712 (358856 pairs)
#FastQ single records discarded: 488931 (from PE1: 44933, from PE2: 443998)
sickle pe \
    -t sanger -l 120 -q 20 \
    -f trimmed/R1.scythe.fq.gz \
    -r trimmed/R2.scythe.fq.gz \
    -o trimmed/R1.sickle.fq \
    -p trimmed/R2.sickle.fq \
    -s trimmed/single.sickle.fq

find . -type f -name "*.sickle.fq" | parallel -j 1 pigz -p 8

fastqc -t 8 \
    trimmed/R1.sickle.fq.gz \
    trimmed/R2.sickle.fq.gz \
    trimmed/single.sickle.fq.gz

# 
faops n50 -S -C ~/data/dna-seq/scer_yjx_2016/process/S288c/SRR4074255/SRR4074255_1.fastq.gz

faops n50 -S -C ~/data/dna-seq/scer_yjx_2016/process/S288c/SRR4074255/trimmed/R1.sickle.fq.gz

# clean
find . -type d -name "*fastqc" | sort | xargs rm -fr
find . -type f -name "*_fastqc.zip" | sort | xargs rm
find . -type f -name "*matches.txt" | sort | xargs rm

```

### S288c: Down sampling

* Original

```bash
midir -p ~/data/dna-seq/scer_yjx_2016/superreads/
cd ~/data/dna-seq/scer_yjx_2016/superreads/

for count in 500000 1000000 1500000 2000000 3000000 4000000 5000000 6000000 7000000 8000000;
do
    echo
    echo "==> Reads ${count}"
    DIR_COUNT="$HOME/data/dna-seq/scer_yjx_2016/superreads/original_${count}/"
    mkdir -p ${DIR_COUNT}
    
    if [ -e ${DIR_COUNT}/R1.fq.gz ]; then
        continue     
    fi
    
    seqtk sample -s${count} \
        ~/data/dna-seq/scer_yjx_2016/process/S288c/SRR4074255/SRR4074255_1.fastq.gz ${count} \
        | pigz -p 8 > ${DIR_COUNT}/R1.fq.gz
    seqtk sample -s${count} \
        ~/data/dna-seq/scer_yjx_2016/process/S288c/SRR4074255/SRR4074255_2.fastq.gz ${count} \
        | pigz -p 8 > ${DIR_COUNT}/R2.fq.gz
done
```

* Trimmed

```bash
midir -p ~/data/dna-seq/scer_yjx_2016/superreads/
cd ~/data/dna-seq/scer_yjx_2016/superreads/

for count in 500000 1000000 1500000 2000000 3000000 4000000 5000000 6000000 7000000 8000000;
do
    echo
    echo "==> Reads ${count}"
    DIR_COUNT="$HOME/data/dna-seq/scer_yjx_2016/superreads/trimmed_${count}/"
    mkdir -p ${DIR_COUNT}
    
    if [ -e ${DIR_COUNT}/R1.fq.gz ]; then
        continue     
    fi
    
    seqtk sample -s${count} \
        ~/data/dna-seq/scer_yjx_2016/process/S288c/SRR4074255/trimmed/R1.sickle.fq.gz ${count} \
        | pigz -p 8 > ${DIR_COUNT}/R1.fq.gz
    seqtk sample -s${count} \
        ~/data/dna-seq/scer_yjx_2016/process/S288c/SRR4074255/trimmed/R2.sickle.fq.gz ${count} \
        | pigz -p 8 > ${DIR_COUNT}/R2.fq.gz
done
```

### S288c: Generate super-reads

```bash
BASE_DIR=$HOME/data/dna-seq/scer_yjx_2016/superreads/
cd ${BASE_DIR}

for d in trimmed_{500000,1000000,1500000,2000000,3000000,4000000,5000000,6000000,7000000,8000000};
do
    echo
    echo "==> Reads ${d}"
    DIR_COUNT="${BASE_DIR}/${d}/"

    if [ ! -d ${DIR_COUNT} ]; then
        echo "${DIR_COUNT} doesn't exist"
        continue
    fi
    
    if [ -e ${DIR_COUNT}/pe.cor.fa ]; then
        echo "pe.cor.fa already presents"
        continue
    fi
    
    pushd ${DIR_COUNT} > /dev/null
    perl ~/Scripts/sra/superreads.pl \
        R1.fq.gz \
        R2.fq.gz \
        -s 300 -d 30 -p 16
    popd > /dev/null
done
```

Stats of super-reads

```bash
BASE_DIR=$HOME/data/dna-seq/scer_yjx_2016/superreads/
cd ${BASE_DIR}

REAL_G=12157105

bash ~/Scripts/sra/sr_stat.sh 1 header \
    > ${BASE_DIR}/stat1.md

bash ~/Scripts/sra/sr_stat.sh 2 header \
    > ${BASE_DIR}/stat2.md

for d in trimmed_{500000,1000000,1500000,2000000,3000000,4000000,5000000,6000000,7000000,8000000};
do
    DIR_COUNT="${BASE_DIR}/${d}/"
    
    if [ ! -d ${DIR_COUNT} ]; then
        continue     
    fi
    
    bash ~/Scripts/sra/sr_stat.sh 1 ${DIR_COUNT} \
        >> ${BASE_DIR}/stat1.md
    
    bash ~/Scripts/sra/sr_stat.sh 2 ${DIR_COUNT} ${REAL_G} \
        >> ${BASE_DIR}/stat2.md
done

cat stat1.md
cat stat2.md
```

### S288c: Create anchors

```bash
BASE_DIR=$HOME/data/dna-seq/scer_yjx_2016/superreads/
cd ${BASE_DIR}

for d in trimmed_{500000,1000000,1500000,2000000,3000000,4000000,5000000,6000000,7000000,8000000};
do
    echo
    echo "==> Reads ${d}"
    DIR_COUNT="${BASE_DIR}/${d}/"

    if [ -e ${DIR_COUNT}/sr/pe.anchor.fa ]; then
        continue     
    fi
    
    rm -fr ${DIR_COUNT}/sr
    bash ~/Scripts/sra/anchor.sh ${DIR_COUNT} 16 false 120
done
```

Stats of anchors

```bash
BASE_DIR=$HOME/data/dna-seq/scer_yjx_2016/superreads/
cd ${BASE_DIR}

bash ~/Scripts/sra/sr_stat.sh 3 header \
    > ${BASE_DIR}/stat3.md

bash ~/Scripts/sra/sr_stat.sh 4 header \
    > ${BASE_DIR}/stat4.md

for d in trimmed_{500000,1000000,1500000,2000000,3000000,4000000,5000000,6000000,7000000,8000000};
do
    DIR_COUNT="${BASE_DIR}/${d}/"
    
    if [ ! -e ${DIR_COUNT}/sr/pe.anchor.fa ]; then
        continue     
    fi
    
    bash ~/Scripts/sra/sr_stat.sh 3 ${DIR_COUNT} \
        >> ${BASE_DIR}/stat3.md
    
    bash ~/Scripts/sra/sr_stat.sh 4 ${DIR_COUNT} \
        >> ${BASE_DIR}/stat4.md
done

cat stat3.md
cat stat4.md
```

### Results of S288c

| Name             | fqSize | faSize | Length | Kmer |     EstG |  #reads |   RunTime |    SumSR | SR/EstG |
|:-----------------|-------:|-------:|-------:|-----:|---------:|--------:|----------:|---------:|--------:|
| trimmed_500000   |   301M |   157M |    150 |  105 | 11034416 |  250510 | 0:01'59'' | 12898029 |    1.17 |
| trimmed_1000000  |   602M |   315M |    150 |  105 | 11428932 |  190203 | 0:02'32'' | 13133447 |    1.15 |
| trimmed_1500000  |   903M |   473M |    150 |  105 | 11542383 |  190368 | 0:03'29'' | 13424947 |    1.16 |
| trimmed_2000000  |   1.2G |   631M |    150 |  105 | 11614920 |  223292 | 0:03'58'' | 14198101 |    1.22 |
| trimmed_3000000  |   1.8G |   947M |    150 |  105 | 11701994 |  318891 | 0:05'29'' | 16554333 |    1.41 |
| trimmed_4000000  |   2.4G |   1.3G |    150 |  105 | 11807365 |  456704 | 0:06'50'' | 19981222 |    1.69 |
| trimmed_5000000  |   3.0G |   1.6G |    150 |  105 | 11924055 |  632872 | 0:08'09'' | 24101433 |    2.02 |
| trimmed_6000000  |   3.6G |   1.9G |    150 |  105 | 12040201 |  765627 | 0:10'02'' | 26435339 |    2.20 |
| trimmed_7000000  |   4.2G |   2.2G |    150 |  105 | 12162944 |  937582 | 0:12'09'' | 29072350 |    2.39 |
| trimmed_8000000  |   4.8G |   2.5G |    150 |  105 | 12276451 | 1105794 | 0:13'13'' | 30960737 |    2.52 |

| Name             | TotalFq | TotalFa | RatioDiscard | TotalSubs | RatioSubs |  RealG | CovFq | CovFa |   EstG |  SumSR | Est/Real | SumSR/Real | N50SR |
|:-----------------|--------:|--------:|-------------:|----------:|----------:|-------:|------:|------:|-------:|-------:|---------:|-----------:|------:|
| trimmed_500000   | 143.38M | 142.94M |       0.0031 |   131.21K |    0.0009 | 11.59M |  12.4 |  12.3 | 10.52M |  12.3M |     0.91 |       1.06 |   527 |
| trimmed_1000000  | 286.75M | 286.12M |       0.0022 |   258.58K |    0.0009 | 11.59M |  24.7 |  24.7 |  10.9M | 12.53M |     0.94 |       1.08 |  1657 |
| trimmed_1500000  | 430.12M | 429.26M |       0.0020 |   386.37K |    0.0009 | 11.59M |  37.1 |  37.0 | 11.01M |  12.8M |     0.95 |       1.10 |  2911 |
| trimmed_2000000  | 573.49M | 572.42M |       0.0019 |    510.7K |    0.0009 | 11.59M |  49.5 |  49.4 | 11.08M | 13.54M |     0.96 |       1.17 |  4099 |
| trimmed_3000000  | 860.24M | 858.67M |       0.0018 |    764.3K |    0.0009 | 11.59M |  74.2 |  74.1 | 11.16M | 15.79M |     0.96 |       1.36 |  6382 |
| trimmed_4000000  |   1.12G |   1.12G |       0.0018 | 1,007.88K |    0.0009 | 11.59M |  98.9 |  98.8 | 11.26M | 19.06M |     0.97 |       1.64 |  7282 |
| trimmed_5000000  |    1.4G |    1.4G |       0.0017 |     1.22M |    0.0009 | 11.59M | 123.7 | 123.5 | 11.37M | 22.98M |     0.98 |       1.98 |  7492 |
| trimmed_6000000  |   1.68G |   1.68G |       0.0017 |     1.45M |    0.0008 | 11.59M | 148.4 | 148.1 | 11.48M | 25.21M |     0.99 |       2.17 |  6729 |
| trimmed_7000000  |   1.96G |   1.96G |       0.0016 |     1.68M |    0.0008 | 11.59M | 173.1 | 172.8 |  11.6M | 27.73M |     1.00 |       2.39 |  6202 |
| trimmed_8000000  |   2.24G |   2.24G |       0.0016 |     1.91M |    0.0008 | 11.59M | 197.9 | 197.5 | 11.71M | 29.53M |     1.01 |       2.55 |  5437 |

| Name            |  #cor.fa | #strict.fa | strict/cor | N50SRclean | SumSRclean | #SRclean |   RunTime |
|:----------------|---------:|-----------:|-----------:|-----------:|-----------:|---------:|----------:|
| trimmed_500000  |  1000000 |     910443 |     0.9104 |        874 |    6537127 |     7664 | 0:00'48'' |
| trimmed_1000000 |  2000000 |    1823622 |     0.9118 |       1941 |   10707277 |     6843 | 0:01'19'' |
| trimmed_1500000 |  3000000 |    2738489 |     0.9128 |       3310 |   11444989 |     4821 | 0:01'49'' |
| trimmed_2000000 |  4000000 |    3653498 |     0.9134 |       4675 |   11736850 |     3693 | 0:02'14'' |
| trimmed_3000000 |  6000000 |    5481874 |     0.9136 |       7619 |   12468434 |     2663 | 0:03'25'' |
| trimmed_4000000 |  8000000 |    7315989 |     0.9145 |       8507 |   13321848 |     2485 | 0:04'45'' |
| trimmed_5000000 | 10000000 |    9153451 |     0.9153 |       9196 |   14799781 |     2554 | 0:05'18'' |
| trimmed_6000000 | 12000000 |   10992524 |     0.9160 |       8388 |   15369788 |     2799 | 0:06'35'' |
| trimmed_7000000 | 14000000 |   12834735 |     0.9168 |       7729 |   16396488 |     3139 | 0:07'38'' |
| trimmed_8000000 | 16000000 |   14676723 |     0.9173 |       6846 |   17047880 |     3517 | 0:08'28'' |

| Name            | N50Anchor | SumAnchor | #anchor | N50Anchor2 | SumAnchor2 | #anchor2 | N50Others | SumOthers | #others |
|:----------------|----------:|----------:|--------:|-----------:|-----------:|---------:|----------:|----------:|--------:|
| trimmed_500000  |      1352 |   2247653 |    1630 |       1355 |      79904 |       54 |       714 |   4209570 |    5980 |
| trimmed_1000000 |      2274 |   8534438 |    4067 |       1986 |     170628 |       88 |       777 |   2002211 |    2688 |
| trimmed_1500000 |      3581 |  10008459 |    3355 |       3296 |     387820 |      138 |       809 |   1048710 |    1328 |
| trimmed_2000000 |      4928 |  10211595 |    2632 |       5006 |     712079 |      175 |       884 |    813176 |     886 |
| trimmed_3000000 |      7798 |   8941073 |    1611 |       8855 |    2516810 |      377 |      2357 |   1010551 |     675 |
| trimmed_4000000 |      8665 |   7222811 |    1114 |       9617 |    4253093 |      557 |      4820 |   1845944 |     814 |
| trimmed_5000000 |      9386 |   5058395 |     753 |      10304 |    6277715 |      770 |      6903 |   3463671 |    1031 |
| trimmed_6000000 |     10272 |   4290571 |     595 |       9132 |    6519695 |      869 |      6063 |   4559522 |    1335 |
| trimmed_7000000 |      9514 |   3248847 |     475 |       8780 |    6741632 |      919 |      6172 |   6406009 |    1745 |
| trimmed_8000000 |      8760 |   2763641 |     433 |       7983 |    6570759 |      964 |      5467 |   7713480 |    2120 |

### S288c: Quality assessment

```bash
cd ~/data/dna-seq/scer_yjx_2016/superreads/

for part in anchor anchor2 others;
do 
    bash ~/Scripts/sra/sort_on_ref.sh trimmed_4000000/sr/pe.${part}.fa ../ref/genome.fa pe.${part}
    nucmer -l 200 ../ref/genome.fa pe.${part}.fa
    mummerplot -png out.delta -p pe.${part} --medium
done

# mummerplot files
rm *.[fr]plot
rm out.delta
rm *.gp
```

## Dmel iso-1 (ycnbwsp), SRR306628

果蝇的 paralog 比例为 0.0531.

* Real:

    * N50: 25,286,936
    * S: 137,567,477
    * C: 8

* Original:

    * N50: 146
    * S: 6,426,336,000
    * C: 44,016,000

* Trimmed:

    * N50: 146
    * S: 3,675,899,439
    * C: 25,742,237

```bash
# genome
mkdir -p ~/data/dna-seq/dmel_iso_1/ref
cat ~/data/alignment/Ensembl/Dmel/{2L,2R,3L,3R,X}.fa \
    ~/data/alignment/Ensembl/Dmel/4.fa.skip \
    ~/data/alignment/Ensembl/Dmel/Y.fa.skip \
    ~/data/alignment/Ensembl/Dmel/dmel_mitochondrion_genome.fa.skip \
    > ~/data/dna-seq/dmel_iso_1/ref/genome.fa
faops size ~/data/dna-seq/dmel_iso_1/ref/genome.fa \
    > ~/data/dna-seq/dmel_iso_1/ref/chr.sizes

faops n50 -S -C ~/data/dna-seq/dmel_iso_1/ref/genome.fa

# sickle (pair end)
#FastQ paired records kept: 51484474 (25742237 pairs)
#FastQ single records kept: 11634965 (from PE1: 8163557, from PE2: 3471408)
#FastQ paired records discarded: 13277596 (6638798 pairs)
#FastQ single records discarded: 11634965 (from PE1: 3471408, from PE2: 8163557)

cd ~/data/dna-seq/dmel_iso_1/process/ycnbwsp_3-HE/SRR306628/
sickle pe \
    -t sanger -l 120 -q 20 \
    -f trimmed/SRR306628_1.scythe.fq.gz \
    -r trimmed/SRR306628_2.scythe.fq.gz \
    -o trimmed/R1.sickle.fq \
    -p trimmed/R2.sickle.fq \
    -s trimmed/single.sickle.fq

find . -type f -name "*.sickle.fq" | parallel -j 1 pigz -p 8

fastqc -t 8 \
    trimmed/R1.sickle.fq.gz \
    trimmed/R2.sickle.fq.gz \
    trimmed/single.sickle.fq.gz

# 
faops n50 -S -C ~/data/dna-seq/dmel_iso_1/process/ycnbwsp_3-HE/SRR306628/SRR306628_1.fastq.gz

faops n50 -S -C ~/data/dna-seq/dmel_iso_1/process/ycnbwsp_3-HE/SRR306628/trimmed/R1.sickle.fq.gz

# clean
find . -type d -name "*fastqc" | sort | xargs rm -fr
find . -type f -name "*_fastqc.zip" | sort | xargs rm
find . -type f -name "*matches.txt" | sort | xargs rm

```

### Dmel iso-1: Down sampling

* Trimmed

```bash
cd ~/data/dna-seq/dmel_iso_1/superreads/

for count in 5000000 10000000 15000000 20000000 25000000;
do
    echo
    echo "==> Reads ${count}"
    DIR_COUNT="$HOME/data/dna-seq/dmel_iso_1/superreads/trimmed_${count}/"
    mkdir -p ${DIR_COUNT}
    
    if [ -e ${DIR_COUNT}/R1.fq.gz ]; then
        continue     
    fi
    
    seqtk sample -s${count} \
        ~/data/dna-seq/dmel_iso_1/process/ycnbwsp_3-HE/SRR306628/trimmed/R1.sickle.fq.gz ${count} \
        | pigz -p 8 > ${DIR_COUNT}/R1.fq.gz
    seqtk sample -s${count} \
        ~/data/dna-seq/dmel_iso_1/process/ycnbwsp_3-HE/SRR306628/trimmed/R2.sickle.fq.gz ${count} \
        | pigz -p 8 > ${DIR_COUNT}/R2.fq.gz
done
```

### Dmel iso-1: Generate super-reads

```bash
BASE_DIR=$HOME/data/dna-seq/dmel_iso_1/superreads/
cd ${BASE_DIR}

for d in trimmed_{5000000,10000000,15000000,20000000,25000000};
do
    echo
    echo "==> Reads ${d}"
    DIR_COUNT="${BASE_DIR}/${d}/"

    if [ ! -d ${DIR_COUNT} ]; then
        echo "${DIR_COUNT} doesn't exist"
        continue
    fi
    
    if [ -e ${DIR_COUNT}/pe.cor.fa ]; then
        echo "pe.cor.fa already presents"
        continue
    fi
    
    pushd ${DIR_COUNT} > /dev/null
    perl ~/Scripts/sra/superreads.pl \
        R1.fq.gz \
        R2.fq.gz \
        -s 335 -d 33 -p 16
    popd > /dev/null
done
```

Stats of super-reads

```bash
BASE_DIR=$HOME/data/dna-seq/dmel_iso_1/superreads/
cd ${BASE_DIR}

REAL_G=137567477

bash ~/Scripts/sra/sr_stat.sh 1 header \
    > ${BASE_DIR}/stat1.md

bash ~/Scripts/sra/sr_stat.sh 2 header \
    > ${BASE_DIR}/stat2.md

for d in trimmed_{5000000,10000000,15000000,20000000,25000000};
do
    DIR_COUNT="${BASE_DIR}/${d}/"
    
    if [ ! -d ${DIR_COUNT} ]; then
        continue     
    fi
    
    bash ~/Scripts/sra/sr_stat.sh 1 ${DIR_COUNT} \
        >> ${BASE_DIR}/stat1.md
    
    bash ~/Scripts/sra/sr_stat.sh 2 ${DIR_COUNT} ${REAL_G} \
        >> ${BASE_DIR}/stat2.md
done

cat stat1.md
cat stat2.md
```

### Dmel iso-1: Create anchors

```bash
BASE_DIR=$HOME/data/dna-seq/dmel_iso_1/superreads/
cd ${BASE_DIR}

for d in trimmed_{5000000,10000000,15000000,20000000,25000000};
do
    echo
    echo "==> Reads ${d}"
    DIR_COUNT="${BASE_DIR}/${d}/"

    if [ -e ${DIR_COUNT}/sr/pe.anchor.fa ]; then
        continue     
    fi
    
    rm -fr ${DIR_COUNT}/sr
    bash ~/Scripts/sra/anchor.sh ${DIR_COUNT} 16 false 80
done
```

Stats of anchors

```bash
BASE_DIR=$HOME/data/dna-seq/dmel_iso_1/superreads/
cd ${BASE_DIR}

bash ~/Scripts/sra/sr_stat.sh 3 header \
    > ${BASE_DIR}/stat3.md

bash ~/Scripts/sra/sr_stat.sh 4 header \
    > ${BASE_DIR}/stat4.md

for d in trimmed_{5000000,10000000,15000000,20000000,25000000};
do
    DIR_COUNT="${BASE_DIR}/${d}/"
    
    if [ ! -e ${DIR_COUNT}/sr/pe.anchor.fa ]; then
        continue     
    fi
    
    bash ~/Scripts/sra/sr_stat.sh 3 ${DIR_COUNT} \
        >> ${BASE_DIR}/stat3.md
    
    bash ~/Scripts/sra/sr_stat.sh 4 ${DIR_COUNT} \
        >> ${BASE_DIR}/stat4.md
done

cat stat3.md
cat stat4.md
```

### Results of Dmel iso-1, SRR306628

| Name             | fqSize | faSize | Length | Kmer |      EstG |  #reads |   RunTime |     SumSR | SR/EstG |
|:-----------------|-------:|-------:|-------:|-----:|----------:|--------:|----------:|----------:|--------:|
| trimmed_5000000  |   2.8G |   1.5G |    140 |   95 | 101616171 | 2011642 | 0:10'43'' | 118886672 |    1.17 |
| trimmed_10000000 |   5.6G |   3.0G |    139 |   93 | 116605924 | 2410962 | 0:18'05'' | 150111568 |    1.29 |
| trimmed_15000000 |   8.4G |   4.5G |    139 |   93 | 123211364 | 2965273 | 0:28'16'' | 171076322 |    1.39 |
| trimmed_20000000 |    12G |   5.9G |    138 |   91 | 127406531 | 3568605 | 0:39'55'' | 193257821 |    1.52 |
| trimmed_25000000 |    14G |   7.4G |    137 |   91 | 130471378 | 4310106 | 0:46'54'' | 214192281 |    1.64 |

| Name             | TotalFq | TotalFa | RatioDiscard | TotalSubs | RatioSubs |   RealG | CovFq | CovFa |    EstG |   SumSR | Est/Real | SumSR/Real | N50SR |
|:-----------------|--------:|--------:|-------------:|----------:|----------:|--------:|------:|------:|--------:|--------:|---------:|-----------:|------:|
| trimmed_5000000  |   1.32G |   1.29G |       0.0191 |     1.95M |    0.0015 | 131.19M |  10.3 |  10.1 |  96.91M | 113.38M |     0.74 |       0.86 |   508 |
| trimmed_10000000 |   2.64G |   2.61G |       0.0102 |     3.88M |    0.0015 | 131.19M |  20.6 |  20.4 |  111.2M | 143.16M |     0.85 |       1.09 |   976 |
| trimmed_15000000 |   3.96G |   3.93G |       0.0080 |     5.78M |    0.0014 | 131.19M |  30.9 |  30.7 |  117.5M | 163.15M |     0.90 |       1.24 |  1386 |
| trimmed_20000000 |   5.28G |   5.24G |       0.0070 |     7.64M |    0.0014 | 131.19M |  41.2 |  40.9 |  121.5M | 184.31M |     0.93 |       1.40 |  1785 |
| trimmed_25000000 |    6.6G |   6.56G |       0.0065 |     9.47M |    0.0014 | 131.19M |  51.5 |  51.2 | 124.43M | 204.27M |     0.95 |       1.56 |  1953 |

| Name             |  #cor.fa | #strict.fa | strict/cor | N50SRclean | SumSRclean | #SRclean |   RunTime |
|:-----------------|---------:|-----------:|-----------:|-----------:|-----------:|---------:|----------:|
| trimmed_5000000  | 10000000 |    8162877 |     0.8163 |       1016 |   55957772 |    56997 | 0:05'41'' |
| trimmed_10000000 | 20000000 |   16496969 |     0.8248 |       1684 |   93432465 |    67558 | 0:10'12'' |
| trimmed_15000000 | 30000000 |   24841652 |     0.8281 |       2261 |  110024617 |    66301 | 0:15'22'' |
| trimmed_20000000 | 40000000 |   33212165 |     0.8303 |       2752 |  145497169 |    78525 | 0:21'47'' |
| trimmed_25000000 | 50000000 |   41599006 |     0.8320 |       2931 |  162689498 |    83709 | 0:24'01'' |

| Name             | N50Anchor | SumAnchor | #anchor | N50Anchor2 | SumAnchor2 | #anchor2 | N50Others | SumOthers | #others |
|:-----------------|----------:|----------:|--------:|-----------:|-----------:|---------:|----------:|----------:|--------:|
| trimmed_5000000  |      1735 |  23055463 |   13157 |       1546 |    2765005 |     1627 |       720 |  30137304 |   42213 |
| trimmed_10000000 |      2387 |  57066971 |   25818 |       2582 |    6370433 |     2839 |       775 |  29815589 |   38626 |
| trimmed_15000000 |      2897 |  69869174 |   27577 |       3872 |   10143524 |     3446 |       832 |  28101755 |   33129 |
| trimmed_20000000 |      3371 |  74347943 |   26426 |       4564 |   15031178 |     4305 |       919 |  29610525 |   30640 |
| trimmed_25000000 |      3598 |  72963479 |   24775 |       4851 |   19465663 |     5126 |      1034 |  34705899 |   31977 |

## Atha Ler-0-2, SRR611087

拟南芥的 paralog 比例为 0.1115.

* Real:

    * S: 119,667,750

* Original:

    * N50: 100
    * S: 5,079,145,000
    * C: 50,791,450

* Trimmed, 80-100 bp

    * N50: 100
    * S: 4,941,998,283
    * C: 50,161,122


```bash
cd ~/data/dna-seq/atha_ler_0/process/Ler-0-2/SRR611087/

# sickle (pair end)
#FastQ paired records kept: 91969660 (45984830 pairs)
#FastQ single records kept: 4044959 (from PE1: 3144227, from PE2: 900732)
#FastQ paired records discarded: 1523322 (761661 pairs)
#FastQ single records discarded: 4044959 (from PE1: 900732, from PE2: 3144227)
sickle pe \
    -t sanger -l 80 -q 20 \
    -f trimmed/SRR611087_1.scythe.fq.gz \
    -r trimmed/SRR611087_2.scythe.fq.gz \
    -o trimmed/R1.sickle.fq \
    -p trimmed/R2.sickle.fq \
    -s trimmed/single.sickle.fq

find . -type f -name "*.sickle.fq" \
    | parallel --no-run-if-empty -j 1 pigz -p 16

# 
faops n50 -S -C ~/data/dna-seq/atha_ler_0/process/Ler-0-2/SRR611087/SRR611087_1.fastq.gz

faops n50 -S -C ~/data/dna-seq/atha_ler_0/process/Ler-0-2/SRR611087/trimmed/SRR611087_1.sickle.fq.gz

cat ~/data/alignment/Ensembl/Atha/{1,2,3,4,5}.fa \
    ~/data/alignment/Ensembl/Atha/Mt.fa.skip \
    ~/data/alignment/Ensembl/Atha/Pt.fa.skip \
    > ~/data/dna-seq/atha_ler_0/ref/genome.fa
faops size ~/data/dna-seq/atha_ler_0/ref/genome.fa \
    > ~/data/dna-seq/atha_ler_0/ref/chr.sizes

faops n50 -S -C ~/data/dna-seq/atha_ler_0/ref/genome.fa

```

### atha_ler_0: Down sampling

* Trimmed

```bash
cd ~/data/dna-seq/atha_ler_0/superreads/

for count in 10000000 20000000 30000000 40000000 50000000;
do
    echo
    echo "==> Reads ${count}"
    DIR_COUNT="$HOME/data/dna-seq/atha_ler_0/superreads/trimmed_${count}/"
    mkdir -p ${DIR_COUNT}
    
    if [ -e ${DIR_COUNT}/R1.fq.gz ]; then
        continue     
    fi
    
    seqtk sample -s${count} \
        ~/data/dna-seq/atha_ler_0/process/Ler-0-2/SRR611087/trimmed/R1.sickle.fq.gz ${count} \
        | gzip > ${DIR_COUNT}/R1.fq.gz
    seqtk sample -s${count} \
        ~/data/dna-seq/atha_ler_0/process/Ler-0-2/SRR611087/trimmed/R2.sickle.fq.gz ${count} \
        | gzip > ${DIR_COUNT}/R2.fq.gz
done
```

### atha_ler_0: Generate super-reads

```bash
cd ~/data/dna-seq/atha_ler_0/superreads/

for d in trimmed_{10000000,20000000,30000000,40000000,50000000};
do
    echo
    echo "==> Reads ${d}"
    DIR_COUNT="$HOME/data/dna-seq/atha_ler_0/superreads/${d}/"

    if [ ! -d ${DIR_COUNT} ]; then
        echo "${DIR_COUNT} doesn't exist"
        continue;     
    fi
    
    if [ -e ${DIR_COUNT}/pe.cor.fa ]; then
        echo "pe.cor.fa already presents"
        continue     
    fi
    
    pushd ${DIR_COUNT} > /dev/null
    perl ~/Scripts/sra/superreads.pl \
        R1.fq.gz \
        R2.fq.gz \
        -s 450 -d 50 -p 16
    popd > /dev/null
done
```

Stats of super-reads

```bash
cd ~/data/dna-seq/atha_ler_0/superreads/

REAL_G=119667750

bash ~/Scripts/sra/sr_stat.sh 1 header \
    > ~/data/dna-seq/atha_ler_0/superreads/stat1.md

bash ~/Scripts/sra/sr_stat.sh 2 header \
    > ~/data/dna-seq/atha_ler_0/superreads/stat2.md

for d in trimmed_{10000000,20000000,30000000,40000000,50000000};
do
    DIR_COUNT="$HOME/data/dna-seq/atha_ler_0/superreads/${d}/"
    
    if [ ! -d ${DIR_COUNT} ]; then
        continue     
    fi
    
    bash ~/Scripts/sra/sr_stat.sh 1 ${DIR_COUNT} \
        >> ~/data/dna-seq/atha_ler_0/superreads/stat1.md
    
    bash ~/Scripts/sra/sr_stat.sh 2 ${DIR_COUNT} ${REAL_G} \
        >> ~/data/dna-seq/atha_ler_0/superreads/stat2.md
done

cat stat1.md
cat stat2.md
```

### atha_ler_0: Create anchors

```bash
BASE_DIR=$HOME/data/dna-seq/atha_ler_0/superreads/
cd ${BASE_DIR}

for d in trimmed_{10000000,20000000,30000000,40000000,50000000};
do
    echo
    echo "==> Reads ${d}"
    DIR_COUNT="${BASE_DIR}/${d}/"

    if [ -e ${DIR_COUNT}/sr/pe.anchor.fa ]; then
        continue     
    fi
    
    rm -fr ${DIR_COUNT}/sr
    bash ~/Scripts/sra/anchor.sh ${DIR_COUNT} 16 false 80
done
```

Stats of anchors

```bash
BASE_DIR=$HOME/data/dna-seq/atha_ler_0/superreads/
cd ${BASE_DIR}

bash ~/Scripts/sra/sr_stat.sh 3 header \
    > ${BASE_DIR}/stat3.md

bash ~/Scripts/sra/sr_stat.sh 4 header \
    > ${BASE_DIR}/stat4.md

for d in trimmed_{10000000,20000000,30000000,40000000,50000000};
do
    DIR_COUNT="${BASE_DIR}/${d}/"
    
    if [ ! -e ${DIR_COUNT}/sr/pe.anchor.fa ]; then
        continue     
    fi
    
    bash ~/Scripts/sra/sr_stat.sh 3 ${DIR_COUNT} \
        >> ${BASE_DIR}/stat3.md
    
    bash ~/Scripts/sra/sr_stat.sh 4 ${DIR_COUNT} \
        >> ${BASE_DIR}/stat4.md
done

cat stat3.md
cat stat4.md
```

### Results of Ler-0-2 SRR611087

| Name             | fqSize | faSize | Length | Kmer |      EstG |   #reads |   RunTime |     SumSR | SR/EstG |
|:-----------------|-------:|-------:|-------:|-----:|----------:|---------:|----------:|----------:|--------:|
| trimmed_10000000 |   4.0G |   2.2G |     99 |   71 | 109553409 | 14621680 | 0:18'42'' | 149883264 |    1.37 |
| trimmed_20000000 |   8.1G |   4.3G |     99 |   71 | 115109156 | 23959077 | 0:47'49'' | 165694773 |    1.44 |
| trimmed_30000000 |    13G |   6.4G |     99 |   71 | 117211699 | 29102967 | 1:28'18'' | 183153206 |    1.56 |
| trimmed_40000000 |    17G |   8.5G |     99 |   71 | 119222481 | 36697461 | 2:16'24'' | 214842934 |    1.80 |
| trimmed_50000000 |    19G |   9.8G |     99 |   71 | 120413817 | 41843164 | 2:47'51'' | 235069643 |    1.95 |

| Name             | TotalFq | TotalFa | RatioDiscard | TotalSubs | RatioSubs |   RealG | CovFq | CovFa |    EstG |   SumSR | Est/Real | SumSR/Real | N50SR |
|:-----------------|--------:|--------:|-------------:|----------:|----------:|--------:|------:|------:|--------:|--------:|---------:|-----------:|------:|
| trimmed_10000000 |   1.86G |   1.83G |       0.0132 |     1.17M |    0.0006 | 114.12M |  16.7 |  16.4 | 104.48M | 142.94M |     0.92 |       1.25 |   219 |
| trimmed_20000000 |   3.71G |   3.67G |       0.0122 |     1.89M |    0.0005 | 114.12M |  33.3 |  32.9 | 109.78M | 158.02M |     0.96 |       1.38 |   853 |
| trimmed_30000000 |   5.57G |    5.5G |       0.0119 |     2.65M |    0.0005 | 114.12M |  50.0 |  49.4 | 111.78M | 174.67M |     0.98 |       1.53 |  2597 |
| trimmed_40000000 |   7.42G |   7.34G |       0.0117 |     3.38M |    0.0004 | 114.12M |  66.6 |  65.8 |  113.7M | 204.89M |     1.00 |       1.80 |  4813 |
| trimmed_50000000 |   8.53G |   8.44G |       0.0115 |      3.8M |    0.0004 | 114.12M |  76.6 |  75.7 | 114.84M | 224.18M |     1.01 |       1.96 |  5616 |

| Name             |  #cor.fa | #strict.fa | strict/cor | N50SR |     SumSR |    #SR |   RunTime |
|:-----------------|---------:|-----------:|-----------:|------:|----------:|-------:|----------:|
| trimmed_10000000 | 20000000 |   18679241 |     0.9340 |   219 | 149883264 | 743902 | 0:15'22'' |
| trimmed_20000000 | 40000000 |   37700045 |     0.9425 |   853 | 165694773 | 441815 | 0:33'52'' |
| trimmed_30000000 | 60000000 |   56740235 |     0.9457 |  2597 | 183153206 | 422754 | 0:58'45'' |
| trimmed_40000000 | 80000000 |   75829134 |     0.9479 |  4813 | 214842934 | 479384 | 1:16'51'' |
| trimmed_50000000 | 91969660 |   87268629 |     0.9489 |  5616 | 235069643 | 520760 | 1:27'35'' |

| Name             | N50Anchor | SumAnchor | #anchor | N50Anchor2 | SumAnchor2 | #anchor2 | N50Others | SumOthers | #others |
|:-----------------|----------:|----------:|--------:|-----------:|-----------:|---------:|----------:|----------:|--------:|
| trimmed_10000000 |      1162 |   1125310 |     925 |       1717 |      42040 |       24 |       217 | 148715914 |  742953 |
| trimmed_20000000 |      2036 |  64236455 |   33284 |       2267 |    3007022 |     1335 |       363 |  98451296 |  407196 |
| trimmed_30000000 |      5814 |  78937319 |   18666 |       5760 |   15931644 |     3574 |       244 |  88284243 |  400514 |
| trimmed_40000000 |      9934 |  53969975 |    8065 |      11160 |   34196134 |     4443 |       692 | 126676825 |  466876 |
| trimmed_50000000 |     10887 |  40425834 |    5527 |      12557 |   39642813 |     4506 |      1292 | 155000996 |  510727 |

Clear intermediate files.

```bash
# masurca
cd ~/data/dna-seq/atha_ler_0/superreads/

find . -type f -name "quorum_mer_db.jf" | xargs rm
find . -type f -name "k_u_hash_0" | xargs rm
#find . -type f -name "pe.linking.fa" | xargs rm
find . -type f -name "pe.linking.frg" | xargs rm
find . -type f -name "superReadSequences_shr.frg" | xargs rm
find . -type f -name "readPositionsInSuperReads" | xargs rm
find . -type f -name "*.tmp" | xargs rm
#find . -type f -name "pe.renamed.fastq" | xargs rm
```

Dotplot of pe.anchor.fa.

http://www.opiniomics.org/generate-a-single-contig-hybrid-assembly-of-e-coli-using-miseq-and-minion-data/

```bash
cd ~/data/dna-seq/atha_ler_0/superreads/

for part in anchor anchor2 others;
do 
    bash ~/Scripts/sra/sort_on_ref.sh trimmed_30000000/sr/pe.${part}.fa ../ref/genome.fa pe.${part}
    nucmer -l 200 ../ref/genome.fa pe.${part}.fa
    mummerplot -png out.delta -p pe.${part} --medium
done

#brew install mummer
#brew install homebrew/versions/gnuplot4

# mummerplot files
rm *.[fr]plot
rm out.delta
rm *.gp
```

## Cele N2, SRR065390

线虫的 paralog 比例为 0.0472.

* Real:

    * S: 100,286,401

* Original:

    * N50: 100
    * S: 3,380,854,600
    * C: 33,808,546

* Trimmed, 80-100 bp

    * N50: 100
    * S: 2,389,553,628
    * C: 24,324,991

```bash
cd ~/data/dna-seq/cele_n2/process/cele_n2_2/SRR065390/

# 
faops n50 -S -C ~/data/dna-seq/cele_n2/process/cele_n2_4/SRR065390/SRR065390_1.fastq.gz

faops n50 -S -C ~/data/dna-seq/cele_n2/process/cele_n2_4/SRR065390/trimmed/SRR065390_1.sickle.fq.gz

cat ~/data/alignment/Ensembl/Cele/{I,II,III,IV,V,X}.fa \
    ~/data/alignment/Ensembl/Cele/MtDNA.fa.skip \
    > ~/data/dna-seq/cele_n2/ref/genome.fa
faops size ~/data/dna-seq/cele_n2/ref/genome.fa \
    > ~/data/dna-seq/cele_n2/ref/chr.sizes

faops n50 -S -C ~/data/dna-seq/cele_n2/ref/genome.fa

find 
```

### cele_n2: Down sampling

* Original

```bash
mkdir -p ~/data/dna-seq/cele_n2/superreads/
cd ~/data/dna-seq/cele_n2/superreads/

for count in 5000000 10000000 15000000 20000000 25000000;
do
    echo
    echo "==> Reads ${count}"
    DIR_COUNT="$HOME/data/dna-seq/cele_n2/superreads/original_${count}/"
    mkdir -p ${DIR_COUNT}
    
    if [ -e ${DIR_COUNT}/R1.fq.gz ]; then
        continue     
    fi
    
    seqtk sample -s${count} \
        ~/data/dna-seq/cele_n2/process/cele_n2_4/SRR065390/SRR065390_1.fastq.gz ${count} \
        | pigz -p 8 > ${DIR_COUNT}/R1.fq.gz
    seqtk sample -s${count} \
        ~/data/dna-seq/cele_n2/process/cele_n2_4/SRR065390/SRR065390_2.fastq.gz ${count} \
        | pigz -p 8 > ${DIR_COUNT}/R2.fq.gz
done
```

* Trimmed

```bash
cd ~/data/dna-seq/cele_n2/superreads/

for count in 5000000 10000000 15000000 20000000 25000000;
do
    echo
    echo "==> Reads ${count}"
    DIR_COUNT="$HOME/data/dna-seq/cele_n2/superreads/trimmed_${count}/"
    mkdir -p ${DIR_COUNT}
    
    if [ -e ${DIR_COUNT}/R1.fq.gz ]; then
        continue     
    fi
    
    seqtk sample -s${count} \
        ~/data/dna-seq/cele_n2/process/cele_n2_4/SRR065390/trimmed/SRR065390_1.sickle.fq.gz ${count} \
        | pigz -p 8 > ${DIR_COUNT}/R1.fq.gz
    seqtk sample -s${count} \
        ~/data/dna-seq/cele_n2/process/cele_n2_4/SRR065390/trimmed/SRR065390_2.sickle.fq.gz ${count} \
        | pigz -p 8 > ${DIR_COUNT}/R2.fq.gz
done
```

### cele_n2: Generate super-reads

```bash
BASE_DIR=$HOME/data/dna-seq/cele_n2/superreads/
cd ${BASE_DIR}

for d in {original,trimmed}_{5000000,10000000,15000000,20000000,25000000};
do
    echo
    echo "==> Reads ${d}"
    DIR_COUNT="${BASE_DIR}/${d}/"

    if [ ! -d ${DIR_COUNT} ]; then
        echo "${DIR_COUNT} doesn't exist"
        continue;     
    fi
    
    if [ -e ${DIR_COUNT}/pe.cor.fa ]; then
        echo "pe.cor.fa already presents"
        continue     
    fi
    
    pushd ${DIR_COUNT} > /dev/null
    perl ~/Scripts/sra/superreads.pl \
        R1.fq.gz \
        R2.fq.gz \
        -s 200 -d 20 -p 16
    popd > /dev/null
done
```

Stats of super-reads

```bash
BASE_DIR=$HOME/data/dna-seq/cele_n2/superreads/
cd ${BASE_DIR}

REAL_G=100286401

bash ~/Scripts/sra/sr_stat.sh 1 header \
    > ${BASE_DIR}/stat1.md

bash ~/Scripts/sra/sr_stat.sh 2 header \
    > ${BASE_DIR}/stat2.md

for d in {original,trimmed}_{5000000,10000000,15000000,20000000,25000000};
do
    DIR_COUNT="${BASE_DIR}/${d}/"
    
    if [ ! -d ${DIR_COUNT} ]; then
        continue     
    fi
    
    bash ~/Scripts/sra/sr_stat.sh 1 ${DIR_COUNT} \
        >> ${BASE_DIR}/stat1.md
    
    bash ~/Scripts/sra/sr_stat.sh 2 ${DIR_COUNT} ${REAL_G} \
        >> ${BASE_DIR}/stat2.md
done

cat stat1.md
cat stat2.md
```

### cele_n2: Create anchors

```bash
BASE_DIR=$HOME/data/dna-seq/cele_n2/superreads/
cd ${BASE_DIR}

for d in {original,trimmed}_{5000000,10000000,15000000,20000000,25000000};
do
    echo
    echo "==> Reads ${d}"
    DIR_COUNT="${BASE_DIR}/${d}/"

    if [ -e ${DIR_COUNT}/sr/pe.anchor.fa ]; then
        continue     
    fi
    
    rm -fr ${DIR_COUNT}/sr
    bash ~/Scripts/sra/anchor.sh ${DIR_COUNT} 16 false 80
done
```

Stats of anchors

```bash
BASE_DIR=$HOME/data/dna-seq/cele_n2/superreads/
cd ${BASE_DIR}

bash ~/Scripts/sra/sr_stat.sh 3 header \
    > ${BASE_DIR}/stat3.md

bash ~/Scripts/sra/sr_stat.sh 4 header \
    > ${BASE_DIR}/stat4.md

for d in {original,trimmed}_{5000000,10000000,15000000,20000000,25000000};
do
    DIR_COUNT="${BASE_DIR}/${d}/"
    
    if [ ! -e ${DIR_COUNT}/sr/pe.anchor.fa ]; then
        continue     
    fi
    
    bash ~/Scripts/sra/sr_stat.sh 3 ${DIR_COUNT} \
        >> ${BASE_DIR}/stat3.md
    
    bash ~/Scripts/sra/sr_stat.sh 4 ${DIR_COUNT} \
        >> ${BASE_DIR}/stat4.md
done

cat stat3.md
cat stat4.md
```

### Results of SRR065390

| Name              | fqSize | faSize | Length | Kmer |     EstG |  #reads |   RunTime |     SumSR | SR/EstG |
|:------------------|-------:|-------:|-------:|-----:|---------:|--------:|----------:|----------:|--------:|
| original_5000000  |   2.1G |   1.1G |    100 |   71 | 92929502 | 4237331 | 0:07'47'' | 114630055 |    1.23 |
| original_10000000 |   4.1G |   2.2G |    100 |   71 | 98356494 | 4103765 | 0:13'17'' | 124527490 |    1.27 |
| original_15000000 |   6.1G |   3.3G |    100 |   71 | 98957791 | 3457756 | 0:18'47'' | 136907233 |    1.38 |
| original_20000000 |   8.1G |   4.4G |    100 |   71 | 99267481 | 3709733 | 0:25'29'' | 169600281 |    1.71 |
| original_25000000 |    11G |   5.5G |    100 |   71 | 99544508 | 4384492 | 0:32'06'' | 205852690 |    2.07 |
| trimmed_5000000   |   2.0G |   1.1G |     97 |   71 | 89728970 | 4238244 | 0:08'01'' | 108071815 |    1.20 |
| trimmed_10000000  |   4.0G |   2.1G |     97 |   71 | 96338023 | 4461952 | 0:14'16'' | 119316625 |    1.24 |
| trimmed_15000000  |   6.0G |   3.2G |     97 |   71 | 97632827 | 4229480 | 0:19'53'' | 125977170 |    1.29 |
| trimmed_20000000  |   7.9G |   4.3G |     97 |   71 | 98140587 | 4497438 | 0:23'54'' | 138081063 |    1.41 |
| trimmed_25000000  |   9.6G |   5.2G |     97 |   71 | 98401080 | 4956541 | 0:28'33'' | 152036528 |    1.55 |

| Name              | TotalFq | TotalFa | RatioDiscard | TotalSubs | RatioSubs |  RealG | CovFq | CovFa |   EstG |   SumSR | Est/Real | SumSR/Real | N50SR |
|:------------------|--------:|--------:|-------------:|----------:|----------:|-------:|------:|------:|-------:|--------:|---------:|-----------:|------:|
| original_5000000  | 953.67M | 917.48M |       0.0380 |      3.6M |    0.0039 | 95.64M |  10.0 |   9.6 | 88.62M | 109.32M |     0.93 |       1.14 |   225 |
| original_10000000 |   1.86G |    1.8G |       0.0319 |     7.19M |    0.0039 | 95.64M |  19.9 |  19.3 |  93.8M | 118.76M |     0.98 |       1.24 |   852 |
| original_15000000 |   2.79G |   2.71G |       0.0314 |    10.75M |    0.0039 | 95.64M |  29.9 |  29.0 | 94.37M | 130.56M |     0.99 |       1.37 |  2548 |
| original_20000000 |   3.73G |   3.61G |       0.0313 |    14.32M |    0.0039 | 95.64M |  39.9 |  38.6 | 94.67M | 161.74M |     0.99 |       1.69 |  5041 |
| original_25000000 |   4.66G |   4.51G |       0.0312 |    17.86M |    0.0039 | 95.64M |  49.9 |  48.3 | 94.93M | 196.32M |     0.99 |       2.05 |  6399 |
| trimmed_5000000   | 934.54M |  924.9M |       0.0103 |   720.84K |    0.0008 | 95.64M |   9.8 |   9.7 | 85.57M | 103.07M |     0.89 |       1.08 |   232 |
| trimmed_10000000  |   1.83G |   1.81G |       0.0058 |     1.22M |    0.0007 | 95.64M |  19.5 |  19.4 | 91.88M | 113.79M |     0.96 |       1.19 |   732 |
| trimmed_15000000  |   2.74G |   2.72G |       0.0053 |     1.79M |    0.0006 | 95.64M |  29.3 |  29.2 | 93.11M | 120.14M |     0.97 |       1.26 |  1625 |
| trimmed_20000000  |   3.65G |   3.63G |       0.0051 |     2.37M |    0.0006 | 95.64M |  39.1 |  38.9 | 93.59M | 131.68M |     0.98 |       1.38 |  2742 |
| trimmed_25000000  |   4.44G |   4.42G |       0.0051 |     2.87M |    0.0006 | 95.64M |  47.5 |  47.3 | 93.84M | 144.99M |     0.98 |       1.52 |  3679 |

| Name              |  #cor.fa | #strict.fa | strict/cor | N50SR |     SumSR |    #SR |   RunTime |
|:------------------|---------:|-----------:|-----------:|------:|----------:|-------:|----------:|
| original_5000000  | 10000000 |    7602249 |     0.7602 |   225 | 114630055 | 553678 | 0:09'56'' |
| original_10000000 | 20000000 |   15354601 |     0.7677 |   852 | 124527490 | 265450 | 0:13'20'' |
| original_15000000 | 30000000 |   23067089 |     0.7689 |  2548 | 136907233 | 179006 | 0:16'53'' |
| original_20000000 | 40000000 |   30773095 |     0.7693 |  5041 | 169600281 | 176764 | 0:22'13'' |
| original_25000000 | 50000000 |   38488018 |     0.7698 |  6399 | 205852690 | 196932 | 0:29'24'' |
| trimmed_5000000   | 10000000 |    9262666 |     0.9263 |   232 | 108071815 | 515466 | 0:08'19'' |
| trimmed_10000000  | 20000000 |   18710792 |     0.9355 |   732 | 119316625 | 289489 | 0:12'53'' |
| trimmed_15000000  | 30000000 |   28105632 |     0.9369 |  1625 | 125977170 | 200138 | 0:16'23'' |
| trimmed_20000000  | 40000000 |   37490526 |     0.9373 |  2742 | 138081063 | 170549 | 0:22'34'' |
| trimmed_25000000  | 48649982 |   45610597 |     0.9375 |  3679 | 152036528 | 162520 | 0:27'03'' |

| Name              | N50Anchor | SumAnchor | #anchor | N50Anchor2 | SumAnchor2 | #anchor2 | N50Others | SumOthers | #others |
|:------------------|----------:|----------:|--------:|-----------:|-----------:|---------:|----------:|----------:|--------:|
| original_5000000  |      1189 |    875539 |     702 |       1554 |      58965 |       38 |       223 | 113695551 |  552938 |
| original_10000000 |      1744 |  44247800 |   25614 |       1886 |    3818241 |     2046 |       482 |  76461449 |  237790 |
| original_15000000 |      3845 |  61350580 |   19927 |       3890 |   15783908 |     4784 |       773 |  59772745 |  154295 |
| original_20000000 |      6562 |  39170711 |    8611 |       8018 |   28677979 |     5306 |      3411 | 101751591 |  162847 |
| original_25000000 |      7708 |  19947221 |    3779 |       9172 |   27177977 |     4439 |      5663 | 158727492 |  188714 |
| trimmed_5000000   |      1175 |   1454889 |    1183 |          0 |          0 |        0 |       228 | 106616926 |  514283 |
| trimmed_10000000  |      1698 |  38258120 |   22577 |       2027 |    2770249 |     1367 |       425 |  78288256 |  265545 |
| trimmed_15000000  |      2819 |  57157408 |   23279 |       3193 |    9709459 |     3375 |       532 |  59110303 |  173484 |
| trimmed_20000000  |      4024 |  54819040 |   17605 |       4704 |   16850986 |     4409 |       869 |  66411037 |  148535 |
| trimmed_25000000  |      4658 |  46567378 |   13569 |       6449 |   23488038 |     4979 |      1947 |  81981112 |  143972 |

### Results of SRX770040

[Insert size](https://www.ncbi.nlm.nih.gov/sra/SRX770040[accn]) is 500-600 bp.

### Results of ERR1039478

Adaptor contamination "ACTTCCAGGGATTTATAAGCCGATGACGTCATAACATCCCTGACCCTTTA"

### Results of DRR008443

* Original:

    * N50: 110
    * S: 3,584,972,820
    * C: 32,590,662

* Trimmed, 80-110 bp

    * N50: 110
    * S: 3,176,158,837
    * C: 29,148,069

* Trimmed90, 90-110 bp

    * N50: 110
    * S: 3,072,256,253
    * C: 28,077,771

| Name               | fqSize | faSize | Length | Kmer |     EstG |  #reads |   RunTime |     SumSR | SR/EstG |
|:-------------------|-------:|-------:|-------:|-----:|---------:|--------:|----------:|----------:|--------:|
| original_10000000  |   4.4G |   2.4G |    110 |   77 | 94405489 | 4514485 | 0:18'09'' | 128624782 |    1.36 |
| original_15000000  |   6.6G |   3.6G |    110 |   77 | 94715939 | 3950049 | 0:25'14'' | 172917944 |    1.83 |
| original_20000000  |   8.8G |   4.7G |    110 |   77 | 95009944 | 4703366 | 0:32'52'' | 220727549 |    2.32 |
| original_25000000  |    11G |   5.9G |    110 |   77 | 95144116 | 5790505 | 0:38'46'' | 241332415 |    2.54 |
| original_30000000  |    14G |   7.1G |    110 |   77 | 95413408 | 6929191 | 0:47'26'' | 257614098 |    2.70 |
| trimmed_10000000   |   4.4G |   2.4G |    108 |   77 | 93967317 | 4922532 | 0:18'22'' | 122414436 |    1.30 |
| trimmed_15000000   |   6.6G |   3.5G |    108 |   77 | 94227914 | 4366126 | 0:25'04'' | 146604089 |    1.56 |
| trimmed_20000000   |   8.7G |   4.7G |    107 |   77 | 94347283 | 4995221 | 0:30'54'' | 177827217 |    1.88 |
| trimmed_25000000   |    11G |   5.8G |    107 |   77 | 94487936 | 5976897 | 0:38'10'' | 200157634 |    2.12 |
| trimmed_30000000   |    13G |   6.8G |    107 |   77 | 94605989 | 6881557 | 0:43'46'' | 214657271 |    2.27 |
| trimmed90_10000000 |   4.4G |   2.4G |    109 |   77 | 93858829 | 4661446 | 0:17'36'' | 122158822 |    1.30 |
| trimmed90_15000000 |   6.6G |   3.5G |    108 |   77 | 94156388 | 4176053 | 0:23'21'' | 147310564 |    1.56 |
| trimmed90_20000000 |   8.8G |   4.7G |    108 |   77 | 94286339 | 4821201 | 0:31'08'' | 177020385 |    1.88 |
| trimmed90_25000000 |    11G |   5.8G |    108 |   77 | 94428289 | 5756927 | 0:38'18'' | 198896723 |    2.11 |
| trimmed90_30000000 |    13G |   6.6G |    108 |   77 | 94517849 | 6393797 | 0:41'27'' | 210872908 |    2.23 |

| Name               | TotalFq | TotalFa | RatioDiscard | TotalSubs | RatioSubs |  RealG | CovFq | CovFa |   EstG |   SumSR | Est/Real | SumSR/Real | N50SR |
|:-------------------|--------:|--------:|-------------:|----------:|----------:|-------:|------:|------:|-------:|--------:|---------:|-----------:|------:|
| original_10000000  |   2.05G |   2.03G |       0.0109 |     3.57M |    0.0017 | 95.64M |  21.9 |  21.7 | 90.03M | 122.67M |     0.94 |       1.28 |  2029 |
| original_15000000  |   3.07G |   3.04G |       0.0107 |      5.3M |    0.0017 | 95.64M |  32.9 |  32.6 | 90.33M | 164.91M |     0.94 |       1.72 |  6502 |
| original_20000000  |    4.1G |   4.05G |       0.0106 |     7.03M |    0.0017 | 95.64M |  43.9 |  43.4 | 90.61M |  210.5M |     0.95 |       2.20 |  8110 |
| original_25000000  |   5.12G |   5.07G |       0.0106 |     8.78M |    0.0017 | 95.64M |  54.8 |  54.3 | 90.74M | 230.15M |     0.95 |       2.41 |  7701 |
| original_30000000  |   6.15G |   6.08G |       0.0106 |     10.5M |    0.0017 | 95.64M |  65.8 |  65.1 | 90.99M | 245.68M |     0.95 |       2.57 |  6691 |
| trimmed_10000000   |   2.03G |   2.03G |       0.0011 |   773.46K |    0.0004 | 95.64M |  21.7 |  21.7 | 89.61M | 116.74M |     0.94 |       1.22 |  1871 |
| trimmed_15000000   |   3.04G |   3.04G |       0.0010 |     1.11M |    0.0004 | 95.64M |  32.6 |  32.5 | 89.86M | 139.81M |     0.94 |       1.46 |  5472 |
| trimmed_20000000   |   4.05G |   4.05G |       0.0010 |     1.48M |    0.0004 | 95.64M |  43.4 |  43.4 | 89.98M | 169.59M |     0.94 |       1.77 |  8032 |
| trimmed_25000000   |   5.07G |   5.06G |       0.0009 |     1.83M |    0.0004 | 95.64M |  54.3 |  54.2 | 90.11M | 190.89M |     0.94 |       2.00 |  8293 |
| trimmed_30000000   |   5.91G |    5.9G |       0.0009 |     2.13M |    0.0004 | 95.64M |  63.3 |  63.2 | 90.22M | 204.71M |     0.94 |       2.14 |  7909 |
| trimmed90_10000000 |   2.04G |   2.03G |       0.0011 |   742.88K |    0.0003 | 95.64M |  21.8 |  21.8 | 89.51M |  116.5M |     0.94 |       1.22 |  1992 |
| trimmed90_15000000 |   3.06G |   3.05G |       0.0010 |     1.07M |    0.0003 | 95.64M |  32.7 |  32.7 | 89.79M | 140.49M |     0.94 |       1.47 |  5656 |
| trimmed90_20000000 |   4.07G |   4.07G |       0.0009 |     1.41M |    0.0003 | 95.64M |  43.6 |  43.6 | 89.92M | 168.82M |     0.94 |       1.77 |  8086 |
| trimmed90_25000000 |   5.09G |   5.09G |       0.0009 |     1.75M |    0.0003 | 95.64M |  54.5 |  54.5 | 90.05M | 189.68M |     0.94 |       1.98 |  8237 |
| trimmed90_30000000 |   5.72G |   5.71G |       0.0009 |     1.96M |    0.0003 | 95.64M |  61.2 |  61.2 | 90.14M |  201.1M |     0.94 |       2.10 |  8013 |

| Name               |  #cor.fa | #strict.fa | strict/cor | N50SR |     SumSR |    #SR |
|:-------------------|---------:|-----------:|-----------:|------:|----------:|-------:|
| original_10000000  | 20000000 |   17850257 |     0.8925 |  2029 | 128624782 | 206021 |
| original_15000000  | 30000000 |   26809584 |     0.8937 |  6502 | 172917944 | 199831 |
| original_20000000  | 40000000 |   35768418 |     0.8942 |  8110 | 220727549 | 235086 |
| original_25000000  | 50000000 |   44716604 |     0.8943 |  7701 | 241332415 | 269431 |
| original_30000000  | 60000000 |   53683251 |     0.8947 |  6691 | 257614098 | 309542 |
| trimmed_10000000   | 20000000 |   19252195 |     0.9626 |  1871 | 122414436 | 182546 |
| trimmed_15000000   | 30000000 |   28896681 |     0.9632 |  5472 | 146604089 | 147202 |
| trimmed_20000000   | 40000000 |   38534767 |     0.9634 |  8032 | 177827217 | 153437 |
| trimmed_25000000   | 50000000 |   48181917 |     0.9636 |  8293 | 200157634 | 167004 |
| trimmed_30000000   | 58296138 |   56188361 |     0.9638 |  7909 | 214657271 | 180694 |
| trimmed90_10000000 | 20000000 |   19279660 |     0.9640 |  1992 | 122158822 | 176013 |
| trimmed90_15000000 | 30000000 |   28939783 |     0.9647 |  5656 | 147310564 | 143857 |
| trimmed90_20000000 | 40000000 |   38592933 |     0.9648 |  8086 | 177020385 | 148874 |
| trimmed90_25000000 | 50000000 |   48254390 |     0.9651 |  8237 | 198896723 | 162462 |
| trimmed90_30000000 | 56155542 |   54202292 |     0.9652 |  8013 | 210872908 | 172232 |

| Name               | N50Anchor | SumAnchor | #anchor | N50Anchor2 | SumAnchor2 | #anchor2 | N50Others | SumOthers | #others |
|:-------------------|----------:|----------:|--------:|-----------:|-----------:|---------:|----------:|----------:|--------:|
| original_10000000  |      3293 |  63653531 |   23416 |       3426 |   10275929 |     3396 |       569 |  54695322 |  179209 |
| original_15000000  |      8263 |  32269369 |    5997 |      10407 |   30834060 |     4502 |      4715 | 109814515 |  189332 |
| original_20000000  |      8608 |   8560469 |    1483 |      11254 |   22531744 |     2952 |      7666 | 189635336 |  230651 |
| original_25000000  |      9339 |   4152246 |     684 |       9974 |   15606024 |     2164 |      7453 | 221574145 |  266583 |
| original_30000000  |      8121 |   2182076 |     406 |       9077 |   11437166 |     1720 |      6568 | 243994856 |  307416 |
| trimmed_10000000   |      3050 |  61693766 |   23827 |       3498 |    9304882 |     3056 |       550 |  51415788 |  155663 |
| trimmed_15000000   |      6924 |  47781063 |   10352 |       9053 |   24959317 |     4231 |      3113 |  73863709 |  132619 |
| trimmed_20000000   |      8210 |  27689673 |    5136 |      11530 |   29686983 |     4021 |      7001 | 120450561 |  144280 |
| trimmed_25000000   |      8253 |  16827614 |    3070 |      10926 |   27673190 |     3694 |      7722 | 155656830 |  160240 |
| trimmed_30000000   |      7460 |  11505843 |    2240 |      10265 |   24930981 |     3445 |      7544 | 178220447 |  175009 |
| trimmed90_10000000 |      3213 |  61970383 |   23094 |       3558 |    9397603 |     3014 |       564 |  50790836 |  149905 |
| trimmed90_15000000 |      6985 |  47116315 |   10232 |       9091 |   25266931 |     4232 |      3342 |  74927318 |  129393 |
| trimmed90_20000000 |      8242 |  28104963 |    5196 |      11343 |   29216944 |     4008 |      7084 | 119698478 |  139670 |
| trimmed90_25000000 |      8038 |  17823911 |    3287 |      10932 |   27132570 |     3648 |      7700 | 153940242 |  155527 |
| trimmed90_30000000 |      7590 |  13168217 |    2536 |      10214 |   25377251 |     3520 |      7640 | 172327440 |  166176 |

Clear intermediate files.

```bash
# masurca
cd ~/data/dna-seq/cele_n2/superreads/

find . -type f -name "quorum_mer_db.jf" | xargs rm
find . -type f -name "k_u_hash_0" | xargs rm
#find . -type f -name "pe.linking.fa" | xargs rm
find . -type f -name "pe.linking.frg" | xargs rm
find . -type f -name "superReadSequences_shr.frg" | xargs rm
find . -type f -name "readPositionsInSuperReads" | xargs rm
find . -type f -name "*.tmp" | xargs rm
#find . -type f -name "pe.renamed.fastq" | xargs rm
```

