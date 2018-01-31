# Organelles: anchr + spades

[TOC levels=1-3]: # " "
- [Organelles: anchr + spades](#organelles-anchr--spades)
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
- [m15](#m15)
    - [m15: download](#m15-download)
    - [m15: combinations of different quality values and read lengths](#m15-combinations-of-different-quality-values-and-read-lengths)
- [m17](#m17)
    - [m17: download](#m17-download)
    - [m17: combinations of different quality values and read lengths](#m17-combinations-of-different-quality-values-and-read-lengths)
- [m19](#m19)
    - [m19: download](#m19-download)
    - [m19: combinations of different quality values and read lengths](#m19-combinations-of-different-quality-values-and-read-lengths)
- [m20](#m20)
    - [m20: download](#m20-download)
    - [m20: template](#m20-template)
    - [m20: run](#m20-run)
- [m22](#m22)
    - [m22: download](#m22-download)
    - [m22: template](#m22-template)
    - [m22: run](#m22-run)
    - [m22: spades](#m22-spades)
- [mt203](#mt203)
    - [mt203: download](#mt203-download)
    - [mt203: template](#mt203-template)
    - [mt203: run](#mt203-run)
- [mt301](#mt301)
    - [mt301: download](#mt301-download)
    - [mt301: template](#mt301-template)
    - [mt301: run](#mt301-run)
- [mt302](#mt302)
    - [mt302: download](#mt302-download)
    - [mt302: template](#mt302-template)
    - [mt302: run](#mt302-run)
- [Create tarballs](#create-tarballs)


* Rsync to hpcc

```bash
rsync -avP \
    ~/data/dna-seq/xjy/clean_data/ \
    wangq@202.119.37.251:data/dna-seq/xjy/clean_data

rsync -avP \
    ~/data/dna-seq/xjy/raw_data/ \
    wangq@202.119.37.251:data/dna-seq/xjy/raw_data

# rsync -avP wangq@202.119.37.251:data/dna-seq/xjy/ data/dna-seq/xjy

```

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
            " ::: 25 30 ::: 60 ::: 10 20 40 80 160 ::: $(printf "%03d " {0..100})
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
            " ::: 25 30 ::: 60 ::: 10 20 40 80 160 ::: $(printf "%03d " {0..100})
    ) \
    --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
    -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/others.contained.fasta
anchr orient merge/others.contained.fasta --len 1000 --idt 0.98 -o merge/others.orient.fasta
anchr merge merge/others.orient.fasta --len 1000 --idt 0.999 -o merge/others.merge0.fasta
anchr contained merge/others.merge0.fasta --len 1000 --idt 0.98 \
    --proportion 0.99 --parallel 16 -o stdout \
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
    --range "1-${CONTIG_COUNT}" --len 1000 --idt 0.98 --max 2000 -c 1

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
| anchor.merge         |   2381 |  9444380 |  4154 |
| others.merge         |   1619 |  4705716 |  2743 |
| contigTrim           | 106055 |  7952830 |   218 |
| spades.contig        |    299 | 36134245 | 95229 |
| spades.non-contained | 146263 |  9281259 |  1203 |

* Clear QxxLxxXxx.

```bash
cd ${HOME}/data/dna-seq/xjy/${BASE_NAME}

rm -fr 2_illumina/Q{20,25,30,35}L{1,30,60,90,120}X*
rm -fr Q{20,25,30,35}L{1,30,60,90,120}X*
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

## m08: combinations of different quality values and read lengths

* qual: 25 and 30
* len: 60

| Name     | N50 |        Sum |        # |
|:---------|----:|-----------:|---------:|
| Illumina | 150 | 4775528100 | 31836854 |
| uniq     | 150 | 3818789100 | 25458594 |
| Q25L60   | 150 | 3747791294 | 25336226 |
| Q30L60   | 150 | 3637564323 | 25146240 |

| Name   | SumIn | CovIn | SumOut | CovOut | Discard% | AvgRead |  Kmer | RealG |    EstG | Est/Real |   RunTime |
|:-------|------:|------:|-------:|-------:|---------:|--------:|------:|------:|--------:|---------:|----------:|
| Q25L60 | 3.75G | 749.6 |  2.16G |  432.6 |  42.290% |     148 | "105" |    5M | 272.67M |    54.53 | 0:19'02'' |
| Q30L60 | 3.64G | 727.6 |  2.15G |  430.0 |  40.904% |     145 | "105" |    5M | 268.31M |    53.66 | 0:19'16'' |

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

| Name                 |   N50 |       Sum |      # |
|:---------------------|------:|----------:|-------:|
| anchor.merge         |  1669 |   1076402 |    641 |
| others.merge         |  1042 |    333326 |    311 |
| contigTrim           | 20993 |    928522 |    104 |
| spades.contig        |   964 | 403808501 | 623552 |
| spades.non-contained |  1805 | 195666641 | 109369 |

# m15

## m15: download

```bash
BASE_NAME=m15
REAL_G=5000000

mkdir -p ~/data/dna-seq/xjy/${BASE_NAME}/2_illumina
cd ~/data/dna-seq/xjy/${BASE_NAME}/2_illumina

ln -s ~/data/dna-seq/xjy/clean_data/m15_H3HTCDMXX_L1_1.clean.fq.gz R1.fq.gz
ln -s ~/data/dna-seq/xjy/clean_data/m15_H3HTCDMXX_L1_2.clean.fq.gz R2.fq.gz
```

## m15: combinations of different quality values and read lengths

* qual: 25 and 30
* len: 60

| Name     | N50 |        Sum |        # |
|:---------|----:|-----------:|---------:|
| Illumina | 150 | 6522297300 | 43481982 |
| uniq     | 150 | 5586591600 | 37243944 |
| Q25L60   | 150 | 5537686393 | 37150680 |
| Q30L60   | 150 | 5401706841 | 36955329 |

| Name   | SumIn |  CovIn | SumOut | CovOut | Discard% | AvgRead |  Kmer | RealG |   EstG | Est/Real |   RunTime |
|:-------|------:|-------:|-------:|-------:|---------:|--------:|------:|------:|-------:|---------:|----------:|
| Q25L60 | 5.54G | 1107.5 |  2.13G |  426.8 |  61.460% |     149 | "105" |    5M | 96.64M |    19.33 | 0:26'25'' |
| Q30L60 |  5.4G | 1080.4 |   2.1G |  420.9 |  61.041% |     146 | "105" |    5M | 91.82M |    18.36 | 0:28'59'' |

| Name           | SumCor | CovCor | N50SR |     Sum |   # | N50Anchor |     Sum |   # | N50Others |     Sum |   # |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|:-------|-------:|------:|--------:|----:|----------:|--------:|----:|----------:|--------:|----:|--------------------:|----------:|----------:|
| Q25L60X10P000  | 50M    |   10.0 |  1960 | 707.82K | 465 |      2536 |  509.3K | 223 |       825 | 198.52K | 242 | "31,41,51,61,71,81" | 0:01'20'' | 0:00'18'' |
| Q25L60X10P001  | 50M    |   10.0 |  2098 | 700.04K | 438 |      3035 | 484.68K | 193 |       879 | 215.36K | 245 | "31,41,51,61,71,81" | 0:01'18'' | 0:00'15'' |
| Q25L60X10P002  | 50M    |   10.0 |  2006 | 700.16K | 465 |      2620 | 499.58K | 216 |       792 | 200.58K | 249 | "31,41,51,61,71,81" | 0:01'18'' | 0:00'16'' |
| Q25L60X20P000  | 100M   |   20.0 |  1281 | 589.43K | 505 |      1621 | 246.62K | 153 |       871 | 342.81K | 352 | "31,41,51,61,71,81" | 0:01'28'' | 0:00'16'' |
| Q25L60X20P001  | 100M   |   20.0 |  1286 | 589.97K | 507 |      1671 | 239.66K | 143 |       857 | 350.32K | 364 | "31,41,51,61,71,81" | 0:01'30'' | 0:00'15'' |
| Q25L60X20P002  | 100M   |   20.0 |  1188 | 607.86K | 540 |      1578 | 248.74K | 159 |       866 | 359.12K | 381 | "31,41,51,61,71,81" | 0:01'31'' | 0:00'12'' |
| Q25L60X40P000  | 200M   |   40.0 |   935 | 332.03K | 324 |      1346 |  38.06K |  27 |       819 | 293.96K | 297 | "31,41,51,61,71,81" | 0:02'38'' | 0:00'13'' |
| Q25L60X40P001  | 200M   |   40.0 |   913 | 332.28K | 328 |      1332 |  48.31K |  33 |       806 | 283.97K | 295 | "31,41,51,61,71,81" | 0:02'41'' | 0:00'21'' |
| Q25L60X40P002  | 200M   |   40.0 |   829 | 326.86K | 334 |      1505 |   41.2K |  25 |       758 | 285.66K | 309 | "31,41,51,61,71,81" | 0:02'29'' | 0:00'19'' |
| Q25L60X80P000  | 400M   |   80.0 |  2472 |  173.9K | 139 |      3687 | 107.58K |  35 |       622 |  66.32K | 104 | "31,41,51,61,71,81" | 0:04'31'' | 0:00'10'' |
| Q25L60X80P001  | 400M   |   80.0 |  1958 | 172.86K | 137 |      3041 | 111.37K |  40 |       624 |  61.49K |  97 | "31,41,51,61,71,81" | 0:04'31'' | 0:00'10'' |
| Q25L60X80P002  | 400M   |   80.0 |  1888 | 165.96K | 131 |      3080 | 108.69K |  42 |       623 |  57.27K |  89 | "31,41,51,61,71,81" | 0:04'33'' | 0:00'12'' |
| Q25L60X160P000 | 800M   |  160.0 |  1068 | 173.69K | 178 |      1201 |   3.75K |   3 |      1047 | 169.93K | 175 | "31,41,51,61,71,81" | 0:10'20'' | 0:00'15'' |
| Q25L60X160P001 | 800M   |  160.0 |  1041 | 178.84K | 190 |      1142 |   1.14K |   1 |       942 |  177.7K | 189 | "31,41,51,61,71,81" | 0:10'24'' | 0:00'14'' |
| Q30L60X10P000  | 50M    |   10.0 |  2439 |  719.1K | 404 |      3142 | 549.67K | 211 |       871 | 169.42K | 193 | "31,41,51,61,71,81" | 0:01'04'' | 0:00'12'' |
| Q30L60X10P001  | 50M    |   10.0 |  2805 | 716.33K | 395 |      3714 | 524.54K | 181 |       885 | 191.78K | 214 | "31,41,51,61,71,81" | 0:01'06'' | 0:00'10'' |
| Q30L60X10P002  | 50M    |   10.0 |  2432 | 712.27K | 409 |      2949 | 542.95K | 206 |       803 | 169.33K | 203 | "31,41,51,61,71,81" | 0:01'03'' | 0:00'10'' |
| Q30L60X20P000  | 100M   |   20.0 |  1558 | 639.55K | 498 |      1834 | 324.64K | 179 |       885 | 314.91K | 319 | "31,41,51,61,71,81" | 0:01'40'' | 0:00'15'' |
| Q30L60X20P001  | 100M   |   20.0 |  1507 | 650.54K | 507 |      1843 | 327.62K | 181 |       867 | 322.93K | 326 | "31,41,51,61,71,81" | 0:01'41'' | 0:00'15'' |
| Q30L60X20P002  | 100M   |   20.0 |  1435 | 659.44K | 522 |      1731 | 329.29K | 192 |       891 | 330.16K | 330 | "31,41,51,61,71,81" | 0:01'41'' | 0:00'14'' |
| Q30L60X40P000  | 200M   |   40.0 |   994 |  405.1K | 396 |      1352 |   85.6K |  61 |       815 |  319.5K | 335 | "31,41,51,61,71,81" | 0:02'55'' | 0:00'16'' |
| Q30L60X40P001  | 200M   |   40.0 |   958 | 407.43K | 406 |      1320 |  73.32K |  54 |       816 | 334.12K | 352 | "31,41,51,61,71,81" | 0:02'59'' | 0:00'14'' |
| Q30L60X40P002  | 200M   |   40.0 |   884 | 406.91K | 416 |      1313 |  65.43K |  50 |       773 | 341.49K | 366 | "31,41,51,61,71,81" | 0:02'51'' | 0:00'14'' |
| Q30L60X80P000  | 400M   |   80.0 |  1237 | 208.24K | 186 |      4040 | 114.23K |  39 |       629 |  94.01K | 147 | "31,41,51,61,71,81" | 0:05'21'' | 0:00'18'' |
| Q30L60X80P001  | 400M   |   80.0 |  1745 | 198.18K | 174 |      3136 |  115.4K |  39 |       599 |  82.78K | 135 | "31,41,51,61,71,81" | 0:05'26'' | 0:00'17'' |
| Q30L60X80P002  | 400M   |   80.0 |  1580 | 191.69K | 162 |      3423 | 115.81K |  42 |       620 |  75.88K | 120 | "31,41,51,61,71,81" | 0:05'25'' | 0:00'16'' |
| Q30L60X160P000 | 800M   |  160.0 |  1172 | 170.17K | 165 |      1201 |   3.81K |   3 |      1126 | 166.36K | 162 | "31,41,51,61,71,81" | 0:10'28'' | 0:00'24'' |
| Q30L60X160P001 | 800M   |  160.0 |  1174 | 180.65K | 179 |      1198 |   2.36K |   2 |      1174 | 178.29K | 177 | "31,41,51,61,71,81" | 0:10'16'' | 0:00'24'' |

| Name                 |   N50 |       Sum |       # |
|:---------------------|------:|----------:|--------:|
| anchor.merge         | 18461 |   1050354 |     120 |
| others.merge         |  1632 |    459105 |     258 |
| contigTrim           | 35778 |    855518 |      58 |
| spades.contig        |   285 | 459823867 | 1432956 |
| spades.non-contained |  1441 |  31715024 |   20536 |

# m17

## m17: download

```bash
BASE_NAME=m17
REAL_G=5000000

mkdir -p ~/data/dna-seq/xjy/${BASE_NAME}/2_illumina
cd ~/data/dna-seq/xjy/${BASE_NAME}/2_illumina

ln -s ~/data/dna-seq/xjy/clean_data/m17_H3J5KDMXX_L1_1.clean.fq.gz R1.fq.gz
ln -s ~/data/dna-seq/xjy/clean_data/m17_H3J5KDMXX_L1_2.clean.fq.gz R2.fq.gz
```

## m17: combinations of different quality values and read lengths

* qual: 25 and 30
* len: 60

| Name     | N50 |        Sum |        # |
|:---------|----:|-----------:|---------:|
| Illumina | 150 | 5426320500 | 36175470 |
| uniq     | 150 | 4368842100 | 29125614 |
| Q25L60   | 150 | 4298180667 | 28999450 |
| Q30L60   | 150 | 4180574936 | 28801284 |

| Name   | SumIn | CovIn | SumOut | CovOut | Discard% | AvgRead |  Kmer | RealG |    EstG | Est/Real |   RunTime |
|:-------|------:|------:|-------:|-------:|---------:|--------:|------:|------:|--------:|---------:|----------:|
| Q25L60 |  4.3G | 859.6 |  2.96G |  592.7 |  31.051% |     148 | "105" |    5M | 379.46M |    75.89 | 0:23'32'' |
| Q30L60 | 4.18G | 836.2 |  2.96G |  591.2 |  29.294% |     145 | "105" |    5M | 375.71M |    75.14 | 0:22'21'' |

| Name           | SumCor | CovCor | N50SR |     Sum |    # | N50Anchor |     Sum |   # | N50Others |     Sum |    # |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|:-------|-------:|------:|--------:|-----:|----------:|--------:|----:|----------:|--------:|-----:|--------------------:|----------:|----------:|
| Q25L60X10P000  | 50M    |   10.0 |   992 |  608.9K |  647 |      1556 | 256.02K | 163 |       742 | 352.88K |  484 | "31,41,51,61,71,81" | 0:01'23'' | 0:00'46'' |
| Q25L60X10P001  | 50M    |   10.0 |   935 | 595.92K |  651 |      1528 | 235.12K | 153 |       745 |  360.8K |  498 | "31,41,51,61,71,81" | 0:01'23'' | 0:00'46'' |
| Q25L60X10P002  | 50M    |   10.0 |   957 | 583.01K |  633 |      1521 | 241.83K | 155 |       720 | 341.18K |  478 | "31,41,51,61,71,81" | 0:01'20'' | 0:00'13'' |
| Q25L60X20P000  | 100M   |   20.0 |  3262 |   1.03M |  499 |      3697 | 874.59K | 292 |       752 |  153.5K |  207 | "31,41,51,61,71,81" | 0:01'57'' | 0:00'18'' |
| Q25L60X20P001  | 100M   |   20.0 |  3019 |   1.04M |  509 |      3628 | 847.46K | 285 |       840 | 197.29K |  224 | "31,41,51,61,71,81" | 0:02'18'' | 0:00'18'' |
| Q25L60X20P002  | 100M   |   20.0 |  3062 |   1.04M |  492 |      3578 | 867.52K | 293 |       845 | 172.01K |  199 | "31,41,51,61,71,81" | 0:02'15'' | 0:00'18'' |
| Q25L60X40P000  | 200M   |   40.0 |  5575 |    1.1M |  415 |      6507 | 964.93K | 221 |       705 | 134.94K |  194 | "31,41,51,61,71,81" | 0:04'28'' | 0:00'20'' |
| Q25L60X40P001  | 200M   |   40.0 |  5577 |    1.1M |  400 |      6055 | 949.91K | 217 |       785 |  151.8K |  183 | "31,41,51,61,71,81" | 0:03'36'' | 0:00'21'' |
| Q25L60X40P002  | 200M   |   40.0 |  5878 |   1.11M |  418 |      6506 | 974.94K | 224 |       657 | 130.64K |  194 | "31,41,51,61,71,81" | 0:03'57'' | 0:00'20'' |
| Q25L60X80P000  | 400M   |   80.0 |  2044 |   1.32M | 1021 |      1424 |  40.66K |  27 |      2148 |   1.28M |  994 | "31,41,51,61,71,81" | 0:06'11'' | 0:00'29'' |
| Q25L60X80P001  | 400M   |   80.0 |  2091 |    1.3M |  969 |      1427 |  34.62K |  23 |      2127 |   1.27M |  946 | "31,41,51,61,71,81" | 0:07'04'' | 0:00'27'' |
| Q25L60X80P002  | 400M   |   80.0 |  2149 |   1.35M | 1017 |      1456 |  19.84K |  14 |      2212 |   1.33M | 1003 | "31,41,51,61,71,81" | 0:07'13'' | 0:00'27'' |
| Q25L60X160P000 | 800M   |  160.0 |   595 |   4.91M | 7380 |      1208 |  37.14K |  30 |       594 |   4.87M | 7350 | "31,41,51,61,71,81" | 0:13'36'' | 0:00'54'' |
| Q25L60X160P001 | 800M   |  160.0 |   596 |   5.03M | 7551 |      1153 |  34.43K |  29 |       595 |      5M | 7522 | "31,41,51,61,71,81" | 0:16'07'' | 0:00'54'' |
| Q25L60X160P002 | 800M   |  160.0 |   597 |   4.94M | 7429 |      1275 |  34.91K |  26 |       595 |   4.91M | 7403 | "31,41,51,61,71,81" | 0:14'19'' | 0:00'54'' |
| Q30L60X10P000  | 50M    |   10.0 |   991 |    612K |  652 |      1547 | 256.12K | 163 |       737 | 355.88K |  489 | "31,41,51,61,71,81" | 0:00'53'' | 0:00'18'' |
| Q30L60X10P001  | 50M    |   10.0 |   928 |  609.2K |  672 |      1567 | 233.04K | 150 |       740 | 376.16K |  522 | "31,41,51,61,71,81" | 0:00'54'' | 0:00'14'' |
| Q30L60X10P002  | 50M    |   10.0 |   958 | 601.14K |  650 |      1505 |    238K | 154 |       745 | 363.14K |  496 | "31,41,51,61,71,81" | 0:00'54'' | 0:00'16'' |
| Q30L60X20P000  | 100M   |   20.0 |  3204 |   1.03M |  499 |      3671 | 873.96K | 292 |       748 | 152.51K |  207 | "31,41,51,61,71,81" | 0:01'31'' | 0:00'12'' |
| Q30L60X20P001  | 100M   |   20.0 |  3034 |   1.04M |  512 |      3623 |  850.5K | 291 |       854 | 191.74K |  221 | "31,41,51,61,71,81" | 0:01'31'' | 0:00'12'' |
| Q30L60X20P002  | 100M   |   20.0 |  2993 |   1.05M |  495 |      3630 | 870.87K | 291 |       845 | 179.36K |  204 | "31,41,51,61,71,81" | 0:01'33'' | 0:00'12'' |
| Q30L60X40P000  | 200M   |   40.0 |  5799 |    1.1M |  406 |      6519 | 963.42K | 213 |       720 |  135.3K |  193 | "31,41,51,61,71,81" | 0:02'46'' | 0:00'14'' |
| Q30L60X40P001  | 200M   |   40.0 |  5951 |    1.1M |  387 |      6627 | 955.52K | 209 |       771 | 145.74K |  178 | "31,41,51,61,71,81" | 0:03'09'' | 0:00'15'' |
| Q30L60X40P002  | 200M   |   40.0 |  6487 |    1.1M |  386 |      7446 | 986.79K | 213 |       634 | 116.21K |  173 | "31,41,51,61,71,81" | 0:02'55'' | 0:00'14'' |
| Q30L60X80P000  | 400M   |   80.0 |  2297 |   1.32M |  994 |      1513 |  35.36K |  22 |      2349 |   1.29M |  972 | "31,41,51,61,71,81" | 0:05'30'' | 0:00'16'' |
| Q30L60X80P001  | 400M   |   80.0 |  2263 |   1.32M |  958 |      1424 |  37.82K |  25 |      2370 |   1.28M |  933 | "31,41,51,61,71,81" | 0:05'27'' | 0:00'17'' |
| Q30L60X80P002  | 400M   |   80.0 |  2212 |   1.34M |  983 |      1456 |  25.72K |  18 |      2327 |   1.32M |  965 | "31,41,51,61,71,81" | 0:05'45'' | 0:00'17'' |
| Q30L60X160P000 | 800M   |  160.0 |   597 |   4.83M | 7193 |      1224 |  40.22K |  32 |       596 |   4.79M | 7161 | "31,41,51,61,71,81" | 0:24'40'' | 0:00'36'' |
| Q30L60X160P001 | 800M   |  160.0 |   599 |   5.02M | 7470 |      1154 |  29.85K |  25 |       598 |   4.99M | 7445 | "31,41,51,61,71,81" | 0:23'27'' | 0:00'36'' |
| Q30L60X160P002 | 800M   |  160.0 |   599 |   4.85M | 7212 |      1300 |   38.4K |  29 |       597 |   4.81M | 7183 | "31,41,51,61,71,81" | 0:19'51'' | 0:00'32'' |


| Name                 |   N50 |       Sum |      # |
|:---------------------|------:|----------:|-------:|
| anchor.merge         | 22513 |   1542305 |    293 |
| others.merge         |  4438 |   1778238 |    722 |
| contigTrim           | 33478 |   1438879 |    194 |
| spades.contig        |  2016 | 465173951 | 422022 |
| spades.non-contained |  2673 | 348073390 | 147336 |

# m19

## m19: download

```bash
BASE_NAME=m19
REAL_G=5000000

mkdir -p ~/data/dna-seq/xjy/${BASE_NAME}/2_illumina
cd ~/data/dna-seq/xjy/${BASE_NAME}/2_illumina

ln -s ~/data/dna-seq/xjy/clean_data/m19_H3J5KDMXX_L1_1.clean.fq.gz R1.fq.gz
ln -s ~/data/dna-seq/xjy/clean_data/m19_H3J5KDMXX_L1_2.clean.fq.gz R2.fq.gz
```


## m19: combinations of different quality values and read lengths

* qual: 25 and 30
* len: 60

| Name     | N50 |        Sum |        # |
|:---------|----:|-----------:|---------:|
| Illumina | 150 | 6626560500 | 44177070 |
| uniq     | 150 | 5265157500 | 35101050 |
| Q25L60   | 150 | 5171514024 | 34908498 |
| Q30L60   | 150 | 5036343271 | 34707064 |

| Name   | SumIn |  CovIn | SumOut | CovOut | Discard% | AvgRead |  Kmer | RealG |    EstG | Est/Real |   RunTime |
|:-------|------:|-------:|-------:|-------:|---------:|--------:|------:|------:|--------:|---------:|----------:|
| Q25L60 | 5.17G | 1034.3 |  1.56G |  313.0 |  69.740% |     148 | "105" |    5M | 143.26M |    28.65 | 0:34'33'' |
| Q30L60 | 5.04G | 1007.3 |  1.56G |  312.3 |  68.996% |     145 | "105" |    5M | 140.46M |    28.09 | 0:31'22'' |

| Name           | SumCor | CovCor | N50SR |     Sum |    # | N50Anchor |     Sum |   # | N50Others |     Sum |   # |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|:-------|-------:|------:|--------:|-----:|----------:|--------:|----:|----------:|--------:|----:|--------------------:|----------:|----------:|
| Q25L60X10P000  | 50M    |   10.0 |  2812 | 137.87K |   74 |      3150 | 112.24K |  39 |       766 |  25.62K |  35 | "31,41,51,61,71,81" | 0:01'05'' | 0:00'14'' |
| Q25L60X10P001  | 50M    |   10.0 |  2689 | 149.76K |   86 |      3401 | 117.47K |  39 |       717 |  32.29K |  47 | "31,41,51,61,71,81" | 0:01'04'' | 0:00'16'' |
| Q25L60X10P002  | 50M    |   10.0 |  2965 | 143.19K |   76 |      3480 | 118.14K |  39 |       650 |  25.06K |  37 | "31,41,51,61,71,81" | 0:01'04'' | 0:00'17'' |
| Q25L60X20P000  | 100M   |   20.0 |  1348 |  170.3K |  151 |      2538 |  96.59K |  42 |       684 |  73.71K | 109 | "31,41,51,61,71,81" | 0:02'14'' | 0:00'19'' |
| Q25L60X20P001  | 100M   |   20.0 |  1419 | 178.58K |  152 |      2689 | 105.67K |  45 |       660 |  72.91K | 107 | "31,41,51,61,71,81" | 0:02'28'' | 0:00'15'' |
| Q25L60X20P002  | 100M   |   20.0 |  1565 |    176K |  157 |      2623 |  99.12K |  43 |       665 |  76.88K | 114 | "31,41,51,61,71,81" | 0:02'35'' | 0:00'18'' |
| Q25L60X40P000  | 200M   |   40.0 |   870 | 234.99K |  266 |      2065 |   8.44K |   5 |       848 | 226.55K | 261 | "31,41,51,61,71,81" | 0:05'31'' | 0:00'20'' |
| Q25L60X40P001  | 200M   |   40.0 |   870 | 241.01K |  278 |      1611 |    7.8K |   5 |       843 |  233.2K | 273 | "31,41,51,61,71,81" | 0:05'40'' | 0:00'21'' |
| Q25L60X40P002  | 200M   |   40.0 |   844 | 216.58K |  242 |      2421 |    7.9K |   4 |       805 | 208.68K | 238 | "31,41,51,61,71,81" | 0:05'27'' | 0:00'21'' |
| Q25L60X80P000  | 400M   |   80.0 |   724 | 435.65K |  569 |      1442 |  48.75K |  35 |       686 | 386.89K | 534 | "31,41,51,61,71,81" | 0:10'41'' | 0:00'32'' |
| Q25L60X80P001  | 400M   |   80.0 |   685 | 430.78K |  580 |      1520 |     48K |  30 |       645 | 382.78K | 550 | "31,41,51,61,71,81" | 0:10'27'' | 0:00'26'' |
| Q25L60X80P002  | 400M   |   80.0 |   720 | 416.35K |  550 |      1340 |  53.06K |  39 |       668 |  363.3K | 511 | "31,41,51,61,71,81" | 0:11'09'' | 0:00'26'' |
| Q25L60X160P000 | 800M   |  160.0 |   776 | 911.98K | 1100 |      1847 |  270.5K | 154 |       647 | 641.48K | 946 | "31,41,51,61,71,81" | 0:22'14'' | 0:00'53'' |
| Q30L60X10P000  | 50M    |   10.0 |  2932 | 138.39K |   68 |      3238 | 118.37K |  39 |       662 |  20.02K |  29 | "31,41,51,61,71,81" | 0:01'48'' | 0:00'15'' |
| Q30L60X10P001  | 50M    |   10.0 |  2986 | 152.36K |   86 |      3821 | 119.67K |  38 |       661 |  32.68K |  48 | "31,41,51,61,71,81" | 0:01'54'' | 0:00'17'' |
| Q30L60X10P002  | 50M    |   10.0 |  3191 | 145.25K |   75 |      3512 | 123.54K |  42 |       650 |  21.71K |  33 | "31,41,51,61,71,81" | 0:01'59'' | 0:00'16'' |
| Q30L60X20P000  | 100M   |   20.0 |  1303 | 175.37K |  155 |      2547 | 100.39K |  44 |       681 |  74.98K | 111 | "31,41,51,61,71,81" | 0:02'33'' | 0:00'19'' |
| Q30L60X20P001  | 100M   |   20.0 |  1679 | 182.59K |  149 |      3122 | 107.37K |  41 |       702 |  75.22K | 108 | "31,41,51,61,71,81" | 0:02'20'' | 0:00'16'' |
| Q30L60X20P002  | 100M   |   20.0 |  1636 | 171.26K |  142 |      2724 | 103.19K |  43 |       699 |  68.07K |  99 | "31,41,51,61,71,81" | 0:02'35'' | 0:00'18'' |
| Q30L60X40P000  | 200M   |   40.0 |   897 | 242.57K |  270 |      2013 |   9.51K |   6 |       867 | 233.06K | 264 | "31,41,51,61,71,81" | 0:04'31'' | 0:00'20'' |
| Q30L60X40P001  | 200M   |   40.0 |   823 | 246.01K |  285 |      1567 |    6.7K |   4 |       814 | 239.31K | 281 | "31,41,51,61,71,81" | 0:04'35'' | 0:00'22'' |
| Q30L60X40P002  | 200M   |   40.0 |   888 | 231.96K |  252 |      2421 |   8.86K |   4 |       864 |  223.1K | 248 | "31,41,51,61,71,81" | 0:04'22'' | 0:00'19'' |
| Q30L60X80P000  | 400M   |   80.0 |   720 | 437.39K |  573 |      1442 |  47.81K |  35 |       681 | 389.59K | 538 | "31,41,51,61,71,81" | 0:09'02'' | 0:00'32'' |
| Q30L60X80P001  | 400M   |   80.0 |   701 | 451.01K |  599 |      1520 |  56.45K |  36 |       650 | 394.56K | 563 | "31,41,51,61,71,81" | 0:08'35'' | 0:00'25'' |
| Q30L60X80P002  | 400M   |   80.0 |   720 | 415.32K |  550 |      1340 |  48.59K |  36 |       676 | 366.73K | 514 | "31,41,51,61,71,81" | 0:08'23'' | 0:00'27'' |
| Q30L60X160P000 | 800M   |  160.0 |   782 | 936.76K | 1133 |      1791 | 275.67K | 157 |       652 |  661.1K | 976 | "31,41,51,61,71,81" | 0:15'44'' | 0:00'50'' |

| Name                 |   N50 |       Sum |       # |
|:---------------------|------:|----------:|--------:|
| anchor.merge         |  2284 |    535008 |     233 |
| others.merge         |  1440 |    866510 |     591 |
| contigTrim           | 10766 |    560441 |     119 |
| spades.contig        |   292 | 357083219 | 1124150 |
| spades.non-contained |  1761 |  34758783 |   19397 |

# m20

## m20: download

```bash
mkdir -p ~/data/dna-seq/xjy/m20/2_illumina
cd ~/data/dna-seq/xjy/m20/2_illumina

ln -s ~/data/dna-seq/xjy/clean_data/m20_H3J5KDMXX_L1_1.clean.fq.gz R1.fq.gz
ln -s ~/data/dna-seq/xjy/clean_data/m20_H3J5KDMXX_L1_2.clean.fq.gz R2.fq.gz
```

## m20: template

```bash
WORKING_DIR=${HOME}/data/dna-seq/xjy
BASE_NAME=m20

cd ${WORKING_DIR}/${BASE_NAME}

anchr template \
    . \
    --basename ${BASE_NAME} \
    --queue mpi \
    --genome 5000000 \
    --is_euk \
    --trim2 "--dedupe --tile" \
    --cov2 "10 20 40 80 160" \
    --qual2 "25 30" \
    --len2 "60" \
    --filter "adapter,phix,artifact" \
    --tadpole \
    --mergereads \
    --ecphase "1,2,3" \
    --insertsize \
    --parallel 24

# run
bash 0_bsub.sh

```

```bash
WORKING_DIR=${HOME}/data/dna-seq/xjy
BASE_NAME=m20

cd ${WORKING_DIR}/${BASE_NAME}

```

| Name     | N50 |        Sum |        # |
|:---------|----:|-----------:|---------:|
| Illumina | 150 | 7180853700 | 47872358 |
| uniq     | 150 | 5425764300 | 36171762 |
| Q25L60   | 150 | 5381411918 | 36089936 |
| Q30L60   | 150 | 5267126278 | 35937929 |

| Name   | SumIn |  CovIn | SumOut | CovOut | Discard% | AvgRead |  Kmer | RealG |   EstG | Est/Real |   RunTime |
|:-------|------:|-------:|-------:|-------:|---------:|--------:|------:|------:|-------:|---------:|----------:|
| Q25L60 | 5.38G | 1076.3 |  4.36G |  872.9 |  18.893% |     149 | "105" |    5M | 82.28M |    16.46 | 0:57'12'' |
| Q30L60 | 5.27G | 1053.5 |  4.31G |  862.0 |  18.178% |     147 | "105" |    5M | 79.09M |    15.82 | 0:48'04'' |

| Name           | SumCor | CovCor | N50SR |     Sum |    # | N50Anchor |     Sum |   # | N50Others |     Sum |   # |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|-------:|------:|--------:|-----:|----------:|--------:|----:|----------:|--------:|----:|--------------------:|----------:|:----------|
| Q25L60X10P000  |    50M |   10.0 |  3899 | 547.79K |  232 |      4383 | 462.41K | 124 |       766 |  85.39K | 108 | "31,41,51,61,71,81" | 0:01'45'' | 0:00'09'' |
| Q25L60X10P001  |    50M |   10.0 |  5074 | 543.65K |  218 |      6265 | 458.38K | 105 |       738 |  85.27K | 113 | "31,41,51,61,71,81" | 0:01'50'' | 0:00'09'' |
| Q25L60X10P002  |    50M |   10.0 |  4532 | 545.71K |  240 |      5579 | 451.68K | 123 |       809 |  94.03K | 117 | "31,41,51,61,71,81" | 0:01'56'' | 0:00'09'' |
| Q25L60X20P000  |   100M |   20.0 |  1947 | 473.97K |  319 |      2291 | 366.89K | 172 |       740 | 107.07K | 147 | "31,41,51,61,71,81" | 0:01'54'' | 0:00'11'' |
| Q25L60X20P001  |   100M |   20.0 |  1800 | 473.32K |  322 |      2214 | 363.56K | 173 |       744 | 109.76K | 149 | "31,41,51,61,71,81" | 0:02'07'' | 0:00'09'' |
| Q25L60X20P002  |   100M |   20.0 |  1913 | 481.09K |  318 |      2558 | 368.53K | 163 |       730 | 112.56K | 155 | "31,41,51,61,71,81" | 0:01'45'' | 0:00'09'' |
| Q25L60X40P000  |   200M |   40.0 |   920 | 353.04K |  392 |      1315 | 143.67K | 102 |       753 | 209.38K | 290 | "31,41,51,61,71,81" | 0:04'04'' | 0:00'10'' |
| Q25L60X40P001  |   200M |   40.0 |   995 | 362.64K |  381 |      1476 | 170.47K | 106 |       707 | 192.17K | 275 | "31,41,51,61,71,81" | 0:03'11'' | 0:00'09'' |
| Q25L60X40P002  |   200M |   40.0 |   924 | 367.24K |  411 |      1360 | 159.07K | 114 |       709 | 208.17K | 297 | "31,41,51,61,71,81" | 0:03'22'' | 0:00'10'' |
| Q25L60X80P000  |   400M |   80.0 |   661 | 218.84K |  303 |      1505 |  35.41K |  25 |       627 | 183.43K | 278 | "31,41,51,61,71,81" | 0:05'04'' | 0:00'10'' |
| Q25L60X80P001  |   400M |   80.0 |   641 | 201.34K |  288 |      1466 |  20.52K |  13 |       624 | 180.82K | 275 | "31,41,51,61,71,81" | 0:05'48'' | 0:00'10'' |
| Q25L60X80P002  |   400M |   80.0 |   668 | 206.39K |  282 |      1095 |  23.83K |  18 |       634 | 182.56K | 264 | "31,41,51,61,71,81" | 0:03'40'' | 0:00'10'' |
| Q25L60X160P000 |   800M |  160.0 |   632 |    662K |  974 |      1419 |  54.19K |  34 |       616 |  607.8K | 940 | "31,41,51,61,71,81" | 0:13'31'' | 0:00'16'' |
| Q25L60X160P001 |   800M |  160.0 |   634 | 630.86K |  917 |      1691 |  52.47K |  30 |       619 | 578.38K | 887 | "31,41,51,61,71,81" | 0:10'28'' | 0:00'15'' |
| Q25L60X160P002 |   800M |  160.0 |   633 | 616.56K |  903 |      1501 |  51.67K |  32 |       616 | 564.89K | 871 | "31,41,51,61,71,81" | 0:11'36'' | 0:00'14'' |
| Q30L60X10P000  |    50M |   10.0 |  5399 | 556.54K |  216 |      6370 | 475.55K | 110 |       753 |  80.98K | 106 | "31,41,51,61,71,81" | 0:00'58'' | 0:00'12'' |
| Q30L60X10P001  |    50M |   10.0 |  5232 | 560.89K |  222 |      6091 | 487.09K | 116 |       710 |   73.8K | 106 | "31,41,51,61,71,81" | 0:00'55'' | 0:00'10'' |
| Q30L60X10P002  |    50M |   10.0 |  5173 | 561.07K |  227 |      5919 | 464.56K | 108 |       820 |  96.51K | 119 | "31,41,51,61,71,81" | 0:00'49'' | 0:00'11'' |
| Q30L60X20P000  |   100M |   20.0 |  2392 | 493.36K |  297 |      2834 | 396.94K | 162 |       706 |  96.42K | 135 | "31,41,51,61,71,81" | 0:01'12'' | 0:00'09'' |
| Q30L60X20P001  |   100M |   20.0 |  2055 | 496.81K |  319 |      2397 | 391.64K | 174 |       724 | 105.16K | 145 | "31,41,51,61,71,81" | 0:01'12'' | 0:00'09'' |
| Q30L60X20P002  |   100M |   20.0 |  2315 | 508.33K |  302 |      2953 | 405.68K | 159 |       701 | 102.66K | 143 | "31,41,51,61,71,81" | 0:01'13'' | 0:00'09'' |
| Q30L60X40P000  |   200M |   40.0 |  1055 | 396.11K |  397 |      1534 | 206.18K | 135 |       752 | 189.93K | 262 | "31,41,51,61,71,81" | 0:02'02'' | 0:00'09'' |
| Q30L60X40P001  |   200M |   40.0 |  1183 | 399.07K |  383 |      1553 | 226.88K | 140 |       714 | 172.19K | 243 | "31,41,51,61,71,81" | 0:02'02'' | 0:00'09'' |
| Q30L60X40P002  |   200M |   40.0 |  1060 | 406.29K |  417 |      1525 | 206.06K | 136 |       712 | 200.23K | 281 | "31,41,51,61,71,81" | 0:02'02'' | 0:00'09'' |
| Q30L60X80P000  |   400M |   80.0 |   704 | 280.47K |  376 |      1272 |  34.16K |  26 |       661 | 246.31K | 350 | "31,41,51,61,71,81" | 0:02'49'' | 0:00'10'' |
| Q30L60X80P001  |   400M |   80.0 |   684 | 270.04K |  375 |      1233 |  26.03K |  20 |       655 | 244.01K | 355 | "31,41,51,61,71,81" | 0:02'49'' | 0:00'12'' |
| Q30L60X80P002  |   400M |   80.0 |   691 | 268.73K |  365 |      1275 |  32.53K |  22 |       653 | 236.21K | 343 | "31,41,51,61,71,81" | 0:02'48'' | 0:00'11'' |
| Q30L60X160P000 |   800M |  160.0 |   630 | 690.87K | 1020 |      1404 |  63.46K |  40 |       616 | 627.41K | 980 | "31,41,51,61,71,81" | 0:05'23'' | 0:00'13'' |
| Q30L60X160P001 |   800M |  160.0 |   630 | 678.91K |  983 |      1336 |  51.15K |  32 |       616 | 627.76K | 951 | "31,41,51,61,71,81" | 0:05'25'' | 0:00'15'' |
| Q30L60X160P002 |   800M |  160.0 |   634 | 628.34K |  918 |      1660 |  36.24K |  21 |       619 |  592.1K | 897 | "31,41,51,61,71,81" | 0:05'22'' | 0:00'15'' |

| Name                 |   N50 |       Sum |      # |
|:---------------------|------:|----------:|-------:|
| anchor.merge         | 11071 |   1353094 |    418 |
| others.merge         |  1115 |    689202 |    484 |
| contigTrim           | 21785 |   1050355 |    210 |
| spades.contig        |   384 | 182028086 | 465531 |
| spades.non-contained |  2838 |  41985607 |  16992 |

# m22

## m22: download

```bash
mkdir -p ~/data/dna-seq/xjy/m22/2_illumina
cd ~/data/dna-seq/xjy/m22/2_illumina

ln -s ~/data/dna-seq/xjy/clean_data/m22_H3JJGDMXX_L1_1.clean.fq.gz R1.fq.gz
ln -s ~/data/dna-seq/xjy/clean_data/m22_H3JJGDMXX_L1_2.clean.fq.gz R2.fq.gz
```

## m22: template

```bash
WORKING_DIR=${HOME}/data/dna-seq/xjy
BASE_NAME=m22
QUEUE_NAME=mpi

cd ${WORKING_DIR}/${BASE_NAME}

anchr template \
    . \
    --basename ${BASE_NAME} \
    --genome 5000000 \
    --is_euk \
    --trim2 "--dedupe --tile" \
    --cov2 "10 20 40 80 160" \
    --qual2 "25 30" \
    --len2 "60" \
    --filter "adapter,phix,artifact" \
    --tadpole \
    --mergereads \
    --ecphase "1,2,3" \
    --insertsize \
    --parallel 24

```

## m22: run

```bash
WORKING_DIR=${HOME}/data/dna-seq/xjy
BASE_NAME=m20

cd ${WORKING_DIR}/${BASE_NAME}

bash 0_master.sh

# bash 0_cleanup.sh

```

| Name     | N50 |         Sum |        # |
|:---------|----:|------------:|---------:|
| Illumina | 150 | 11593186500 | 77287910 |
| uniq     | 150 | 10283319600 | 68555464 |
| Q25L60   | 150 | 10197625302 | 68378762 |
| Q30L60   | 150 |  9977172214 | 68015510 |

## m22: spades

> You need approx. 269.686GB of free RAM to assemble your dataset

```bash
cd ${HOME}/data/dna-seq/xjy/${BASE_NAME}

mkdir -p 8_spades
gzip -d -c 2_illumina/Q25L60/R1.fq.gz \
    | head -n 30000000 \
    | pigz -p 4 \
    > 8_spades/R1.fq.gz
gzip -d -c 2_illumina/Q25L60/R2.fq.gz \
    | head -n 30000000 \
    | pigz -p 4 \
    > 8_spades/R2.fq.gz

spades.py \
    -t 16 \
    -k 21,33,55,77 \
    -1 8_spades/R1.fq.gz \
    -2 8_spades/R2.fq.gz \
    -o 8_spades

anchr contained \
    8_spades/contigs.fasta \
    --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
    -o stdout \
    | faops filter -a 1000 -l 0 stdin 8_spades/contigs.non-contained.fasta

```

| Name   | SumIn |  CovIn | SumOut | CovOut | Discard% | AvgRead | Kmer | RealG |    EstG | Est/Real |   RunTime |
|:-------|------:|-------:|-------:|-------:|---------:|--------:|-----:|------:|--------:|---------:|----------:|
| Q25L60 | 10.2G | 2039.5 |  3.55G |  709.1 |  65.230% |     149 | "75" |    5M |  444.7M |    88.94 | 0:40'11'' |
| Q30L60 | 9.98G | 1995.5 |  3.49G |  698.9 |  64.978% |     146 | "75" |    5M | 430.68M |    86.14 | 0:46'15'' |

| Name           | SumCor | CovCor | N50SR |     Sum |     # | N50Anchor |     Sum |    # | N50Others |     Sum |    # |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|:-------|-------:|------:|--------:|------:|----------:|--------:|-----:|----------:|--------:|-----:|--------------------:|----------:|----------:|
| Q25L60X10P000  | 50M    |   10.0 |   711 | 669.03K |   853 |      1348 |   58.8K |   42 |       686 | 610.23K |  811 | "31,41,51,61,71,81" | 0:00'58'' | 0:00'13'' |
| Q25L60X10P001  | 50M    |   10.0 |   736 | 659.48K |   844 |      1381 |  58.21K |   42 |       706 | 601.27K |  802 | "31,41,51,61,71,81" | 0:00'57'' | 0:00'13'' |
| Q25L60X10P002  | 50M    |   10.0 |   717 | 699.35K |   897 |      1265 |  60.88K |   46 |       688 | 638.47K |  851 | "31,41,51,61,71,81" | 0:00'58'' | 0:00'10'' |
| Q25L60X20P000  | 100M   |   20.0 |  1027 |   2.69M |  2742 |      1567 |   1.19M |  737 |       755 |    1.5M | 2005 | "31,41,51,61,71,81" | 0:01'41'' | 0:00'18'' |
| Q25L60X20P001  | 100M   |   20.0 |  1031 |   2.76M |  2798 |      1602 |   1.22M |  751 |       768 |   1.54M | 2047 | "31,41,51,61,71,81" | 0:01'40'' | 0:00'19'' |
| Q25L60X20P002  | 100M   |   20.0 |  1037 |   2.71M |  2757 |      1576 |    1.2M |  739 |       765 |   1.52M | 2018 | "31,41,51,61,71,81" | 0:01'39'' | 0:00'18'' |
| Q25L60X40P000  | 200M   |   40.0 |  3765 |   4.46M |  1785 |      4240 |   3.99M | 1172 |       791 | 472.25K |  613 | "31,41,51,61,71,81" | 0:02'57'' | 0:00'25'' |
| Q25L60X40P001  | 200M   |   40.0 |  3799 |   4.46M |  1756 |      4210 |   4.01M | 1170 |       791 | 454.01K |  586 | "31,41,51,61,71,81" | 0:02'54'' | 0:00'24'' |
| Q25L60X40P002  | 200M   |   40.0 |  3946 |   4.45M |  1796 |      4309 |   3.95M | 1159 |       794 | 498.48K |  637 | "31,41,51,61,71,81" | 0:02'56'' | 0:00'23'' |
| Q25L60X80P000  | 400M   |   80.0 | 11197 |   5.38M |  2114 |      1765 | 107.14K |   59 |     11363 |   5.28M | 2055 | "31,41,51,61,71,81" | 0:05'16'' | 0:00'28'' |
| Q25L60X80P001  | 400M   |   80.0 | 11043 |    5.4M |  2164 |      1745 |  95.04K |   54 |     11343 |    5.3M | 2110 | "31,41,51,61,71,81" | 0:05'17'' | 0:00'28'' |
| Q25L60X80P002  | 400M   |   80.0 | 10149 |   5.43M |  2213 |      1461 |  108.8K |   65 |     11294 |   5.32M | 2148 | "31,41,51,61,71,81" | 0:05'15'' | 0:00'29'' |
| Q25L60X160P000 | 800M   |  160.0 |  1012 |  11.07M | 10342 |      1429 |   1.08M |  721 |       895 |   9.99M | 9621 | "31,41,51,61,71,81" | 0:10'15'' | 0:00'54'' |
| Q25L60X160P001 | 800M   |  160.0 |  1042 |  11.09M | 10311 |      1417 |   1.19M |  792 |       898 |    9.9M | 9519 | "31,41,51,61,71,81" | 0:15'39'' | 0:00'53'' |
| Q25L60X160P002 | 800M   |  160.0 |  1044 |  10.93M | 10163 |      1416 |   1.15M |  775 |       904 |   9.78M | 9388 | "31,41,51,61,71,81" | 0:11'05'' | 0:00'57'' |
| Q30L60X10P000  | 50M    |   10.0 |   711 |  674.1K |   857 |      1347 |  60.06K |   44 |       684 | 614.04K |  813 | "31,41,51,61,71,81" | 0:00'59'' | 0:00'10'' |
| Q30L60X10P001  | 50M    |   10.0 |   736 | 681.37K |   871 |      1360 |  66.26K |   48 |       702 | 615.11K |  823 | "31,41,51,61,71,81" | 0:01'04'' | 0:00'09'' |
| Q30L60X10P002  | 50M    |   10.0 |   718 | 710.68K |   910 |      1307 |  63.38K |   46 |       693 |  647.3K |  864 | "31,41,51,61,71,81" | 0:00'58'' | 0:00'09'' |
| Q30L60X20P000  | 100M   |   20.0 |  1038 |   2.74M |  2779 |      1595 |   1.24M |  763 |       754 |    1.5M | 2016 | "31,41,51,61,71,81" | 0:03'07'' | 0:00'17'' |
| Q30L60X20P001  | 100M   |   20.0 |  1051 |   2.82M |  2806 |      1643 |   1.28M |  769 |       767 |   1.54M | 2037 | "31,41,51,61,71,81" | 0:04'41'' | 0:00'17'' |
| Q30L60X20P002  | 100M   |   20.0 |  1065 |   2.77M |  2741 |      1594 |   1.28M |  774 |       771 |   1.49M | 1967 | "31,41,51,61,71,81" | 0:03'18'' | 0:00'17'' |
| Q30L60X40P000  | 200M   |   40.0 |  3911 |   4.48M |  1749 |      4367 |   4.02M | 1153 |       795 | 462.93K |  596 | "31,41,51,61,71,81" | 0:03'33'' | 0:00'23'' |
| Q30L60X40P001  | 200M   |   40.0 |  3999 |   4.48M |  1715 |      4462 |   4.03M | 1140 |       800 | 451.01K |  575 | "31,41,51,61,71,81" | 0:03'39'' | 0:00'24'' |
| Q30L60X40P002  | 200M   |   40.0 |  4012 |   4.46M |  1726 |      4429 |      4M | 1133 |       797 | 465.33K |  593 | "31,41,51,61,71,81" | 0:03'41'' | 0:00'23'' |
| Q30L60X80P000  | 400M   |   80.0 | 12539 |   5.41M |  2093 |      1769 | 108.73K |   60 |     13097 |    5.3M | 2033 | "31,41,51,61,71,81" | 0:06'41'' | 0:00'27'' |
| Q30L60X80P001  | 400M   |   80.0 | 13568 |   5.44M |  2137 |      1475 |  99.75K |   59 |     14511 |   5.34M | 2078 | "31,41,51,61,71,81" | 0:06'42'' | 0:00'27'' |
| Q30L60X80P002  | 400M   |   80.0 | 12626 |   5.44M |  2136 |      1623 | 118.76K |   67 |     13261 |   5.32M | 2069 | "31,41,51,61,71,81" | 0:06'34'' | 0:00'28'' |
| Q30L60X160P000 | 800M   |  160.0 |  1010 |  11.24M | 10367 |      1448 |   1.11M |  738 |       898 |  10.13M | 9629 | "31,41,51,61,71,81" | 0:16'09'' | 0:00'52'' |
| Q30L60X160P001 | 800M   |  160.0 |  1053 |  11.23M | 10212 |      1415 |   1.23M |  820 |       908 |     10M | 9392 | "31,41,51,61,71,81" | 0:15'15'' | 0:00'52'' |
| Q30L60X160P002 | 800M   |  160.0 |  1051 |  11.11M | 10161 |      1406 |    1.2M |  814 |       902 |   9.91M | 9347 | "31,41,51,61,71,81" | 0:14'31'' | 0:00'51'' |

| Name                 |   N50 |       Sum |       # |
|:---------------------|------:|----------:|--------:|
| anchor.merge         |  4938 |   9236311 |    3164 |
| others.merge         | 54054 |   6622204 |    2005 |
| contigTrim           |  8529 |   8482457 |    2637 |
| spades.contig        |   285 | 443831113 | 1289399 |
| spades.non-contained |  1583 |  59215300 |   35218 |


# mt203

五娅果

## mt203: download

```bash
mkdir -p ~/data/dna-seq/xjy/mt203/2_illumina
cd ~/data/dna-seq/xjy/mt203/2_illumina

ln -s ../../raw_data/MT203_H3LCYDMXX_L1_1.fq.gz R1.fq.gz
ln -s ../../raw_data/MT203_H3LCYDMXX_L1_2.fq.gz R2.fq.gz

```

## mt203: template

```bash
WORKING_DIR=${HOME}/data/dna-seq/xjy
BASE_NAME=mt203
QUEUE_NAME=mpi

cd ${WORKING_DIR}/${BASE_NAME}

anchr template \
    . \
    --basename ${BASE_NAME} \
    --genome 5000000 \
    --is_euk \
    --trim2 "--dedupe --tile" \
    --cov2 "10 20 40 80 160" \
    --qual2 "25 30" \
    --len2 "60" \
    --filter "adapter,phix,artifact" \
    --tadpole \
    --mergereads \
    --ecphase "1,2,3" \
    --insertsize \
    --parallel 24

```

## mt203: run

```bash
WORKING_DIR=${HOME}/data/dna-seq/xjy
BASE_NAME=mt203

cd ${WORKING_DIR}/${BASE_NAME}

bash 0_master.sh

# bash 0_cleanup.sh

```

# mt301

金鱼藻

## mt301: download

```bash
mkdir -p ~/data/dna-seq/xjy/mt301/2_illumina
cd ~/data/dna-seq/xjy/mt301/2_illumina

ln -s ../../raw_data/mt301_H73Y3DMXX_L1_1.fq.gz R1.fq.gz
ln -s ../../raw_data/mt301_H73Y3DMXX_L1_2.fq.gz R2.fq.gz

```

## mt301: template

```bash
WORKING_DIR=${HOME}/data/dna-seq/xjy
BASE_NAME=mt301

cd ${WORKING_DIR}/${BASE_NAME}

anchr template \
    . \
    --basename ${BASE_NAME} \
    --queue mpi \
    --genome 5000000 \
    --is_euk \
    --trim2 "--dedupe --tile" \
    --cov2 "10 20 40 80 160" \
    --qual2 "25 30" \
    --len2 "60" \
    --filter "adapter,phix,artifact" \
    --tadpole \
    --mergereads \
    --ecphase "1,2,3" \
    --insertsize \
    --parallel 24

# run
bash 0_bsub.sh

```

```bash
WORKING_DIR=${HOME}/data/dna-seq/xjy
BASE_NAME=mt301

cd ${WORKING_DIR}/${BASE_NAME}

```


Table: statInsertSize

| Group           |  Mean | Median | STDev | PercentOfPairs/PairOrientation |
|:----------------|------:|-------:|------:|-------------------------------:|
| tadpole.bbtools | 224.5 |    226 |  47.0 |                         12.48% |
| tadpole.picard  | 221.8 |    223 |  48.1 |                             FR |


Table: statReads

| Name     | N50 |   Sum |        # |
|:---------|----:|------:|---------:|
| Illumina | 150 | 2.14G | 14275626 |
| trim     | 150 | 1.51G | 10197408 |
| Q25L60   | 150 | 1.49G | 10108895 |
| Q30L60   | 150 | 1.43G |  9863712 |


Table: statTrimReads

| Name           | N50 |     Sum |        # |
|:---------------|----:|--------:|---------:|
| clumpify       | 150 |   1.64G | 10914474 |
| filteredbytile | 150 |   1.54G | 10275454 |
| trim           | 150 |   1.51G | 10197704 |
| filter         | 150 |   1.51G | 10197408 |
| R1             | 150 | 756.76M |  5098704 |
| R2             | 150 | 755.27M |  5098704 |
| Rs             |   0 |       0 |        0 |


```text
#trim
#Matched        244166  2.37621%
#Name   Reads   ReadsPct
Reverse_adapter 89980   0.87568%
pcr_dimer       49729   0.48396%
TruSeq_Adapter_Index_1_6        42581   0.41440%
PCR_Primers     32982   0.32098%
Nextera_LMP_Read2_External_Adapter      15575   0.15157%
TruSeq_Universal_Adapter        6965    0.06778%
```

```text
#filter
#Matched        153     0.00150%
#Name   Reads   ReadsPct
```


Table: statMergeReads

| Name          | N50 |     Sum |        # |
|:--------------|----:|--------:|---------:|
| clumped       | 150 |   1.51G | 10165370 |
| ecco          | 150 |   1.51G | 10165370 |
| eccc          | 150 |   1.51G | 10165370 |
| ecct          | 150 |  171.8M |  1185892 |
| extended      | 186 | 202.99M |  1185892 |
| merged        | 296 | 124.48M |   463252 |
| unmerged.raw  | 167 |  41.93M |   259388 |
| unmerged.trim | 167 |  41.93M |   259366 |
| U1            | 168 |  21.07M |   129683 |
| U2            | 166 |  20.86M |   129683 |
| Us            |   0 |       0 |        0 |
| pe.cor        | 264 | 166.88M |  1185870 |

| Group            |  Mean | Median | STDev | PercentOfPairs |
|:-----------------|------:|-------:|------:|---------------:|
| ihist.merge1.txt | 229.3 |    239 |  43.4 |         49.69% |
| ihist.merge.txt  | 268.7 |    275 |  78.5 |         78.13% |


Table: statQuorum

| Name   | CovIn | CovOut | Discard% | AvgRead | Kmer | RealG |   EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|-----:|------:|-------:|---------:|----------:|
| Q0L0   | 302.4 |   97.1 |   67.89% |     147 | "69" |    5M | 78.94M |    15.79 | 0:08'21'' |
| Q25L60 | 298.3 |   96.5 |   67.66% |     146 | "69" |    5M | 78.07M |    15.61 | 0:09'40'' |
| Q30L60 | 286.0 |   91.1 |   68.15% |     141 | "69" |    5M | 72.13M |    14.43 | 0:07'52'' |


Table: statKunitigsAnchors.md

| Name          | CovCor | Mapped% | N50Anchor |     Sum |   # | N50Others |     Sum |    # | median |  MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|-------:|--------:|----------:|--------:|----:|----------:|--------:|-----:|-------:|-----:|------:|------:|--------------------:|----------:|----------:|
| Q0L0X10P000   |   10.0 |   9.71% |      1649 | 248.79K | 153 |      1332 | 235.55K |  526 |    7.0 |  1.0 |   3.0 |  14.0 | "31,41,51,61,71,81" | 0:01'06'' | 0:00'50'' |
| Q0L0X10P001   |   10.0 |   9.59% |      1764 | 237.36K | 137 |      1459 | 233.13K |  486 |    7.0 |  2.0 |   3.0 |  14.0 | "31,41,51,61,71,81" | 0:01'30'' | 0:00'50'' |
| Q0L0X10P002   |   10.0 |   9.34% |      1693 | 239.45K | 139 |      1214 |  214.3K |  488 |    7.0 |  2.0 |   3.0 |  14.0 | "31,41,51,61,71,81" | 0:01'10'' | 0:00'50'' |
| Q0L0X20P000   |   20.0 |  10.12% |      2321 | 361.97K | 164 |      1635 | 159.44K |  528 |   12.0 |  2.0 |   3.0 |  24.0 | "31,41,51,61,71,81" | 0:02'38'' | 0:00'52'' |
| Q0L0X20P001   |   20.0 |  10.09% |      2421 | 352.67K | 163 |      1589 | 175.68K |  513 |   12.0 |  2.0 |   3.0 |  24.0 | "31,41,51,61,71,81" | 0:02'39'' | 0:00'54'' |
| Q0L0X20P002   |   20.0 |  10.28% |      2466 | 357.61K | 159 |      1994 | 175.09K |  491 |   12.0 |  2.0 |   3.0 |  24.0 | "31,41,51,61,71,81" | 0:02'35'' | 0:00'54'' |
| Q0L0X40P000   |   40.0 |   8.80% |      2245 | 375.17K | 181 |      1311 | 181.41K |  490 |   23.0 |  7.0 |   3.0 |  46.0 | "31,41,51,61,71,81" | 0:07'56'' | 0:00'56'' |
| Q0L0X40P001   |   40.0 |   8.71% |      2348 | 390.58K | 179 |      1274 |  157.4K |  470 |   24.0 |  8.0 |   3.0 |  48.0 | "31,41,51,61,71,81" | 0:08'40'' | 0:01'02'' |
| Q0L0X80P000   |   80.0 |   8.78% |      1273 |  377.2K | 286 |      1320 |   1.09M | 1288 |    5.0 |  1.0 |   3.0 |  10.0 | "31,41,51,61,71,81" | 0:14'33'' | 0:01'11'' |
| Q25L60X10P000 |   10.0 |   9.94% |      1669 | 240.65K | 140 |      1452 | 255.35K |  494 |    7.0 |  2.0 |   3.0 |  14.0 | "31,41,51,61,71,81" | 0:01'31'' | 0:00'59'' |
| Q25L60X10P001 |   10.0 |  10.18% |      1735 | 239.02K | 137 |      1474 | 245.27K |  481 |    7.0 |  2.0 |   3.0 |  14.0 | "31,41,51,61,71,81" | 0:01'07'' | 0:00'57'' |
| Q25L60X10P002 |   10.0 |   9.72% |      1569 | 252.37K | 155 |      1510 | 234.67K |  492 |    7.0 |  1.0 |   3.0 |  14.0 | "31,41,51,61,71,81" | 0:01'50'' | 0:00'50'' |
| Q25L60X20P000 |   20.0 |  10.31% |      2412 | 367.51K | 168 |      1707 | 157.88K |  504 |   12.0 |  2.0 |   3.0 |  24.0 | "31,41,51,61,71,81" | 0:03'36'' | 0:00'55'' |
| Q25L60X20P001 |   20.0 |  10.35% |      2583 | 354.34K | 157 |      1873 | 178.33K |  512 |   12.0 |  2.0 |   3.0 |  24.0 | "31,41,51,61,71,81" | 0:03'38'' | 0:00'53'' |
| Q25L60X20P002 |   20.0 |  10.46% |      2380 | 365.71K | 167 |      1737 | 166.95K |  520 |   12.0 |  2.0 |   3.0 |  24.0 | "31,41,51,61,71,81" | 0:03'44'' | 0:00'58'' |
| Q25L60X40P000 |   40.0 |   8.87% |      2360 | 392.06K | 183 |      1327 | 158.46K |  470 |   24.0 |  7.0 |   3.0 |  48.0 | "31,41,51,61,71,81" | 0:07'55'' | 0:01'04'' |
| Q25L60X40P001 |   40.0 |   8.80% |      2417 | 386.87K | 177 |      1248 | 160.58K |  456 |   24.0 |  7.0 |   3.0 |  48.0 | "31,41,51,61,71,81" | 0:08'06'' | 0:01'04'' |
| Q25L60X80P000 |   80.0 |   9.08% |      1285 | 360.41K | 275 |      1348 |   1.18M | 1316 |    5.0 |  1.0 |   3.0 |  10.0 | "31,41,51,61,71,81" | 0:16'23'' | 0:01'06'' |
| Q30L60X10P000 |   10.0 |  10.98% |      1705 |  263.4K | 155 |      1631 |  270.8K |  534 |    7.0 |  1.0 |   3.0 |  14.0 | "31,41,51,61,71,81" | 0:01'57'' | 0:00'51'' |
| Q30L60X10P001 |   10.0 |  10.61% |      1612 | 231.96K | 141 |      1465 | 258.58K |  492 |    7.0 |  1.0 |   3.0 |  14.0 | "31,41,51,61,71,81" | 0:01'50'' | 0:00'50'' |
| Q30L60X10P002 |   10.0 |  10.89% |      1837 | 272.95K | 155 |      1402 |  248.5K |  525 |    7.0 |  1.0 |   3.0 |  14.0 | "31,41,51,61,71,81" | 0:01'58'' | 0:00'50'' |
| Q30L60X20P000 |   20.0 |  11.27% |      2630 | 379.64K | 164 |      1836 | 157.93K |  506 |   13.0 |  3.0 |   3.0 |  26.0 | "31,41,51,61,71,81" | 0:03'56'' | 0:00'58'' |
| Q30L60X20P001 |   20.0 |  11.34% |      2637 | 390.99K | 171 |      1657 | 146.12K |  532 |   13.0 |  3.0 |   3.0 |  26.0 | "31,41,51,61,71,81" | 0:04'09'' | 0:01'01'' |
| Q30L60X20P002 |   20.0 |  11.13% |      2560 | 382.07K | 169 |      1829 | 152.56K |  492 |   13.0 |  3.0 |   3.0 |  26.0 | "31,41,51,61,71,81" | 0:04'09'' | 0:00'56'' |
| Q30L60X40P000 |   40.0 |  10.11% |      2482 | 415.77K | 187 |      1271 | 189.44K |  498 |   25.0 | 10.0 |   3.0 |  50.0 | "31,41,51,61,71,81" | 0:08'17'' | 0:00'58'' |
| Q30L60X40P001 |   40.0 |  10.01% |      2347 | 408.97K | 189 |      1328 | 178.79K |  489 |   25.0 |  8.5 |   3.0 |  50.0 | "31,41,51,61,71,81" | 0:07'51'' | 0:01'04'' |
| Q30L60X80P000 |   80.0 |  10.59% |      1288 |    421K | 320 |      1385 |   1.26M | 1430 |    5.0 |  1.0 |   3.0 |  10.0 | "31,41,51,61,71,81" | 0:16'08'' | 0:01'11'' |


Table: statTadpoleAnchors.md

| Name          | CovCor | Mapped% | N50Anchor |     Sum |   # | N50Others |     Sum |   # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|-------:|--------:|----------:|--------:|----:|----------:|--------:|----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q0L0X10P000   |   10.0 |   8.83% |      1447 | 207.71K | 138 |      1249 | 165.53K | 421 |    8.0 | 2.0 |   3.0 |  16.0 | "31,41,51,61,71,81" | 0:01'29'' | 0:00'40'' |
| Q0L0X10P001   |   10.0 |   8.93% |      1718 | 194.88K | 119 |      1594 | 154.22K | 397 |    8.0 | 2.0 |   3.0 |  16.0 | "31,41,51,61,71,81" | 0:01'25'' | 0:00'40'' |
| Q0L0X10P002   |   10.0 |   9.13% |      1548 | 186.45K | 115 |      1306 | 176.36K | 400 |    8.0 | 2.0 |   3.0 |  16.0 | "31,41,51,61,71,81" | 0:01'28'' | 0:00'37'' |
| Q0L0X20P000   |   20.0 |  12.69% |      2515 | 385.88K | 174 |      1786 | 204.55K | 674 |   13.0 | 2.0 |   3.0 |  26.0 | "31,41,51,61,71,81" | 0:03'00'' | 0:00'44'' |
| Q0L0X20P001   |   20.0 |  12.46% |      2286 | 335.74K | 165 |      1550 | 264.32K | 661 |   12.0 | 2.0 |   3.0 |  24.0 | "31,41,51,61,71,81" | 0:02'42'' | 0:00'49'' |
| Q0L0X20P002   |   20.0 |  12.25% |      2387 | 381.44K | 179 |      1503 | 195.56K | 666 |   13.0 | 2.0 |   3.0 |  26.0 | "31,41,51,61,71,81" | 0:02'53'' | 0:00'46'' |
| Q0L0X40P000   |   40.0 |  11.18% |      2711 | 433.01K | 178 |      1744 |  130.6K | 458 |   26.0 | 6.0 |   3.0 |  52.0 | "31,41,51,61,71,81" | 0:05'24'' | 0:00'49'' |
| Q0L0X40P001   |   40.0 |  11.34% |      2904 | 417.64K | 163 |      1936 | 136.12K | 429 |   25.0 | 5.0 |   3.3 |  50.0 | "31,41,51,61,71,81" | 0:05'37'' | 0:00'51'' |
| Q0L0X80P000   |   80.0 |  10.78% |      1213 | 203.44K | 160 |      2219 | 659.56K | 659 |    7.0 | 3.0 |   3.0 |  14.0 | "31,41,51,61,71,81" | 0:10'01'' | 0:00'55'' |
| Q25L60X10P000 |   10.0 |   9.18% |      1599 | 209.33K | 129 |      1291 | 158.64K | 393 |    8.0 | 2.0 |   3.0 |  16.0 | "31,41,51,61,71,81" | 0:01'31'' | 0:00'46'' |
| Q25L60X10P001 |   10.0 |   9.61% |      1637 | 212.73K | 132 |      1244 | 155.89K | 422 |    8.0 | 2.0 |   3.0 |  16.0 | "31,41,51,61,71,81" | 0:01'38'' | 0:00'47'' |
| Q25L60X10P002 |   10.0 |   9.00% |      1587 | 212.83K | 133 |      1364 |  146.5K | 404 |    8.0 | 2.0 |   3.0 |  16.0 | "31,41,51,61,71,81" | 0:01'43'' | 0:00'39'' |
| Q25L60X20P000 |   20.0 |  12.72% |      2137 | 361.46K | 176 |      2080 | 226.76K | 627 |   12.0 | 2.0 |   3.0 |  24.0 | "31,41,51,61,71,81" | 0:02'49'' | 0:00'43'' |
| Q25L60X20P001 |   20.0 |  12.62% |      2488 | 386.17K | 183 |      1692 | 176.69K | 663 |   13.0 | 2.0 |   3.0 |  26.0 | "31,41,51,61,71,81" | 0:02'45'' | 0:00'50'' |
| Q25L60X20P002 |   20.0 |  12.53% |      2479 | 376.51K | 174 |      1748 | 197.29K | 664 |   13.0 | 3.0 |   3.0 |  26.0 | "31,41,51,61,71,81" | 0:02'47'' | 0:00'50'' |
| Q25L60X20P003 |   20.0 |  12.32% |      2511 |  388.7K | 176 |      1851 | 188.76K | 644 |   13.0 | 2.0 |   3.0 |  26.0 | "31,41,51,61,71,81" | 0:02'35'' | 0:00'52'' |
| Q25L60X40P000 |   40.0 |  11.41% |      2939 | 442.07K | 175 |      1705 | 112.44K | 425 |   26.0 | 6.0 |   3.0 |  52.0 | "31,41,51,61,71,81" | 0:05'08'' | 0:00'49'' |
| Q25L60X40P001 |   40.0 |  11.02% |      2875 | 431.24K | 172 |      1736 | 116.44K | 406 |   26.0 | 5.0 |   3.7 |  52.0 | "31,41,51,61,71,81" | 0:05'16'' | 0:00'48'' |
| Q25L60X80P000 |   80.0 |  11.20% |      1226 | 200.83K | 156 |      2258 | 679.89K | 650 |    7.0 | 3.0 |   3.0 |  14.0 | "31,41,51,61,71,81" | 0:10'30'' | 0:00'49'' |
| Q30L60X10P000 |   10.0 |  11.05% |      1724 | 218.89K | 134 |      1550 | 216.46K | 449 |    8.0 | 2.0 |   3.0 |  16.0 | "31,41,51,61,71,81" | 0:01'31'' | 0:00'45'' |
| Q30L60X10P001 |   10.0 |  10.28% |      1521 |  218.7K | 141 |      1450 | 180.28K | 419 |    8.0 | 2.0 |   3.0 |  16.0 | "31,41,51,61,71,81" | 0:01'29'' | 0:00'44'' |
| Q30L60X10P002 |   10.0 |  10.43% |      1649 | 223.28K | 139 |      1239 | 198.06K | 453 |    8.0 | 2.0 |   3.0 |  16.0 | "31,41,51,61,71,81" | 0:01'32'' | 0:00'47'' |
| Q30L60X20P000 |   20.0 |  13.68% |      2505 | 377.32K | 175 |      1892 | 207.71K | 672 |   13.0 | 2.0 |   3.0 |  26.0 | "31,41,51,61,71,81" | 0:02'47'' | 0:00'45'' |
| Q30L60X20P001 |   20.0 |  13.16% |      2195 | 395.81K | 196 |      1759 | 179.48K | 675 |   13.0 | 2.0 |   3.0 |  26.0 | "31,41,51,61,71,81" | 0:02'47'' | 0:00'45'' |
| Q30L60X20P002 |   20.0 |  13.44% |      2506 | 401.86K | 182 |      1836 | 175.18K | 630 |   14.0 | 3.0 |   3.0 |  28.0 | "31,41,51,61,71,81" | 0:02'33'' | 0:00'42'' |
| Q30L60X40P000 |   40.0 |  12.33% |      2903 | 443.63K | 177 |      1873 | 113.34K | 434 |   27.0 | 6.0 |   3.0 |  54.0 | "31,41,51,61,71,81" | 0:05'23'' | 0:00'53'' |
| Q30L60X40P001 |   40.0 |  12.42% |      2892 |  441.7K | 176 |      1836 | 126.95K | 436 |   27.0 | 6.0 |   3.0 |  54.0 | "31,41,51,61,71,81" | 0:05'35'' | 0:00'51'' |
| Q30L60X80P000 |   80.0 |  12.47% |      1247 |  252.2K | 197 |      2278 | 701.57K | 749 |    7.0 | 2.0 |   3.0 |  14.0 | "31,41,51,61,71,81" | 0:08'59'' | 0:00'51'' |


Table: statMRKunitigsAnchors.md

| Name      | CovCor | Mapped% | N50Anchor |     Sum |   # | N50Others |     Sum |   # | median |  MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:----------|-------:|--------:|----------:|--------:|----:|----------:|--------:|----:|-------:|-----:|------:|------:|--------------------:|----------:|----------:|
| MRX10P000 |   10.0 |  31.79% |      2611 | 373.84K | 161 |      1463 | 251.58K | 454 |   19.0 |  9.0 |   3.0 |  38.0 | "31,41,51,61,71,81" | 0:01'42'' | 0:00'44'' |
| MRX10P001 |   10.0 |  31.68% |      2864 |  357.7K | 148 |      1478 | 285.19K | 447 |   19.0 | 10.0 |   3.0 |  38.0 | "31,41,51,61,71,81" | 0:01'49'' | 0:00'45'' |
| MRX10P002 |   10.0 |  31.25% |      2609 | 372.91K | 163 |      1546 | 248.44K | 451 |   19.0 |  8.0 |   3.0 |  38.0 | "31,41,51,61,71,81" | 0:01'46'' | 0:00'53'' |
| MRX20P000 |   20.0 |   4.66% |      1126 |  64.96K |  56 |      1087 |  56.44K | 157 |   33.0 | 12.0 |   3.0 |  66.0 | "31,41,51,61,71,81" | 0:03'04'' | 0:00'46'' |


Table: statMRTadpoleAnchors.md

| Name      | CovCor | Mapped% | N50Anchor |     Sum |   # | N50Others |     Sum |   # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:----------|-------:|--------:|----------:|--------:|----:|----------:|--------:|----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| MRX10P000 |   10.0 |  32.56% |      2828 |  401.8K | 163 |      1888 | 179.55K | 387 |   20.0 | 5.0 |   3.0 |  40.0 | "31,41,51,61,71,81" | 0:01'11'' | 0:00'51'' |
| MRX10P001 |   10.0 |  32.73% |      2864 | 404.05K | 167 |      1583 |    181K | 405 |   20.0 | 6.0 |   3.0 |  40.0 | "31,41,51,61,71,81" | 0:01'13'' | 0:00'52'' |
| MRX10P002 |   10.0 |  32.30% |      2607 | 402.68K | 172 |      1758 | 177.11K | 404 |   20.0 | 5.0 |   3.0 |  40.0 | "31,41,51,61,71,81" | 0:01'19'' | 0:00'51'' |
| MRX20P000 |   20.0 |  33.51% |      1265 | 169.25K | 131 |      2368 | 722.81K | 592 |    6.0 | 2.0 |   3.0 |  12.0 | "31,41,51,61,71,81" | 0:01'59'' | 0:00'50'' |


Table: statFinal

| Name                             |  N50 |       Sum |      # |
|:---------------------------------|-----:|----------:|-------:|
| 7_mergeKunitigsAnchors.anchors   | 1578 |   1402596 |    833 |
| 7_mergeKunitigsAnchors.others    | 1420 |   2808598 |   1853 |
| 7_mergeTadpoleAnchors.anchors    | 1938 |    960688 |    504 |
| 7_mergeTadpoleAnchors.others     | 2306 |   1214832 |    637 |
| 7_mergeMRKunitigsAnchors.anchors | 2641 |    459705 |    209 |
| 7_mergeMRKunitigsAnchors.others  | 1315 |    514617 |    354 |
| 7_mergeMRTadpoleAnchors.anchors  | 2057 |    644492 |    333 |
| 7_mergeMRTadpoleAnchors.others   | 2275 |    817383 |    420 |
| 7_mergeAnchors.anchors           | 1585 |   1562311 |    911 |
| 7_mergeAnchors.others            | 1363 |   2950334 |   1957 |
| spades.contig                    |  316 | 293663182 | 827859 |
| spades.scaffold                  |  316 | 293664912 | 827695 |
| spades.non-contained             | 1723 |  35217638 |  19283 |
| megahit.contig                   |  498 |  59566954 | 121596 |
| megahit.non-contained            | 1970 |  12686539 |   6502 |
| platanus.contig                  |  174 |   1283346 |   5752 |
| platanus.scaffold                | 1801 |    725216 |   2395 |
| platanus.non-contained           | 6665 |    397626 |     85 |
| platanus.anchor                  | 3931 |    335187 |    102 |

# mt302

番荔枝


## mt302: download

```bash
mkdir -p ~/data/dna-seq/xjy/mt302/2_illumina
cd ~/data/dna-seq/xjy/mt302/2_illumina

ln -s ../../raw_data/mt302_H73Y3DMXX_L1_1.fq.gz R1.fq.gz
ln -s ../../raw_data/mt302_H73Y3DMXX_L1_2.fq.gz R2.fq.gz

```

## mt302: template

```bash
WORKING_DIR=${HOME}/data/dna-seq/xjy
BASE_NAME=mt302
QUEUE_NAME=mpi

cd ${WORKING_DIR}/${BASE_NAME}

anchr template \
    . \
    --basename ${BASE_NAME} \
    --genome 5000000 \
    --is_euk \
    --trim2 "--dedupe --tile" \
    --cov2 "10 20 40 80 160" \
    --qual2 "25 30" \
    --len2 "60" \
    --filter "adapter,phix,artifact" \
    --tadpole \
    --mergereads \
    --ecphase "1,2,3" \
    --insertsize \
    --parallel 24

```

## mt302: run

```bash
WORKING_DIR=${HOME}/data/dna-seq/xjy
BASE_NAME=mt302

cd ${WORKING_DIR}/${BASE_NAME}

bash 0_master.sh

# bash 0_cleanup.sh

```

Table: statInsertSize

| Group           |  Mean | Median | STDev | PercentOfPairs/PairOrientation |
|:----------------|------:|-------:|------:|-------------------------------:|
| tadpole.bbtools | 223.0 |    217 |  58.1 |                         11.27% |
| tadpole.picard  | 219.1 |    212 |  59.6 |                             FR |


Table: statReads

| Name     | N50 |   Sum |        # |
|:---------|----:|------:|---------:|
| Illumina | 150 |  1.8G | 11981828 |
| trim     | 150 | 1.29G |  8712168 |
| Q25L60   | 150 | 1.28G |  8650278 |
| Q30L60   | 150 | 1.23G |  8466867 |


Table: statTrimReads

| Name           | N50 |     Sum |       # |
|:---------------|----:|--------:|--------:|
| clumpify       | 150 |   1.36G | 9068014 |
| filteredbytile | 150 |   1.31G | 8747046 |
| trim           | 150 |   1.29G | 8712322 |
| filter         | 150 |   1.29G | 8712168 |
| R1             | 150 | 647.52M | 4356084 |
| R2             | 150 | 646.65M | 4356084 |
| Rs             |   0 |       0 |       0 |


```text
#trim
#Matched        193951  2.21733%
#Name   Reads   ReadsPct
Reverse_adapter 67223   0.76852%
TruSeq_Adapter_Index_1_6        40454   0.46249%
pcr_dimer       35597   0.40696%
PCR_Primers     26876   0.30726%
Nextera_LMP_Read2_External_Adapter      15646   0.17887%
TruSeq_Universal_Adapter        3001    0.03431%
PhiX_read2_adapter      2867    0.03278%
```

```text
#filter
#Matched        80      0.00092%
#Name   Reads   ReadsPct
```


Table: statMergeReads

| Name          | N50 |     Sum |       # |
|:--------------|----:|--------:|--------:|
| clumped       | 150 |   1.29G | 8686878 |
| ecco          | 150 |   1.29G | 8686878 |
| eccc          | 150 |   1.29G | 8686878 |
| ecct          | 150 | 252.73M | 1712224 |
| extended      | 188 | 299.61M | 1712224 |
| merged        | 301 | 206.07M |  740340 |
| unmerged.raw  | 170 |  38.03M |  231544 |
| unmerged.trim | 170 |  38.03M |  231526 |
| U1            | 170 |  19.05M |  115763 |
| U2            | 170 |  18.97M |  115763 |
| Us            |   0 |       0 |       0 |
| pe.cor        | 284 | 244.84M | 1712206 |

| Group            |  Mean | Median | STDev | PercentOfPairs |
|:-----------------|------:|-------:|------:|---------------:|
| ihist.merge1.txt | 226.5 |    234 |  41.4 |         57.29% |
| ihist.merge.txt  | 278.3 |    281 |  75.0 |         86.48% |


Table: statQuorum

| Name   | CovIn | CovOut | Discard% | AvgRead |  Kmer | RealG |   EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|------:|------:|-------:|---------:|----------:|
| Q0L0   | 258.8 |  104.3 |   59.72% |     145 | "105" |    5M | 64.31M |    12.86 | 0:10'46'' |
| Q25L60 | 255.9 |  104.0 |   59.36% |     142 | "105" |    5M | 63.95M |    12.79 | 0:10'51'' |
| Q30L60 | 246.0 |  100.7 |   59.07% |     136 | "105" |    5M | 60.54M |    12.11 | 0:09'26'' |


Table: statKunitigsAnchors.md

| Name          | CovCor | Mapped% | N50Anchor |     Sum |   # | N50Others |     Sum |   # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|-------:|--------:|----------:|--------:|----:|----------:|--------:|----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q0L0X10P000   |   10.0 |  16.04% |      1982 | 603.12K | 319 |      1286 | 369.24K | 872 |    6.0 | 1.0 |   3.0 |  12.0 | "31,41,51,61,71,81" | 0:02'14'' | 0:00'54'' |
| Q0L0X10P001   |   10.0 |  16.06% |      2000 | 587.13K | 306 |      1384 | 371.38K | 866 |    6.0 | 1.0 |   3.0 |  12.0 | "31,41,51,61,71,81" | 0:02'23'' | 0:00'55'' |
| Q0L0X10P002   |   10.0 |  16.34% |      1849 | 583.31K | 314 |      1316 | 403.62K | 917 |    6.0 | 1.0 |   3.0 |  12.0 | "31,41,51,61,71,81" | 0:02'24'' | 0:01'07'' |
| Q0L0X20P000   |   20.0 |  18.61% |      8149 | 915.46K | 173 |      1674 | 136.26K | 619 |   12.0 | 1.0 |   3.0 |  22.5 | "31,41,51,61,71,81" | 0:04'18'' | 0:00'50'' |
| Q0L0X20P001   |   20.0 |  18.89% |      9012 | 914.11K | 170 |      1525 |  131.7K | 660 |   12.0 | 1.0 |   3.0 |  22.5 | "31,41,51,61,71,81" | 0:04'01'' | 0:00'50'' |
| Q0L0X20P002   |   20.0 |  18.88% |      8382 | 914.16K | 174 |      1624 | 142.32K | 646 |   12.0 | 1.0 |   3.0 |  22.5 | "31,41,51,61,71,81" | 0:04'10'' | 0:00'54'' |
| Q0L0X40P000   |   40.0 |  15.97% |      6566 | 913.44K | 192 |      1686 |  80.31K | 435 |   24.0 | 2.0 |   6.0 |  45.0 | "31,41,51,61,71,81" | 0:08'09'' | 0:00'52'' |
| Q0L0X40P001   |   40.0 |  15.82% |      6400 | 917.78K | 197 |      1344 |  75.97K | 438 |   25.0 | 2.0 |   6.3 |  46.5 | "31,41,51,61,71,81" | 0:08'16'' | 0:00'48'' |
| Q0L0X80P000   |   80.0 |  14.46% |      4341 |  870.3K | 267 |      1093 |  82.05K | 587 |   48.0 | 5.0 |  11.0 |  94.5 | "31,41,51,61,71,81" | 0:13'34'' | 0:00'54'' |
| Q25L60X10P000 |   10.0 |  16.28% |      2035 | 559.26K | 298 |      1498 | 396.94K | 858 |    6.0 | 1.0 |   3.0 |  12.0 | "31,41,51,61,71,81" | 0:01'57'' | 0:00'45'' |
| Q25L60X10P001 |   10.0 |  16.05% |      2091 |  608.4K | 315 |      1242 | 343.25K | 872 |    6.0 | 1.0 |   3.0 |  12.0 | "31,41,51,61,71,81" | 0:01'54'' | 0:00'46'' |
| Q25L60X10P002 |   10.0 |  16.57% |      1997 | 620.85K | 322 |      1288 | 381.28K | 899 |    6.0 | 1.0 |   3.0 |  12.0 | "31,41,51,61,71,81" | 0:01'52'' | 0:00'47'' |
| Q25L60X20P000 |   20.0 |  19.07% |      8183 |  915.4K | 180 |      1615 | 162.85K | 683 |   12.0 | 1.0 |   3.0 |  22.5 | "31,41,51,61,71,81" | 0:03'53'' | 0:00'51'' |
| Q25L60X20P001 |   20.0 |  18.72% |      8055 | 927.17K | 180 |      1489 | 123.45K | 646 |   12.0 | 1.0 |   3.0 |  22.5 | "31,41,51,61,71,81" | 0:03'48'' | 0:00'50'' |
| Q25L60X20P002 |   20.0 |  18.56% |      8371 | 908.42K | 175 |      1586 | 134.61K | 616 |   12.0 | 1.0 |   3.0 |  22.5 | "31,41,51,61,71,81" | 0:04'08'' | 0:00'50'' |
| Q25L60X40P000 |   40.0 |  15.95% |      7545 | 911.91K | 181 |      1714 |  87.45K | 408 |   25.0 | 2.0 |   6.3 |  46.5 | "31,41,51,61,71,81" | 0:08'09'' | 0:00'59'' |
| Q25L60X40P001 |   40.0 |  15.95% |      6319 | 912.82K | 194 |      1586 |  82.31K | 425 |   25.0 | 2.0 |   6.3 |  46.5 | "31,41,51,61,71,81" | 0:08'21'' | 0:00'52'' |
| Q25L60X80P000 |   80.0 |  14.65% |      4415 | 873.75K | 258 |      1062 |  84.93K | 570 |   48.5 | 4.5 |  11.7 |  93.0 | "31,41,51,61,71,81" | 0:14'20'' | 0:00'59'' |
| Q30L60X10P000 |   10.0 |  17.61% |      1982 | 592.55K | 304 |      1421 |  443.3K | 906 |    6.0 | 1.0 |   3.0 |  12.0 | "31,41,51,61,71,81" | 0:02'00'' | 0:00'48'' |
| Q30L60X10P001 |   10.0 |  16.56% |      2063 |  593.6K | 301 |      1420 | 375.13K | 848 |    6.0 | 1.0 |   3.0 |  12.0 | "31,41,51,61,71,81" | 0:02'07'' | 0:00'47'' |
| Q30L60X10P002 |   10.0 |  17.01% |      2234 | 598.67K | 296 |      1340 | 394.66K | 879 |    6.0 | 1.0 |   3.0 |  12.0 | "31,41,51,61,71,81" | 0:01'56'' | 0:00'45'' |
| Q30L60X20P000 |   20.0 |  19.55% |      9946 | 915.59K | 156 |      1727 | 139.42K | 579 |   12.0 | 1.0 |   3.0 |  22.5 | "31,41,51,61,71,81" | 0:04'26'' | 0:00'53'' |
| Q30L60X20P001 |   20.0 |  20.26% |      7832 | 918.19K | 175 |      2248 | 157.42K | 683 |   12.0 | 1.0 |   3.0 |  22.5 | "31,41,51,61,71,81" | 0:04'24'' | 0:00'55'' |
| Q30L60X20P002 |   20.0 |  19.87% |      8040 | 906.29K | 177 |      1577 | 170.57K | 694 |   12.0 | 1.0 |   3.0 |  22.5 | "31,41,51,61,71,81" | 0:04'00'' | 0:00'52'' |
| Q30L60X40P000 |   40.0 |  16.81% |      7404 | 926.56K | 173 |      2170 |  86.44K | 389 |   26.0 | 2.0 |   6.7 |  48.0 | "31,41,51,61,71,81" | 0:07'09'' | 0:00'49'' |
| Q30L60X40P001 |   40.0 |  16.84% |      7710 | 924.89K | 154 |      2322 |  89.16K | 355 |   25.0 | 2.0 |   6.3 |  46.5 | "31,41,51,61,71,81" | 0:07'41'' | 0:00'49'' |
| Q30L60X80P000 |   80.0 |  15.81% |      5334 | 897.55K | 218 |      1309 |  96.73K | 491 |   50.0 | 5.0 |  11.7 |  97.5 | "31,41,51,61,71,81" | 0:15'31'' | 0:00'53'' |


Table: statTadpoleAnchors.md

| Name          | CovCor | Mapped% | N50Anchor |     Sum |   # | N50Others |     Sum |    # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|-------:|--------:|----------:|--------:|----:|----------:|--------:|-----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q0L0X10P000   |   10.0 |  12.35% |      1722 |  462.3K | 273 |      1247 | 215.44K |  737 |    7.0 | 1.0 |   3.0 |  14.0 | "31,41,51,61,71,81" | 0:01'32'' | 0:00'52'' |
| Q0L0X10P001   |   10.0 |  12.41% |      1674 | 444.57K | 271 |      1134 | 229.63K |  746 |    7.0 | 1.0 |   3.0 |  14.0 | "31,41,51,61,71,81" | 0:01'29'' | 0:00'50'' |
| Q0L0X10P002   |   10.0 |  12.32% |      1672 | 456.11K | 282 |      1275 | 231.87K |  729 |    7.0 | 1.0 |   3.0 |  14.0 | "31,41,51,61,71,81" | 0:01'37'' | 0:00'45'' |
| Q0L0X20P000   |   20.0 |  19.69% |      4711 | 933.82K | 264 |      1685 | 206.06K |  951 |   12.0 | 1.0 |   3.0 |  22.5 | "31,41,51,61,71,81" | 0:02'13'' | 0:00'58'' |
| Q0L0X20P001   |   20.0 |  20.08% |      5461 | 933.77K | 237 |      1807 | 208.37K |  997 |   12.0 | 1.0 |   3.0 |  22.5 | "31,41,51,61,71,81" | 0:02'04'' | 0:01'02'' |
| Q0L0X20P002   |   20.0 |  20.12% |      6359 | 926.86K | 222 |      2135 | 236.27K |  933 |   12.0 | 1.0 |   3.0 |  22.5 | "31,41,51,61,71,81" | 0:01'57'' | 0:00'53'' |
| Q0L0X40P000   |   40.0 |  18.18% |     14345 | 942.26K | 101 |      4645 |  87.86K |  349 |   24.0 | 2.0 |   6.0 |  45.0 | "31,41,51,61,71,81" | 0:04'51'' | 0:00'52'' |
| Q0L0X40P001   |   40.0 |  18.65% |     14432 |  952.1K | 111 |      3888 |   75.3K |  346 |   24.5 | 2.5 |   5.7 |  48.0 | "31,41,51,61,71,81" | 0:04'23'' | 0:00'47'' |
| Q0L0X80P000   |   80.0 |  16.54% |      9660 | 940.27K | 140 |      2267 |  88.06K |  320 |   50.0 | 5.0 |  11.7 |  97.5 | "31,41,51,61,71,81" | 0:09'24'' | 0:00'47'' |
| Q25L60X10P000 |   10.0 |  12.53% |      1595 | 439.55K | 271 |      1271 | 246.63K |  729 |    7.0 | 1.0 |   3.0 |  14.0 | "31,41,51,61,71,81" | 0:01'21'' | 0:00'43'' |
| Q25L60X10P001 |   10.0 |  12.60% |      1648 | 463.31K | 272 |      1209 | 230.79K |  742 |    7.0 | 1.0 |   3.0 |  14.0 | "31,41,51,61,71,81" | 0:01'55'' | 0:00'44'' |
| Q25L60X10P002 |   10.0 |  13.08% |      1733 | 498.85K | 298 |      1303 |  227.5K |  806 |    7.0 | 1.0 |   3.0 |  14.0 | "31,41,51,61,71,81" | 0:02'11'' | 0:00'46'' |
| Q25L60X20P000 |   20.0 |  19.88% |      5399 | 896.46K | 239 |      1517 | 233.61K |  934 |   12.0 | 1.0 |   3.0 |  22.5 | "31,41,51,61,71,81" | 0:02'11'' | 0:00'52'' |
| Q25L60X20P001 |   20.0 |  19.80% |      7518 | 923.62K | 215 |      3888 | 217.47K |  883 |   12.0 | 1.0 |   3.0 |  22.5 | "31,41,51,61,71,81" | 0:02'07'' | 0:00'53'' |
| Q25L60X20P002 |   20.0 |  20.26% |      7245 | 911.92K | 211 |      1562 | 198.48K |  976 |   12.0 | 1.0 |   3.0 |  22.5 | "31,41,51,61,71,81" | 0:02'31'' | 0:01'06'' |
| Q25L60X40P000 |   40.0 |  18.68% |     14416 | 940.83K |  99 |      3888 |  95.55K |  345 |   25.0 | 2.0 |   6.3 |  46.5 | "31,41,51,61,71,81" | 0:04'20'' | 0:01'12'' |
| Q25L60X40P001 |   40.0 |  18.01% |     14165 | 945.21K | 105 |      4086 |  83.11K |  314 |   25.0 | 2.0 |   6.3 |  46.5 | "31,41,51,61,71,81" | 0:04'28'' | 0:00'55'' |
| Q25L60X80P000 |   80.0 |  16.49% |      9411 | 940.43K | 141 |      2085 |  81.06K |  322 |   50.0 | 5.0 |  11.7 |  97.5 | "31,41,51,61,71,81" | 0:08'20'' | 0:00'58'' |
| Q30L60X10P000 |   10.0 |  13.70% |      1607 | 480.71K | 300 |      1243 | 266.04K |  797 |    7.0 | 1.0 |   3.0 |  14.0 | "31,41,51,61,71,81" | 0:01'17'' | 0:00'51'' |
| Q30L60X10P001 |   10.0 |  13.16% |      1648 |  488.4K | 295 |      1178 | 220.45K |  769 |    7.0 | 1.0 |   3.0 |  14.0 | "31,41,51,61,71,81" | 0:01'05'' | 0:00'53'' |
| Q30L60X10P002 |   10.0 |  13.23% |      1637 | 484.73K | 290 |      1517 | 237.21K |  763 |    7.0 | 1.0 |   3.0 |  14.0 | "31,41,51,61,71,81" | 0:01'32'' | 0:00'48'' |
| Q30L60X20P000 |   20.0 |  20.89% |      6937 | 920.75K | 217 |      1808 | 235.23K |  920 |   12.0 | 1.0 |   3.0 |  22.5 | "31,41,51,61,71,81" | 0:01'50'' | 0:00'53'' |
| Q30L60X20P001 |   20.0 |  20.87% |      5861 | 926.88K | 242 |      1624 | 237.95K | 1018 |   12.0 | 1.0 |   3.0 |  22.5 | "31,41,51,61,71,81" | 0:02'20'' | 0:00'53'' |
| Q30L60X20P002 |   20.0 |  20.69% |      7264 | 925.48K | 201 |      1713 | 191.71K |  901 |   13.0 | 1.0 |   3.3 |  24.0 | "31,41,51,61,71,81" | 0:02'39'' | 0:00'49'' |
| Q30L60X40P000 |   40.0 |  19.01% |     14448 |  942.1K |  99 |      4536 | 101.36K |  335 |   25.0 | 2.0 |   6.3 |  46.5 | "31,41,51,61,71,81" | 0:04'02'' | 0:01'10'' |
| Q30L60X40P001 |   40.0 |  18.95% |     18341 |  956.3K |  98 |      3660 |  86.73K |  312 |   26.0 | 2.0 |   6.7 |  48.0 | "31,41,51,61,71,81" | 0:04'11'' | 0:00'49'' |
| Q30L60X80P000 |   80.0 |  17.33% |     11554 | 944.92K | 122 |      2836 |  98.36K |  288 |   52.0 | 5.0 |  12.3 | 100.5 | "31,41,51,61,71,81" | 0:06'10'' | 0:00'40'' |


Table: statMRKunitigsAnchors.md

| Name      | CovCor | Mapped% | N50Anchor |     Sum |   # | N50Others |     Sum |   # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:----------|-------:|--------:|----------:|--------:|----:|----------:|--------:|----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| MRX10P000 |   10.0 |  38.19% |     13989 |  937.1K | 110 |      1860 | 107.41K | 266 |   16.0 | 2.0 |   3.3 |  32.0 | "31,41,51,61,71,81" | 0:01'29'' | 0:00'47'' |
| MRX10P001 |   10.0 |  38.21% |     14441 | 942.28K | 104 |      1586 | 100.86K | 253 |   16.0 | 2.0 |   3.3 |  32.0 | "31,41,51,61,71,81" | 0:02'21'' | 0:00'47'' |
| MRX10P002 |   10.0 |  38.84% |     13693 | 943.51K | 109 |      2709 |  93.14K | 271 |   16.0 | 2.0 |   3.3 |  32.0 | "31,41,51,61,71,81" | 0:02'33'' | 0:00'55'' |
| MRX10P003 |   10.0 |  38.38% |     13578 | 948.71K | 121 |      1487 |  99.53K | 294 |   16.0 | 2.0 |   3.3 |  32.0 | "31,41,51,61,71,81" | 0:02'40'' | 0:00'54'' |
| MRX20P000 |   20.0 |  15.48% |      1222 | 328.25K | 260 |      1067 | 268.45K | 748 |   25.0 | 3.0 |   5.3 |  50.0 | "31,41,51,61,71,81" | 0:03'18'' | 0:00'49'' |
| MRX20P001 |   20.0 |  15.90% |      1214 | 322.46K | 254 |      1074 | 289.75K | 758 |   25.0 | 3.0 |   5.3 |  50.0 | "31,41,51,61,71,81" | 0:02'37'' | 0:00'49'' |


Table: statMRTadpoleAnchors.md

| Name      | CovCor | Mapped% | N50Anchor |     Sum |   # | N50Others |     Sum |   # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:----------|-------:|--------:|----------:|--------:|----:|----------:|--------:|----:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| MRX10P000 |   10.0 |  38.37% |     17464 | 940.96K |  94 |      3660 |  83.23K | 212 |   16.0 | 2.0 |   3.3 |  32.0 | "31,41,51,61,71,81" | 0:01'14'' | 0:00'51'' |
| MRX10P001 |   10.0 |  38.52% |     18550 | 953.16K |  91 |      3660 |  76.25K | 219 |   16.0 | 2.0 |   3.3 |  32.0 | "31,41,51,61,71,81" | 0:01'13'' | 0:00'51'' |
| MRX10P002 |   10.0 |  38.45% |     15337 | 947.33K |  98 |      2267 |  79.58K | 230 |   16.0 | 2.0 |   3.3 |  32.0 | "31,41,51,61,71,81" | 0:01'38'' | 0:00'53'' |
| MRX10P003 |   10.0 |  38.65% |     17495 | 954.61K |  98 |      1691 |  83.37K | 237 |   16.0 | 2.0 |   3.3 |  32.0 | "31,41,51,61,71,81" | 0:01'19'' | 0:00'53'' |
| MRX20P000 |   20.0 |  38.20% |     17503 |  948.1K |  93 |      2267 |  92.51K | 215 |   31.0 | 5.0 |   5.3 |  62.0 | "31,41,51,61,71,81" | 0:01'34'' | 0:00'52'' |
| MRX20P001 |   20.0 |  38.11% |     14476 | 954.41K | 100 |      2033 |  87.78K | 231 |   32.0 | 4.0 |   6.7 |  64.0 | "31,41,51,61,71,81" | 0:01'53'' | 0:00'53'' |
| MRX40P000 |   40.0 |  37.81% |     12393 | 941.27K | 116 |      1861 | 112.89K | 278 |   63.0 | 9.0 |  12.0 | 126.0 | "31,41,51,61,71,81" | 0:03'14'' | 0:00'51'' |


Table: statFinal

| Name                             |   N50 |       Sum |      # |
|:---------------------------------|------:|----------:|-------:|
| 7_mergeKunitigsAnchors.anchors   | 18060 |   1074358 |    154 |
| 7_mergeKunitigsAnchors.others    |  1613 |   3235041 |   2055 |
| 7_mergeTadpoleAnchors.anchors    | 18807 |   1079140 |    148 |
| 7_mergeTadpoleAnchors.others     |  1220 |   2480311 |   1867 |
| 7_mergeMRKunitigsAnchors.anchors | 17568 |    981135 |    108 |
| 7_mergeMRKunitigsAnchors.others  |  1096 |    584613 |    463 |
| 7_mergeMRTadpoleAnchors.anchors  | 19871 |    989489 |    107 |
| 7_mergeMRTadpoleAnchors.others   |  3832 |    183499 |     86 |
| 7_mergeAnchors.anchors           | 19297 |   1130343 |    171 |
| 7_mergeAnchors.others            |  1572 |   3878454 |   2505 |
| spades.contig                    |   365 | 188351151 | 499381 |
| spades.scaffold                  |   365 | 188353079 | 499286 |
| spades.non-contained             |  1430 |  20316929 |  13183 |
| megahit.contig                   |   416 |  77656405 | 190910 |
| megahit.non-contained            |  1428 |   3955299 |   2318 |
| platanus.contig                  |   202 |   3674410 |  15971 |
| platanus.scaffold                |  1063 |   2258898 |   7729 |
| platanus.non-contained           | 29825 |   1138217 |    114 |
| platanus.anchor                  | 31126 |   1024906 |     86 |

# Create tarballs

* FastQC reports
* Spades assemblies
* Our assemblies
* Slightly unreliable parts of our assemblies
* Short gaps (fill gaps shorter than 2000 bp)

```bash
for BASE_NAME in m07 m08 m15 m17 m19 m20 m22; do
    echo >&2 "==> ${BASE_NAME}"
    pushd ${HOME}/data/dna-seq/xjy/${BASE_NAME}
    
    if [ -e ../${BASE_NAME}.tar.gz ]; then
        echo >&2 "    ${BASE_NAME}.tar.gz exists"
    else
        tar -czvf \
            ../${BASE_NAME}.tar.gz \
            2_illumina/fastqc/*.html \
            8_spades/contigs.non-contained.fasta \
            merge/anchor.merge.fasta \
            merge/others.merge.fasta \
            contigTrim/contig.fasta
    fi

    popd
done

find ${HOME}/data/dna-seq/xjy/ -type d -path "*8_spades/*" | xargs rm -fr
```

