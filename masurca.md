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

* Trimmed:

    * N50: 151
    * S: 371,039,918
    * C: 2,457,218

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
    -t sanger -l 151 -q 20 \
    -f trimmed/R1.scythe.fq.gz \
    -r trimmed/R2.scythe.fq.gz \
    -o trimmed/R1.sickle.fq \
    -p trimmed/R2.sickle.fq \
    -s trimmed/single.sickle.fq

find trimmed/ -type f -name "*.sickle.fq" | parallel -j 1 pigz

fastqc -t 8 \
    trimmed/R1.sickle.fq.gz \
    trimmed/R2.sickle.fq.gz \
    trimmed/single.sickle.fq.gz

find . -type d -name "*fastqc" | sort | xargs rm -fr
find . -type f -name "*_fastqc.zip" | sort | xargs rm
find . -type f -name "*matches.txt" | sort | xargs rm
#find . -type f -name "*scythe.fq.gz" | sort | grep trimmed | xargs rm

faops n50 -S -C trimmed/R1.sickle.fq.gz
```

### Down sampling

过高的 coverage 会造成不好的影响. SGA 的文档里也说了类似的事情.

> Very highly-represented sequences (>1000X) can cause problems for SGA... In these cases, it is
> worth considering pre-filtering the data...

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
        ~/data/dna-seq/e_coli/superreads/MiSeq/trimmed/R1.sickle.fq.gz ${count} \
        | gzip > ${DIR_COUNT}/R1.fq.gz
    seqtk sample -s${count} \
        ~/data/dna-seq/e_coli/superreads/MiSeq/trimmed/R1.sickle.fq.gz ${count} \
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

| Name           | fqSize | faSize | Length | Kmer |    EstG | #reads |   RunTime |    SumSR | SR/EstG |
|:---------------|-------:|-------:|-------:|-----:|--------:|-------:|----------:|---------:|--------:|
| MiSeq_50000    |    31M |    15M |    151 |   75 | 2848356 |  15009 | 0:00'56'' |  2432529 |    0.85 |
| MiSeq_100000   |    61M |    33M |    151 |   75 | 4283432 |  23894 | 0:01'19'' |  4442346 |    1.04 |
| MiSeq_150000   |    91M |    49M |    151 |   75 | 4525464 |  18242 | 0:01'38'' |  4880895 |    1.08 |
| MiSeq_200000   |   121M |    66M |    151 |   75 | 4570010 |  14079 | 0:01'24'' |  5740960 |    1.26 |
| MiSeq_300000   |   181M |    98M |    151 |   75 | 4604273 |  14619 | 0:01'39'' |  9248681 |    2.01 |
| MiSeq_400000   |   241M |   131M |    151 |   75 | 4637990 |  15852 | 0:01'56'' | 10223031 |    2.20 |
| MiSeq_500000   |   302M |   164M |    151 |   75 | 4673825 |  17386 | 0:02'17'' | 10663685 |    2.28 |
| MiSeq_600000   |   362M |   197M |    151 |   75 | 4720834 |  19576 | 0:02'31'' | 10996696 |    2.33 |
| MiSeq_700000   |   423M |   229M |    151 |   75 | 4769693 |  21103 | 0:04'09'' | 11244264 |    2.36 |
| MiSeq_800000   |   483M |   262M |    151 |   75 | 4819275 |  23685 | 0:03'00'' | 11668035 |    2.42 |
| MiSeq_900000   |   544M |   295M |    151 |   75 | 4869460 |  25744 | 0:03'11'' | 11959177 |    2.46 |
| MiSeq_1000000  |   604M |   328M |    151 |   75 | 4933858 |  28278 | 0:03'33'' | 12271938 |    2.49 |
| MiSeq_1200000  |   725M |   393M |    151 |   75 | 5052478 |  33423 | 0:04'09'' | 12929921 |    2.56 |
| MiSeq_1400000  |   846M |   459M |    151 |   75 | 5183791 |  39503 | 0:04'22'' | 13405411 |    2.59 |
| MiSeq_1600000  |   967M |   525M |    151 |   75 | 5326650 |  46014 | 0:04'58'' | 14100368 |    2.65 |
| MiSeq_1800000  |   1.1G |   590M |    151 |   75 | 5460717 |  54170 | 0:05'34'' | 14724645 |    2.70 |
| MiSeq_2000000  |   1.2G |   656M |    151 |   75 | 5621863 |  62178 | 0:06'16'' | 15468429 |    2.75 |
| MiSeq_3000000  |   1.8G |   983M |    151 |   75 | 6490892 | 107693 | 0:10'39'' | 18695968 |    2.88 |
| MiSeq_4000000  |   2.4G |   1.3G |    151 |   75 | 7492813 | 159719 | 0:12'15'' | 22406939 |    2.99 |
| MiSeq_5000000  |   3.0G |   1.6G |    151 |   75 | 8630397 | 215063 | 0:18'20'' | 26685370 |    3.09 |
| filter_50000   |    31M |    15M |    151 |  105 | 2683517 |  11057 | 0:00'18'' |  2129505 |    0.79 |
| filter_100000  |    61M |    31M |    151 |  105 | 3770049 |  18816 | 0:00'28'' |  4069741 |    1.08 |
| filter_150000  |    91M |    47M |    151 |  105 | 4152670 |  20137 | 0:00'37'' |  4971171 |    1.20 |
| filter_200000  |   121M |    63M |    151 |  105 | 4326361 |  18890 | 0:00'45'' |  5347654 |    1.24 |
| filter_300000  |   181M |    95M |    151 |  105 | 4467375 |  14864 | 0:00'58'' |  5493211 |    1.23 |
| filter_400000  |   241M |   126M |    151 |  105 | 4524625 |  11781 | 0:01'09'' |  5586213 |    1.23 |
| filter_500000  |   302M |   158M |    151 |  105 | 4566083 |  10247 | 0:01'22'' |  5832859 |    1.28 |
| filter_600000  |   362M |   189M |    151 |  105 | 4590574 |   8853 | 0:01'33'' |  5706053 |    1.24 |
| filter_700000  |   423M |   221M |    151 |  105 | 4611513 |   8433 | 0:01'46'' |  5955084 |    1.29 |
| filter_800000  |   483M |   253M |    151 |  105 | 4627402 |   8339 | 0:02'03'' |  6197805 |    1.34 |
| filter_900000  |   544M |   284M |    151 |  105 | 4647730 |   8310 | 0:02'14'' |  6473929 |    1.39 |
| filter_1000000 |   604M |   316M |    151 |  105 | 4663621 |   8422 | 0:02'29'' |  6702087 |    1.44 |
| filter_1200000 |   725M |   379M |    151 |  105 | 4699665 |   8863 | 0:02'52'' |  7336739 |    1.56 |
| filter_1400000 |   846M |   442M |    151 |  105 | 4735876 |   9313 | 0:03'14'' |  7753472 |    1.64 |
| filter_1600000 |   967M |   506M |    151 |  105 | 4771750 |   9899 | 0:03'51'' |  8309740 |    1.74 |
| filter_1800000 |   1.1G |   569M |    151 |  105 | 4809484 |  10297 | 0:04'26'' |  8688679 |    1.81 |
| filter_2000000 |   1.2G |   632M |    151 |  105 | 4841516 |  10756 | 0:04'49'' |  8953123 |    1.85 |
| filter_3000000 |   1.5G |   777M |    151 |  105 | 4928296 |  12143 | 0:05'57'' |  9662727 |    1.96 |

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

| Name           | TotalFq | TotalFa | RatioDiscard | TotalSubs | RatioSubs | RealG | CovFq | CovFa |  EstG |  SumSR | Est/Real | SumSR/Real | N50SR |
|:---------------|--------:|--------:|-------------:|----------:|----------:|------:|------:|------:|------:|-------:|---------:|-----------:|------:|
| MiSeq_50000    |   14.4M |  12.87M |       0.1061 |    57.03K |    0.0043 | 4.43M |   3.3 |   2.9 | 2.72M |  2.32M |     0.61 |       0.52 |   375 |
| MiSeq_100000   |   28.8M |  28.12M |       0.0238 |   154.15K |    0.0054 | 4.43M |   6.5 |   6.4 | 4.08M |  4.24M |     0.92 |       0.96 |   874 |
| MiSeq_150000   |   43.2M |  42.28M |       0.0212 |   245.39K |    0.0057 | 4.43M |   9.8 |   9.6 | 4.32M |  4.65M |     0.97 |       1.05 |  2366 |
| MiSeq_200000   |   57.6M |  56.42M |       0.0205 |   328.01K |    0.0057 | 4.43M |  13.0 |  12.7 | 4.36M |  5.48M |     0.98 |       1.24 |  5885 |
| MiSeq_300000   |   86.4M |  84.66M |       0.0202 |   495.96K |    0.0057 | 4.43M |  19.5 |  19.1 | 4.39M |  8.82M |     0.99 |       1.99 |  7066 |
| MiSeq_400000   |  115.2M | 112.89M |       0.0201 |    654.4K |    0.0057 | 4.43M |  26.0 |  25.5 | 4.42M |  9.75M |     1.00 |       2.20 |  5514 |
| MiSeq_500000   |    144M |  141.2M |       0.0195 |   818.88K |    0.0057 | 4.43M |  32.5 |  31.9 | 4.46M | 10.17M |     1.01 |       2.30 |  4200 |
| MiSeq_600000   | 172.81M | 169.44M |       0.0195 |   977.41K |    0.0056 | 4.43M |  39.0 |  38.3 |  4.5M | 10.49M |     1.02 |       2.37 |  3423 |
| MiSeq_700000   | 201.61M | 197.72M |       0.0193 |     1.11M |    0.0056 | 4.43M |  45.5 |  44.7 | 4.55M | 10.72M |     1.03 |       2.42 |  2922 |
| MiSeq_800000   | 230.41M | 225.95M |       0.0194 |     1.26M |    0.0056 | 4.43M |  52.1 |  51.0 |  4.6M | 11.13M |     1.04 |       2.51 |  2583 |
| MiSeq_900000   | 259.21M | 254.27M |       0.0190 |     1.41M |    0.0056 | 4.43M |  58.6 |  57.4 | 4.64M | 11.41M |     1.05 |       2.58 |  2330 |
| MiSeq_1000000  | 288.01M | 282.53M |       0.0190 |     1.57M |    0.0056 | 4.43M |  65.1 |  63.8 | 4.71M |  11.7M |     1.06 |       2.64 |  2057 |
| MiSeq_1200000  | 345.61M | 339.12M |       0.0188 |     1.87M |    0.0055 | 4.43M |  78.1 |  76.6 | 4.82M | 12.33M |     1.09 |       2.79 |  1796 |
| MiSeq_1400000  | 403.21M | 395.72M |       0.0186 |     2.17M |    0.0055 | 4.43M |  91.1 |  89.4 | 4.94M | 12.78M |     1.12 |       2.89 |  1528 |
| MiSeq_1600000  | 460.82M | 452.32M |       0.0184 |     2.47M |    0.0055 | 4.43M | 104.1 | 102.2 | 5.08M | 13.45M |     1.15 |       3.04 |  1377 |
| MiSeq_1800000  | 518.42M |  508.9M |       0.0184 |     2.76M |    0.0054 | 4.43M | 117.1 | 115.0 | 5.21M | 14.04M |     1.18 |       3.17 |  1233 |
| MiSeq_2000000  | 576.02M | 565.54M |       0.0182 |     3.06M |    0.0054 | 4.43M | 130.1 | 127.8 | 5.36M | 14.75M |     1.21 |       3.33 |  1117 |
| MiSeq_3000000  | 864.03M | 848.73M |       0.0177 |     4.48M |    0.0053 | 4.43M | 195.2 | 191.7 | 6.19M | 17.83M |     1.40 |       4.03 |   730 |
| MiSeq_4000000  |   1.13G |   1.11G |       0.0173 |     5.88M |    0.0052 | 4.43M | 260.3 | 255.8 | 7.15M | 21.37M |     1.61 |       4.83 |   543 |
| MiSeq_5000000  |   1.41G |   1.38G |       0.0170 |     7.22M |    0.0051 | 4.43M | 325.3 | 319.8 | 8.23M | 25.45M |     1.86 |       5.75 |   439 |
| filter_50000   |   14.4M |  13.43M |       0.0671 |     5.22K |    0.0004 | 4.43M |   3.3 |   3.0 | 2.56M |  2.03M |     0.58 |       0.46 |   189 |
| filter_100000  |   28.8M |  28.41M |       0.0134 |    14.72K |    0.0005 | 4.43M |   6.5 |   6.4 |  3.6M |  3.88M |     0.81 |       0.88 |   208 |
| filter_150000  |   43.2M |  42.98M |       0.0050 |    24.93K |    0.0006 | 4.43M |   9.8 |   9.7 | 3.96M |  4.74M |     0.89 |       1.07 |   241 |
| filter_200000  |   57.6M |  57.44M |       0.0028 |    34.71K |    0.0006 | 4.43M |  13.0 |  13.0 | 4.13M |   5.1M |     0.93 |       1.15 |   288 |
| filter_300000  |   86.4M |  86.25M |       0.0017 |    53.25K |    0.0006 | 4.43M |  19.5 |  19.5 | 4.26M |  5.24M |     0.96 |       1.18 |   444 |
| filter_400000  |  115.2M | 115.04M |       0.0015 |    71.26K |    0.0006 | 4.43M |  26.0 |  26.0 | 4.32M |  5.33M |     0.97 |       1.20 |   699 |
| filter_500000  |    144M |  143.8M |       0.0014 |    88.78K |    0.0006 | 4.43M |  32.5 |  32.5 | 4.35M |  5.56M |     0.98 |       1.26 |   980 |
| filter_600000  | 172.81M | 172.56M |       0.0014 |   109.88K |    0.0006 | 4.43M |  39.0 |  39.0 | 4.38M |  5.44M |     0.99 |       1.23 |  1295 |
| filter_700000  | 201.61M | 201.33M |       0.0014 |   127.14K |    0.0006 | 4.43M |  45.5 |  45.5 |  4.4M |  5.68M |     0.99 |       1.28 |  1594 |
| filter_800000  | 230.41M | 230.11M |       0.0013 |   145.92K |    0.0006 | 4.43M |  52.1 |  52.0 | 4.41M |  5.91M |     1.00 |       1.34 |  1733 |
| filter_900000  | 259.21M | 258.88M |       0.0013 |   164.13K |    0.0006 | 4.43M |  58.6 |  58.5 | 4.43M |  6.17M |     1.00 |       1.39 |  1829 |
| filter_1000000 | 288.01M | 287.65M |       0.0013 |    182.2K |    0.0006 | 4.43M |  65.1 |  65.0 | 4.45M |  6.39M |     1.00 |       1.44 |  1862 |
| filter_1200000 | 345.61M | 345.19M |       0.0012 |   218.72K |    0.0006 | 4.43M |  78.1 |  78.0 | 4.48M |     7M |     1.01 |       1.58 |  1828 |
| filter_1400000 | 403.21M | 402.74M |       0.0012 |   254.37K |    0.0006 | 4.43M |  91.1 |  91.0 | 4.52M |  7.39M |     1.02 |       1.67 |  1750 |
| filter_1600000 | 460.82M | 460.28M |       0.0012 |   289.43K |    0.0006 | 4.43M | 104.1 | 104.0 | 4.55M |  7.92M |     1.03 |       1.79 |  1627 |
| filter_1800000 | 518.42M | 517.84M |       0.0011 |   326.03K |    0.0006 | 4.43M | 117.1 | 117.0 | 4.59M |  8.29M |     1.04 |       1.87 |  1531 |
| filter_2000000 | 576.02M | 575.38M |       0.0011 |   361.42K |    0.0006 | 4.43M | 130.1 | 130.0 | 4.62M |  8.54M |     1.04 |       1.93 |  1434 |
| filter_3000000 |  707.7M | 706.95M |       0.0011 |    440.6K |    0.0006 | 4.43M | 159.9 | 159.7 |  4.7M |  9.22M |     1.06 |       2.08 |  1211 |

* Illumina reads 的分布是有偏性的. 极端 GC 区域, 结构复杂区域都会得到较低的 fq 分值, 本应被 trim 掉.
  但覆盖度过高时, 这些区域之间的 reads 相互支持, 被保留下来的概率大大增加.
    * RatioDiscard 在 CovFq 大于 100 倍时, 快速下降.
* Illumina reads 错误率约为 1% 不到一点. 当覆盖度过高时, 错误的点重复出现的概率要比完全无偏性的情况大一些.
    * 理论上 RatioSubs 应该是恒定值, 但当 CovFq 大于 100 倍时, 这个值在下降, 也就是这些错误的点相互支持, 躲过了
      Kmer 纠错.
* 直接的反映就是 EstG 过大, SumSR 过大.
* 留下的错误片段, 会形成 **伪独立** 片段, 降低 N50 SR
* 留下的错误位点, 会形成 **伪杂合** 位点, 降低 N50 SR

### Create anchors

```bash
cd ~/data/dna-seq/e_coli/superreads/

for count in 50000 100000 150000 200000 300000 400000 500000 600000 700000 800000 900000 1000000 1200000 1400000 1600000 1800000 2000000 3000000 4000000 5000000;
do
    echo
    echo "==> Reads ${count}"
#    DIR_COUNT="$HOME/data/dna-seq/e_coli/superreads/MiSeq_${count}/"
    DIR_COUNT="$HOME/data/dna-seq/e_coli/superreads/filter_${count}/"

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

| Name           |  #cor.fa | #strict.fa | strict/cor | N50SR |    SumSR |   #SR |
|:---------------|---------:|-----------:|-----------:|------:|---------:|------:|
| MiSeq_50000    |   100000 |      76717 |     0.7672 |   375 |  2432529 |  7595 |
| MiSeq_100000   |   200000 |     161610 |     0.8081 |   874 |  4442346 |  7265 |
| MiSeq_150000   |   300000 |     240332 |     0.8011 |  2366 |  4880895 |  3425 |
| MiSeq_200000   |   400000 |     320627 |     0.8016 |  5885 |  5740960 |  1823 |
| MiSeq_300000   |   600000 |     479962 |     0.7999 |  7066 |  9248681 |  2098 |
| MiSeq_400000   |   800000 |     641280 |     0.8016 |  5514 | 10223031 |  2981 |
| MiSeq_500000   |  1000000 |     802104 |     0.8021 |  4200 | 10663685 |  3808 |
| MiSeq_600000   |  1200000 |     963216 |     0.8027 |  3423 | 10996696 |  4785 |
| MiSeq_700000   |  1400000 |    1125118 |     0.8037 |  2922 | 11244264 |  5662 |
| MiSeq_800000   |  1600000 |    1286410 |     0.8040 |  2583 | 11668035 |  6626 |
| MiSeq_900000   |  1800000 |    1449088 |     0.8050 |  2330 | 11959177 |  7413 |
| MiSeq_1000000  |  2000000 |    1609161 |     0.8046 |  2057 | 12271938 |  8522 |
| MiSeq_1200000  |  2400000 |    1935704 |     0.8065 |  1796 | 12929921 | 10364 |
| MiSeq_1400000  |  2800000 |    2260464 |     0.8073 |  1528 | 13405411 | 12278 |
| MiSeq_1600000  |  3200000 |    2586433 |     0.8083 |  1377 | 14100368 | 14388 |
| MiSeq_1800000  |  3600000 |    2912306 |     0.8090 |  1233 | 14724645 | 16778 |
| MiSeq_2000000  |  4000000 |    3239023 |     0.8098 |  1117 | 15468429 | 19143 |
| MiSeq_3000000  |  6000000 |    4881446 |     0.8136 |   730 | 18695968 | 32523 |
| MiSeq_4000000  |  8000000 |    6534196 |     0.8168 |   543 | 22406939 | 48244 |
| MiSeq_5000000  | 10000000 |    8198162 |     0.8198 |   439 | 26685370 | 66799 |
| filter_50000   |   100000 |      88599 |     0.8860 |   189 |  2129505 | 11057 |
| filter_100000  |   200000 |     183864 |     0.9193 |   208 |  4069741 | 18816 |
| filter_150000  |   300000 |     275543 |     0.9185 |   241 |  4971171 | 20137 |
| filter_200000  |   400000 |     366813 |     0.9170 |   288 |  5347654 | 18883 |
| filter_300000  |   600000 |     549791 |     0.9163 |   444 |  5493211 | 14696 |
| filter_400000  |   800000 |     732987 |     0.9162 |   699 |  5586213 | 11245 |
| filter_500000  |  1000000 |     916451 |     0.9165 |   980 |  5832859 |  9225 |
| filter_600000  |  1200000 |    1096768 |     0.9140 |  1295 |  5706053 |  7313 |
| filter_700000  |  1400000 |    1280678 |     0.9148 |  1594 |  5955084 |  6364 |
| filter_800000  |  1600000 |    1462908 |     0.9143 |  1733 |  6197805 |  5956 |
| filter_900000  |  1800000 |    1645888 |     0.9144 |  1829 |  6473929 |  5670 |
| filter_1000000 |  2000000 |    1828888 |     0.9144 |  1862 |  6702087 |  5655 |
| filter_1200000 |  2400000 |    2194568 |     0.9144 |  1828 |  7336739 |  5956 |
| filter_1400000 |  2800000 |    2561491 |     0.9148 |  1750 |  7753472 |  6401 |
| filter_1600000 |  3200000 |    2928526 |     0.9152 |  1627 |  8309740 |  7185 |
| filter_1800000 |  3600000 |    3294373 |     0.9151 |  1531 |  8688679 |  7780 |
| filter_2000000 |  4000000 |    3660846 |     0.9152 |  1434 |  8953123 |  8508 |
| filter_3000000 |  4914436 |    4500883 |     0.9158 |  1211 |  9662727 | 10589 |

| Name           | N50Anchor | SumAnchor | #anchor | N50Anchor2 | SumAnchor2 | #anchor2 | N50Others | SumOthers | #others |
|:---------------|----------:|----------:|--------:|-----------:|-----------:|---------:|----------:|----------:|--------:|
| MiSeq_50000    |      1304 |     20340 |      15 |       1355 |      12862 |        9 |       373 |   2399327 |    7571 |
| MiSeq_100000   |      1674 |   1184783 |     714 |       1429 |     431987 |      298 |       592 |   2825576 |    6253 |
| MiSeq_150000   |      2973 |   3108720 |    1196 |       2259 |     608083 |      281 |       792 |   1164092 |    1948 |
| MiSeq_200000   |      5953 |   2776938 |     604 |       6601 |    1162604 |      234 |      5097 |   1801418 |     985 |
| MiSeq_300000   |      5810 |    124911 |      28 |       7965 |    1074088 |      162 |      6978 |   8049682 |    1908 |
| MiSeq_400000   |         0 |         0 |       0 |       6606 |     154187 |       29 |      5509 |  10068844 |    2952 |
| MiSeq_500000   |         0 |         0 |       0 |       6237 |      25431 |        6 |      4197 |  10638254 |    3802 |
| MiSeq_600000   |         0 |         0 |       0 |       2839 |       4756 |        2 |      3423 |  10991940 |    4783 |
| MiSeq_700000   |         0 |         0 |       0 |       4190 |       4190 |        1 |      2920 |  11240074 |    5661 |
| MiSeq_800000   |         0 |         0 |       0 |          0 |          0 |        0 |      2583 |  11668035 |    6626 |
| MiSeq_900000   |         0 |         0 |       0 |          0 |          0 |        0 |      2330 |  11959177 |    7413 |
| MiSeq_1000000  |         0 |         0 |       0 |          0 |          0 |        0 |      2057 |  12271938 |    8522 |
| MiSeq_1200000  |         0 |         0 |       0 |          0 |          0 |        0 |      1796 |  12929921 |   10364 |
| MiSeq_1400000  |         0 |         0 |       0 |          0 |          0 |        0 |      1528 |  13405411 |   12278 |
| MiSeq_1600000  |         0 |         0 |       0 |          0 |          0 |        0 |      1377 |  14100368 |   14388 |
| MiSeq_1800000  |         0 |         0 |       0 |          0 |          0 |        0 |      1233 |  14724645 |   16778 |
| MiSeq_2000000  |      1054 |      2072 |       2 |          0 |          0 |        0 |      1117 |  15466357 |   19141 |
| MiSeq_3000000  |      2351 |      4125 |       2 |          0 |          0 |        0 |       730 |  18691843 |   32521 |
| MiSeq_4000000  |      1863 |      1863 |       1 |       1127 |       1127 |        1 |       543 |  22403949 |   48242 |
| MiSeq_5000000  |      1856 |      1856 |       1 |          0 |          0 |        0 |       439 |  26683514 |   66798 |
| filter_50000   |         0 |         0 |       0 |          0 |          0 |        0 |       189 |   2129505 |   11057 |
| filter_100000  |         0 |         0 |       0 |          0 |          0 |        0 |       208 |   4069741 |   18816 |
| filter_150000  |      1157 |     40699 |      34 |          0 |          0 |        0 |       240 |   4930472 |   20103 |
| filter_200000  |      1246 |    161257 |     125 |       1728 |      10031 |        6 |       281 |   5176366 |   18752 |
| filter_300000  |      1361 |    793318 |     552 |       1776 |      45203 |       24 |       373 |   4654690 |   14120 |
| filter_400000  |      1486 |   1342116 |     876 |       2552 |     167672 |       74 |       495 |   4076425 |   10295 |
| filter_500000  |      1625 |   1527661 |     938 |       2554 |     422392 |      176 |       652 |   3882806 |    8111 |
| filter_600000  |      1778 |   1908999 |    1090 |       2813 |     555989 |      211 |       757 |   3241065 |    6012 |
| filter_700000  |      1868 |   1817196 |    1001 |       2950 |     797312 |      293 |       922 |   3340576 |    5070 |
| filter_800000  |      1976 |   1683436 |     901 |       2828 |     936518 |      354 |      1177 |   3577851 |    4701 |
| filter_900000  |      2005 |   1516617 |     800 |       2904 |     959085 |      366 |      1465 |   3998227 |    4504 |
| filter_1000000 |      2066 |   1405798 |     716 |       2789 |    1013750 |      392 |      1500 |   4282539 |    4547 |
| filter_1200000 |      1932 |    925720 |     499 |       2798 |    1070231 |      408 |      1617 |   5340788 |    5049 |
| filter_1400000 |      1892 |    695011 |     382 |       2626 |     998489 |      407 |      1553 |   6059972 |    5612 |
| filter_1600000 |      1767 |    495451 |     290 |       2464 |     861560 |      364 |      1489 |   6952729 |    6531 |
| filter_1800000 |      1648 |    353284 |     209 |       2521 |     763884 |      322 |      1419 |   7571511 |    7249 |
| filter_2000000 |      1656 |    288461 |     177 |       2367 |     680319 |      298 |      1334 |   7984343 |    8033 |
| filter_3000000 |      1604 |    162776 |     106 |       2168 |     439954 |      207 |      1154 |   9059997 |   10276 |
