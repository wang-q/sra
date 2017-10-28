# Organelles 2

[TOC levels=1-3]: # " "
- [Organelles 2](#organelles-2)
- [m07](#m07)
    - [m07: download](#m07-download)
    - [m07: combinations of different quality values and read lengths](#m07-combinations-of-different-quality-values-and-read-lengths)
    - [m07: spades](#m07-spades)
    - [m07: platanus](#m07-platanus)
    - [m07: quorum](#m07-quorum)
    - [m07: down sampling](#m07-down-sampling)
    - [m07: k-unitigs and anchors (sampled)](#m07-k-unitigs-and-anchors-sampled)
    - [m07: merge anchors](#m07-merge-anchors)


# m07

## m07: download

```bash
mkdir -p ~/data/dna-seq/xjy/m07/2_illumina
cd ~/data/dna-seq/xjy/m07/2_illumina

ln -s ~/data/dna-seq/xjy/clean_data/m07_H3J5KDMXX_L1_1.clean.fq.gz R1.fq.gz
ln -s ~/data/dna-seq/xjy/clean_data/m07_H3J5KDMXX_L1_2.clean.fq.gz R2.fq.gz
```

* FastQC

```bash
BASE_NAME=m07
cd ${HOME}/data/dna-seq/xjy/${BASE_NAME}

mkdir -p 2_illumina/fastqc
cd 2_illumina/fastqc

fastqc -t 16 \
    ../R1.fq.gz ../R2.fq.gz \
    -o .

```

* kmergenie

```bash
BASE_NAME=m07
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
BASE_NAME=m07
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
| Illumina | 150 | 7085079300 | 47233862 |
| uniq     | 150 | 5359437300 | 35729582 |
| Q25L60   | 150 | 5318392753 | 35640710 |
| Q30L60   | 150 | 5219102107 | 35499865 |

## m07: spades

```bash
BASE_NAME=m07
cd ${HOME}/data/dna-seq/xjy/${BASE_NAME}

spades.py \
    -t 16 \
    -k 21,33,55,77 \
    -1 2_illumina/Q25L60/R1.fq.gz \
    -2 2_illumina/Q25L60/R2.fq.gz \
    -s 2_illumina/Q25L60/Rs.fq.gz \
    -o 8_spades

```

## m07: platanus

```bash
BASE_NAME=m07
cd ${HOME}/data/dna-seq/xjy/${BASE_NAME}

mkdir -p 8_platanus
cd 8_platanus

if [ ! -e R1.fa ]; then
    parallel --no-run-if-empty -j 3 "
        faops filter -l 0 ../2_illumina/Q25L60/{}.fq.gz {}.fa
        " ::: R1 R2 Rs
fi

platanus assemble -t 16 -m 200 \
    -f R1.fa R2.fa Rs.fa \
    2>&1 | tee ass_log.txt

platanus scaffold -t 16 \
    -c out_contig.fa -b out_contigBubble.fa \
    -IP1 R1.fa R2.fa \
    2>&1 | tee sca_log.txt

platanus gap_close -t 16 \
    -c out_scaffold.fa \
    -IP1 R1.fa R2.fa \
    2>&1 | tee gap_log.txt

```

## m07: quorum

```bash
BASE_NAME=m07
REAL_G=5000000
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
BASE_NAME=m07
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
BASE_NAME=m07
REAL_G=5000000
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
BASE_NAME=m07
REAL_G=5000000
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
BASE_NAME=m07
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

* Stats

```bash
BASE_NAME=m07
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
    $(echo "spades.contig"; faops n50 -H -S -C 8_spades/contigs.fasta;) >> stat3.md

cat stat3.md
```

| Name          |   N50 |      Sum |     # |
|:--------------|------:|---------:|------:|
| anchor.merge  | 10412 |   971844 |   140 |
| others.merge  |  3456 |   400838 |   159 |
| spades.contig |   299 | 36134245 | 95229 |

* Clear QxxLxxXxx.

```bash
BASE_NAME=m07
cd ${HOME}/data/dna-seq/xjy/${BASE_NAME}

rm -fr 2_illumina/Q{20,25,30,35}L{1,60,90,120}X*
rm -fr Q{20,25,30,35}L{1,60,90,120}X*
```
