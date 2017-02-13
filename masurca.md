# [MaSuRCA](http://www.genome.umd.edu/masurca.html) 安装与样例

doi:10.1093/bioinformatics/btt476

[MaSuRCA_QuickStartGuide](ftp://ftp.genome.umd.edu/pub/MaSuRCA/MaSuRCA_QuickStartGuide.pdf)


[TOC levels=1-3]: # " "

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
        - [E. coli: Quality assessment](#e-coli-quality-assessment)
        - [E. coli: link anchors](#e-coli-link-anchors)
    - [Scer S288c](#scer-s288c)
        - [S288c: Down sampling](#s288c-down-sampling)
        - [S288c: Generate super-reads](#s288c-generate-super-reads)
        - [S288c: Create anchors](#s288c-create-anchors)
        - [Results of S288c](#results-of-s288c)
        - [S288c: Quality assessment](#s288c-quality-assessment)
    - [Dmel iso-1 (ycnbwsp), SRR306628](#dmel-iso-1-ycnbwsp-srr306628)
        - [Dmel iso-1: Down sampling](#dmel-iso-1-down-sampling)
        - [Dmel iso-1: Generate super-reads](#dmel-iso-1-generate-super-reads)
        - [Dmel iso-1: Create anchors](#dmel-iso-1-create-anchors)
        - [Results of Dmel iso-1, SRR306628](#results-of-dmel-iso-1-srr306628)
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

if [ -d $HOME/share/MaSuRCA ]; then
    rm -fr $HOME/share/MaSuRCA
fi

cd $HOME/share/
tar xvfz /prepare/resource/MaSuRCA-3.1.3.tar.gz

mv MaSuRCA-* MaSuRCA
cd MaSuRCA
sh install.sh
```

```bash
echo "==> SuperReads_RNA"
cd /prepare/resource/
wget -N ftp://ftp.genome.umd.edu/pub/MaSuRCA/beta/SuperReads_RNA-1.0.1.tar.gz

if [ -d $HOME/share/SuperReads_RNA ]; then
    rm -fr $HOME/share/SuperReads_RNA
fi

cd $HOME/share/
tar xvfz /prepare/resource/SuperReads_RNA-1.0.1.tar.gz

mv SuperReads_RNA-* SuperReads_RNA
cd SuperReads_RNA
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

## Atha Ler-0-2, SRR611087

拟南芥的 paralog 比例为 0.1115.

* Real:

    * S:

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

| Name             |  #cor.fa | #strict.fa | strict/cor | N50SRclean | SumSRclean | #SRclean |   RunTime |
|:-----------------|---------:|-----------:|-----------:|-----------:|-----------:|---------:|----------:|
| trimmed_10000000 | 20000000 |   18679241 |     0.9340 |        665 |   15117883 |    21676 | 0:05'53'' |
| trimmed_20000000 | 40000000 |   37700045 |     0.9425 |       1603 |   96963700 |    71845 | 0:15'36'' |
| trimmed_30000000 | 60000000 |   56740235 |     0.9457 |       4985 |  115969739 |    38291 | 0:22'42'' |
| trimmed_40000000 | 80000000 |   75829134 |     0.9479 |       9072 |  123964881 |    27226 | 0:30'31'' |
| trimmed_50000000 | 91969660 |   87268629 |     0.9489 |      10443 |  128431248 |    25632 | 0:34'15'' |

| Name             | N50Anchor | SumAnchor | #anchor | N50Anchor2 | SumAnchor2 | #anchor2 | N50Others | SumOthers | #others |
|:-----------------|----------:|----------:|--------:|-----------:|-----------:|---------:|----------:|----------:|--------:|
| trimmed_10000000 |      1168 |   1238983 |     999 |       5026 |     155425 |       40 |       644 |  13723475 |   20637 |
| trimmed_20000000 |      2036 |  66346001 |   34380 |       2214 |    2338849 |     1062 |       791 |  28278850 |   36403 |
| trimmed_30000000 |      5885 |  90031979 |   21136 |       4704 |   10309894 |     2637 |      1096 |  15627866 |   14518 |
| trimmed_40000000 |     10603 |  79899158 |   11388 |       9786 |   25685862 |     3613 |      1854 |  18379861 |   12225 |
| trimmed_50000000 |     12123 |  72061387 |    9119 |      11791 |   34473968 |     4101 |      2505 |  21895893 |   12412 |

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
