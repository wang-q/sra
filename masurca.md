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

perl ~/Scripts/sra/ovlp_layout.pl 1_4.ovlp.tsv --range 1-4

# 3 5 10 8 4 9 7 2 11 6 1
perl ~/Scripts/egaz/sparsemem_exact.pl \
    -f 0_11.renamed.fasta -g ~/data/dna-seq/e_coli/superreads/NC_000913.fa \
    --length 500 -o 0_11.chr.tsv
perl ~/Scripts/sra/ovlp_layout.pl 0_11.ovlp.tsv --range 1-11

# 16 47 19 51 28 22 15 11 43 5 34 44 4 37 6 9 53 24 40 52 46 23 32 38 55 54 18 31 10 26 2 8 48 36 27 29 30 45 50 33 35 42 41 3 25 20 17 14 7 56 21 13 39 49 12 1
perl ~/Scripts/egaz/sparsemem_exact.pl \
    -f 6_56.renamed.fasta -g ~/data/dna-seq/e_coli/superreads/NC_000913.fa \
    --length 500 -o 6_56.chr.tsv
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

for d in trimmed_{5000000,10000000,15000000,20000000,25000000};
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

### cele_n2: Create anchors

```bash
BASE_DIR=$HOME/data/dna-seq/cele_n2/superreads/
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
BASE_DIR=$HOME/data/dna-seq/cele_n2/superreads/
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

| Name             |  #cor.fa | #strict.fa | strict/cor | N50SRclean | SumSRclean | #SRclean |   RunTime |
|:-----------------|---------:|-----------:|-----------:|-----------:|-----------:|---------:|----------:|
| trimmed_5000000  | 10000000 |    9262666 |     0.9263 |        656 |   16860822 |    24892 | 0:03'05'' |
| trimmed_10000000 | 20000000 |   18710792 |     0.9355 |       1202 |   72403022 |    66063 | 0:08'49'' |
| trimmed_15000000 | 30000000 |   28105632 |     0.9369 |       2283 |   90455377 |    52811 | 0:15'44'' |
| trimmed_20000000 | 40000000 |   37490526 |     0.9373 |       3539 |   97262140 |    42272 | 0:19'51'' |
| trimmed_25000000 | 48649982 |   45610597 |     0.9375 |       4598 |  101631684 |    37314 | 0:23'37'' |

| Name             | N50Anchor | SumAnchor | #anchor | N50Anchor2 | SumAnchor2 | #anchor2 | N50Others | SumOthers | #others |
|:-----------------|----------:|----------:|--------:|-----------:|-----------:|---------:|----------:|----------:|--------:|
| trimmed_5000000  |      1186 |   1595854 |    1281 |       1583 |      26977 |       17 |       636 |  15237991 |   23594 |
| trimmed_10000000 |      1704 |  40364896 |   23744 |       2000 |    1822284 |      916 |       746 |  30215842 |   41403 |
| trimmed_15000000 |      2914 |  65293984 |   26036 |       2725 |    5552309 |     2184 |       802 |  19609084 |   24591 |
| trimmed_20000000 |      4396 |  71508480 |   21534 |       3806 |    9876411 |     2963 |       869 |  15877249 |   17775 |
| trimmed_25000000 |      5389 |  69644295 |   18143 |       5794 |   16173208 |     3657 |       964 |  15814181 |   15514 |

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

