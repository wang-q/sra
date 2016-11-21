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

## 分析平台的历史

PacBio 在 github 上的[首页](https://github.com/PacificBiosciences).

GenomicConsensus 是 PacBio 的组合程序包, 是 SMRT Analysis Software 的一部分. 用于 consensus 和 variant
calling. 当前版本为 v2.3.0, 发表时间为2014年.

SMRT Analysis Software 还包括了一些其它第三方程序:

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

## 安装 GenomicConsensus

安装最新的第三方依赖.

```bash
brew install md5sha1sum
brew install zlib boost openblas
brew install python cmake ccache hdf5
brew install samtools
brew cleanup # only keep the latest version

pip install --upgrade pip
pip install virtualenv
```

下载其它第三方依赖.

```bash
mkdir -p ~/share/thirdparty
cd ~/share/thirdparty

proxychains4 wget -N https://prdownloads.sourceforge.net/swig/swig-3.0.8.tar.gz
proxychains4 wget -N https://prdownloads.sourceforge.net/pcre/pcre-8.38.tar.gz 
proxychains4 wget -N http://eddylab.org/software/hmmer3/3.1b2/hmmer-3.1b2.tar.gz

```

通过 pitchfork 编译 GenomicConsensus.

```bash
mkdir -p ~/share
cd ~/share
git clone git@github.com:PacificBiosciences/pitchfork.git
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


sed -i".bak" "/rsync/d" ~/share/pitchfork/ports/python/virtualenv/Makefile
    
cd ~/share/pitchfork/ports/thirdparty/swig/
cp -f ~/share/thirdparty/swig-3.0.8.tar.gz .
cp -f ~/share/thirdparty/pcre-8.38.tar.gz .

cd ~/share/pitchfork
make GenomicConsensus
```

```bash
source ~/share/pitchfork/deployment/setup-env.sh
```

## 其它与 PacBio 有关的程序

* HGAP: Hierarchical Genome Assembly Process，层次基因组组装, 以相对较长的读长数据为种子 (Seeding Reads),
  以相对较短的读长数据用于内部纠错. 这个时候得到的读长数据足够长也足够准确, 完全可以用于 de novo 组装,
  而无需二代数据帮忙.
* ectools: 用二代的 contigs 代替 reads 来校正三代.
* blasr: long read aligner.
* PBJelly: 用于gapclosing,
  [这里有简介.](https://github.com/alvaralmstedt/Tutorials/wiki/Gap-closing-with-PBJelly)
* PacBio CLI tools, 用于转换 PacBio Sequel 生成的 .bam 文件
    * `brew install PacificBiosciences/tools/*tool-name*`
    * bam2fasta
    * bam2fastq

## 中文资料

[生物通上有个专题](http://www.ebiotrade.com/custom/ebiotrade/zt/130503/index.htm), 有点老,
但基本的内容还是不错的.

生物通上近期还有两篇文章也挺好

* [韩国人基因组](http://www.ebiotrade.com/newsf/2016-10/2016108164502500.htm)
* [Atha Ler-0](http://www.ebiotrade.com/newsf/2016-9/201693094511949.htm)
