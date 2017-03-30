# Plants 2+3

[TOC levels=1-3]: # " "

- [Plants 2+3](#plants-23)
- [F63, Closterium sp., 新月藻](#f63-closterium-sp-新月藻)
- [F295, Cosmarium botrytis, 葡萄鼓藻](#f295-cosmariumbotrytis-葡萄鼓藻)
- [F340, Zygnema extenue, 亚小双星藻](#f340-zygnema-extenue-亚小双星藻)
- [F354, Spirogyra gracilis, 纤细水绵](#f354-spirogyragracilis-纤细水绵)
    - [F354: download](#f354-download)
    - [F354: combinations of different quality values and read lengths](#f354-combinations-of-different-quality-values-and-read-lengths)
    - [F354: down sampling](#f354-down-sampling)
    - [F354: generate super-reads](#f354-generate-super-reads)
    - [F354: create anchors](#f354-create-anchors)
    - [F354: merge anchors](#f354-merge-anchors)
- [F357, Botryococcus braunii, 布朗葡萄藻](#f357-botryococcus-braunii-布朗葡萄藻)
- [F1084, Staurastrum sp., 角星鼓藻](#f1084-staurastrumsp-角星鼓藻)
- [moli, 茉莉](#moli-茉莉)
- [Summary of SR](#summary-of-sr)
- [Anchors](#anchors)



# F63, Closterium sp., 新月藻

```bash
mkdir -p ~/data/dna-seq/chara/superreads/F63
cd ~/data/dna-seq/chara/superreads/F63

perl ~/Scripts/sra/superreads.pl \
    ~/data/dna-seq/chara/clean_data/F63_HF5WLALXX_L5_1.clean.fq.gz \
    ~/data/dna-seq/chara/clean_data/F63_HF5WLALXX_L5_2.clean.fq.gz \
    -s 300 -d 30 -p 16
```

# F295, Cosmarium botrytis, 葡萄鼓藻

```bash
mkdir -p ~/data/dna-seq/chara/superreads/F295
cd ~/data/dna-seq/chara/superreads/F295

perl ~/Scripts/sra/superreads.pl \
    ~/data/dna-seq/chara/clean_data/F295_HF5KMALXX_L7_1.clean.fq.gz \
    ~/data/dna-seq/chara/clean_data/F295_HF5KMALXX_L7_2.clean.fq.gz \
    -s 300 -d 30 -p 16
```

# F340, Zygnema extenue, 亚小双星藻

```bash
mkdir -p ~/data/dna-seq/chara/superreads/F340
cd ~/data/dna-seq/chara/superreads/F340

perl ~/Scripts/sra/superreads.pl \
    ~/data/dna-seq/chara/clean_data/F340-hun_HF3JLALXX_L6_1.clean.fq.gz \
    ~/data/dna-seq/chara/clean_data/F340-hun_HF3JLALXX_L6_2.clean.fq.gz \
    -s 300 -d 30 -p 16
```

# F354, Spirogyra gracilis, 纤细水绵

转录本杂合度 0.35%

## F354: download

```bash
mkdir -p ~/data/dna-seq/chara/superreads/F354
cd ~/data/dna-seq/chara/superreads/F354

perl ~/Scripts/sra/superreads.pl \
    ~/data/dna-seq/chara/clean_data/F354_HF5KMALXX_L7_1.clean.fq.gz \
    ~/data/dna-seq/chara/clean_data/F354_HF5KMALXX_L7_2.clean.fq.gz \
    -s 300 -d 30 -p 16
```

```bash
mkdir -p ~/data/dna-seq/chara/F354/2_illumina
cd ~/data/dna-seq/chara/F354/2_illumina

ln -s ~/data/dna-seq/chara/clean_data/F354_HF5KMALXX_L7_1.clean.fq.gz R1.fq.gz
ln -s ~/data/dna-seq/chara/clean_data/F354_HF5KMALXX_L7_2.clean.fq.gz R2.fq.gz
```

## F354: combinations of different quality values and read lengths

* qual: 20, 25, and 30
* len: 100, 110, 120, 130, 140, and 150

```bash
BASE_DIR=$HOME/data/dna-seq/chara/F354

# get the default adapter file
# anchr trim --help
cd ${BASE_DIR}
parallel --no-run-if-empty -j 2 "
    scythe \
        2_illumina/{}.fq.gz \
        -q sanger \
        -a /home/wangq/.plenv/versions/5.18.4/lib/perl5/site_perl/5.18.4/auto/share/dist/App-Anchr/illumina_adapters.fa \
        --quiet \
        | pigz -p 4 -c \
        > 2_illumina/{}.scythe.fq.gz
    " ::: R1 R2

cd ${BASE_DIR}
parallel --no-run-if-empty -j 6 "
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
    " ::: 20 25 30 ::: 100 110 120 130 140 150

```

* Stats

```bash
BASE_DIR=$HOME/data/dna-seq/chara/F354
cd ${BASE_DIR}

printf "| %s | %s | %s | %s |\n" \
    "Name" "N50" "Sum" "#" \
    > stat.md
printf "|:--|--:|--:|--:|\n" >> stat.md

printf "| %s | %s | %s | %s |\n" \
    $(echo "Illumina"; faops n50 -H -S -C 2_illumina/R1.fq.gz 2_illumina/R2.fq.gz;) >> stat.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "scythe";   faops n50 -H -S -C 2_illumina/R1.scythe.fq.gz 2_illumina/R2.scythe.fq.gz;) >> stat.md

for qual in 20 25 30; do
    for len in 100 110 120 130 140 150; do
        DIR_COUNT="${BASE_DIR}/2_illumina/Q${qual}L${len}"

        printf "| %s | %s | %s | %s |\n" \
            $(echo "Q${qual}L${len}"; faops n50 -H -S -C ${DIR_COUNT}/R1.fq.gz  ${DIR_COUNT}/R2.fq.gz;) \
            >> stat.md
    done
done

cat stat.md
```

## F354: down sampling

```bash
BASE_DIR=$HOME/data/dna-seq/chara/F354
cd ${BASE_DIR}

# works on bash 3
ARRAY=(
    "2_illumina/Q20L100:Q20L100"
    "2_illumina/Q20L110:Q20L110"
    "2_illumina/Q20L120:Q20L120"
    "2_illumina/Q20L130:Q20L130"
    "2_illumina/Q20L140:Q20L140"
    "2_illumina/Q20L150:Q20L150"
    "2_illumina/Q25L100:Q25L100"
    "2_illumina/Q25L110:Q25L110"
    "2_illumina/Q25L120:Q25L120"
    "2_illumina/Q25L130:Q25L130"
    "2_illumina/Q25L140:Q25L140"
    "2_illumina/Q25L150:Q25L150"
    "2_illumina/Q30L100:Q30L100"
    "2_illumina/Q30L110:Q30L110"
    "2_illumina/Q30L120:Q30L120"
    "2_illumina/Q30L130:Q30L130"
    "2_illumina/Q30L140:Q30L140"
    "2_illumina/Q30L150:Q30L150"
)

for group in "${ARRAY[@]}" ; do
    
    GROUP_DIR=$(group=${group} perl -e '@p = split q{:}, $ENV{group}; print $p[0];')
    GROUP_ID=$( group=${group} perl -e '@p = split q{:}, $ENV{group}; print $p[1];')
    printf "==> %s \t %s\n" "$GROUP_DIR" "$GROUP_ID"

    echo "==> Group ${GROUP_ID}"
    DIR_COUNT="${BASE_DIR}/${GROUP_ID}"
    mkdir -p ${DIR_COUNT}
    
    if [ -e ${DIR_COUNT}/R1.fq.gz ]; then
        continue     
    fi
    
    ln -s ${BASE_DIR}/${GROUP_DIR}/R1.fq.gz ${DIR_COUNT}/R1.fq.gz
    ln -s ${BASE_DIR}/${GROUP_DIR}/R2.fq.gz ${DIR_COUNT}/R2.fq.gz

done
```

## F354: generate super-reads

```bash
BASE_DIR=$HOME/data/dna-seq/chara/F354
cd ${BASE_DIR}

perl -e '
    for my $n (
        qw{
        Q20L100 Q20L110 Q20L120 Q20L130 Q20L140 Q20L150
        Q25L100 Q25L110 Q25L120 Q25L130 Q25L140 Q25L150
        Q30L100 Q30L110 Q30L120 Q30L130 Q30L140 Q30L150
        }
        )
    {
        printf qq{%s\n}, $n;
    }
    ' \
    | parallel --no-run-if-empty -j 3 "
        echo '==> Group {}'
        
        if [ ! -d ${BASE_DIR}/{} ]; then
            echo '    directory not exists'
            exit;
        fi        

        if [ -e ${BASE_DIR}/{}/pe.cor.fa ]; then
            echo '    pe.cor.fa already presents'
            exit;
        fi

        cd ${BASE_DIR}/{}
        anchr superreads \
            R1.fq.gz R2.fq.gz \
            --nosr -p 8 \
            -o superreads.sh
        bash superreads.sh
    "

```

Clear intermediate files.

```bash
BASE_DIR=$HOME/data/dna-seq/chara/F354

find . -type f -name "quorum_mer_db.jf"          | xargs rm
find . -type f -name "k_u_hash_0"                | xargs rm
find . -type f -name "readPositionsInSuperReads" | xargs rm
find . -type f -name "*.tmp"                     | xargs rm
find . -type f -name "pe.renamed.fastq"          | xargs rm
find . -type f -name "pe.cor.sub.fa"             | xargs rm
```

## F354: create anchors

```bash
BASE_DIR=$HOME/data/dna-seq/chara/F354
cd ${BASE_DIR}

perl -e '
    for my $n (
        qw{
        Q20L100 Q20L110 Q20L120 Q20L130 Q20L140 Q20L150
        Q25L100 Q25L110 Q25L120 Q25L130 Q25L140 Q25L150
        Q30L100 Q30L110 Q30L120 Q30L130 Q30L140 Q30L150
        }
        )
    {
        printf qq{%s\n}, $n;
    }
    ' \
    | parallel --no-run-if-empty -j 4 "
        echo '==> Group {}'

        if [ -e ${BASE_DIR}/{}/anchor/pe.anchor.fa ]; then
            exit;
        fi

        rm -fr ${BASE_DIR}/{}/anchor
        bash ~/Scripts/cpan/App-Anchr/share/anchor.sh ${BASE_DIR}/{} 8 false
    "

```

## F354: results

* Stats of anchors

```bash
BASE_DIR=$HOME/data/dna-seq/chara/F354
cd ${BASE_DIR}

bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 header \
    > ${BASE_DIR}/stat2.md

perl -e '
    for my $n (
        qw{
        Q20L100 Q20L110 Q20L120 Q20L130 Q20L140 Q20L150
        Q25L100 Q25L110 Q25L120 Q25L130 Q25L140 Q25L150
        Q30L100 Q30L110 Q30L120 Q30L130 Q30L140 Q30L150
        }
        )
    {
        printf qq{%s\n}, $n;
    }
    ' \
    | parallel -k --no-run-if-empty -j 16 "
        if [ ! -e ${BASE_DIR}/{}/anchor/pe.anchor.fa ]; then
            exit;
        fi

        bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 ${BASE_DIR}/{}
    " >> ${BASE_DIR}/stat2.md

cat stat2.md
```

## F354: merge anchors

```bash
BASE_DIR=$HOME/data/dna-seq/chara/F354
cd ${BASE_DIR}

# merge anchors
mkdir -p merge
anchr contained \
    Q20L100/anchor/pe.anchor.fa \
    Q20L110/anchor/pe.anchor.fa \
    Q20L120/anchor/pe.anchor.fa \
    Q20L130/anchor/pe.anchor.fa \
    Q20L140/anchor/pe.anchor.fa \
    Q20L150/anchor/pe.anchor.fa \
    Q25L100/anchor/pe.anchor.fa \
    Q25L110/anchor/pe.anchor.fa \
    Q25L120/anchor/pe.anchor.fa \
    Q25L130/anchor/pe.anchor.fa \
    Q25L140/anchor/pe.anchor.fa \
    Q25L150/anchor/pe.anchor.fa \
    Q30L100/anchor/pe.anchor.fa \
    Q30L110/anchor/pe.anchor.fa \
    Q30L120/anchor/pe.anchor.fa \
    Q30L130/anchor/pe.anchor.fa \
    Q30L140/anchor/pe.anchor.fa \
    Q30L150/anchor/pe.anchor.fa \
    --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
    -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/anchor.contained.fasta
anchr orient merge/anchor.contained.fasta --len 1000 --idt 0.98 -o merge/anchor.orient.fasta
anchr merge merge/anchor.orient.fasta --len 1000 --idt 0.999 -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/anchor.merge.fasta

faops n50 -S -C merge/anchor.merge.fasta

# quast
rm -fr 9_qa
quast --no-check --threads 24 \
    Q20L100/anchor/pe.anchor.fa \
    Q20L110/anchor/pe.anchor.fa \
    Q20L120/anchor/pe.anchor.fa \
    Q20L130/anchor/pe.anchor.fa \
    Q20L140/anchor/pe.anchor.fa \
    Q20L150/anchor/pe.anchor.fa \
    Q25L100/anchor/pe.anchor.fa \
    Q25L110/anchor/pe.anchor.fa \
    Q25L120/anchor/pe.anchor.fa \
    Q25L130/anchor/pe.anchor.fa \
    Q25L140/anchor/pe.anchor.fa \
    Q25L150/anchor/pe.anchor.fa \
    Q30L100/anchor/pe.anchor.fa \
    Q30L110/anchor/pe.anchor.fa \
    Q30L120/anchor/pe.anchor.fa \
    Q30L130/anchor/pe.anchor.fa \
    Q30L140/anchor/pe.anchor.fa \
    Q30L150/anchor/pe.anchor.fa \
    merge/anchor.merge.fasta \
    --label "Q20L100,Q20L110,Q20L120,Q20L130,Q20L140,Q20L150,Q25L100,Q25L110,Q25L120,Q25L130,Q25L140,Q25L150,Q30L100,Q30L110,Q30L120,Q30L130,Q30L140,Q30L150,merge" \
    -o 9_qa

```

# F357, Botryococcus braunii, 布朗葡萄藻

```bash
mkdir -p ~/data/dna-seq/chara/superreads/F357
cd ~/data/dna-seq/chara/superreads/F357

perl ~/Scripts/sra/superreads.pl \
    ~/data/dna-seq/chara/clean_data/F357_HF5WLALXX_L7_1.clean.fq.gz \
    ~/data/dna-seq/chara/clean_data/F357_HF5WLALXX_L7_2.clean.fq.gz \
    -s 300 -d 30 -p 16
```

# F1084, Staurastrum sp., 角星鼓藻

```bash
mkdir -p ~/data/dna-seq/chara/superreads/F1084
cd ~/data/dna-seq/chara/superreads/F1084

perl ~/Scripts/sra/superreads.pl \
    ~/data/dna-seq/chara/clean_data/F1084_HF5KMALXX_L7_1.clean.fq.gz \
    ~/data/dna-seq/chara/clean_data/F1084_HF5KMALXX_L7_2.clean.fq.gz \
    -s 300 -d 30 -p 16
```

# moli, 茉莉

SR had failed twice due to the calculating results from awk were larger than the MAX_INT

* for jellyfish
* for --number-reads of `getSuperReadInsertCountsFromReadPlacementFileTwoPasses`

```bash
mkdir -p /home/wangq/zlc/medfood/superreads/moli
cd ~/zlc/medfood/superreads/moli

perl ~/Scripts/sra/superreads.pl \
    ~/zlc/medfood/moli/lane5ml_R1.fq.gz \
    ~/zlc/medfood/moli/lane5ml_R2.fq.gz \
    -s 300 -d 30 -p 16 --jf 10_000_000_000 --kmer 77
```

```bash
mkdir -p /home/wangq/zlc/medfood/superreads/moli_sub
cd ~/zlc/medfood/superreads/moli_sub

# 200 M Reads
zcat ~/zlc/medfood/moli/lane5ml_R1.fq.gz \
    | head -n 800000000 \
    | gzip > R1.fq.gz

zcat ~/zlc/medfood/moli/lane5ml_R2.fq.gz \
    | head -n 800000000 \
    | gzip > R2.fq.gz

perl ~/Scripts/sra/superreads.pl \
    R1.fq.gz \
    R2.fq.gz \
    -s 300 -d 30 -p 16 --jf 10_000_000_000
```

# Summary of SR

| Name       | fq size | fa size | Length | Kmer | Est. Genome |   Run time |     Sum SR | SR/Est.G |
|:-----------|--------:|--------:|-------:|-----:|------------:|-----------:|-----------:|---------:|
| F63        |   33.9G |     19G |    150 |   49 |   345627684 |  4:04'22'' |  697371843 |     2.02 |
| F295       |   43.3G |     24G |    150 |   49 |   452975652 |  6:01'13'' |  742260051 |     1.64 |
| F340       |   35.9G |     20G |    150 |   75 |   566603922 |  3:21'01'' |  852873811 |     1.51 |
| F354       |   36.2G |     20G |    150 |   49 |   133802786 |  6:06'09'' |  351863887 |     2.63 |
| F357       |   43.5G |     24G |    150 |   49 |   338905264 |  5:41'49'' |  796466152 |     2.35 |
| F1084      |   33.9G |     19G |    150 |   75 |   199395661 |  4:32'01'' |  570760287 |     2.86 |
| moli_sub   |    118G |     63G |    150 |  105 |   608561446 | 11:29'38'' | 2899953305 |     4.77 |

```bash
printf "| %s | %s | %s | %s | %s | %s | %s | %s | %s | | \n" \
    $( basename $( pwd ) ) \
    $( if [[ -e pe.renamed.fastq ]]; then du -h pe.renamed.fastq | cut -f1; else echo 0; fi ) \
    $( du -h pe.cor.fa | cut -f1 ) \
    $( cat environment.sh \
        | perl -n -e '/PE_AVG_READ_LENGTH=\"(\d+)\"/ and print $1' ) \
    $( cat environment.sh \
        | perl -n -e '/KMER=\"(\d+)\"/ and print $1' ) \
    $( cat environment.sh \
        | perl -n -e '/ESTIMATED_GENOME_SIZE=\"(\d+)\"/ and print $1' ) \
    $( cat environment.sh \
        | perl -n -e '/TOTAL_READS=\"(\d+)\"/ and print $1' ) \
    $( secs=$(expr $(stat -c %Y environment.sh) - $(stat -c %Y assemble.sh)); \
        printf "%d:%02d'%02d''\n" $(($secs/3600)) $(($secs%3600/60)) $(($secs%60)) ) \
    $( faops n50 -H -N 0 -S work1/superReadSequences.fasta)

```

Thoughts:

* kmer 与污染的关系还不好说
* kmer 估计基因组比真实的大得越多, 污染就越多
* 有多个因素会影响 SR/Est.G. 细菌与单倍体会趋向于 2, paralog 与杂合会趋向于 4.
* 50 倍的二代数据并不充分, 与 100 倍之间还是有明显的差异的. 覆盖数不够也会导致 SR/Est.G 低于真实值.

# Anchors

```bash

cd sr
faops n50 -N 50 -S -C superReadSequences.fasta
faops n50 -N 0 -C pe.cor.fa
faops n50 -N 0 -C pe.strict.fa

printf "| %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | \n" \
    $( basename $( dirname $(pwd) ) ) \
    $( faops n50 -H -N 50 -S -C pe.anchor.fa) \
    $( faops n50 -H -N 50 -S -C pe.anchor2.fa) \
    $( faops n50 -H -N 50 -S -C pe.others.fa)

```

| Name       | N50 SR |     Sum SR |     #SR |   #cor.fa | #strict.fa |
|:-----------|-------:|-----------:|--------:|----------:|-----------:|
| F63        |   1815 |  697371843 |  986675 | 115078314 |   94324950 |
| F295       |    477 |  742260051 | 1975444 | 146979656 |  119415569 |
| F340       |    388 |  852873811 | 2383927 | 122062736 |  102014388 |
| F354       |    768 |  351863887 |  584408 | 123057622 |  106900181 |
| F357       |    599 |  796466152 | 1644428 | 147581634 |  129353409 |
| F1084      |    893 |  570760287 |  882123 | 115210566 |   97481899 |

| Name       |  N50 |      Sum | #anchor |   N50 |      Sum | #anchor2 |  N50 |        Sum | #others |
|:-----------|-----:|---------:|--------:|------:|---------:|---------:|-----:|-----------:|--------:|
| F63        | 4003 | 52342433 |   21120 |       |          |          |      |            |         |
| F295       | 2118 | 17374987 |   10473 |       |          |          |      |            |         |
| F340       | 1105 | 76859329 |   70742 |       |          |          |      |            |         |
| F354       | 2553 | 23543840 |   11667 |       |          |          |      |            |         |
| F357       | 1541 | 53821193 |   40017 |       |          |          |      |            |         |
| F1084      | 1721 |  4412080 |    3059 |       |          |          |      |            |         |

