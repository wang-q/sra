# Organelles 2

[TOC levels=1-3]: # " "
- [Organelles 2](#organelles-2)
- [m07](#m07)
    - [m07: download](#m07-download)
    - [m07: combinations of different quality values and read lengths](#m07-combinations-of-different-quality-values-and-read-lengths)
    - [m07: spades](#m07-spades)
    - [m07: quorum](#m07-quorum)
    - [m07: down sampling](#m07-down-sampling)
    - [m07: k-unitigs and anchors (sampled)](#m07-k-unitigs-and-anchors-sampled)
    - [m07: merge anchors](#m07-merge-anchors)
    - [m07: expand anchors](#m07-expand-anchors)
    - [m07: final stats](#m07-final-stats)
- [m08](#m08)
    - [m08: download](#m08-download)
    - [m08: combinations of different quality values and read lengths](#m08-combinations-of-different-quality-values-and-read-lengths)
    - [m08: spades](#m08-spades)
    - [m08: quorum](#m08-quorum)
    - [m08: down sampling](#m08-down-sampling)
    - [m08: k-unitigs and anchors (sampled)](#m08-k-unitigs-and-anchors-sampled)
    - [m08: merge anchors](#m08-merge-anchors)
    - [m08: expand anchors](#m08-expand-anchors)
    - [m08: final stats](#m08-final-stats)


# m07

## m07: download

```bash
BASE_NAME=m07
REAL_G=5000000

mkdir -p ~/data/dna-seq/xjy/${BASE_NAME}/2_illumina
cd ~/data/dna-seq/xjy/${BASE_NAME}/2_illumina

ln -s ~/data/dna-seq/xjy/clean_data/m07_H3J5KDMXX_L1_1.clean.fq.gz R1.fq.gz
ln -s ~/data/dna-seq/xjy/clean_data/m07_H3J5KDMXX_L1_2.clean.fq.gz R2.fq.gz

```

* FastQC

```bash
cd ${HOME}/data/dna-seq/xjy/${BASE_NAME}

mkdir -p 2_illumina/fastqc
cd 2_illumina/fastqc

fastqc -t 16 \
    ../R1.fq.gz ../R2.fq.gz \
    -o .

```

* kmergenie

```bash
cd ${HOME}/data/dna-seq/xjy/${BASE_NAME}

mkdir -p 2_illumina/kmergenie
cd 2_illumina/kmergenie

kmergenie -l 21 -k 121 -s 10 -t 8 ../R1.fq.gz -o oriR1
kmergenie -l 21 -k 121 -s 10 -t 8 ../R2.fq.gz -o oriR2

```

## m07: combinations of different quality values and read lengths

* qual: 25 and 30
* len: 60

```bash
cd ${HOME}/data/dna-seq/xjy/${BASE_NAME}

if [ ! -e 2_illumina/R1.uniq.fq.gz ]; then
    tally \
        --pair-by-offset --with-quality --nozip --unsorted \
        -i 2_illumina/R1.fq.gz \
        -j 2_illumina/R2.fq.gz \
        -o 2_illumina/R1.uniq.fq \
        -p 2_illumina/R2.uniq.fq
    
    parallel --no-run-if-empty -j 2 "
            pigz -p 8 2_illumina/{}.uniq.fq
        " ::: R1 R2
fi

parallel --no-run-if-empty -j 3 "
    mkdir -p 2_illumina/Q{1}L{2}
    cd 2_illumina/Q{1}L{2}
    
    if [ -e R1.fq.gz ]; then
        echo '    R1.fq.gz already presents'
        exit;
    fi

    anchr trim \
        --noscythe \
        -q {1} -l {2} \
        ../R1.uniq.fq.gz ../R2.uniq.fq.gz \
        -o stdout \
        | bash
    " ::: 25 30 ::: 60

# Stats
printf "| %s | %s | %s | %s |\n" \
    "Name" "N50" "Sum" "#" \
    > stat.md
printf "|:--|--:|--:|--:|\n" >> stat.md

printf "| %s | %s | %s | %s |\n" \
    $(echo "Illumina"; faops n50 -H -S -C 2_illumina/R1.fq.gz 2_illumina/R2.fq.gz;) >> stat.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "uniq";     faops n50 -H -S -C 2_illumina/R1.uniq.fq.gz 2_illumina/R2.uniq.fq.gz;) >> stat.md

parallel -k --no-run-if-empty -j 3 "
    printf \"| %s | %s | %s | %s |\n\" \
        \$( 
            echo Q{1}L{2};
            if [[ {1} -ge '30' ]]; then
                faops n50 -H -S -C \
                    2_illumina/Q{1}L{2}/R1.fq.gz \
                    2_illumina/Q{1}L{2}/R2.fq.gz \
                    2_illumina/Q{1}L{2}/Rs.fq.gz;
            else
                faops n50 -H -S -C \
                    2_illumina/Q{1}L{2}/R1.fq.gz \
                    2_illumina/Q{1}L{2}/R2.fq.gz;
            fi
        )
    " ::: 25 30 ::: 60 \
    >> stat.md

cat stat.md
```

| Name     | N50 |        Sum |        # |
|:---------|----:|-----------:|---------:|
| Illumina | 150 | 4775528100 | 31836854 |
| uniq     | 150 | 3818789100 | 25458594 |
| Q25L60   | 150 | 3747791294 | 25336226 |
| Q30L60   | 150 | 3637564323 | 25146240 |

## m07: spades

```bash
cd ${HOME}/data/dna-seq/xjy/${BASE_NAME}

spades.py \
    -t 16 \
    -k 21,33,55,77 \
    -1 2_illumina/Q25L60/R1.fq.gz \
    -2 2_illumina/Q25L60/R2.fq.gz \
    -s 2_illumina/Q25L60/Rs.fq.gz \
    -o 8_spades

anchr contained \
    8_spades/contigs.fasta \
    --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
    -o stdout \
    | faops filter -a 1000 -l 0 stdin 8_spades/contigs.non-contained.fasta

```

## m07: quorum

```bash
cd ${HOME}/data/dna-seq/xjy/${BASE_NAME}

parallel --no-run-if-empty -j 1 "
    cd 2_illumina/Q{1}L{2}
    echo >&2 '==> Group Q{1}L{2} <=='

    if [ ! -e R1.fq.gz ]; then
        echo >&2 '    R1.fq.gz not exists'
        exit;
    fi

    if [ -e pe.cor.fa ]; then
        echo >&2 '    pe.cor.fa exists'
        exit;
    fi

    if [[ {1} -ge '30' ]]; then
        anchr quorum \
            R1.fq.gz R2.fq.gz Rs.fq.gz \
            -p 16 \
            -o quorum.sh
    else
        anchr quorum \
            R1.fq.gz R2.fq.gz \
            -p 16 \
            -o quorum.sh
    fi

    bash quorum.sh
    
    echo >&2
    " ::: 25 30 ::: 60

# Stats of processed reads
bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 1 header \
    > stat1.md

parallel -k --no-run-if-empty -j 3 "
    if [ ! -d 2_illumina/Q{1}L{2} ]; then
        exit;
    fi

    bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 1 2_illumina/Q{1}L{2} ${REAL_G}
    " ::: 25 30 ::: 60 \
     >> stat1.md

cat stat1.md

```

| Name   | SumIn |  CovIn | SumOut | CovOut | Discard% | AvgRead |  Kmer | RealG |   EstG | Est/Real |   RunTime |
|:-------|------:|-------:|-------:|-------:|---------:|--------:|------:|------:|-------:|---------:|----------:|
| Q25L60 | 5.32G | 1063.7 |  4.79G |  958.3 |   9.907% |     149 | "105" |    5M | 21.99M |     4.40 | 0:13'07'' |
| Q30L60 | 5.22G | 1043.9 |  4.75G |  949.2 |   9.069% |     147 | "105" |    5M | 20.03M |     4.01 | 0:18'22'' |

* Clear intermediate files.

```bash
cd ${HOME}/data/dna-seq/xjy/${BASE_NAME}

find 2_illumina -type f -name "quorum_mer_db.jf" | xargs rm
find 2_illumina -type f -name "k_u_hash_0"       | xargs rm
find 2_illumina -type f -name "*.tmp"            | xargs rm
find 2_illumina -type f -name "pe.renamed.fastq" | xargs rm
find 2_illumina -type f -name "se.renamed.fastq" | xargs rm
find 2_illumina -type f -name "pe.cor.sub.fa"    | xargs rm
```

## m07: down sampling

```bash
cd ${HOME}/data/dna-seq/xjy/${BASE_NAME}

for QxxLxx in $( parallel "echo 'Q{1}L{2}'" ::: 25 30 ::: 60 ); do
    echo "==> ${QxxLxx}"

    if [ ! -e 2_illumina/${QxxLxx}/pe.cor.fa ]; then
        echo "2_illumina/${QxxLxx}/pe.cor.fa not exists"
        continue;
    fi

    for X in 10 20 40 80 160; do
        printf "==> Coverage: %s\n" ${X}
        
        rm -fr 2_illumina/${QxxLxx}X${X}*
    
        faops split-about -l 0 \
            2_illumina/${QxxLxx}/pe.cor.fa \
            $(( ${REAL_G} * ${X} )) \
            "2_illumina/${QxxLxx}X${X}"
        
        MAX_SERIAL=$(
            cat 2_illumina/${QxxLxx}/environment.json \
                | jq ".SUM_OUT | tonumber | . / ${REAL_G} / ${X} | floor | . - 1"
        )
        
        for i in $( seq 0 1 ${MAX_SERIAL} ); do
            P=$( printf "%03d" ${i})
            printf "  * Part: %s\n" ${P}
            
            mkdir -p "2_illumina/${QxxLxx}X${X}P${P}"
            
            mv  "2_illumina/${QxxLxx}X${X}/${P}.fa" \
                "2_illumina/${QxxLxx}X${X}P${P}/pe.cor.fa"
            cp 2_illumina/${QxxLxx}/environment.json "2_illumina/${QxxLxx}X${X}P${P}"
    
        done
    done
done

```

## m07: k-unitigs and anchors (sampled)

```bash
cd ${HOME}/data/dna-seq/xjy/${BASE_NAME}

# k-unitigs (sampled)
parallel --no-run-if-empty -j 1 "
    echo >&2 '==> Group Q{1}L{2}X{3}P{4}'

    if [ ! -e 2_illumina/Q{1}L{2}X{3}P{4}/pe.cor.fa ]; then
        echo >&2 '    2_illumina/Q{1}L{2}X{3}P{4}/pe.cor.fa not exists'
        exit;
    fi

    if [ -e Q{1}L{2}X{3}P{4}/k_unitigs.fasta ]; then
        echo >&2 '    k_unitigs.fasta already presents'
        exit;
    fi

    mkdir -p Q{1}L{2}X{3}P{4}
    cd Q{1}L{2}X{3}P{4}

    anchr kunitigs \
        ../2_illumina/Q{1}L{2}X{3}P{4}/pe.cor.fa \
        ../2_illumina/Q{1}L{2}X{3}P{4}/environment.json \
        -p 16 \
        --kmer 31,41,51,61,71,81 \
        -o kunitigs.sh
    bash kunitigs.sh

    echo >&2
    " ::: 25 30 ::: 60 ::: 10 20 40 80 160 ::: $(printf "%03d " {0..100})

# anchors (sampled)
parallel --no-run-if-empty -j 2 "
    echo >&2 '==> Group Q{1}L{2}X{3}P{4}'

    if [ ! -e Q{1}L{2}X{3}P{4}/pe.cor.fa ]; then
        echo >&2 '    pe.cor.fa not exists'
        exit;
    fi

    if [ -e Q{1}L{2}X{3}P{4}/anchor/pe.anchor.fa ]; then
        echo >&2 '    pe.anchor.fa already presents'
        exit;
    fi

    rm -fr Q{1}L{2}X{3}P{4}/anchor
    mkdir -p Q{1}L{2}X{3}P{4}/anchor
    cd Q{1}L{2}X{3}P{4}/anchor
    anchr anchors \
        ../k_unitigs.fasta \
        ../pe.cor.fa \
        -p 8 \
        -o anchors.sh
    bash anchors.sh
    
    echo >&2
    " ::: 25 30 ::: 60 ::: 10 20 40 80 160 ::: $(printf "%03d " {0..100})

# Stats of anchors
bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 header \
    > stat2.md

parallel -k --no-run-if-empty -j 6 "
    if [ ! -e Q{1}L{2}X{3}P{4}/anchor/pe.anchor.fa ]; then
        exit;
    fi

    bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 Q{1}L{2}X{3}P{4} ${REAL_G}
    " ::: 25 30 ::: 60 ::: 10 20 40 80 160 ::: $(printf "%03d " {0..100}) \
     >> stat2.md

cat stat2.md
```

| Name           | SumCor | CovCor | N50SR |     Sum |    # | N50Anchor |     Sum |    # | N50Others |     Sum |    # |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|:-------|-------:|------:|--------:|-----:|----------:|--------:|-----:|----------:|--------:|-----:|--------------------:|----------:|----------:|
| Q25L60X10P000  | 50M    |   10.0 |  2435 |   1.04M |  563 |      2997 | 759.67K |  290 |       954 | 279.01K |  273 | "31,41,51,61,71,81" | 0:00'38'' | 0:00'11'' |
| Q25L60X10P001  | 50M    |   10.0 |  2530 |   1.04M |  535 |      3145 | 793.03K |  300 |       973 | 247.36K |  235 | "31,41,51,61,71,81" | 0:00'38'' | 0:00'11'' |
| Q25L60X10P002  | 50M    |   10.0 |  2748 |   1.05M |  542 |      3154 | 786.17K |  283 |       947 | 264.96K |  259 | "31,41,51,61,71,81" | 0:00'37'' | 0:00'11'' |
| Q25L60X20P000  | 100M   |   20.0 |  1384 | 911.81K |  735 |      1826 |  481.3K |  271 |       842 | 430.51K |  464 | "31,41,51,61,71,81" | 0:00'54'' | 0:00'11'' |
| Q25L60X20P001  | 100M   |   20.0 |  1423 | 932.17K |  755 |      1773 | 489.37K |  279 |       836 |  442.8K |  476 | "31,41,51,61,71,81" | 0:00'54'' | 0:00'12'' |
| Q25L60X20P002  | 100M   |   20.0 |  1371 | 919.46K |  763 |      1743 |  475.3K |  279 |       832 | 444.16K |  484 | "31,41,51,61,71,81" | 0:00'53'' | 0:00'11'' |
| Q25L60X40P000  | 200M   |   40.0 |   772 | 633.76K |  742 |      1288 | 114.76K |   85 |       694 | 518.99K |  657 | "31,41,51,61,71,81" | 0:01'25'' | 0:00'12'' |
| Q25L60X40P001  | 200M   |   40.0 |   811 | 631.14K |  732 |      1228 | 120.15K |   91 |       702 | 510.99K |  641 | "31,41,51,61,71,81" | 0:01'25'' | 0:00'11'' |
| Q25L60X40P002  | 200M   |   40.0 |   792 | 622.34K |  718 |      1272 | 110.31K |   82 |       711 | 512.03K |  636 | "31,41,51,61,71,81" | 0:01'25'' | 0:00'11'' |
| Q25L60X80P000  | 400M   |   80.0 |   689 |   1.17M | 1595 |      1240 |  93.38K |   71 |       666 |   1.08M | 1524 | "31,41,51,61,71,81" | 0:02'31'' | 0:00'14'' |
| Q25L60X80P001  | 400M   |   80.0 |   695 |   1.15M | 1554 |      1266 |   93.1K |   70 |       669 |   1.05M | 1484 | "31,41,51,61,71,81" | 0:02'32'' | 0:00'14'' |
| Q25L60X80P002  | 400M   |   80.0 |   677 |   1.21M | 1657 |      1314 |  99.13K |   73 |       656 |   1.11M | 1584 | "31,41,51,61,71,81" | 0:02'31'' | 0:00'13'' |
| Q25L60X160P000 | 800M   |  160.0 |  1123 |   4.49M | 4332 |      1591 |   2.34M | 1462 |       766 |   2.15M | 2870 | "31,41,51,61,71,81" | 0:04'47'' | 0:00'27'' |
| Q25L60X160P001 | 800M   |  160.0 |  1137 |   4.59M | 4363 |      1632 |   2.43M | 1486 |       772 |   2.16M | 2877 | "31,41,51,61,71,81" | 0:04'47'' | 0:00'29'' |
| Q25L60X160P002 | 800M   |  160.0 |  1124 |   4.46M | 4288 |      1625 |   2.33M | 1423 |       757 |   2.13M | 2865 | "31,41,51,61,71,81" | 0:04'48'' | 0:00'28'' |
| Q30L60X10P000  | 50M    |   10.0 |  2810 |   1.05M |  509 |      3345 | 806.31K |  287 |      1093 | 244.53K |  222 | "31,41,51,61,71,81" | 0:00'38'' | 0:00'12'' |
| Q30L60X10P001  | 50M    |   10.0 |  3137 |   1.06M |  463 |      3797 | 824.11K |  262 |      1188 |  238.8K |  201 | "31,41,51,61,71,81" | 0:00'38'' | 0:00'11'' |
| Q30L60X10P002  | 50M    |   10.0 |  3251 |   1.06M |  475 |      4129 | 819.57K |  258 |      1170 | 243.89K |  217 | "31,41,51,61,71,81" | 0:00'37'' | 0:00'10'' |
| Q30L60X20P000  | 100M   |   20.0 |  1641 | 981.19K |  712 |      1890 | 575.76K |  308 |       882 | 405.42K |  404 | "31,41,51,61,71,81" | 0:00'53'' | 0:00'11'' |
| Q30L60X20P001  | 100M   |   20.0 |  1679 | 978.72K |  692 |      1985 | 600.99K |  308 |       871 | 377.74K |  384 | "31,41,51,61,71,81" | 0:00'53'' | 0:00'11'' |
| Q30L60X20P002  | 100M   |   20.0 |  1572 | 967.28K |  719 |      1864 | 564.41K |  308 |       862 | 402.87K |  411 | "31,41,51,61,71,81" | 0:00'53'' | 0:00'11'' |
| Q30L60X40P000  | 200M   |   40.0 |   819 |  743.7K |  836 |      1383 | 180.38K |  126 |       714 | 563.32K |  710 | "31,41,51,61,71,81" | 0:01'24'' | 0:00'11'' |
| Q30L60X40P001  | 200M   |   40.0 |   848 | 736.66K |  827 |      1336 | 182.77K |  131 |       709 | 553.89K |  696 | "31,41,51,61,71,81" | 0:01'24'' | 0:00'11'' |
| Q30L60X40P002  | 200M   |   40.0 |   857 | 729.48K |  813 |      1275 | 180.69K |  134 |       739 | 548.79K |  679 | "31,41,51,61,71,81" | 0:01'23'' | 0:00'11'' |
| Q30L60X80P000  | 400M   |   80.0 |   691 |   1.25M | 1705 |      1239 |  95.83K |   73 |       668 |   1.16M | 1632 | "31,41,51,61,71,81" | 0:02'30'' | 0:00'14'' |
| Q30L60X80P001  | 400M   |   80.0 |   701 |   1.21M | 1643 |      1265 |  96.33K |   73 |       676 |   1.12M | 1570 | "31,41,51,61,71,81" | 0:02'31'' | 0:00'14'' |
| Q30L60X80P002  | 400M   |   80.0 |   681 |   1.29M | 1770 |      1298 | 107.86K |   81 |       659 |   1.18M | 1689 | "31,41,51,61,71,81" | 0:02'29'' | 0:00'14'' |
| Q30L60X160P000 | 800M   |  160.0 |  1139 |   4.56M | 4353 |      1592 |   2.42M | 1504 |       766 |   2.14M | 2849 | "31,41,51,61,71,81" | 0:04'41'' | 0:00'28'' |
| Q30L60X160P001 | 800M   |  160.0 |  1161 |   4.66M | 4364 |      1645 |    2.5M | 1518 |       776 |   2.15M | 2846 | "31,41,51,61,71,81" | 0:04'40'' | 0:00'28'' |
| Q30L60X160P002 | 800M   |  160.0 |  1164 |   4.52M | 4274 |      1639 |   2.42M | 1462 |       759 |    2.1M | 2812 | "31,41,51,61,71,81" | 0:04'41'' | 0:00'28'' |

## m07: merge anchors

```bash
cd ${HOME}/data/dna-seq/xjy/${BASE_NAME}

# merge anchors
mkdir -p merge
anchr contained \
    $(
        parallel -k --no-run-if-empty -j 6 "
            if [ -e Q{1}L{2}X{3}P{4}/anchor/pe.anchor.fa ]; then
                echo Q{1}L{2}X{3}P{4}/anchor/pe.anchor.fa
            fi
            " ::: 25 30 ::: 60 ::: 10 20 40 ::: 000 001 002 003 004 005 006
    ) \
    --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
    -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/anchor.contained.fasta
anchr orient merge/anchor.contained.fasta --len 1000 --idt 0.98 -o merge/anchor.orient.fasta
anchr merge merge/anchor.orient.fasta --len 1000 --idt 0.999 -o merge/anchor.merge0.fasta
anchr contained merge/anchor.merge0.fasta --len 1000 --idt 0.98 \
    --proportion 0.99 --parallel 16 -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/anchor.merge.fasta

# merge others
mkdir -p merge
anchr contained \
    $(
        parallel -k --no-run-if-empty -j 6 "
            if [ -e Q{1}L{2}X{3}P{4}/anchor/pe.others.fa ]; then
                echo Q{1}L{2}X{3}P{4}/anchor/pe.others.fa
            fi
            " ::: 25 30 ::: 60 ::: 10 20 40 ::: 000 001 002 003 004 005 006
    ) \
    --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
    -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/others.contained.fasta
anchr orient merge/others.contained.fasta --len 1000 --idt 0.98 -o merge/others.orient.fasta
anchr merge merge/others.orient.fasta --len 1000 --idt 0.999 -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/others.merge.fasta

# quast
rm -fr 9_qa
quast --no-check --threads 16 \
    --eukaryote \
    --no-icarus \
    merge/anchor.merge.fasta \
    merge/others.merge.fasta \
    --label "merge,others" \
    -o 9_qa

```

## m07: expand anchors

* contigTrim

```bash
cd ${HOME}/data/dna-seq/xjy/${BASE_NAME}

rm -fr contigTrim
anchr overlap2 \
    --parallel 16 \
    merge/anchor.merge.fasta \
    8_spades/contigs.non-contained.fasta \
    -d contigTrim \
    -b 10 --len 1000 --idt 0.98 --all

CONTIG_COUNT=$(faops n50 -H -N 0 -C contigTrim/anchor.fasta)
echo ${CONTIG_COUNT}

rm -fr contigTrim/group
anchr group \
    --parallel 16 \
    --keep \
    contigTrim/anchorLong.db \
    contigTrim/anchorLong.ovlp.tsv \
    --range "1-${CONTIG_COUNT}" --len 1000 --idt 0.98 --max 500 -c 1 --png

pushd contigTrim
cat group/groups.txt \
    | parallel --no-run-if-empty -j 8 '
        echo {};
        anchr orient \
            --len 1000 --idt 0.98 \
            group/{}.anchor.fasta \
            group/{}.long.fasta \
            -r group/{}.restrict.tsv \
            -o group/{}.strand.fasta;

        anchr overlap --len 1000 --idt 0.98 --all \
            group/{}.strand.fasta \
            -o stdout \
            | anchr restrict \
                stdin group/{}.restrict.tsv \
                -o group/{}.ovlp.tsv;

        anchr layout \
            group/{}.ovlp.tsv \
            group/{}.relation.tsv \
            group/{}.strand.fasta \
            --png \
            -o group/{}.contig.fasta
    '
popd

cat \
    contigTrim/group/non_grouped.fasta \
    contigTrim/group/*.contig.fasta \
    >  contigTrim/contig.fasta

```

## m07: final stats

* Stats

```bash
cd ${HOME}/data/dna-seq/xjy/${BASE_NAME}

printf "| %s | %s | %s | %s |\n" \
    "Name" "N50" "Sum" "#" \
    > stat3.md
printf "|:--|--:|--:|--:|\n" >> stat3.md

printf "| %s | %s | %s | %s |\n" \
    $(echo "anchor.merge"; faops n50 -H -S -C merge/anchor.merge.fasta;) >> stat3.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "others.merge"; faops n50 -H -S -C merge/others.merge.fasta;) >> stat3.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "contigTrim"; faops n50 -H -S -C contigTrim/contig.fasta;) >> stat3.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "spades.contig"; faops n50 -H -S -C 8_spades/contigs.fasta;) >> stat3.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "spades.non-contained"; faops n50 -H -S -C 8_spades/contigs.non-contained.fasta;) >> stat3.md

cat stat3.md
```

| Name                 |    N50 |      Sum |     # |
|:---------------------|-------:|---------:|------:|
| anchor.merge         |  10412 |   971844 |   140 |
| others.merge         |   3456 |   400838 |   159 |
| contigTrim           |  17931 |   929973 |    85 |
| spades.contig        |    299 | 36134245 | 95229 |
| spades.non-contained | 146263 |  9281259 |  1203 |

* Clear QxxLxxXxx.

```bash
cd ${HOME}/data/dna-seq/xjy/${BASE_NAME}

rm -fr 2_illumina/Q{20,25,30,35}L{1,60,90,120}X*
rm -fr Q{20,25,30,35}L{1,60,90,120}X*
```

# m08

## m08: download

```bash
BASE_NAME=m08
REAL_G=5000000

mkdir -p ~/data/dna-seq/xjy/${BASE_NAME}/2_illumina
cd ~/data/dna-seq/xjy/${BASE_NAME}/2_illumina

ln -s ~/data/dna-seq/xjy/clean_data/m08_H3J5KDMXX_L1_1.clean.fq.gz R1.fq.gz
ln -s ~/data/dna-seq/xjy/clean_data/m08_H3J5KDMXX_L1_2.clean.fq.gz R2.fq.gz
```

* FastQC

* kmergenie


## m08: combinations of different quality values and read lengths

* qual: 25 and 30
* len: 60


| Name     | N50 |        Sum |        # |
|:---------|----:|-----------:|---------:|
| Illumina | 150 | 7085079300 | 47233862 |
| uniq     | 150 | 5359437300 | 35729582 |
| Q25L60   | 150 | 5318392753 | 35640710 |
| Q30L60   | 150 | 5219102107 | 35499865 |

## m08: spades


## m08: quorum

| Name   | SumIn | CovIn | SumOut | CovOut | Discard% | AvgRead |  Kmer | RealG |    EstG | Est/Real |   RunTime |
|:-------|------:|------:|-------:|-------:|---------:|--------:|------:|------:|--------:|---------:|----------:|
| Q25L60 | 3.75G | 749.6 |  2.16G |  432.6 |  42.290% |     148 | "105" |    5M | 272.67M |    54.53 | 0:19'02'' |
| Q30L60 | 3.64G | 727.6 |  2.15G |  430.0 |  40.904% |     145 | "105" |    5M | 268.31M |    53.66 | 0:19'16'' |

* Clear intermediate files.


## m08: down sampling


## m08: k-unitigs and anchors (sampled)

| Name           | SumCor | CovCor | N50SR |     Sum |    # | N50Anchor |     Sum |   # | N50Others |     Sum |    # |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|:-------|-------:|------:|--------:|-----:|----------:|--------:|----:|----------:|--------:|-----:|--------------------:|----------:|----------:|
| Q25L60X10P000  | 50M    |   10.0 |   628 |  18.98K |   29 |      1317 |   1.32K |   1 |       619 |  17.67K |   28 | "31,41,51,61,71,81" | 0:01'21'' | 0:00'06'' |
| Q25L60X10P001  | 50M    |   10.0 |   568 |  21.33K |   35 |         0 |       0 |   0 |       568 |  21.33K |   35 | "31,41,51,61,71,81" | 0:01'20'' | 0:00'06'' |
| Q25L60X10P002  | 50M    |   10.0 |   574 |  15.05K |   24 |         0 |       0 |   0 |       574 |  15.05K |   24 | "31,41,51,61,71,81" | 0:01'20'' | 0:00'05'' |
| Q25L60X20P000  | 100M   |   20.0 |   618 | 126.43K |  195 |      1173 |   7.33K |   6 |       607 | 119.11K |  189 | "31,41,51,61,71,81" | 0:02'18'' | 0:00'07'' |
| Q25L60X20P001  | 100M   |   20.0 |   635 | 125.64K |  193 |      1213 |   1.21K |   1 |       634 | 124.43K |  192 | "31,41,51,61,71,81" | 0:02'19'' | 0:00'07'' |
| Q25L60X20P002  | 100M   |   20.0 |   653 | 126.11K |  186 |      1340 |   9.64K |   7 |       626 | 116.47K |  179 | "31,41,51,61,71,81" | 0:02'19'' | 0:00'07'' |
| Q25L60X40P000  | 200M   |   40.0 |   918 |  609.9K |  705 |      1355 | 229.63K | 160 |       700 | 380.27K |  545 | "31,41,51,61,71,81" | 0:04'16'' | 0:00'09'' |
| Q25L60X40P001  | 200M   |   40.0 |   902 | 597.78K |  671 |      1499 | 231.05K | 154 |       730 | 366.74K |  517 | "31,41,51,61,71,81" | 0:04'09'' | 0:00'11'' |
| Q25L60X40P002  | 200M   |   40.0 |   887 |  571.5K |  669 |      1344 | 205.78K | 144 |       706 | 365.71K |  525 | "31,41,51,61,71,81" | 0:04'18'' | 0:00'10'' |
| Q25L60X80P000  | 400M   |   80.0 |  2349 |   1.15M |  824 |      3295 | 801.45K | 280 |       625 | 352.81K |  544 | "31,41,51,61,71,81" | 0:06'49'' | 0:00'13'' |
| Q25L60X80P001  | 400M   |   80.0 |  1943 |   1.14M |  832 |      3125 | 788.79K | 301 |       656 | 353.35K |  531 | "31,41,51,61,71,81" | 0:06'38'' | 0:00'13'' |
| Q25L60X80P002  | 400M   |   80.0 |  2319 |   1.16M |  816 |      3267 | 813.18K | 280 |       624 | 347.49K |  536 | "31,41,51,61,71,81" | 0:07'30'' | 0:00'13'' |
| Q25L60X160P000 | 800M   |  160.0 |   663 |   2.54M | 2996 |      1392 |  27.71K |  20 |       658 |   2.51M | 2976 | "31,41,51,61,71,81" | 0:12'08'' | 0:00'22'' |
| Q25L60X160P001 | 800M   |  160.0 |   654 |   2.59M | 3063 |      1333 |  27.53K |  19 |       650 |   2.56M | 3044 | "31,41,51,61,71,81" | 0:13'15'' | 0:00'21'' |
| Q30L60X10P000  | 50M    |   10.0 |   628 |  16.67K |   26 |         0 |       0 |   0 |       628 |  16.67K |   26 | "31,41,51,61,71,81" | 0:00'53'' | 0:00'06'' |
| Q30L60X10P001  | 50M    |   10.0 |   574 |  23.21K |   37 |         0 |       0 |   0 |       574 |  23.21K |   37 | "31,41,51,61,71,81" | 0:01'17'' | 0:00'06'' |
| Q30L60X10P002  | 50M    |   10.0 |   593 |  19.31K |   30 |         0 |       0 |   0 |       593 |  19.31K |   30 | "31,41,51,61,71,81" | 0:01'16'' | 0:00'07'' |
| Q30L60X20P000  | 100M   |   20.0 |   622 | 131.39K |  202 |      1173 |   7.42K |   6 |       614 | 123.97K |  196 | "31,41,51,61,71,81" | 0:01'48'' | 0:00'07'' |
| Q30L60X20P001  | 100M   |   20.0 |   641 | 126.29K |  193 |      1212 |   2.28K |   2 |       637 | 124.02K |  191 | "31,41,51,61,71,81" | 0:01'40'' | 0:00'08'' |
| Q30L60X20P002  | 100M   |   20.0 |   680 | 127.79K |  187 |      1349 |   9.78K |   7 |       640 | 118.01K |  180 | "31,41,51,61,71,81" | 0:01'29'' | 0:00'08'' |
| Q30L60X40P000  | 200M   |   40.0 |   905 | 622.49K |  720 |      1405 | 234.62K | 162 |       697 | 387.87K |  558 | "31,41,51,61,71,81" | 0:03'52'' | 0:00'10'' |
| Q30L60X40P001  | 200M   |   40.0 |   892 | 619.22K |  699 |      1525 | 230.74K | 150 |       730 | 388.48K |  549 | "31,41,51,61,71,81" | 0:03'06'' | 0:00'10'' |
| Q30L60X40P002  | 200M   |   40.0 |   913 | 584.11K |  680 |      1370 |  211.3K | 149 |       702 | 372.81K |  531 | "31,41,51,61,71,81" | 0:03'14'' | 0:00'10'' |
| Q30L60X80P000  | 400M   |   80.0 |  2355 |   1.17M |  837 |      3391 | 813.24K | 286 |       618 | 354.73K |  551 | "31,41,51,61,71,81" | 0:05'13'' | 0:00'14'' |
| Q30L60X80P001  | 400M   |   80.0 |  2111 |   1.14M |  821 |      3119 |  805.1K | 306 |       647 | 338.89K |  515 | "31,41,51,61,71,81" | 0:05'13'' | 0:00'13'' |
| Q30L60X80P002  | 400M   |   80.0 |  2155 |   1.17M |  837 |      3096 |  807.9K | 284 |       633 | 361.71K |  553 | "31,41,51,61,71,81" | 0:05'13'' | 0:00'14'' |
| Q30L60X160P000 | 800M   |  160.0 |   660 |   2.56M | 3029 |      1346 |  27.56K |  20 |       656 |   2.54M | 3009 | "31,41,51,61,71,81" | 0:10'26'' | 0:00'21'' |
| Q30L60X160P001 | 800M   |  160.0 |   657 |   2.57M | 3020 |      1333 |  42.21K |  29 |       650 |   2.53M | 2991 | "31,41,51,61,71,81" | 0:10'32'' | 0:00'21'' |

## m08: merge anchors


## m08: expand anchors

* contigTrim


## m08: final stats

* Stats

| Name                 |  N50 |       Sum |      # |
|:---------------------|-----:|----------:|-------:|
| anchor.merge         | 1669 |   1076402 |    641 |
| others.merge         | 1042 |    333326 |    311 |
| contigTrim           | 8852 |    860024 |    170 |
| spades.contig        |  964 | 403808501 | 623552 |
| spades.non-contained | 1805 | 195666641 | 109369 |

* Clear QxxLxxXxx.

