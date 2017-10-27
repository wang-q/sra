# Plants 2+3

[TOC levels=1-3]: # " "
- [Plants 2+3](#plants-23)
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

* qual: 25, and 30
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
REAL_G=20000000
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

| Name   | SumIn | CovIn | SumOut | CovOut | Discard% | AvgRead |  Kmer | RealG |   EstG | Est/Real |   RunTime |
|:-------|------:|------:|-------:|-------:|---------:|--------:|------:|------:|-------:|---------:|----------:|
| Q25L60 | 5.32G | 265.9 |  4.79G |  239.6 |   9.907% |     149 | "105" |   20M | 21.99M |     1.10 | 0:13'07'' |
| Q30L60 | 5.22G | 261.0 |  4.75G |  237.3 |   9.069% |     147 | "105" |   20M | 20.03M |     1.00 | 0:18'22'' |

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
        echo >&2 '    k_unitigs.fasta already presents'
        exit;
    fi

    rm -fr Q{1}L{2}X{3}P{4}/anchor
    mkdir -p Q{1}L{2}X{3}P{4}/anchor
    cd Q{1}L{2}X{3}P{4}/anchor
    anchr anchors \
        ../pe.cor.fa \
        ../k_unitigs.fasta \
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
    " ::: 25 30 ::: 60 ::: 10 20 40 80 ::: $(printf "%03d " {0..100}) \
     >> stat2.md

cat stat2.md
```

| Name           | SumCor | CovCor | N50SR |     Sum |     # | N50Anchor |     Sum |     # | N50Others |    Sum |     # |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|-------:|------:|--------:|------:|----------:|--------:|------:|----------:|-------:|------:|--------------------:|----------:|:----------|
| Q20L60X40P000  |     4G |   40.0 |  7479 | 139.88M | 60972 |     12174 | 111.85M | 20935 |       700 | 28.03M | 40037 | "31,41,51,61,71,81" | 1:28'42'' | 0:14'24'' |
| Q20L60X40P001  |     4G |   40.0 |  6610 | 137.78M | 62485 |     10906 | 109.55M | 21870 |       698 | 28.23M | 40615 | "31,41,51,61,71,81" | 1:25'53'' | 0:13'01'' |
| Q20L60X80P000  |     8G |   80.0 |  4590 |  198.1M | 87730 |      8423 | 162.94M | 39393 |       740 | 35.16M | 48337 | "31,41,51,61,71,81" | 2:24'09'' | 0:21'16'' |
| Q20L60X100P000 |    10G |  100.0 |  5215 | 213.12M | 85378 |      8014 | 180.82M | 41234 |       740 |  32.3M | 44144 | "31,41,51,61,71,81" | 2:39'18'' | 0:24'35'' |
| Q25L60X40P000  |     4G |   40.0 | 10314 | 140.94M | 56147 |     16375 | 114.65M | 18621 |       701 | 26.29M | 37526 | "31,41,51,61,71,81" | 1:04'04'' | 0:12'31'' |
| Q25L60X40P001  |     4G |   40.0 |  8800 |  139.8M | 57714 |     14190 | 113.22M | 19645 |       699 | 26.57M | 38069 | "31,41,51,61,71,81" | 1:10'58'' | 0:11'55'' |
| Q25L60X80P000  |     8G |   80.0 |  6809 |  200.4M | 80736 |     12615 | 167.57M | 36005 |       743 | 32.83M | 44731 | "31,41,51,61,71,81" | 2:49'28'' | 0:23'11'' |
| Q25L60X100P000 |    10G |  100.0 |  7239 | 215.01M | 77341 |     11779 | 186.17M | 37905 |       739 | 28.83M | 39436 | "31,41,51,61,71,81" | 3:07'40'' | 0:28'14'' |
| Q30L60X40P000  |     4G |   40.0 | 12974 | 140.23M | 52040 |     20960 | 115.42M | 16637 |       699 | 24.81M | 35403 | "31,41,51,61,71,81" | 2:14'27'' | 0:14'04'' |
| Q30L60X40P001  |     4G |   40.0 | 11765 | 138.81M | 52119 |     19214 | 114.46M | 17216 |       697 | 24.35M | 34903 | "31,41,51,61,71,81" | 1:33'04'' | 0:14'51'' |
| Q30L60X80P000  |     8G |   80.0 | 10259 | 200.04M | 74096 |     19916 | 169.76M | 32909 |       744 | 30.28M | 41187 | "31,41,51,61,71,81" | 2:36'42'' | 0:24'45'' |
| Q30L60X100P000 |    10G |  100.0 | 10386 | 214.72M | 70890 |     17497 | 188.42M | 35024 |       743 |  26.3M | 35866 | "31,41,51,61,71,81" | 3:25'34'' | 0:29'04'' |

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

cat stat3.md
```

| Name         |   N50 |       Sum |     # |
|:-------------|------:|----------:|------:|
| anchor.merge | 31691 | 205191119 | 32022 |
| others.merge |  1055 |  19869683 | 16442 |

* Clear QxxLxxXxx.

```bash
BASE_NAME=m07
cd ${HOME}/data/dna-seq/xjy/${BASE_NAME}

rm -fr 2_illumina/Q{20,25,30,35}L{1,60,90,120}X*
rm -fr Q{20,25,30,35}L{1,60,90,120}X*
```
