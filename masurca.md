# [MaSuRCA](http://www.genome.umd.edu/masurca.html) 安装与样例

doi:10.1093/bioinformatics/btt476

[MaSuRCA_QuickStartGuide](ftp://ftp.genome.umd.edu/pub/MaSuRCA/MaSuRCA_QuickStartGuide.pdf)

## 特点

de novo 基因组序列的拼接有以下几种主流的策略:

1. Overlap–layout–consensus (OLC) assembly
    * 主要用于长reads, 在Sanger测序时代就基本发展完备, 三代时代又重新发展
    * 代表: Celera Assembler, PCAP, Canu

2. de Bruijn graph (德布鲁因图)
    * 二代测序的主流
    * 代表: Velvet, SOAPdenovo, Allpaths-LG

3. String graph
    * 与 de Bruijn graph 类似, 但较为节省内存
    * 代表: SGA

MaSuRCA 提出了一种新的策略, Super-reads. 主要思想是将多个短 reads 按 1 bp 延伸, 合并得到数量少得多的长 reads.
在单倍体基因组的情况下, 无论覆盖度是多少 (50, 100), 最终的 super-reads 覆盖度都趋向于 2x. 高杂合基因组则趋向于 4x.

合并后的 super-reads 的 N50 约为 2-4 kbp.

## 版本

version 3.1.3.

homebrew-science 里的版本是 2.3.2b, 3.1.3 的
[PR](https://github.com/Homebrew/homebrew-science/pull/3802) 也有了, 但没合并.

九月 UMD 的 ftp 上有了 3.2.1 版, 多了 CA8, MUMmer 和 PacBio 三个目录, 还末详细研究.

http://ccb.jhu.edu/software.shtml

> New modules coming soon include methods to create hybrid assemblies using both Illumina and PacBio
> data.

## 依赖

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

## 安装

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

## 样例数据

MaSuRCA 发表在 Bioinformatics 时自带的测试数据.

> IMPORTANT! Do not pre‐process Illumina data before providing it to MaSuRCA. Do not do any
> trimming, cleaning or error correction. This WILL deteriorate the assembly

Super-reads在 `work1/superReadSequences.fasta`, `work2/` 和 `work2.1/` 是 short jump 的处理, 不用管.
`superReadSequences_shr.frg` 里面的 super-reads 是作过截断处理的, 数量不对.

> Assembly result. The final assembly files are under CA/10-gapclose and named 'genome.ctg.fasta'
> for the contig sequences and 'genome.scf.fasta' for the scaffold sequences.

MaSuRCA-3.1.3 supports gzipped fastq files while MaSuRCA-2.1.0 doesn't.

### Rhodobacter sphaeroides (球形红细菌)

高 GC 原核生物 (68%), 基因组 4.5 Mbp.

* 数据

```bash
mkdir -p ~/data/test
cd ~/data/test

wget -m ftp://ftp.genome.umd.edu/pub/MaSuRCA/test_data/rhodobacter .

mv ftp.genome.umd.edu/pub/MaSuRCA/test_data/rhodobacter .
rm -fr ftp.genome.umd.edu
find . -name ".listing" | xargs rm

```

#### Illumina PE, Short Jump and Sanger4

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

#### Illumina PE, Short Jump and Sanger

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

#real    15m2.065s
#user    73m5.869s
#sys     49m29.684s
time bash assemble.sh
```

#### Illumina PE and Short Jump

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

#real    13m32.175s
#user    71m48.583s
#sys     29m41.092s
time bash assemble.sh
```

#### Illumina PE

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

#real    5m46.738s
#user    20m58.316s
#sys     4m21.681s
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

cd sr
ln -s ../pe.cor.fa .
ln -s ../work1/superReadSequences.fasta .

faops size superReadSequences.fasta > sr.chr.sizes

# tolerates 1 substitution
cat pe.cor.fa \
    | perl -nle '/>/ or next; /sub.+sub/ and next; />(\w+)/ and print $1;' \
    > pe.strict.txt

# correct
#cat pe.strict.txt | sort | uniq > uniq.txt

# No Ns; longer than 69 bp
faops some pe.cor.fa pe.strict.txt stdout \
    | faops filter -n 0 -a 70 -l 0 stdin stdout \
    > pe.strict.fa

#N50	4705
#S	8609951
#C	4043
faops n50 -N 50 -S -C superReadSequences.fasta
#C	2050868
faops n50 -N 0 -C pe.cor.fa
#C	922664
faops n50 -N 0 -C pe.strict.fa

# bowtie2
#bowtie2-build superReadSequences.fasta superReadSequences
#bowtie2 -x superReadSequences \
#    -N 0 -p 4 -f \
#    -U pe.strict.fa -S strict.sam

#----------------------------#
# unambiguous
#----------------------------#

# https://www.biostars.org/p/163429/
# "out" gets all reads. "outm" only gets mapped reads. But with "ambig=toss", 
# reads mapping to multiple locations will be classified as unmapped, so they will not go to outm.
bbmap.sh \
    maxindel=0 strictmaxindel perfectmode nodisk \
    ambiguous=toss \
    ref=superReadSequences.fasta in=pe.strict.fa \
    outm=unambiguous.sam outu=unmapped.sam

java -jar ~/share/picard-tools-1.128/picard.jar \
    CleanSam \
    INPUT=unambiguous.sam \
    OUTPUT=_clean.bam
java -jar ~/share/picard-tools-1.128/picard.jar \
    SortSam \
    INPUT=_clean.bam \
    OUTPUT=_sort.bam \
    SORT_ORDER=coordinate \
    VALIDATION_STRINGENCY=LENIENT
rm _clean.bam
mv _sort.bam unambiguous.sort.bam
#samtools index unambiguous.sort.bam

genomeCoverageBed -bga -split -g sr.chr.sizes -ibam unambiguous.sort.bam \
    | perl -nlae '
        $F[3] == 0 and next;
        $F[3] == 1 and next;
        printf qq{%s:%s-%s\n}, $F[0], $F[1] + 1, $F[2];
    ' \
    > unambiguous.cover.txt

#----------------------------#
# ambiguous
#----------------------------#
cat unmapped.sam \
    | perl -nle '
        /^@/ and next;
        @fields = split "\t";
        print $fields[0];
    ' \
    > pe.unmapped.txt
faops some pe.strict.fa pe.unmapped.txt pe.unmapped.fa

bbmap.sh \
    maxindel=0 strictmaxindel perfectmode nodisk \
    ref=superReadSequences.fasta in=pe.unmapped.fa \
    outm=ambiguous.sam outu=unmapped2.sam

java -jar ~/share/picard-tools-1.128/picard.jar \
    CleanSam \
    INPUT=ambiguous.sam \
    OUTPUT=_clean.bam
java -jar ~/share/picard-tools-1.128/picard.jar \
    SortSam \
    INPUT=_clean.bam \
    OUTPUT=_sort.bam \
    SORT_ORDER=coordinate \
    VALIDATION_STRINGENCY=LENIENT
rm _clean.bam
mv _sort.bam ambiguous.sort.bam

genomeCoverageBed -bga -split -g sr.chr.sizes -ibam ambiguous.sort.bam \
    | perl -nlae '
        $F[3] == 0 and next;
        printf qq{%s:%s-%s\n}, $F[0], $F[1] + 1, $F[2];
    ' \
    > ambiguous.cover.txt

jrunlist cover unambiguous.cover.txt 
runlist stat unambiguous.cover.txt.yml -s sr.chr.sizes -o unambiguous.cover.csv

jrunlist cover ambiguous.cover.txt 
runlist stat ambiguous.cover.txt.yml -s sr.chr.sizes -o ambiguous.cover.csv

runlist compare --op diff unambiguous.cover.txt.yml ambiguous.cover.txt.yml -o unique.cover.yml
runlist stat unique.cover.yml -s sr.chr.sizes -o stdout \
    | perl -nla -F"," -e '
        $F[0] eq q{chr} and next;
        $F[0] eq q{all} and next;
        $F[2] < 500 and next;
        $F[3] < 0.95 and next;
        print $F[0];
    ' \
    | sort -n \
    > anchor.txt

faops some superReadSequences.fasta anchor.txt pe.anchor.fa
faops n50 -N 50 -S -C pe.anchor.fa

```


#### 结果比较

```bash
cd ~/data/test/

printf "| %s | %s | %s | %s | %s | %s | %s | %s |\n" \
    "name" "N50 SR" "#SR" "N50 Contig" "#Contig" "N50 Scaffold" "#Scaffold" "Est. G" \
    > stat.md
printf "|---|--:|--:|--:|--:|--:|--:|--:|\n" >> stat.md

for d in rhodobacter_PE_SJ_Sanger4 rhodobacter_PE_SJ_Sanger rhodobacter_PE_SJ rhodobacter_PE rhodobacter_superreads;
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

| name          | N50 SR |  #SR | N50 Contig | #Contig | N50 Scaffold | #Scaffold |  Est. G |
|:--------------|-------:|-----:|-----------:|--------:|-------------:|----------:|--------:|
| PE_SJ_Sanger4 |   4586 | 4187 |     205225 |      69 |      3196849 |        35 | 4602968 |
| PE_SJ_Sanger  |   4586 | 4187 |      63274 |     141 |      3070846 |        28 | 4602968 |
| PE_SJ         |   4586 | 4187 |      43125 |     219 |      3058404 |        59 | 4602968 |
| PE            |   4705 | 4043 |      20826 |     407 |        34421 |       278 | 4595684 |
| superreads    |   4705 | 4043 |            |         |              |           | 4595684 |
