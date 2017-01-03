# PacBio consensus

现在主流的两种 PacBio 平台
[RS II 与 Sequel 对比](http://allseq.com/knowledge-bank/sequencing-platforms/pacific-biosciences/)

P 指得是聚合酶, C 是化学试剂.

|                          | RS II (P6-C4) |  Sequel  |
|:-------------------------|:-------------:|:--------:|
| Run time                 |    240 min    | 240 min  |
| Total output             |   0.5-1 Gb    | 5-10 Gb  |
| Output/day               |     2 Gb      |  20 Gb   |
| Mean read length         |   10-15 kb    | 10-15 kb |
| Single pass accuracy     |     ~86%      |   ~86%   |
| Consensus (30X) accuracy |   >99.999%    | >99.999% |
| # of reads               |      50k      |   500k   |
| Instrument price         |     $700k     |  $350k   |
| Run price                |     $400      |   $850   |

|                    |  Sequel   |                 原因                 |
|:-------------------|:---------:|:-----------------------------------:|
| Human Whole Genome |  Ok/Good  | 贵; 低偏向, 长读长, 利于鉴定结构变异及组装 |
| Small Genome       |   Good    |        长读长, 只需要较低的通量         |
| Targeted           |   Good    |        长读长, 只需要较低的通量         |
| Transcriptome      | Poor/Good |      贵; 但二代没法得到全长的转录本       |
| Metagenomics       |  Poor/Ok  |        贵; 但利于 de novo 组装        |
| Exome              |   Poor    |        贵; 长读长对外显子没有用处        |
| RNA Profiling      |   Poor    |                 贵                  |
| ChIP-Seq           |   Poor    |                 贵                  |

## 文档

* PacBio 在 github 上的[首页](https://github.com/PacificBiosciences)
* [Quiver HowTo](https://github.com/PacificBiosciences/GenomicConsensus/blob/master/doc/HowTo.rst)
* [Quiver FAQ](https://github.com/PacificBiosciences/GenomicConsensus/blob/master/doc/FAQ.rst)
* [FALCON Manual](https://github.com/PacificBiosciences/FALCON/wiki/Manual)
* [FALCON Tips](https://github.com/PacificBiosciences/FALCON/wiki/Tips)
* [PacBio 的 slides](https://speakerdeck.com/pacbio)
* HDF5 即将成为历史, PacBio 正在向 BAM 转移
* Falcon 问题合集
    * [Trace assembled and unassembled reads in FALCON](https://github.com/PacificBiosciences/FALCON/issues/472)
    * [Is there any need to polish the assembly result with quiver?](https://github.com/PacificBiosciences/FALCON/issues/304)
    * [minimum sequencing depth requirement for FALCON](https://github.com/PacificBiosciences/FALCON/issues/256)
    * [Hybrid Assembly using falcon](https://github.com/PacificBiosciences/FALCON/issues/282)
    * 调整 falcon 参数
        * [Falcon assembly](https://github.com/PacificBiosciences/FALCON/issues/308)
        * [how to set the appropriate config file for larger genome using local mode](https://github.com/PacificBiosciences/FALCON/issues/466)

## 分析平台的历史

GenomicConsensus 是 PacBio 的组合程序包 SMRT Analysis Software (SMRTanalysis) 的一部分. 用于 consensus 和
variant calling. SMRTanalysis 的当前版本为 v2.3.0, 发表时间为2014年. v3.0 好像已经跳票, v3.2
不知道什么时候出来.

SMRTanalysis 包括了一些第三方程序:

* 编程语言
    * Java 7
    * Mono 3
    * Perl 5.8
    * Python 2.7
    * Scala 2.9
* 平台
    * Tomcat 7.0.23
    * MySQL 5.1.73
    * Docutils
* 生物信息学工具
    * Celera Assembler 8.1
    * GMAP
    * HMMER 3.1
    * SAMtools

在版本更替过程中, 出现过多个程序, 有些已经死了, 有的正在死.

* Quiver - 基于条件随机场 (conditional random field, CRF), 计算拟极大似然值 (maximum quasi-likelihood),
  以降低 consensus 的错误率, 最近版本中已经被放弃, 只用于 PacBio RS.
* Arrow - 基于隐马模型 (HMM), 适用于 PacBio Sequel and RS.
* Plurality - 用于variant calling, 忽略.
* EviCons - v1.3.1 中移除.

[GenomicConsensus](https://github.com/PacificBiosciences/GenomicConsensus) 背后的库叫
[ConsensusCore](https://github.com/PacificBiosciences/ConsensusCore), 这是安装 Quiver 所需要的.

但是, ConsensusCore 也死了, 后继者叫做
[ConsensusCore2](https://github.com/PacificBiosciences/ConsensusCore2), 这个后继者也未能幸免.

ConsensusCore2 的后继者叫 [unanimity](https://github.com/PacificBiosciences/unanimity). 这个家伙已经与
Quiver 没关系了. 因此, 我们不能直接从最新的代码中得到可以运行的 Quiver.

PacBio 也知道它的程序是一团乱麻, 给了一个从源码安装的方法,
[pitchfork](https://github.com/PacificBiosciences/pitchfork), 还很酷地表示, 这是 unsupported.

## 使用 pitchfork 安装 GenomicConsensus 和 falcon

### 安装Linuxbrew

```bash
echo "==> Install dependencies"
sudo apt-get install build-essential curl git python-setuptools ruby

echo "==> Clone latest linuxbrew"
git clone https://github.com/Linuxbrew/brew.git ~/.linuxbrew

# .bashrc
if grep -q -i linuxbrew $HOME/.bashrc; then
    echo "==> .bashrc already contains linuxbrew"
else
    echo "==> Update .bashrc"

    LB_PATH='export PATH="$HOME/.linuxbrew/bin:$PATH"'
    LB_MAN='export MANPATH="$HOME/.linuxbrew/share/man:$MANPATH"'
    LB_INFO='export INFOPATH="$HOME/.linuxbrew/share/info:$INFOPATH"'
    echo '# Linuxbrew' >> $HOME/.bashrc
    echo $LB_PATH >> $HOME/.bashrc
    echo $LB_MAN  >> $HOME/.bashrc
    echo $LB_INFO >> $HOME/.bashrc
    echo >> $HOME/.bashrc

    eval $LB_PATH
    eval $LB_MAN
    eval $LB_INFO
fi
```

### 安装最新的第三方依赖.

```bash
brew install md5sha1sum
brew install zlib boost openblas
brew install python cmake ccache hdf5
brew install samtools
brew cleanup # only keep the latest version

pip install --upgrade pip
pip install virtualenv
```

其它可能有用的程序.

```bash
echo "==> Add tap science"
brew tap homebrew/science
brew tap wang-q/tap

echo "==> Install bioinfomatics softwares"
brew install clustal-w mafft    # aligning
brew install seqtk              # fa/fq transforming
brew install quast              # assembly statistics

echo "==> Install wang-q/tap"
brew install faops
```

下载其它第三方依赖.

```bash
mkdir -p ~/share/thirdparty
cd ~/share/thirdparty

proxychains4 wget -N https://prdownloads.sourceforge.net/swig/swig-3.0.8.tar.gz
proxychains4 wget -N https://prdownloads.sourceforge.net/pcre/pcre-8.38.tar.gz 
proxychains4 wget -N http://eddylab.org/software/hmmer3/3.1b2/hmmer-3.1b2.tar.gz

```

### 通过 pitchfork 编译.

```bash
mkdir -p ~/share
cd ~/share
git clone https://github.com/PacificBiosciences/pitchfork
cd ~/share/pitchfork

cat <<EOF > settings.mk
HAVE_ZLIB     = $(brew --prefix)/Cellar/$(brew list --versions zlib | sed 's/ /\//')
HAVE_BOOST    = $(brew --prefix)/Cellar/$(brew list --versions boost | sed 's/ /\//')
HAVE_OPENBLAS = $(brew --prefix)/Cellar/$(brew list --versions openblas | sed 's/ /\//')

HAVE_PYTHON   = $(brew --prefix)/bin/python
HAVE_CMAKE    = $(brew --prefix)/bin/cmake
HAVE_CCACHE   = $(brew --prefix)/Cellar/$(brew list --versions ccache | sed 's/ /\//')/bin/ccache
HAVE_HDF5     = $(brew --prefix)/Cellar/$(brew list --versions hdf5 | sed 's/ /\//')

EOF

# fix bugs in several Makefile
sed -i".bak" "/rsync/d" ~/share/pitchfork/ports/python/virtualenv/Makefile

sed -i".bak" "s/-- third-party\/cpp-optparse/--remote/" ~/share/pitchfork/ports/pacbio/bam2fastx/Makefile
sed -i".bak" "/third-party\/gtest/d" ~/share/pitchfork/ports/pacbio/bam2fastx/Makefile
sed -i".bak" "/ccache /d" ~/share/pitchfork/ports/pacbio/bam2fastx/Makefile

cd ~/share/pitchfork
make GenomicConsensus
make pbfalcon
```

编译好的可执行文件与库文件在 `~/share/pitchfork/deployment`.

试运行.

```bash
source ~/share/pitchfork/deployment/setup-env.sh

quiver --help
```

单独安装 dextractor, 稍稍修改了下.

```bash
cd ~/share
git clone https://github.com/wang-q/DEXTRACTOR
cd DEXTRACTOR

cat <<EOF > settings.mk
HAVE_ZLIB = $(brew --prefix)/Cellar/$(brew list --versions zlib | sed 's/ /\//')
HAVE_HDF5 = $(brew --prefix)/Cellar/$(brew list --versions hdf5 | sed 's/ /\//')

EOF

make

```

### 直接安装 falcon-integrate, 现在不推荐

[wiki page](https://github.com/PacificBiosciences/FALCON-integrate/wiki/Installation)

```bash
mkdir -p $HOME/share
cd $HOME/share

git clone git://github.com/PacificBiosciences/FALCON-integrate.git
cd FALCON-integrate
git checkout master  # or whatever version you want
make init
source env.sh
make config-edit-user
make -j all

# Test data stored in dropbox. f* gfw
# make test
```

编译完成后, 会生成`fc_env`目录, 里面是可执行文件. `tree -L 2 fc_env`, `6 directories, 79 files`.

## falcon 样例数据

falcon-examples里的数据是通过一个小众程序`git-sym`从dropbox下载的, 在墙内无法按说明文件里的提示来使用.

同时其内的很多设置都是写死的集群路径, 以及sge配置, 大大增加了复杂度, 并让人无法理解.

注意:

* fasta文件**必须**以`.fasta`为扩展名
* fasta文件中的序列名称, 必须符合falcon的要求, 即sra默认名称**不符合要求**, 错误提示为`Pacbio header line format
  error`
* [这里](https://github.com/PacificBiosciences/FALCON/issues/251)有个脚本帮助解决这个问题. 已经放到本地,
  `falcon_name_fasta.pl`

### `falcon/example`里的 [*E. coli* 样例](https://github.com/PacificBiosciences/FALCON/wiki/Setup:-Complete-example).

* 过墙下载以下三个文件

```bash
mkdir -p $HOME/data/pacbio/rawdata/ecoli_test
cd $HOME/data/pacbio/rawdata/ecoli_test

proxychains4 wget -c https://www.dropbox.com/s/tb78i5i3nrvm6rg/m140913_050931_42139_c100713652400000001823152404301535_s1_p0.1.subreads.fasta
proxychains4 wget -c https://www.dropbox.com/s/v6wwpn40gedj470/m140913_050931_42139_c100713652400000001823152404301535_s1_p0.2.subreads.fasta
proxychains4 wget -c https://www.dropbox.com/s/j61j2cvdxn4dx4g/m140913_050931_42139_c100713652400000001823152404301535_s1_p0.3.subreads.fasta
```

* 配置文件及运行
    * `daligner`
        * `0-rawreads/job_*`
        * 每进程两线程
    * `fc_consensus`
        * `0-rawreads/m_*`
        * 由 `falcon_sense_option` 里的 `--n_core` 指定线程数. 内部会竞争 CPU, 超出 CPU 数量会极大地降低性能
    * `FA4Falcon`
        * `0-rawreads/preads/cns_*`
        * 前面合并的 rawreads 生成 preads, 高 I/O. 耗时最长.

```bash
source ~/share/pitchfork/deployment/setup-env.sh

if [ -d $HOME/data/pacbio/ecoli_test ];
then
    rm -fr $HOME/data/pacbio/ecoli_test
fi
mkdir -p $HOME/data/pacbio/ecoli_test
cd $HOME/data/pacbio/ecoli_test
find $HOME/data/pacbio/rawdata/ecoli_test -name "*.fasta" > input.fofn

# https://github.com/PacificBiosciences/FALCON/blob/master/examples/fc_run_ecoli.cfg
cat <<EOF > fc_run.cfg
[General]
job_type = local

# list of files of the initial bas.h5 files
input_fofn = input.fofn

input_type = raw
#input_type = preads

# The length cutoff used for seed reads used for initial mapping
length_cutoff = 12000

# The length cutoff used for seed reads used for pre-assembly
length_cutoff_pr = 12000

# Cluster queue setting
sge_option_da =
sge_option_la =
sge_option_pda =
sge_option_pla =
sge_option_fc =
sge_option_cns =

pa_concurrent_jobs = 4
ovlp_concurrent_jobs = 4

pa_HPCdaligner_option =  -v -B4 -t16 -e.70 -l1000 -s1000
ovlp_HPCdaligner_option = -v -B4 -t32 -h60 -e.96 -l500 -s1000

pa_DBsplit_option = -x500 -s50
ovlp_DBsplit_option = -x500 -s50

falcon_sense_option = --output_multi --min_idt 0.70 --min_cov 4 --max_n_read 200 --n_core 2

overlap_filtering_setting = --max_diff 100 --max_cov 100 --min_cov 20 --bestn 10 --n_core 2

EOF

# macOS, i7-6700k, 32G RAM, SSD
# Unfinished

# Ubuntu 14.04, E5-2690 v3 x 2, 128G RAM, HDD
#real    116m27.337s
#user    940m48.526s
#sys     194m47.010s
time fc_run fc_run.cfg
```

* 结果文件
    * `ecoli_test/0-rawreads/`
        * `0-rawreads/preads/` - the error corrected reads
    * `ecoli_test/1-preads_ovl/` - pread overlaps
    * `ecoli_test/2-asm-falcon/`
        * `p_ctg.fa` - primary contigs, 组装好的 draft genome
        * `a_ctg.fa` - alternative contigs, 无法区分的 contigs, 可能是二倍体, 也可能是重复序列
        * `sg_edges_list` - 原始 reads 之间的联系, 也就是组装 string graph 里的 edges. 可以用它将 reads
          映射回 contigs

### 复活草

* 预处理

```text
$ ls -al ~/zlc/Oropetium_thomaeum/pacbio/data/
total 2517104
drwxrwxr-x 2 wangq wangq       4096 Nov  2 15:03 .
drwxrwxr-x 4 wangq wangq       4096 Nov  2 15:04 ..
-rw-rw-r-- 1 wangq wangq 2577500677 Nov  2 15:36 head80.fa

$ head -n 1 ~/zlc/Oropetium_thomaeum/pacbio/data/head80.fa
>SRR2058409.1 1 length=5249

$ perl ~/Scripts/sra/falcon_name_fasta.pl -i data/head80.fa

$ head -n 1 ~/zlc/Oropetium_thomaeum/pacbio/data/head80.fa.outfile
>falcon_read/000001/0_5249

$ mv ~/zlc/Oropetium_thomaeum/pacbio/data/head80.fa.outfile ~/zlc/Oropetium_thomaeum/pacbio/data/head80.fasta
```

* 配置文件及运行

```bash
cd $HOME/share/FALCON-integrate
source env.sh

if [ -d ~/zlc/Oropetium_thomaeum/pacbio/falcon ];
then
    rm -fr ~/zlc/Oropetium_thomaeum/pacbio/falcon
fi
mkdir -p ~/zlc/Oropetium_thomaeum/pacbio/falcon
cd ~/zlc/Oropetium_thomaeum/pacbio/falcon
find ~/zlc/Oropetium_thomaeum/pacbio/data/ -name "*.fasta" > input.fofn

cat <<EOF > fc_run.cfg
[General]
job_type = local

# list of files of the initial bas.h5 files
input_fofn = input.fofn

input_type = raw
#input_type = preads

# The length cutoff used for seed reads used for initial mapping
length_cutoff = 12000

# The length cutoff used for seed reads used for pre-assembly
length_cutoff_pr = 12000

# Cluster queue setting
sge_option_da =
sge_option_la =
sge_option_pda =
sge_option_pla =
sge_option_fc =
sge_option_cns =

pa_concurrent_jobs = 16
ovlp_concurrent_jobs = 16

pa_HPCdaligner_option =  -v -B4 -t16 -e.70 -l1000 -s1000
ovlp_HPCdaligner_option = -v -B4 -t32 -h60 -e.96 -l500 -s1000

pa_DBsplit_option = -x500 -s50
ovlp_DBsplit_option = -x500 -s50

falcon_sense_option = --output_multi --min_idt 0.70 --min_cov 4 --max_n_read 200 --n_core 6

overlap_filtering_setting = --max_diff 100 --max_cov 100 --min_cov 20 --bestn 10 --n_core 24

EOF

fc_run fc_run.cfg
```

### Atha Ler-0

* 三代原始数据

```bash
cd ~/data/pacbio/rawdata/
perl ~/Scripts/download/list.pl -u https://downloads.pacbcloud.com/public/SequelData/ArabidopsisDemoData/
perl ~/Scripts/download/download.pl -a -i public_SequelData_ArabidopsisDemoData.yml

aria2c -x 9 -s 3 -c -i /home/wangq/data/pacbio/rawdata/public_SequelData_ArabidopsisDemoData.yml.txt
```

* 二代数据

    之前在 ERA 下载的数据, 方法在[这里](README.md#ath19). 这里用的是 GA IIx, 长度只有 50 bp, 放弃.


```bash
mkdir -p ~/data/dna-seq/atha_ler_0/superreads/SRR616965
cd ~/data/dna-seq/atha_ler_0/superreads/SRR616965

perl ~/Scripts/sra/superreads.pl \
    ~/data/dna-seq/atha_ler_0/process/Ler-0-2/SRR616965/SRR616965_1.fastq.gz \
    ~/data/dna-seq/atha_ler_0/process/Ler-0-2/SRR616965/SRR616965_2.fastq.gz \
    -s 450 -d 50 --long

```

`.subreads.bam` to fasta

```bash
mkdir -p $HOME/data/pacbio/rawdata/ler0_test
cd $HOME/data/pacbio/rawdata/ler0_test

dextract ~/data/pacbio/rawdata/public/SequelData/ArabidopsisDemoData/SequenceData/1_A01_customer/m54113_160913_184949.subreads.bam
```


```bash
source ~/share/pitchfork/deployment/setup-env.sh

if [ -d $HOME/data/pacbio/ler0_test ];
then
    rm -fr $HOME/data/pacbio/ler0_test
fi
mkdir -p $HOME/data/pacbio/ler0_test
cd $HOME/data/pacbio/ler0_test
find $HOME/data/pacbio/rawdata/public/SequelData/ArabidopsisDemoData -name "*.subreads.bam" > input.fofn

cat <<EOF > fc_run.cfg
[General]
job_type = local

# list of files of the initial bas.h5 files
input_fofn = input.fofn

input_type = raw
#input_type = preads

# The length cutoff used for seed reads used for initial mapping
length_cutoff = 12000

# The length cutoff used for seed reads used for pre-assembly
length_cutoff_pr = 12000

# Cluster queue setting
sge_option_da =
sge_option_la =
sge_option_pda =
sge_option_pla =
sge_option_fc =
sge_option_cns =

pa_concurrent_jobs = 16
ovlp_concurrent_jobs = 16

pa_HPCdaligner_option =  -v -B4 -t16 -e.70 -l1000 -s1000
ovlp_HPCdaligner_option = -v -B4 -t32 -h60 -e.96 -l500 -s1000

pa_DBsplit_option = -x500 -s50
ovlp_DBsplit_option = -x500 -s50

falcon_sense_option = --output_multi --min_idt 0.70 --min_cov 4 --max_n_read 200 --n_core 6

overlap_filtering_setting = --max_diff 100 --max_cov 100 --min_cov 20 --bestn 10 --n_core 24

EOF

fc_run fc_run.cfg
```

### 其它模式生物

用这篇文章里提供的样例, doi:10.1038/sdata.2014.45.

## 其它相关的程序

### PacBio 自产

* HGAP: Hierarchical Genome Assembly Process，层次基因组组装, 以相对较长的读长数据为种子 (Seeding Reads),
  以相对较短的读长数据用于内部纠错. 这个时候得到的读长数据足够长也足够准确, 完全可以用于 de novo 组装,
  而无需二代数据帮忙.
* PBJelly: 用于gapclosing,
  [这里有简介.](https://github.com/alvaralmstedt/Tutorials/wiki/Gap-closing-with-PBJelly)
* PacBio CLI tools, 用于转换 PacBio Sequel 生成的 .bam 文件, 只能在 macOS 下使用
    * `brew install PacificBiosciences/tools/*tool-name*`
    * bam2fasta
    * bam2fastq

### 混合组装

* [DBG2LOC](http://www.nature.com/articles/srep31900) - 加上纯二代程序 Platanus (SOAP/ABySS)
* ectools: 用二代的 contigs 代替 reads 来校正三代
* LoRDEC - Celera Assembler
* [quickmerge](https://github.com/mahulchak/quickmerge) - 合并纯三代组装与二三代混合组装

## 中文资料

[生物通上有个专题](http://www.ebiotrade.com/custom/ebiotrade/zt/130503/index.htm), 有点老,
但基本的内容还是不错的.

生物通上近期还有两篇文章也挺好

* [韩国人基因组](http://www.ebiotrade.com/newsf/2016-10/2016108164502500.htm)
* [Atha Ler-0](http://www.ebiotrade.com/newsf/2016-9/201693094511949.htm)
