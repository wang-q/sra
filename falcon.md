# falcon安装与样例

## 安装Linuxbrew

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

## 用Linuxbrew安装python和其它程序

falcon编译过程中需要`python.h`, 为了方便起见, 使用Linuxbrew从源码编译安装.

```bash
brew install python
```

其它可能有用的程序.

```bash
echo "==> Add tap science"
brew tap homebrew/science
brew tap wang-q/tap

echo "==> Install bioinfomatics softwares"
brew install clustal-w mafft seqtk

echo "==> Install wang-q/tap"
brew install faops
```

## 安装falcon-integrate

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

编译完成后, 会生成`fc_env`目录, 里面是可执行文件, `tree -L 2 fc_env`.

```text
fc_env
├── bin
│   ├── Catrack -> /home/wangq/share/FALCON-integrate/DAZZ_DB/Catrack
│   ├── csv2rdf
│   ├── daligner -> /home/wangq/share/FALCON-integrate/DALIGNER/daligner
│   ├── daligner_p -> /home/wangq/share/FALCON-integrate/DALIGNER/daligner_p
│   ├── DAM2fasta -> /home/wangq/share/FALCON-integrate/DAZZ_DB/DAM2fasta
│   ├── datander -> /home/wangq/share/FALCON-integrate/DAMASKER/datander
│   ├── DB2Falcon -> /home/wangq/share/FALCON-integrate/DALIGNER/DB2Falcon
│   ├── DB2fasta -> /home/wangq/share/FALCON-integrate/DAZZ_DB/DB2fasta
│   ├── DBdump -> /home/wangq/share/FALCON-integrate/DAZZ_DB/DBdump
│   ├── DBdust -> /home/wangq/share/FALCON-integrate/DAZZ_DB/DBdust
│   ├── DBrm -> /home/wangq/share/FALCON-integrate/DAZZ_DB/DBrm
│   ├── DBshow -> /home/wangq/share/FALCON-integrate/DAZZ_DB/DBshow
│   ├── DBsplit -> /home/wangq/share/FALCON-integrate/DAZZ_DB/DBsplit
│   ├── DBstats -> /home/wangq/share/FALCON-integrate/DAZZ_DB/DBstats
│   ├── easy_install
│   ├── easy_install-2.7
│   ├── falcon-task
│   ├── fasta2DAM -> /home/wangq/share/FALCON-integrate/DAZZ_DB/fasta2DAM
│   ├── fasta2DB -> /home/wangq/share/FALCON-integrate/DAZZ_DB/fasta2DB
│   ├── fc_actg_coordinate
│   ├── fc_actg_coordinate.py
│   ├── fc_calc_cutoff
│   ├── fc_consensus
│   ├── fc_consensus.py
│   ├── fc_contig_annotate
│   ├── fc_contig_annotate.py
│   ├── fc_ctg_link_analysis
│   ├── fc_ctg_link_analysis.py
│   ├── fc_dedup_a_tigs
│   ├── fc_dedup_a_tigs.py
│   ├── fc_fasta2fasta
│   ├── fc_fetch_reads
│   ├── fc_get_read_ctg_map
│   ├── fc_graph_to_contig
│   ├── fc_graph_to_contig.py
│   ├── fc_graph_to_utgs
│   ├── fc_graph_to_utgs.py
│   ├── fc_ovlp_filter
│   ├── fc_ovlp_filter.py
│   ├── fc_ovlp_stats
│   ├── fc_ovlp_stats.py
│   ├── fc_ovlp_to_graph
│   ├── fc_ovlp_to_graph.py
│   ├── fc_pr_ctg_track
│   ├── fc_rr_ctg_track
│   ├── fc_run
│   ├── fc_run0
│   ├── fc_run1
│   ├── fc_run.py
│   ├── git-sym -> /home/wangq/share/FALCON-integrate/git-sym/git-sym
│   ├── heartbeat-wrapper
│   ├── HPC.daligner -> /home/wangq/share/FALCON-integrate/DALIGNER/HPC.daligner
│   ├── HPC.REPmask -> /home/wangq/share/FALCON-integrate/DAMASKER/HPC.REPmask
│   ├── HPC.TANmask -> /home/wangq/share/FALCON-integrate/DAMASKER/HPC.TANmask
│   ├── LA4Falcon -> /home/wangq/share/FALCON-integrate/DALIGNER/LA4Falcon
│   ├── LA4Ice -> /home/wangq/share/FALCON-integrate/DALIGNER/LA4Ice
│   ├── LAcat -> /home/wangq/share/FALCON-integrate/DALIGNER/LAcat
│   ├── LAcheck -> /home/wangq/share/FALCON-integrate/DALIGNER/LAcheck
│   ├── LAdump -> /home/wangq/share/FALCON-integrate/DALIGNER/LAdump
│   ├── LAindex -> /home/wangq/share/FALCON-integrate/DALIGNER/LAindex
│   ├── LAmerge -> /home/wangq/share/FALCON-integrate/DALIGNER/LAmerge
│   ├── LAshow -> /home/wangq/share/FALCON-integrate/DALIGNER/LAshow
│   ├── LAsort -> /home/wangq/share/FALCON-integrate/DALIGNER/LAsort
│   ├── LAsplit -> /home/wangq/share/FALCON-integrate/DALIGNER/LAsplit
│   ├── pip
│   ├── pip2
│   ├── pip2.7
│   ├── pwatcher-main
│   ├── pwatcher-pypeflow-example
│   ├── rangen -> /home/wangq/share/FALCON-integrate/DAZZ_DB/rangen
│   ├── rdf2dot
│   ├── rdfpipe
│   ├── rdfs2dot
│   ├── REPmask -> /home/wangq/share/FALCON-integrate/DAMASKER/REPmask
│   ├── simulator -> /home/wangq/share/FALCON-integrate/DAZZ_DB/simulator
│   └── TANmask -> /home/wangq/share/FALCON-integrate/DAMASKER/TANmask
├── include
│   ├── DB.h -> /home/wangq/share/FALCON-integrate/DAZZ_DB/DB.h
│   └── QV.h -> /home/wangq/share/FALCON-integrate/DAZZ_DB/QV.h
├── lib
│   ├── libdazzdb.a -> /home/wangq/share/FALCON-integrate/DAZZ_DB/libdazzdb.a
│   └── python2.7
└── share
    └── doc


6 directories, 79 files
```

## 样例数据

falcon-examples里的数据是通过一个小众程序`git-sym`从dropbox下载的, 在墙内无法按说明文件里的提示来使用.

同时其内的很多设置都是写死的集群路径, 以及sge配置, 大大增加了复杂度, 并让人无法理解.

### `falcon/example`里的[Ecoli样例](https://github.com/PacificBiosciences/FALCON/wiki/Setup:-Complete-example).

* 运行目录

```bash
mkdir -p $HOME/share/FALCON-integrate/ecoli_test/data
cd $HOME/share/FALCON-integrate/ecoli_test/data
```

* 过墙下载以下三个文件

```bash
wget https://www.dropbox.com/s/tb78i5i3nrvm6rg/m140913_050931_42139_c100713652400000001823152404301535_s1_p0.1.subreads.fasta
wget https://www.dropbox.com/s/v6wwpn40gedj470/m140913_050931_42139_c100713652400000001823152404301535_s1_p0.2.subreads.fasta
wget https://www.dropbox.com/s/j61j2cvdxn4dx4g/m140913_050931_42139_c100713652400000001823152404301535_s1_p0.3.subreads.fasta
```

* 准备配置文件

```bash
cd $HOME/share/FALCON-integrate/ecoli_test
find data -name "*.fasta" > input.fofn

# $HOME/share/FALCON-integrate/FALCON/examples/fc_run_ecoli.cfg
cat <<EOF > fc_run_ecoli.cfg
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
sge_option_da = -pe smp 8 -q jobqueue
sge_option_la = -pe smp 2 -q jobqueue
sge_option_pda = -pe smp 8 -q jobqueue
sge_option_pla = -pe smp 2 -q jobqueue
sge_option_fc = -pe smp 24 -q jobqueue
sge_option_cns = -pe smp 8 -q jobqueue

pa_concurrent_jobs = 32
ovlp_concurrent_jobs = 32

pa_HPCdaligner_option =  -v -dal4 -t16 -e.70 -l1000 -s1000
ovlp_HPCdaligner_option = -v -dal4 -t32 -h60 -e.96 -l500 -s1000

pa_DBsplit_option = -x500 -s50
ovlp_DBsplit_option = -x500 -s50

falcon_sense_option = --output_multi --min_idt 0.70 --min_cov 4 --max_n_read 200 --n_core 6

overlap_filtering_setting = --max_diff 100 --max_cov 100 --min_cov 20 --bestn 10 --n_core 24

EOF
```

* 运行

```bash
cd $HOME/share/FALCON-integrate
source env.sh

cd ecoli_test
time fc_run fc_run_ecoli.cfg
```

### 其它模式生物

用这篇文章里提供的样例, doi:10.1038/sdata.2014.45.
