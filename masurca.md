# [MaSuRCA](http://www.genome.umd.edu/masurca.html) 安装与样例

doi:10.1093/bioinformatics/btt476

[MaSuRCA_QuickStartGuide](ftp://ftp.genome.umd.edu/pub/MaSuRCA/MaSuRCA_QuickStartGuide.pdf)

# 特点

de novo 基因组序列的拼接有以下几种主流的策略:

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
mkdir -p ~/data/test/rhodobacter_PE_SJ_Sanger4
cd ~/data/test/rhodobacter_PE_SJ_Sanger4

cat <<EOF > config_PE_SJ_Sanger_4x.txt
PARAMETERS
CA_PARAMETERS= ovlMerSize=30 cgwErrorRate=0.25 merylMemory=8192 ovlMemory=4GB 
LIMIT_JUMP_COVERAGE = 60
KMER_COUNT_THRESHOLD = 1
EXTEND_JUMP_READS=0
NUM_THREADS= 16
JF_SIZE=50000000
END

DATA
PE=  pe 180 20 /home/wangq/data/test/rhodobacter/PE/frag_1.fastq /home/wangq/data/test/rhodobacter/PE/frag_2.fastq
JUMP= sj 3600 200  /home/wangq/data/test/rhodobacter/SJ/short_1.fastq  /home/wangq/data/test/rhodobacter/SJ/short_2.fastq
OTHER=/home/wangq/data/test/rhodobacter/Sanger/rhodobacter_sphaeroides_2_4_1.4x.frg
END

EOF

cd ~/data/test/rhodobacter_PE_SJ_Sanger4

$HOME/share/MaSuRCA/bin/masurca config_PE_SJ_Sanger_4x.txt

#real    19m47.737s
#user    79m13.602s
#sys     60m45.557s
time bash assemble.sh
```

### Illumina PE, Short Jump and Sanger

```bash
mkdir -p ~/data/test/rhodobacter_PE_SJ_Sanger
cd ~/data/test/rhodobacter_PE_SJ_Sanger

cat <<EOF > config_PE_SJ_Sanger_1x.txt
PARAMETERS
CA_PARAMETERS= ovlMerSize=30 cgwErrorRate=0.25 merylMemory=8192 ovlMemory=4GB 
LIMIT_JUMP_COVERAGE = 60
KMER_COUNT_THRESHOLD = 1
EXTEND_JUMP_READS=0
NUM_THREADS= 16
JF_SIZE=50000000
END

DATA
PE=  pe 180 20 /home/wangq/data/test/rhodobacter/PE/frag_1.fastq /home/wangq/data/test/rhodobacter/PE/frag_2.fastq
JUMP= sj 3600 200  /home/wangq/data/test/rhodobacter/SJ/short_1.fastq  /home/wangq/data/test/rhodobacter/SJ/short_2.fastq
OTHER=/home/wangq/data/test/rhodobacter/Sanger/rhodobacter_sphaeroides_2_4_1.1x.frg
END

EOF

cd ~/data/test/rhodobacter_PE_SJ_Sanger

$HOME/share/MaSuRCA/bin/masurca config_PE_SJ_Sanger_1x.txt

time bash assemble.sh
```

### Illumina PE and Short Jump

```bash
mkdir -p ~/data/test/rhodobacter_PE_SJ
cd ~/data/test/rhodobacter_PE_SJ

cat <<EOF > config_PE_SJ.txt
PARAMETERS
CA_PARAMETERS= ovlMerSize=30 cgwErrorRate=0.25 merylMemory=8192 ovlMemory=4GB 
LIMIT_JUMP_COVERAGE = 60
KMER_COUNT_THRESHOLD = 1
EXTEND_JUMP_READS=0
NUM_THREADS= 16
JF_SIZE=50000000
END

DATA
PE=  pe 180 20 /home/wangq/data/test/rhodobacter/PE/frag_1.fastq /home/wangq/data/test/rhodobacter/PE/frag_2.fastq
JUMP= sj 3600 200  /home/wangq/data/test/rhodobacter/SJ/short_1.fastq  /home/wangq/data/test/rhodobacter/SJ/short_2.fastq
END

EOF

cd ~/data/test/rhodobacter_PE_SJ

$HOME/share/MaSuRCA/bin/masurca config_PE_SJ.txt

time bash assemble.sh
```

### Illumina PE, and Sanger4

```bash
mkdir -p ~/data/test/rhodobacter_PE_Sanger4
cd ~/data/test/rhodobacter_PE_Sanger4

cat <<EOF > config_PE_Sanger_4x.txt
PARAMETERS
CA_PARAMETERS= ovlMerSize=30 cgwErrorRate=0.25 merylMemory=8192 ovlMemory=4GB 
LIMIT_JUMP_COVERAGE = 60
KMER_COUNT_THRESHOLD = 1
EXTEND_JUMP_READS=0
NUM_THREADS= 16
JF_SIZE=50000000
END

DATA
PE=  pe 180 20 /home/wangq/data/test/rhodobacter/PE/frag_1.fastq /home/wangq/data/test/rhodobacter/PE/frag_2.fastq
OTHER=/home/wangq/data/test/rhodobacter/Sanger/rhodobacter_sphaeroides_2_4_1.4x.frg
END

EOF

cd ~/data/test/rhodobacter_PE_Sanger4

$HOME/share/MaSuRCA/bin/masurca config_PE_Sanger_4x.txt

time bash assemble.sh
```

### Illumina PE, and Sanger

```bash
mkdir -p ~/data/test/rhodobacter_PE_Sanger
cd ~/data/test/rhodobacter_PE_Sanger

cat <<EOF > config_PE_Sanger.txt
PARAMETERS
CA_PARAMETERS= ovlMerSize=30 cgwErrorRate=0.25 merylMemory=8192 ovlMemory=4GB 
LIMIT_JUMP_COVERAGE = 60
KMER_COUNT_THRESHOLD = 1
EXTEND_JUMP_READS=0
NUM_THREADS= 16
JF_SIZE=50000000
END

DATA
PE=  pe 180 20 /home/wangq/data/test/rhodobacter/PE/frag_1.fastq /home/wangq/data/test/rhodobacter/PE/frag_2.fastq
OTHER=/home/wangq/data/test/rhodobacter/Sanger/rhodobacter_sphaeroides_2_4_1.1x.frg
END

EOF

cd ~/data/test/rhodobacter_PE_Sanger

$HOME/share/MaSuRCA/bin/masurca config_PE_Sanger.txt

time bash assemble.sh
```

### Illumina PE

```bash
mkdir -p ~/data/test/rhodobacter_PE
cd ~/data/test/rhodobacter_PE

cat <<EOF > sr_config.txt
PARAMETERS
CA_PARAMETERS= ovlMerSize=30 cgwErrorRate=0.25 merylMemory=8192 ovlMemory=4GB
LIMIT_JUMP_COVERAGE = 60
KMER_COUNT_THRESHOLD = 1
EXTEND_JUMP_READS=0
NUM_THREADS= 16
JF_SIZE=50000000
END

DATA
PE=  pe 180 20 /home/wangq/data/test/rhodobacter/PE/frag_1.fastq /home/wangq/data/test/rhodobacter/PE/frag_2.fastq
END

EOF

$HOME/share/MaSuRCA/bin/masurca sr_config.txt

time bash assemble.sh
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

## E. coli sampling

### Download

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
#find . -type f -name "*scythe.fq.gz" | sort | grep trimmed | xargs rm

```

### Down sampling

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

### Generate super-reads

```bash
cd ~/data/dna-seq/e_coli/superreads/

for count in 50000 100000 150000 200000 300000 400000 500000 600000 700000 800000 900000 1000000 1200000 1400000 1600000 1800000 2000000 3000000 4000000 5000000;
do
    echo
    echo "==> Reads ${count}"
#    DIR_COUNT="$HOME/data/dna-seq/e_coli/superreads/MiSeq_${count}/"
    DIR_COUNT="$HOME/data/dna-seq/e_coli/superreads/filter_${count}/"
#    DIR_COUNT="$HOME/data/dna-seq/e_coli/superreads/trimmed_${count}/"

    if [ ! -d ${DIR_COUNT} ];
    then
        echo "${DIR_COUNT} doesn't exist"
        continue;     
    fi
    
    if [ -e ${DIR_COUNT}/pe.cor.fa ];
    then
        echo "pe.cor.fa already presents"
        continue     
    fi
    
    pushd ${DIR_COUNT}
    perl ~/Scripts/sra/superreads.pl \
        R1.fq.gz \
        R2.fq.gz \
        -s 300 -d 30 -p 8
    popd
done
```

### Stats of super-reads

```bash
cd ~/data/dna-seq/e_coli/superreads/

printf "| %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | \n" \
    "Name" "fqSize" "faSize" "Length" "Kmer" "EstG" "#reads" "RunTime" "SumSR" "SR/EstG" \
    > ~/data/dna-seq/e_coli/superreads/stat.md
printf "|:--|--:|--:|--:|--:|--:|--:|--:|--:|--:|\n" \
    >> ~/data/dna-seq/e_coli/superreads/stat.md

for count in 50000 100000 150000 200000 300000 400000 500000 600000 700000 800000 900000 1000000 1200000 1400000 1600000 1800000 2000000 3000000 4000000 5000000;
do
#    DIR_COUNT="$HOME/data/dna-seq/e_coli/superreads/MiSeq_${count}/"
    DIR_COUNT="$HOME/data/dna-seq/e_coli/superreads/filter_${count}/"
#    DIR_COUNT="$HOME/data/dna-seq/e_coli/superreads/trimmed_${count}/"

    if [ ! -d ${DIR_COUNT} ];
    then
        continue     
    fi

    pushd ${DIR_COUNT}
    SECS=$(expr $(stat -c %Y environment.sh) - $(stat -c %Y assemble.sh))
    EST_G=$( cat environment.sh | perl -n -e '/ESTIMATED_GENOME_SIZE=\"(\d+)\"/ and print $1' )
    SUM_SR=$( faops n50 -H -N 0 -S work1/superReadSequences.fasta)
    printf "| %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | \n" \
        $( basename $( pwd ) ) \
        $( if [[ -e pe.renamed.fastq ]]; then du -h pe.renamed.fastq | cut -f1; else echo 0; fi ) \
        $( du -h pe.cor.fa | cut -f1 ) \
        $( cat environment.sh \
            | perl -n -e '/PE_AVG_READ_LENGTH=\"(\d+)\"/ and print $1' ) \
        $( cat environment.sh \
            | perl -n -e '/KMER=\"(\d+)\"/ and print $1' ) \
        ${EST_G} \
        $( cat environment.sh \
            | perl -n -e '/TOTAL_READS=\"(\d+)\"/ and print $1' ) \
        $( printf "%d:%02d'%02d''\n" $((${SECS}/3600)) $((${SECS}%3600/60)) $((${SECS}%60)) ) \
        ${SUM_SR} \
        $( perl -e "printf qq{%.2f}, ${SUM_SR} * 1.0 / ${EST_G}" ) \
        >> ~/data/dna-seq/e_coli/superreads/stat.md
    popd
done

cat stat.md
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

printf "| %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | \n" \
    "Name" \
    "TotalFq" "TotalFa" "RatioDiscard" "TotalSubs" "RatioSubs" \
    "RealG" "CovFq" "CovFa" \
    "EstG" "SumSR" "Est/Real" "SumSR/Real" "N50SR" \
    > ~/data/dna-seq/e_coli/superreads/stat2.md
printf "|:--|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|\n" \
    >> ~/data/dna-seq/e_coli/superreads/stat2.md

for count in 50000 100000 150000 200000 300000 400000 500000 600000 700000 800000 900000 1000000 1200000 1400000 1600000 1800000 2000000 3000000 4000000 5000000;
do
#    DIR_COUNT="$HOME/data/dna-seq/e_coli/superreads/MiSeq_${count}/"
    DIR_COUNT="$HOME/data/dna-seq/e_coli/superreads/filter_${count}/"
#    DIR_COUNT="$HOME/data/dna-seq/e_coli/superreads/trimmed_${count}/"
    
    if [ ! -d ${DIR_COUNT} ];
    then
        continue     
    fi

    pushd ${DIR_COUNT}
    
    TOTAL_FQ=$( if [[ -e pe.renamed.fastq ]]; then faops n50 -H -N 0 -S pe.renamed.fastq; else echo 0; fi )
    TOTAL_FA=$( faops n50 -H -N 0 -S pe.cor.fa )
    EST_G=$( cat environment.sh | perl -n -e '/ESTIMATED_GENOME_SIZE=\"(\d+)\"/ and print $1' )
    SUM_SR=$( faops n50 -H -N 0 -S work1/superReadSequences.fasta )
    N50_SR=$( faops n50 -H -N 50 work1/superReadSequences.fasta )
    TOTAL_SUBS=$( cat pe.cor.fa | tr ' ' '\n' | grep ":sub:" | wc -l )
    
    printf "| %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | \n" \
        $( basename $( pwd ) ) \
        \
        $( perl -MNumber::Format -e "print Number::Format::format_bytes(${TOTAL_FQ})") \
        $( perl -MNumber::Format -e "print Number::Format::format_bytes(${TOTAL_FA})") \
        $( perl -e "printf qq{%.4f}, 1 - ${TOTAL_FA} / ${TOTAL_FQ}" ) \
        $( perl -MNumber::Format -e "print Number::Format::format_bytes(${TOTAL_SUBS})") \
        $( perl -e "printf qq{%.4f}, ${TOTAL_SUBS} / ${TOTAL_FA}" ) \
        \
        $( perl -MNumber::Format -e "print Number::Format::format_bytes(${REAL_G})") \
        $( perl -e "printf qq{%.1f}, ${TOTAL_FQ} / ${REAL_G}" ) \
        $( perl -e "printf qq{%.1f}, ${TOTAL_FA} / ${REAL_G}" ) \
        \
        $( perl -MNumber::Format -e "print Number::Format::format_bytes(${EST_G})") \
        $( perl -MNumber::Format -e "print Number::Format::format_bytes(${SUM_SR})") \
        $( perl -e "printf qq{%.2f}, ${EST_G} / ${REAL_G}" ) \
        $( perl -e "printf qq{%.2f}, ${SUM_SR} / ${REAL_G}" ) \
        ${N50_SR} \
        >> ~/data/dna-seq/e_coli/superreads/stat2.md
    popd
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
    * Real    - 4641652
    * Trimmed - 4621800 (EstG)
    * Filter  - 4577674 (EstG)

### Create anchors

```bash
cd ~/data/dna-seq/e_coli/superreads/

for count in 50000 100000 150000 200000 300000 400000 500000 600000 700000 800000 900000 1000000 1200000 1400000 1600000 1800000 2000000 3000000 4000000 5000000;
do
    echo
    echo "==> Reads ${count}"
#    DIR_COUNT="$HOME/data/dna-seq/e_coli/superreads/MiSeq_${count}/"
    DIR_COUNT="$HOME/data/dna-seq/e_coli/superreads/filter_${count}/"
#    DIR_COUNT="$HOME/data/dna-seq/e_coli/superreads/trimmed_${count}/"

    if [ -e ${DIR_COUNT}/sr/pe.anchor.fa ];
    then
        continue     
    fi
    
    rm -fr ${DIR_COUNT}/sr
    bash ~/Scripts/sra/anchor.sh ${DIR_COUNT} 8 false 120
done

```

Stats of anchors

```bash
cd ~/data/dna-seq/e_coli/superreads/

printf "| %s | %s | %s | %s | %s | %s | %s | \n" \
    "Name" \
    "#cor.fa" "#strict.fa" "strict/cor" "N50SR" "SumSR" "#SR" \
    > ~/data/dna-seq/e_coli/superreads/stat3.md
printf "|:--|--:|--:|--:|--:|--:|--:|\n" \
    >> ~/data/dna-seq/e_coli/superreads/stat3.md

for count in 50000 100000 150000 200000 300000 400000 500000 600000 700000 800000 900000 1000000 1200000 1400000 1600000 1800000 2000000 3000000 4000000 5000000;
do
#    DIR_COUNT="$HOME/data/dna-seq/e_coli/superreads/MiSeq_${count}/"
    DIR_COUNT="$HOME/data/dna-seq/e_coli/superreads/filter_${count}/"
#    DIR_COUNT="$HOME/data/dna-seq/e_coli/superreads/trimmed_${count}/"

    if [ ! -e ${DIR_COUNT}/sr/pe.anchor.fa ];
    then
        continue     
    fi

    pushd ${DIR_COUNT}/sr
    COUNT_COR=$( faops n50 -H -N 0 -C pe.cor.fa )
    COUNT_STRICT=$( faops n50 -H -N 0 -C pe.strict.fa )
    printf "| %s | %s | %s | %s | %s | %s | %s | \n" \
        $( basename $( dirname $(pwd) ) ) \
        ${COUNT_COR} \
        ${COUNT_STRICT} \
        $( perl -e "printf qq{%.4f}, ${COUNT_STRICT} / ${COUNT_COR}" ) \
        $( faops n50 -H -N 50 -S -C superReadSequences.fasta ) \
        >> ~/data/dna-seq/e_coli/superreads/stat3.md
    popd
done

cat stat3.md
```

```bash
cd ~/data/dna-seq/e_coli/superreads/

printf "| %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | \n" \
    "Name" \
    "N50Anchor" "SumAnchor" "#anchor" \
    "N50Anchor2" "SumAnchor2" "#anchor2" \
    "N50Others" "SumOthers" "#others" \
    > ~/data/dna-seq/e_coli/superreads/stat4.md
printf "|:--|--:|--:|--:|--:|--:|--:|--:|--:|--:|\n" \
    >> ~/data/dna-seq/e_coli/superreads/stat4.md

for count in 50000 100000 150000 200000 300000 400000 500000 600000 700000 800000 900000 1000000 1200000 1400000 1600000 1800000 2000000 3000000 4000000 5000000;
do
#    DIR_COUNT="$HOME/data/dna-seq/e_coli/superreads/MiSeq_${count}/"
    DIR_COUNT="$HOME/data/dna-seq/e_coli/superreads/filter_${count}/"
#    DIR_COUNT="$HOME/data/dna-seq/e_coli/superreads/trimmed_${count}/"

    if [ ! -e ${DIR_COUNT}/sr/pe.anchor.fa ];
    then
        continue     
    fi

    pushd ${DIR_COUNT}/sr
    printf "| %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | \n" \
        $( basename $( dirname $(pwd) ) ) \
        $( faops n50 -H -N 50 -S -C pe.anchor.fa ) \
        $( faops n50 -H -N 50 -S -C pe.anchor2.fa ) \
        $( faops n50 -H -N 50 -S -C pe.others.fa ) \
        >> ~/data/dna-seq/e_coli/superreads/stat4.md
    popd
done

cat stat4.md
```

| Name            |  #cor.fa | #strict.fa | strict/cor | N50SR |    SumSR |   #SR |
|:----------------|---------:|-----------:|-----------:|------:|---------:|------:|
| MiSeq_50000     |   100000 |      76717 |     0.7672 |   375 |  2432529 |  7595 |
| MiSeq_100000    |   200000 |     161610 |     0.8081 |   874 |  4442346 |  7265 |
| MiSeq_150000    |   300000 |     240332 |     0.8011 |  2366 |  4880895 |  3425 |
| MiSeq_200000    |   400000 |     320627 |     0.8016 |  5885 |  5740960 |  1823 |
| MiSeq_300000    |   600000 |     479962 |     0.7999 |  7066 |  9248681 |  2098 |
| MiSeq_400000    |   800000 |     641280 |     0.8016 |  5514 | 10223031 |  2981 |
| MiSeq_500000    |  1000000 |     802104 |     0.8021 |  4200 | 10663685 |  3808 |
| MiSeq_600000    |  1200000 |     963216 |     0.8027 |  3423 | 10996696 |  4785 |
| MiSeq_700000    |  1400000 |    1125118 |     0.8037 |  2922 | 11244264 |  5662 |
| MiSeq_800000    |  1600000 |    1286410 |     0.8040 |  2583 | 11668035 |  6626 |
| MiSeq_900000    |  1800000 |    1449088 |     0.8050 |  2330 | 11959177 |  7413 |
| MiSeq_1000000   |  2000000 |    1609161 |     0.8046 |  2057 | 12271938 |  8522 |
| MiSeq_1200000   |  2400000 |    1935704 |     0.8065 |  1796 | 12929921 | 10364 |
| MiSeq_1400000   |  2800000 |    2260464 |     0.8073 |  1528 | 13405411 | 12278 |
| MiSeq_1600000   |  3200000 |    2586433 |     0.8083 |  1377 | 14100368 | 14388 |
| MiSeq_1800000   |  3600000 |    2912306 |     0.8090 |  1233 | 14724645 | 16778 |
| MiSeq_2000000   |  4000000 |    3239023 |     0.8098 |  1117 | 15468429 | 19143 |
| MiSeq_3000000   |  6000000 |    4881446 |     0.8136 |   730 | 18695968 | 32523 |
| MiSeq_4000000   |  8000000 |    6534196 |     0.8168 |   543 | 22406939 | 48244 |
| MiSeq_5000000   | 10000000 |    8198162 |     0.8198 |   439 | 26685370 | 66799 |
| trimmed_50000   |   100000 |      81290 |     0.8129 |   194 |  1673901 |  8225 |
| trimmed_100000  |   200000 |     173159 |     0.8658 |   250 |  4174701 | 16084 |
| trimmed_150000  |   300000 |     260730 |     0.8691 |   441 |  4939094 | 14060 |
| trimmed_200000  |   400000 |     347905 |     0.8698 |   688 |  5113050 | 10631 |
| trimmed_300000  |   600000 |     521757 |     0.8696 |  1581 |  4998054 |  5629 |
| trimmed_400000  |   800000 |     696091 |     0.8701 |  2905 |  4896464 |  3380 |
| trimmed_500000  |  1000000 |     870219 |     0.8702 |  4531 |  4891545 |  2271 |
| trimmed_600000  |  1200000 |    1044371 |     0.8703 |  5889 |  4898849 |  1879 |
| trimmed_700000  |  1400000 |    1218533 |     0.8704 |  7308 |  5013590 |  1566 |
| trimmed_800000  |  1600000 |    1392905 |     0.8706 |  8727 |  4959830 |  1301 |
| trimmed_900000  |  1800000 |    1566381 |     0.8702 |  9795 |  5019700 |  1230 |
| trimmed_1000000 |  2000000 |    1740419 |     0.8702 | 10326 |  5115098 |  1157 |
| trimmed_1200000 |  2400000 |    2088409 |     0.8702 | 11697 |  5159538 |  1099 |
| trimmed_1400000 |  2800000 |    2436968 |     0.8703 | 11782 |  5629312 |  1134 |
| trimmed_1600000 |  3200000 |    2786123 |     0.8707 | 12378 |  5879184 |  1136 |
| trimmed_1800000 |  3600000 |    3134393 |     0.8707 | 12613 |  6320459 |  1236 |
| trimmed_2000000 |  4000000 |    3483619 |     0.8709 | 10670 |  6658064 |  1393 |
| trimmed_3000000 |  6000000 |    5230146 |     0.8717 |  6347 |  8503135 |  2477 |
| filter_50000    |   100000 |      81131 |     0.8113 |   210 |  1880026 |  8309 |
| filter_100000   |   200000 |     172366 |     0.8618 |   342 |  3856581 | 12727 |
| filter_150000   |   300000 |     259771 |     0.8659 |   543 |  4531014 | 11018 |
| filter_200000   |   400000 |     347132 |     0.8678 |   810 |  4728385 |  8661 |
| filter_300000   |   600000 |     521019 |     0.8684 |  1548 |  4820562 |  5538 |
| filter_400000   |   800000 |     694980 |     0.8687 |  2439 |  4809291 |  3847 |
| filter_500000   |  1000000 |     868212 |     0.8682 |  3359 |  4815359 |  2980 |
| filter_600000   |  1200000 |    1041182 |     0.8677 |  4142 |  4819308 |  2458 |
| filter_700000   |  1400000 |    1215366 |     0.8681 |  4796 |  4842355 |  2123 |
| filter_800000   |  1600000 |    1388985 |     0.8681 |  5724 |  4874718 |  1913 |
| filter_900000   |  1800000 |    1562937 |     0.8683 |  6159 |  4909160 |  1739 |
| filter_1000000  |  2000000 |    1736651 |     0.8683 |  6436 |  4939608 |  1676 |
| filter_1200000  |  2400000 |    2083345 |     0.8681 |  7493 |  5005087 |  1512 |
| filter_1400000  |  2800000 |    2431625 |     0.8684 |  7834 |  5119952 |  1455 |
| filter_1600000  |  3200000 |    2779359 |     0.8685 |  8246 |  5280512 |  1425 |
| filter_1800000  |  3600000 |    3126804 |     0.8686 |  8730 |  5547849 |  1438 |
| filter_2000000  |  4000000 |    3475124 |     0.8688 |  7981 |  5752657 |  1517 |
| filter_3000000  |  4914436 |    4271274 |     0.8691 |  7532 |  6513055 |  1736 |

| Name            | N50Anchor | SumAnchor | #anchor | N50Anchor2 | SumAnchor2 | #anchor2 | N50Others | SumOthers | #others |
|:----------------|----------:|----------:|--------:|-----------:|-----------:|---------:|----------:|----------:|--------:|
| MiSeq_50000     |      1304 |     20340 |      15 |       1355 |      12862 |        9 |       373 |   2399327 |    7571 |
| MiSeq_100000    |      1674 |   1184783 |     714 |       1429 |     431987 |      298 |       592 |   2825576 |    6253 |
| MiSeq_150000    |      2973 |   3108720 |    1196 |       2259 |     608083 |      281 |       792 |   1164092 |    1948 |
| MiSeq_200000    |      5953 |   2776938 |     604 |       6601 |    1162604 |      234 |      5097 |   1801418 |     985 |
| MiSeq_300000    |      5810 |    124911 |      28 |       7965 |    1074088 |      162 |      6978 |   8049682 |    1908 |
| MiSeq_400000    |         0 |         0 |       0 |       6606 |     154187 |       29 |      5509 |  10068844 |    2952 |
| MiSeq_500000    |         0 |         0 |       0 |       6237 |      25431 |        6 |      4197 |  10638254 |    3802 |
| MiSeq_600000    |         0 |         0 |       0 |       2839 |       4756 |        2 |      3423 |  10991940 |    4783 |
| MiSeq_700000    |         0 |         0 |       0 |       4190 |       4190 |        1 |      2920 |  11240074 |    5661 |
| MiSeq_800000    |         0 |         0 |       0 |          0 |          0 |        0 |      2583 |  11668035 |    6626 |
| MiSeq_900000    |         0 |         0 |       0 |          0 |          0 |        0 |      2330 |  11959177 |    7413 |
| MiSeq_1000000   |         0 |         0 |       0 |          0 |          0 |        0 |      2057 |  12271938 |    8522 |
| MiSeq_1200000   |         0 |         0 |       0 |          0 |          0 |        0 |      1796 |  12929921 |   10364 |
| MiSeq_1400000   |         0 |         0 |       0 |          0 |          0 |        0 |      1528 |  13405411 |   12278 |
| MiSeq_1600000   |         0 |         0 |       0 |          0 |          0 |        0 |      1377 |  14100368 |   14388 |
| MiSeq_1800000   |         0 |         0 |       0 |          0 |          0 |        0 |      1233 |  14724645 |   16778 |
| MiSeq_2000000   |      1054 |      2072 |       2 |          0 |          0 |        0 |      1117 |  15466357 |   19141 |
| MiSeq_3000000   |      2351 |      4125 |       2 |          0 |          0 |        0 |       730 |  18691843 |   32521 |
| MiSeq_4000000   |      1863 |      1863 |       1 |       1127 |       1127 |        1 |       543 |  22403949 |   48242 |
| MiSeq_5000000   |      1856 |      1856 |       1 |          0 |          0 |        0 |       439 |  26683514 |   66798 |
| trimmed_50000   |         0 |         0 |       0 |          0 |          0 |        0 |       194 |   1673901 |    8225 |
| trimmed_100000  |      1210 |     42930 |      34 |       1145 |       7530 |        6 |       247 |   4124241 |   16044 |
| trimmed_150000  |      1324 |    553728 |     401 |       1344 |      47952 |       34 |       386 |   4337414 |   13625 |
| trimmed_200000  |      1500 |   1481189 |     956 |       1692 |     112626 |       66 |       479 |   3519235 |    9609 |
| trimmed_300000  |      2317 |   3014119 |    1414 |       2964 |     211121 |       77 |       592 |   1772814 |    4138 |
| trimmed_400000  |      3590 |   3675357 |    1278 |       4437 |     283253 |       79 |       635 |    937854 |    2023 |
| trimmed_500000  |      5012 |   3849768 |    1016 |       5228 |     419204 |       96 |       714 |    622573 |    1159 |
| trimmed_600000  |      6427 |   3928555 |     871 |       6491 |     406964 |       80 |       774 |    563330 |     928 |
| trimmed_700000  |      7540 |   3731104 |     718 |       9736 |     665719 |       98 |      1469 |    616767 |     750 |
| trimmed_800000  |      9348 |   3957223 |     624 |       7008 |     443649 |       79 |      2297 |    558958 |     598 |
| trimmed_900000  |     10420 |   3899668 |     573 |       9099 |     495368 |       76 |      4675 |    624664 |     581 |
| trimmed_1000000 |     10351 |   3693214 |     529 |      12609 |     753758 |       90 |      7217 |    668126 |     538 |
| trimmed_1200000 |     12064 |   3753215 |     467 |      10445 |     574600 |       79 |      8529 |    831723 |     553 |
| trimmed_1400000 |     11229 |   2849155 |     379 |      15156 |    1502747 |      143 |      9572 |   1277410 |     612 |
| trimmed_1600000 |     12063 |   2657038 |     329 |      16973 |    1572265 |      140 |     10430 |   1649881 |     667 |
| trimmed_1800000 |     12355 |   2157078 |     270 |      13883 |    1955037 |      180 |     11466 |   2208344 |     786 |
| trimmed_2000000 |     10300 |   1534782 |     215 |      12220 |    2111829 |      215 |      9638 |   3011453 |     963 |
| trimmed_3000000 |      7005 |    307962 |      67 |       7429 |    1526848 |      255 |      6017 |   6668325 |    2155 |
| filter_50000    |      1522 |      2822 |       2 |          0 |          0 |        0 |       210 |   1877204 |    8307 |
| filter_100000   |      1384 |    194730 |     138 |       1362 |      30418 |       22 |       319 |   3631433 |   12567 |
| filter_150000   |      1516 |    881263 |     572 |       1436 |      93304 |       58 |       435 |   3556447 |   10388 |
| filter_200000   |      1734 |   1626291 |     935 |       1836 |     196629 |      105 |       513 |   2905465 |    7621 |
| filter_300000   |      2396 |   2777770 |    1267 |       3178 |     299517 |      119 |       574 |   1743275 |    4152 |
| filter_400000   |      3215 |   3352543 |    1249 |       4150 |     354134 |      110 |       614 |   1102614 |    2488 |
| filter_500000   |      4034 |   3625517 |    1158 |       4574 |     365754 |      104 |       659 |    824088 |    1718 |
| filter_600000   |      4816 |   3802218 |    1061 |       4588 |     325501 |       91 |       707 |    691589 |    1306 |
| filter_700000   |      5416 |   3831435 |     956 |       5562 |     391660 |       90 |       743 |    619260 |    1077 |
| filter_800000   |      6229 |   3828107 |     878 |       5990 |     416505 |       88 |       834 |    630106 |     947 |
| filter_900000   |      6716 |   3803368 |     820 |       6598 |     456154 |       93 |       947 |    649638 |     826 |
| filter_1000000  |      6929 |   3839542 |     779 |       6484 |     450296 |       87 |       965 |    649770 |     810 |
| filter_1200000  |      7843 |   3744296 |     702 |       9098 |     598017 |       94 |      2410 |    662774 |     716 |
| filter_1400000  |      7950 |   3599873 |     649 |       8015 |     705805 |      110 |      6547 |    814274 |     696 |
| filter_1600000  |      8320 |   3399950 |     595 |       8539 |     861217 |      128 |      6544 |   1019345 |     702 |
| filter_1800000  |      8564 |   2987090 |     516 |      10992 |    1311134 |      164 |      6801 |   1249625 |     758 |
| filter_2000000  |      7942 |   2597815 |     465 |      10027 |    1562661 |      203 |      6547 |   1592181 |     849 |
| filter_3000000  |      7491 |   1703653 |     339 |       8213 |    1947440 |      294 |      7121 |   2861962 |    1103 |

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

Dotplot of pe.anchor.fa.

http://www.opiniomics.org/generate-a-single-contig-hybrid-assembly-of-e-coli-using-miseq-and-minion-data/

```bash
cd ~/data/dna-seq/e_coli/superreads/

# add a blank line after sequences
cat trimmed_800000/sr/pe.anchor.fa \
    | perl -nl -e '
        /^>/ and print;
        /^\w/ and print qq{$_\n};
    ' \
    > pe.anchor.fa

# simplify header
cat MiSeq/NC_000913.fa \
    | perl -nl -e '
        /^>(\w+)/ and print qq{>$1} and next;
        print;
    ' \
    > NC_000913.fa

perl ~/Scripts/egaz/sparsemem_exact.pl \
    -f pe.anchor.fa -g NC_000913.fa \
    --length 500 -o pe.replace.tsv

cat pe.replace.tsv \
    | perl -nla -e '/\(\-\)/ and print $F[0];' \
    > rc.list

faops some -l 0 -i pe.anchor.fa rc.list stdout \
    > pe.strand.fa
faops some pe.anchor.fa rc.list stdout \
    | faops rc -l 0 stdin stdout \
    >> pe.strand.fa

perl ~/Scripts/egaz/sparsemem_exact.pl \
    -f pe.strand.fa -g NC_000913.fa \
    --length 500 -o pe.replace.tsv

cat pe.strand.fa \
    | perl -nl -e '
        /^>/ and print;
        /^\w/ and print qq{$_\n};
    ' \
    > pe.strand.fas
    
fasops replace pe.strand.fas pe.replace.tsv -o pe.replace.fas

perl -nli -e '/^>.+:(\d+)/ and print qq{>$1} and next; print;' pe.replace.fas

faops filter -l 0 pe.replace.fas pe.replace2.fa

cat pe.replace.fas | grep '>' | sed 's/>//' | sort -n > order.list
fasops subset pe.replace2.fa order.list -o pe.sort.fa

faops n50 -N 0 -C pe.anchor.fa
faops n50 -N 0 -C pe.sort.fa
wc -l pe.replace.tsv

brew install homebrew/versions/gnuplot4
nucmer NC_000913.fa pe.sort.fa
mummerplot -png out.delta

cat NC_000913.fa pe.replace.fas > pe.all.fa
mafft pe.all.fa
```
