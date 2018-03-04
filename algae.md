# Plants 2+3

[TOC levels=1-3]: # " "
- [Plants 2+3](#plants-23)
- [F63, Closterium sp., 新月藻](#f63-closterium-sp-新月藻)
    - [F63: download](#f63-download)
    - [F63: combinations of different quality values and read lengths](#f63-combinations-of-different-quality-values-and-read-lengths)
    - [F63: quorum](#f63-quorum)
    - [F63: down sampling](#f63-down-sampling)
    - [F63: k-unitigs and anchors (sampled)](#f63-k-unitigs-and-anchors-sampled)
    - [F63: merge anchors](#f63-merge-anchors)
- [F295, Cosmarium botrytis, 葡萄鼓藻](#f295-cosmariumbotrytis-葡萄鼓藻)
    - [F295: download](#f295-download)
    - [F295: combinations of different quality values and read lengths](#f295-combinations-of-different-quality-values-and-read-lengths)
    - [F295: down sampling](#f295-down-sampling)
    - [F295: generate super-reads](#f295-generate-super-reads)
    - [F295: create anchors](#f295-create-anchors)
    - [F295: results](#f295-results)
    - [F295: merge anchors](#f295-merge-anchors)
- [F340, Zygnema extenue, 亚小双星藻](#f340-zygnema-extenue-亚小双星藻)
    - [F340: download](#f340-download)
    - [F340: combinations of different quality values and read lengths](#f340-combinations-of-different-quality-values-and-read-lengths)
    - [F340: down sampling](#f340-down-sampling)
    - [F340: generate super-reads](#f340-generate-super-reads)
    - [F340: create anchors](#f340-create-anchors)
    - [F340: results](#f340-results)
    - [F340: merge anchors](#f340-merge-anchors)
- [F354, Spirogyra gracilis, 纤细水绵](#f354-spirogyragracilis-纤细水绵)
    - [F354: download](#f354-download)
    - [F354: template](#f354-template)
    - [F354: run](#f354-run)
- [F357, Botryococcus braunii, 布朗葡萄藻](#f357-botryococcus-braunii-布朗葡萄藻)
    - [F357: download](#f357-download)
    - [F357: combinations of different quality values and read lengths](#f357-combinations-of-different-quality-values-and-read-lengths)
    - [F357: quorum](#f357-quorum)
    - [F357: down sampling](#f357-down-sampling)
    - [F357: k-unitigs and anchors (sampled)](#f357-k-unitigs-and-anchors-sampled)
    - [F357: merge anchors](#f357-merge-anchors)
- [F1084, Staurastrum sp., 角星鼓藻](#f1084-staurastrumsp-角星鼓藻)
    - [F1084: download](#f1084-download)
    - [F1084: template](#f1084-template)
    - [F1084: run](#f1084-run)
- [showa, Botryococcus braunii Showa](#showa-botryococcus-braunii-showa)
    - [showa: download](#showa-download)
    - [3GS](#3gs)
- [Summary of SR](#summary-of-sr)
- [Anchors](#anchors)


* Rsync to hpcc

```bash
rsync -avP \
    ~/data/dna-seq/chara/clean_data/ \
    wangq@202.119.37.251:data/dna-seq/chara/clean_data

# rsync -avP wangq@202.119.37.251:data/dna-seq/chara/ ~/data/dna-seq/chara

```

# F63, Closterium sp., 新月藻

## F63: download

```bash
mkdir -p ~/data/dna-seq/chara/F63/2_illumina
cd ~/data/dna-seq/chara/F63/2_illumina

ln -s ~/data/dna-seq/chara/clean_data/F63_HF5WLALXX_L5_1.clean.fq.gz R1.fq.gz
ln -s ~/data/dna-seq/chara/clean_data/F63_HF5WLALXX_L5_2.clean.fq.gz R2.fq.gz
```

* FastQC

```bash
BASE_NAME=F63
cd ${HOME}/data/dna-seq/chara/${BASE_NAME}

mkdir -p 2_illumina/fastqc
cd 2_illumina/fastqc

fastqc -t 16 \
    ../R1.fq.gz ../R2.fq.gz \
    -o .

```

## F63: combinations of different quality values and read lengths

* qual: 20, 25, and 30
* len: 60

```bash
BASE_NAME=F63
cd ${HOME}/data/dna-seq/chara/${BASE_NAME}

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
    " ::: 20 25 30 ::: 60


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
    " ::: 20 25 30 ::: 60 \
    >> stat.md

cat stat.md
```

| Name     | N50 |         Sum |         # |
|:---------|----:|------------:|----------:|
| Illumina | 150 | 17261747100 | 115078314 |
| uniq     | 150 | 16706582100 | 111377214 |
| Q20L60   | 150 | 14900674294 | 103216264 |
| Q25L60   | 150 | 13281199659 |  94058608 |
| Q30L60   | 150 | 12753703579 |  93666221 |

## F63: quorum

```bash
BASE_NAME=F63
REAL_G=100000000
cd ${HOME}/data/dna-seq/chara/${BASE_NAME}

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
    " ::: 20 25 30 ::: 60

# Stats of processed reads
bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 1 header \
    > stat1.md

parallel -k --no-run-if-empty -j 3 "
    if [ ! -d 2_illumina/Q{1}L{2} ]; then
        exit;
    fi

    bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 1 2_illumina/Q{1}L{2} ${REAL_G}
    " ::: 20 25 30 ::: 60 \
     >> stat1.md

cat stat1.md

```

| Name   |  SumIn | CovIn | SumOut | CovOut | Discard% | AvgRead | Kmer | RealG |    EstG | Est/Real |   RunTime |
|:-------|-------:|------:|-------:|-------:|---------:|--------:|-----:|------:|--------:|---------:|----------:|
| Q20L60 |  14.9G | 149.0 | 11.31G |  113.1 |  24.064% |     149 | "49" |  100M | 270.52M |     2.71 | 0:42'28'' |
| Q25L60 | 13.28G | 132.8 | 10.97G |  109.7 |  17.396% |     149 | "49" |  100M | 259.72M |     2.60 | 0:39'43'' |
| Q30L60 | 12.76G | 127.6 | 11.14G |  111.4 |  12.715% |     149 | "49" |  100M | 255.87M |     2.56 | 0:37'26'' |

* Clear intermediate files.

```bash
BASE_NAME=F63
cd ${HOME}/data/dna-seq/chara/${BASE_NAME}

find 2_illumina -type f -name "quorum_mer_db.jf" | xargs rm
find 2_illumina -type f -name "k_u_hash_0"       | xargs rm
find 2_illumina -type f -name "*.tmp"            | xargs rm
find 2_illumina -type f -name "pe.renamed.fastq" | xargs rm
find 2_illumina -type f -name "se.renamed.fastq" | xargs rm
find 2_illumina -type f -name "pe.cor.sub.fa"    | xargs rm
```

* kmergenie

```bash
BASE_NAME=F63
cd ${HOME}/data/dna-seq/chara/${BASE_NAME}

mkdir -p 2_illumina/kmergenie
cd 2_illumina/kmergenie

kmergenie -l 21 -k 121 -s 10 -t 8 ../R1.fq.gz -o oriR1
kmergenie -l 21 -k 121 -s 10 -t 8 ../R2.fq.gz -o oriR2
kmergenie -l 21 -k 121 -s 10 -t 8 ../Q30L60/pe.cor.fa -o Q30L60

```

## F63: down sampling

```bash
BASE_NAME=F63
REAL_G=100000000
cd ${HOME}/data/dna-seq/chara/${BASE_NAME}

for QxxLxx in $( parallel "echo 'Q{1}L{2}'" ::: 20 25 30 ::: 60 ); do
    echo "==> ${QxxLxx}"

    if [ ! -e 2_illumina/${QxxLxx}/pe.cor.fa ]; then
        echo "2_illumina/${QxxLxx}/pe.cor.fa not exists"
        continue;
    fi

    for X in 40 80 100; do
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

## F63: k-unitigs and anchors (sampled)

```bash
BASE_NAME=F63
REAL_G=100000000
cd ${HOME}/data/dna-seq/chara/${BASE_NAME}

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
    " ::: 20 25 30 ::: 60 ::: 40 80 100 ::: 000 001 002 003 004 005 006

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
        ../k_unitigs.fasta \
        ../pe.cor.fa \
        -p 8 \
        -o anchors.sh
    bash anchors.sh
    
    echo >&2
    " ::: 20 25 30 ::: 60 ::: 40 80 100 ::: 000 001 002 003 004 005 006

# Stats of anchors
bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 header \
    > stat2.md

parallel -k --no-run-if-empty -j 6 "
    if [ ! -e Q{1}L{2}X{3}P{4}/anchor/pe.anchor.fa ]; then
        exit;
    fi

    bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 Q{1}L{2}X{3}P{4} ${REAL_G}
    " ::: 20 25 30 ::: 60 ::: 40 80 100 ::: 000 001 002 003 004 005 006 \
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

## F63: merge anchors

```bash
BASE_NAME=F63
cd ${HOME}/data/dna-seq/chara/${BASE_NAME}

# merge anchors
mkdir -p merge
anchr contained \
    $(
        parallel -k --no-run-if-empty -j 6 "
            if [ -e Q{1}L{2}X{3}P{4}/anchor/pe.anchor.fa ]; then
                echo Q{1}L{2}X{3}P{4}/anchor/pe.anchor.fa
            fi
            " ::: 20 25 30 ::: 60 ::: 40 80 100 ::: 000 001 002 003 004 005 006
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
            " ::: 20 25 30 ::: 60 ::: 40 80 100 ::: 000 001 002 003 004 005 006
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
BASE_NAME=F63
cd ${HOME}/data/dna-seq/chara/${BASE_NAME}

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
BASE_NAME=F63
cd ${HOME}/data/dna-seq/chara/${BASE_NAME}

rm -fr 2_illumina/Q{20,25,30,35}L{1,60,90,120}X*
rm -fr Q{20,25,30,35}L{1,60,90,120}X*
```

# F295, Cosmarium botrytis, 葡萄鼓藻

## F295: download

```bash
mkdir -p ~/data/dna-seq/chara/F295/2_illumina
cd ~/data/dna-seq/chara/F295/2_illumina

ln -s ~/data/dna-seq/chara/clean_data/F295_HF5KMALXX_L7_1.clean.fq.gz R1.fq.gz
ln -s ~/data/dna-seq/chara/clean_data/F295_HF5KMALXX_L7_2.clean.fq.gz R2.fq.gz
```

* FastQC

```bash
BASE_NAME=F295
cd ${HOME}/data/dna-seq/chara/${BASE_NAME}

mkdir -p 2_illumina/fastqc
cd 2_illumina/fastqc

fastqc -t 16 \
    ../R1.fq.gz ../R2.fq.gz \
    -o .

```

## F295: combinations of different quality values and read lengths

* qual: 20, 25, and 30
* len: 100, 120, and 140

```bash
BASE_DIR=$HOME/data/dna-seq/chara/F295

cd ${BASE_DIR}
tally \
    --pair-by-offset --with-quality --nozip \
    -i 2_illumina/R1.fq.gz \
    -j 2_illumina/R2.fq.gz \
    -o 2_illumina/R1.uniq.fq \
    -p 2_illumina/R2.uniq.fq

parallel --no-run-if-empty -j 2 "
        pigz -p 4 2_illumina/{}.uniq.fq
    " ::: R1 R2

cd ${BASE_DIR}
parallel --no-run-if-empty -j 2 "
    scythe \
        2_illumina/{}.uniq.fq.gz \
        -q sanger \
        -a /home/wangq/.plenv/versions/5.18.4/lib/perl5/site_perl/5.18.4/auto/share/dist/App-Anchr/illumina_adapters.fa \
        --quiet \
        | pigz -p 4 -c \
        > 2_illumina/{}.scythe.fq.gz
    " ::: R1 R2

cd ${BASE_DIR}
parallel --no-run-if-empty -j 4 "
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
    " ::: 20 25 30 ::: 100 120 140

```

* Stats

```bash
BASE_DIR=$HOME/data/dna-seq/chara/F295
cd ${BASE_DIR}

printf "| %s | %s | %s | %s |\n" \
    "Name" "N50" "Sum" "#" \
    > stat.md
printf "|:--|--:|--:|--:|\n" >> stat.md

printf "| %s | %s | %s | %s |\n" \
    $(echo "Illumina"; faops n50 -H -S -C 2_illumina/R1.fq.gz 2_illumina/R2.fq.gz;) >> stat.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "uniq";   faops n50 -H -S -C 2_illumina/R1.uniq.fq.gz 2_illumina/R2.uniq.fq.gz;) >> stat.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "scythe";   faops n50 -H -S -C 2_illumina/R1.scythe.fq.gz 2_illumina/R2.scythe.fq.gz;) >> stat.md

for qual in 20 25 30; do
    for len in 100 120 140; do
        DIR_COUNT="${BASE_DIR}/2_illumina/Q${qual}L${len}"

        printf "| %s | %s | %s | %s |\n" \
            $(echo "Q${qual}L${len}"; faops n50 -H -S -C ${DIR_COUNT}/R1.fq.gz  ${DIR_COUNT}/R2.fq.gz;) \
            >> stat.md
    done
done

cat stat.md
```

| Name     | N50 |         Sum |         # |
|:---------|----:|------------:|----------:|
| Illumina | 150 | 22046948400 | 146979656 |
| uniq     | 150 | 21103848300 | 140692322 |
| scythe   | 150 | 21073028310 | 140692322 |
| Q20L100  | 150 | 18152807200 | 124108212 |
| Q20L120  | 150 | 16410045039 | 110542594 |
| Q20L140  | 150 | 14406285004 |  96103358 |
| Q25L100  | 150 | 15962439288 | 110459910 |
| Q25L120  | 150 | 13657879824 |  92491434 |
| Q25L140  | 150 | 11063485749 |  73800134 |
| Q30L100  | 150 | 13315942926 |  93623332 |
| Q30L120  | 150 | 10506610537 |  71679014 |
| Q30L140  | 150 |  7568761655 |  50504228 |

## F295: down sampling

```bash
BASE_DIR=$HOME/data/dna-seq/chara/F295
cd ${BASE_DIR}

# works on bash 3
ARRAY=(
    "2_illumina/Q20L100:Q20L100"
    "2_illumina/Q20L120:Q20L120"
    "2_illumina/Q20L140:Q20L140"
    "2_illumina/Q25L100:Q25L100"
    "2_illumina/Q25L120:Q25L120"
    "2_illumina/Q25L140:Q25L140"
    "2_illumina/Q30L100:Q30L100"
    "2_illumina/Q30L120:Q30L120"
    "2_illumina/Q30L140:Q30L140"
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

## F295: generate super-reads

```bash
BASE_DIR=$HOME/data/dna-seq/chara/F295
cd ${BASE_DIR}

perl -e '
    for my $n (
        qw{
        Q20L100 Q20L120 Q20L140
        Q25L100 Q25L120 Q25L140
        Q30L100 Q30L120 Q30L140
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
BASE_DIR=$HOME/data/dna-seq/chara/F295

find . -type f -name "quorum_mer_db.jf"          | xargs rm
find . -type f -name "k_u_hash_0"                | xargs rm
find . -type f -name "readPositionsInSuperReads" | xargs rm
find . -type f -name "*.tmp"                     | xargs rm
find . -type f -name "pe.renamed.fastq"          | xargs rm
find . -type f -name "pe.cor.sub.fa"             | xargs rm
```

## F295: create anchors

```bash
BASE_DIR=$HOME/data/dna-seq/chara/F295
cd ${BASE_DIR}

perl -e '
    for my $n (
        qw{
        Q20L100 Q20L120 Q20L140
        Q25L100 Q25L120 Q25L140
        Q30L100 Q30L120 Q30L140
        }
        )
    {
        printf qq{%s\n}, $n;
    }
    ' \
    | parallel --no-run-if-empty -j 3 "
        echo '==> Group {}'

        if [ -e ${BASE_DIR}/{}/anchor/pe.anchor.fa ]; then
            exit;
        fi

        rm -fr ${BASE_DIR}/{}/anchor
        bash ~/Scripts/cpan/App-Anchr/share/anchor.sh ${BASE_DIR}/{} 8 false
    "

```

## F295: results

* Stats of super-reads

```bash
BASE_DIR=$HOME/data/dna-seq/chara/F295
cd ${BASE_DIR}

REAL_G=100000000

bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 1 header \
    > ${BASE_DIR}/stat1.md

perl -e '
    for my $n (
        qw{
        Q20L100 Q20L120 Q20L140
        Q25L100 Q25L120 Q25L140
        Q30L100 Q30L120 Q30L140
        }
        )
    {
        printf qq{%s\n}, $n;
    }
    ' \
    | parallel -k --no-run-if-empty -j 4 "
        if [ ! -d ${BASE_DIR}/{} ]; then
            exit;
        fi

        bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 1 ${BASE_DIR}/{} ${REAL_G}
    " >> ${BASE_DIR}/stat1.md

cat stat1.md
```

* Stats of anchors

```bash
BASE_DIR=$HOME/data/dna-seq/chara/F295
cd ${BASE_DIR}

bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 header \
    > ${BASE_DIR}/stat2.md

perl -e '
    for my $n (
        qw{
        Q20L100 Q20L120 Q20L140
        Q25L100 Q25L120 Q25L140
        Q30L100 Q30L120 Q30L140
        }
        )
    {
        printf qq{%s\n}, $n;
    }
    ' \
    | parallel -k --no-run-if-empty -j 8 "
        if [ ! -e ${BASE_DIR}/{}/anchor/pe.anchor.fa ]; then
            exit;
        fi

        bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 ${BASE_DIR}/{}
    " >> ${BASE_DIR}/stat2.md

cat stat2.md
```

| Name    |  SumFq | CovFq | AvgRead | Kmer |  SumFa | Discard% | RealG |    EstG | Est/Real |   SumKU | SumSR |   RunTime |
|:--------|-------:|------:|--------:|-----:|-------:|---------:|------:|--------:|---------:|--------:|------:|----------:|
| Q20L100 | 18.15G | 181.5 |     149 |   49 | 13.66G |  24.736% |  100M | 228.42M |     2.28 | 432.66M |     0 | 5:28'24'' |
| Q20L120 | 16.41G | 164.1 |     149 |   49 | 12.55G |  23.520% |  100M | 216.37M |     2.16 | 374.11M |     0 | 4:48'01'' |
| Q20L140 | 14.41G | 144.1 |     149 |   49 | 11.19G |  22.308% |  100M | 203.26M |     2.03 | 323.24M |     0 | 4:33'44'' |
| Q25L100 | 15.96G | 159.6 |     149 |   49 | 12.84G |  19.532% |  100M |  213.2M |     2.13 | 364.01M |     0 | 3:02'25'' |
| Q25L120 | 13.66G | 136.6 |     149 |   49 | 11.09G |  18.806% |  100M | 198.36M |     1.98 | 306.53M |     0 | 2:44'10'' |
| Q25L140 | 11.06G | 110.6 |     149 |   49 |  9.05G |  18.196% |  100M | 181.56M |     1.82 | 258.74M |     0 | 1:35'56'' |
| Q30L100 | 13.32G | 133.2 |     149 |   49 | 11.19G |  15.954% |  100M | 195.82M |     1.96 | 303.14M |     0 | 3:21'42'' |
| Q30L120 | 10.51G | 105.1 |     149 |   49 |  8.86G |  15.660% |  100M | 177.62M |     1.78 | 249.35M |     0 | 2:23'36'' |
| Q30L140 |  7.57G |  75.7 |     149 |   49 |  6.39G |  15.554% |  100M |  156.8M |     1.57 |  205.1M |     0 | 1:29'42'' |

| Name    | N50SRclean |     Sum |       # | N50Anchor |     Sum |     # | N50Anchor2 |   Sum |    # | N50Others |     Sum |       # |   RunTime |
|:--------|-----------:|--------:|--------:|----------:|--------:|------:|-----------:|------:|-----:|----------:|--------:|--------:|----------:|
| Q20L100 |        102 | 432.66M | 4050421 |      8953 |  123.3M | 25942 |       1372 | 2.55M | 1821 |        70 | 306.81M | 4022658 | 2:09'23'' |
| Q20L120 |        145 | 374.11M | 3141052 |      9888 |  123.2M | 24944 |       1375 | 2.79M | 1979 |        75 | 248.13M | 3114129 | 1:17'40'' |
| Q20L140 |        199 | 323.24M | 2403070 |     11121 | 121.02M | 23440 |       1384 |    3M | 2124 |        83 | 199.23M | 2377506 | 1:07'11'' |
| Q25L100 |        150 | 364.01M | 2998516 |     11001 | 126.94M | 24190 |       1350 | 2.21M | 1604 |        74 | 234.86M | 2972722 | 1:24'17'' |
| Q25L120 |        259 | 306.53M | 2166904 |     12484 | 122.06M | 21735 |       1376 |  2.7M | 1933 |        85 | 181.77M | 2143236 | 1:03'49'' |
| Q25L140 |        581 | 258.74M | 1559661 |     14743 | 113.95M | 18515 |       1339 | 2.78M | 2027 |        97 | 142.01M | 1539119 | 1:31'58'' |
| Q30L100 |        275 | 303.14M | 2151487 |     14366 |  122.9M | 20817 |       1304 | 2.05M | 1526 |        82 |  178.2M | 2129144 | 1:36'41'' |
| Q30L120 |        713 | 249.35M | 1452337 |     16369 | 114.24M | 18285 |       1318 | 2.32M | 1723 |        97 | 132.79M | 1432329 | 1:08'25'' |
| Q30L140 |       1225 |  205.1M |  988570 |     16834 | 103.13M | 15628 |       1327 | 2.07M | 1526 |       109 |  99.89M |  971416 | 0:33'35'' |

## F295: merge anchors

```bash
BASE_DIR=$HOME/data/dna-seq/chara/F295
cd ${BASE_DIR}

# merge anchors
mkdir -p merge
anchr contained \
    Q20L100/anchor/pe.anchor.fa \
    Q20L120/anchor/pe.anchor.fa \
    Q20L140/anchor/pe.anchor.fa \
    Q25L100/anchor/pe.anchor.fa \
    Q25L120/anchor/pe.anchor.fa \
    Q25L140/anchor/pe.anchor.fa \
    Q30L100/anchor/pe.anchor.fa \
    Q30L120/anchor/pe.anchor.fa \
    Q30L140/anchor/pe.anchor.fa \
    --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
    -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/anchor.contained.fasta
anchr orient merge/anchor.contained.fasta --len 1000 --idt 0.98 -o merge/anchor.orient.fasta
anchr merge merge/anchor.orient.fasta --len 1000 --idt 0.999 -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/anchor.merge.fasta

faops n50 -S -C merge/anchor.merge.fasta

# merge anchor2 and others
anchr contained \
    Q20L100/anchor/pe.anchor2.fa \
    Q20L120/anchor/pe.anchor2.fa \
    Q20L140/anchor/pe.anchor2.fa \
    Q25L100/anchor/pe.anchor2.fa \
    Q25L120/anchor/pe.anchor2.fa \
    Q25L140/anchor/pe.anchor2.fa \
    Q30L100/anchor/pe.anchor2.fa \
    Q30L120/anchor/pe.anchor2.fa \
    Q30L140/anchor/pe.anchor2.fa \
    Q20L100/anchor/pe.others.fa \
    Q20L120/anchor/pe.others.fa \
    Q20L140/anchor/pe.others.fa \
    Q25L100/anchor/pe.others.fa \
    Q25L120/anchor/pe.others.fa \
    Q25L140/anchor/pe.others.fa \
    Q30L100/anchor/pe.others.fa \
    Q30L120/anchor/pe.others.fa \
    Q30L140/anchor/pe.others.fa \
    --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
    -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/others.contained.fasta
anchr orient merge/others.contained.fasta --len 1000 --idt 0.98 -o merge/others.orient.fasta
anchr merge merge/others.orient.fasta --len 1000 --idt 0.999 -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/others.merge.fasta
    
faops n50 -S -C merge/others.merge.fasta

# quast
rm -fr 9_qa
quast --no-check --threads 16 \
    Q20L100/anchor/pe.anchor.fa \
    Q25L100/anchor/pe.anchor.fa \
    Q30L100/anchor/pe.anchor.fa \
    merge/anchor.merge.fasta \
    merge/others.merge.fasta \
    --label "Q20L100,Q25L100,Q30L100,merge,others" \
    -o 9_qa

```

* Clear QxxLxxx.

```bash
BASE_DIR=$HOME/data/dna-seq/chara/F295
cd ${BASE_DIR}

rm -fr 2_illumina/Q{20,25,30}L*
rm -fr Q{20,25,30}L*
```

* Stats

```bash
BASE_DIR=$HOME/data/dna-seq/chara/F295
cd ${BASE_DIR}

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
| anchor.merge | 19934 | 137224833 | 20546 |
| others.merge |  1294 |  15859687 | 12027 |

# F340, Zygnema extenue, 亚小双星藻

## F340: download

```bash
mkdir -p ~/data/dna-seq/chara/F340/2_illumina
cd ~/data/dna-seq/chara/F340/2_illumina

ln -s ~/data/dna-seq/chara/clean_data/F340-hun_HF3JLALXX_L6_1.clean.fq.gz R1.fq.gz
ln -s ~/data/dna-seq/chara/clean_data/F340-hun_HF3JLALXX_L6_2.clean.fq.gz R2.fq.gz
```

* FastQC

```bash
BASE_NAME=F340
cd ${HOME}/data/dna-seq/chara/${BASE_NAME}

mkdir -p 2_illumina/fastqc
cd 2_illumina/fastqc

fastqc -t 16 \
    ../R1.fq.gz ../R2.fq.gz \
    -o .

```

## F340: combinations of different quality values and read lengths

* qual: 20, 25, and 30
* len: 100, 120, and 140

```bash
BASE_DIR=$HOME/data/dna-seq/chara/F340

cd ${BASE_DIR}
tally \
    --pair-by-offset --with-quality --nozip \
    -i 2_illumina/R1.fq.gz \
    -j 2_illumina/R2.fq.gz \
    -o 2_illumina/R1.uniq.fq \
    -p 2_illumina/R2.uniq.fq

parallel --no-run-if-empty -j 2 "
        pigz -p 4 2_illumina/{}.uniq.fq
    " ::: R1 R2

cd ${BASE_DIR}
parallel --no-run-if-empty -j 2 "
    scythe \
        2_illumina/{}.uniq.fq.gz \
        -q sanger \
        -a /home/wangq/.plenv/versions/5.18.4/lib/perl5/site_perl/5.18.4/auto/share/dist/App-Anchr/illumina_adapters.fa \
        --quiet \
        | pigz -p 4 -c \
        > 2_illumina/{}.scythe.fq.gz
    " ::: R1 R2

cd ${BASE_DIR}
parallel --no-run-if-empty -j 4 "
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
    " ::: 20 25 30 ::: 100 120 140

```

* Stats

```bash
BASE_DIR=$HOME/data/dna-seq/chara/F340
cd ${BASE_DIR}

printf "| %s | %s | %s | %s |\n" \
    "Name" "N50" "Sum" "#" \
    > stat.md
printf "|:--|--:|--:|--:|\n" >> stat.md

printf "| %s | %s | %s | %s |\n" \
    $(echo "Illumina"; faops n50 -H -S -C 2_illumina/R1.fq.gz 2_illumina/R2.fq.gz;) >> stat.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "uniq";   faops n50 -H -S -C 2_illumina/R1.uniq.fq.gz 2_illumina/R2.uniq.fq.gz;) >> stat.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "scythe";   faops n50 -H -S -C 2_illumina/R1.scythe.fq.gz 2_illumina/R2.scythe.fq.gz;) >> stat.md

for qual in 20 25 30; do
    for len in 100 120 140; do
        DIR_COUNT="${BASE_DIR}/2_illumina/Q${qual}L${len}"

        printf "| %s | %s | %s | %s |\n" \
            $(echo "Q${qual}L${len}"; faops n50 -H -S -C ${DIR_COUNT}/R1.fq.gz  ${DIR_COUNT}/R2.fq.gz;) \
            >> stat.md
    done
done

cat stat.md
```

| Name     | N50 |         Sum |         # |
|:---------|----:|------------:|----------:|
| Illumina | 150 | 18309410400 | 122062736 |
| uniq     | 150 | 17866149600 | 119107664 |
| scythe   | 150 | 17851191742 | 119107664 |
| Q20L100  | 150 | 15513406507 | 105986394 |
| Q20L120  | 150 | 14134581471 |  95323932 |
| Q20L140  | 150 | 12224648204 |  81563320 |
| Q25L100  | 150 | 13163602983 |  91278248 |
| Q25L120  | 150 | 11253296912 |  76464550 |
| Q25L140  | 150 |  8646235281 |  57684080 |
| Q30L100  | 150 | 10234799514 |  72478776 |
| Q30L120  | 150 |  7829284286 |  53788182 |
| Q30L140  | 150 |  4971865380 |  33183492 |

## F340: down sampling

```bash
BASE_DIR=$HOME/data/dna-seq/chara/F340
cd ${BASE_DIR}

# works on bash 3
ARRAY=(
    "2_illumina/Q20L100:Q20L100"
    "2_illumina/Q20L120:Q20L120"
    "2_illumina/Q20L140:Q20L140"
    "2_illumina/Q25L100:Q25L100"
    "2_illumina/Q25L120:Q25L120"
    "2_illumina/Q25L140:Q25L140"
    "2_illumina/Q30L100:Q30L100"
    "2_illumina/Q30L120:Q30L120"
    "2_illumina/Q30L140:Q30L140"
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

## F340: generate super-reads

```bash
BASE_DIR=$HOME/data/dna-seq/chara/F340
cd ${BASE_DIR}

perl -e '
    for my $n (
        qw{
        Q20L100 Q20L120 Q20L140
        Q25L100 Q25L120 Q25L140
        Q30L100 Q30L120 Q30L140
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
BASE_DIR=$HOME/data/dna-seq/chara/F340

find . -type f -name "quorum_mer_db.jf"          | xargs rm
find . -type f -name "k_u_hash_0"                | xargs rm
find . -type f -name "readPositionsInSuperReads" | xargs rm
find . -type f -name "*.tmp"                     | xargs rm
find . -type f -name "pe.renamed.fastq"          | xargs rm
find . -type f -name "pe.cor.sub.fa"             | xargs rm
```

## F340: create anchors

```bash
BASE_DIR=$HOME/data/dna-seq/chara/F340
cd ${BASE_DIR}

perl -e '
    for my $n (
        qw{
        Q20L100 Q20L120 Q20L140
        Q25L100 Q25L120 Q25L140
        Q30L100 Q30L120 Q30L140
        }
        )
    {
        printf qq{%s\n}, $n;
    }
    ' \
    | parallel --no-run-if-empty -j 3 "
        echo '==> Group {}'

        if [ -e ${BASE_DIR}/{}/anchor/pe.anchor.fa ]; then
            exit;
        fi

        rm -fr ${BASE_DIR}/{}/anchor
        bash ~/Scripts/cpan/App-Anchr/share/anchor.sh ${BASE_DIR}/{} 8 false
    "

```

## F340: results

* Stats of super-reads

```bash
BASE_DIR=$HOME/data/dna-seq/chara/F340
cd ${BASE_DIR}

REAL_G=100000000

bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 1 header \
    > ${BASE_DIR}/stat1.md

perl -e '
    for my $n (
        qw{
        Q20L100 Q20L120 Q20L140
        Q25L100 Q25L120 Q25L140
        Q30L100 Q30L120 Q30L140
        }
        )
    {
        printf qq{%s\n}, $n;
    }
    ' \
    | parallel -k --no-run-if-empty -j 4 "
        if [ ! -d ${BASE_DIR}/{} ]; then
            exit;
        fi

        bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 1 ${BASE_DIR}/{} ${REAL_G}
    " >> ${BASE_DIR}/stat1.md

cat stat1.md
```

* Stats of anchors

```bash
BASE_DIR=$HOME/data/dna-seq/chara/F340
cd ${BASE_DIR}

bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 header \
    > ${BASE_DIR}/stat2.md

perl -e '
    for my $n (
        qw{
        Q20L100 Q20L120 Q20L140
        Q25L100 Q25L120 Q25L140
        Q30L100 Q30L120 Q30L140
        }
        )
    {
        printf qq{%s\n}, $n;
    }
    ' \
    | parallel -k --no-run-if-empty -j 8 "
        if [ ! -e ${BASE_DIR}/{}/anchor/pe.anchor.fa ]; then
            exit;
        fi

        bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 ${BASE_DIR}/{}
    " >> ${BASE_DIR}/stat2.md

cat stat2.md
```

| Name    |  SumFq | CovFq | AvgRead | Kmer |  SumFa | Discard% | RealG |    EstG | Est/Real |   SumKU | SumSR |   RunTime |
|:--------|-------:|------:|--------:|-----:|-------:|---------:|------:|--------:|---------:|--------:|------:|----------:|
| Q20L100 | 15.51G | 155.1 |     149 |   75 | 11.75G |  24.284% |  100M | 380.21M |     3.80 | 710.77M |     0 | 4:08'59'' |
| Q20L120 | 14.13G | 141.3 |     149 |   75 | 10.76G |  23.868% |  100M | 354.15M |     3.54 | 629.64M |     0 | 5:04'42'' |
| Q20L140 | 12.22G | 122.2 |     149 |   75 |  9.33G |  23.643% |  100M | 320.25M |     3.20 | 533.58M |     0 | 3:12'09'' |
| Q25L100 | 13.16G | 131.6 |     149 |   75 | 10.55G |  19.820% |  100M | 330.43M |     3.30 |  531.4M |     0 | 5:47'41'' |
| Q25L120 | 11.25G | 112.5 |     149 |   75 |  8.98G |  20.195% |  100M | 296.13M |     2.96 | 458.97M |     0 | 4:54'59'' |
| Q25L140 |  8.65G |  86.5 |     149 |   75 |   6.8G |  21.350% |  100M | 248.77M |     2.49 | 371.81M |     0 | 2:36'46'' |
| Q30L100 | 10.23G | 102.3 |     149 |   75 |  8.49G |  17.044% |  100M | 272.05M |     2.72 | 405.73M |     0 | 2:28'14'' |
| Q30L120 |  7.83G |  78.3 |     149 |   75 |  6.36G |  18.774% |  100M | 226.59M |     2.27 |  330.8M |     0 | 1:06'46'' |
| Q30L140 |  4.97G |  49.7 |     149 |   75 |  3.85G |  22.494% |  100M | 166.18M |     1.66 | 235.64M |     0 | 0:41'46'' |

| Name    | N50SRclean |     Sum |       # | N50Anchor |    Sum |     # | N50Anchor2 |   Sum |    # | N50Others |     Sum |       # |   RunTime |
|:--------|-----------:|--------:|--------:|----------:|-------:|------:|-----------:|------:|-----:|----------:|--------:|--------:|----------:|
| Q20L100 |        156 | 710.77M | 4589043 |      3281 | 73.64M | 26257 |       1244 | 2.62M | 2047 |       149 | 634.52M | 4560739 | 3:36'22'' |
| Q20L120 |        172 | 629.64M | 3868127 |      3626 | 72.88M | 24604 |       1248 | 2.53M | 1975 |       150 | 554.23M | 3841548 | 3:00'00'' |
| Q20L140 |        191 | 533.58M | 3063369 |      4510 | 69.31M | 21127 |       1250 | 2.52M | 1950 |       158 | 461.75M | 3040292 | 2:27'20'' |
| Q25L100 |        203 |  531.4M | 2912056 |      4936 | 73.06M | 21473 |       1231 | 2.07M | 1623 |       168 | 456.28M | 2888960 | 1:46'29'' |
| Q25L120 |        213 | 458.97M | 2409411 |      6149 |  67.5M | 18216 |       1239 | 1.97M | 1536 |       175 |  389.5M | 2389659 | 1:29'21'' |
| Q25L140 |        221 | 371.81M | 1884475 |      7485 | 57.85M | 14750 |       1251 | 1.95M | 1516 |       182 | 312.01M | 1868209 | 1:13'58'' |
| Q30L100 |        218 | 405.73M | 2071543 |      8117 | 63.46M | 16133 |       1231 | 1.39M | 1099 |       179 | 340.87M | 2054311 | 1:24'17'' |
| Q30L120 |        221 |  330.8M | 1653211 |      7563 | 56.79M | 14934 |       1242 | 1.47M | 1143 |       179 | 272.54M | 1637134 | 1:03'43'' |
| Q30L140 |        221 | 235.64M | 1157546 |     12470 | 43.73M |  9191 |       1254 | 1.28M |  998 |       176 | 190.63M | 1147357 | 0:26'33'' |

## F340: merge anchors

```bash
BASE_DIR=$HOME/data/dna-seq/chara/F340
cd ${BASE_DIR}

# merge anchors
mkdir -p merge
anchr contained \
    Q20L100/anchor/pe.anchor.fa \
    Q20L120/anchor/pe.anchor.fa \
    Q20L140/anchor/pe.anchor.fa \
    Q25L100/anchor/pe.anchor.fa \
    Q25L120/anchor/pe.anchor.fa \
    Q25L140/anchor/pe.anchor.fa \
    Q30L100/anchor/pe.anchor.fa \
    Q30L120/anchor/pe.anchor.fa \
    Q30L140/anchor/pe.anchor.fa \
    --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
    -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/anchor.contained.fasta
anchr orient merge/anchor.contained.fasta --len 1000 --idt 0.98 -o merge/anchor.orient.fasta
anchr merge merge/anchor.orient.fasta --len 1000 --idt 0.999 -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/anchor.merge.fasta

faops n50 -S -C merge/anchor.merge.fasta

# merge anchor2 and others
anchr contained \
    Q20L100/anchor/pe.anchor2.fa \
    Q20L120/anchor/pe.anchor2.fa \
    Q20L140/anchor/pe.anchor2.fa \
    Q25L100/anchor/pe.anchor2.fa \
    Q25L120/anchor/pe.anchor2.fa \
    Q25L140/anchor/pe.anchor2.fa \
    Q30L100/anchor/pe.anchor2.fa \
    Q30L120/anchor/pe.anchor2.fa \
    Q30L140/anchor/pe.anchor2.fa \
    Q20L100/anchor/pe.others.fa \
    Q20L120/anchor/pe.others.fa \
    Q20L140/anchor/pe.others.fa \
    Q25L100/anchor/pe.others.fa \
    Q25L120/anchor/pe.others.fa \
    Q25L140/anchor/pe.others.fa \
    Q30L100/anchor/pe.others.fa \
    Q30L120/anchor/pe.others.fa \
    Q30L140/anchor/pe.others.fa \
    --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
    -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/others.contained.fasta
anchr orient merge/others.contained.fasta --len 1000 --idt 0.98 -o merge/others.orient.fasta
anchr merge merge/others.orient.fasta --len 1000 --idt 0.999 -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/others.merge.fasta
    
faops n50 -S -C merge/others.merge.fasta

# quast
rm -fr 9_qa
quast --no-check --threads 16 \
    Q20L100/anchor/pe.anchor.fa \
    Q25L100/anchor/pe.anchor.fa \
    Q30L100/anchor/pe.anchor.fa \
    merge/anchor.merge.fasta \
    merge/others.merge.fasta \
    --label "Q20L100,Q25L100,Q30L100,merge,others" \
    -o 9_qa

```

* Clear QxxLxxx.

```bash
BASE_DIR=$HOME/data/dna-seq/chara/F340
cd ${BASE_DIR}

rm -fr 2_illumina/Q{20,25,30}L*
rm -fr Q{20,25,30}L*
```

* Stats

```bash
BASE_DIR=$HOME/data/dna-seq/chara/F340
cd ${BASE_DIR}

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

| Name         |  N50 |      Sum |     # |
|:-------------|-----:|---------:|------:|
| anchor.merge | 6513 | 88082921 | 23640 |
| others.merge | 1148 | 15051593 | 12632 |

# F354, Spirogyra gracilis, 纤细水绵

转录本杂合度 0.35%

## F354: download

```bash
mkdir -p ~/data/dna-seq/chara/F354/2_illumina
cd ~/data/dna-seq/chara/F354/2_illumina

ln -s ~/data/dna-seq/chara/clean_data/F354_HF5KMALXX_L7_1.clean.fq.gz R1.fq.gz
ln -s ~/data/dna-seq/chara/clean_data/F354_HF5KMALXX_L7_2.clean.fq.gz R2.fq.gz

```

## F354: template

```bash
WORKING_DIR=${HOME}/data/dna-seq/chara
BASE_NAME=F354

cd ${WORKING_DIR}/${BASE_NAME}

rm -f *.sh
anchr template \
    . \
    --basename ${BASE_NAME} \
    --queue mpi \
    --genome 100000000 \
    --fastqc \
    --kmergenie \
    --insertsize \
    --sgapreqc \
    --sgastats \
    --trim2 "--dedupe --tile" \
    --qual2 "25" \
    --len2 "60" \
    --filter "adapter,phix,artifact" \
    --mergereads \
    --ecphase "1,2,3" \
    --cov2 "40 80" \
    --tadpole \
    --splitp 100 \
    --statp 10 \
    --fillanchor \
    --parallel 24

```

## F354: run

```bash
WORKING_DIR=${HOME}/data/dna-seq/chara
BASE_NAME=F354

cd ${WORKING_DIR}/${BASE_NAME}
#rm -fr 4_*/ 6_*/ 7_*/ 8_*/ && rm -fr 2_illumina/trim 2_illumina/mergereads statReads.md 

bash 0_bsub.sh
#bash 0_master.sh

#bash 0_cleanup.sh

```

Table: statInsertSize

| Group           |  Mean | Median | STDev | PercentOfPairs/PairOrientation |
|:----------------|------:|-------:|------:|-------------------------------:|
| tadpole.bbtools | 308.9 |    306 |  58.3 |                         45.43% |
| tadpole.picard  | 308.5 |    305 |  58.1 |                             FR |


Table: statSgaStats

| Item           |  Value |
|:---------------|-------:|
| incorrectBases |  0.26% |
| perfectReads   | 83.44% |
| overlapDepth   | 859.95 |


Table: statReads

| Name     | N50 |    Sum |         # |
|:---------|----:|-------:|----------:|
| Illumina | 150 | 18.46G | 123057622 |
| trim     | 150 | 15.71G | 108733500 |
| Q25L60   | 150 | 14.82G | 103985592 |


Table: statTrimReads

| Name           | N50 |    Sum |         # |
|:---------------|----:|-------:|----------:|
| clumpify       | 150 | 17.58G | 117200712 |
| filteredbytile | 150 | 16.58G | 110552600 |
| trim           | 150 | 15.71G | 108734450 |
| filter         | 150 | 15.71G | 108733500 |
| R1             | 150 |  8.06G |  54366750 |
| R2             | 150 |  7.66G |  54366750 |
| Rs             |   0 |      0 |         0 |


```text
#trim
#Matched	136905	0.12384%
#Name	Reads	ReadsPct
I5_Primer_Nextera_XT_and_Nextera_Enrichment_[N/S/E]501	21731	0.01966%
I5_Nextera_Transposase_1	21653	0.01959%
I5_Adapter_Nextera	13386	0.01211%
TruSeq_Universal_Adapter	9583	0.00867%
I7_Primer_Nextera_XT_and_Nextera_Enrichment_N701	9158	0.00828%
I5_Nextera_Transposase_2	9104	0.00823%
I7_Nextera_Transposase_2	7340	0.00664%
RNA_Adapter_(RA5)_part_#_15013205	5806	0.00525%
I7_Adapter_Nextera_No_Barcode	5373	0.00486%
Reverse_adapter	4854	0.00439%
PhiX_read2_adapter	4425	0.00400%
I7_Nextera_Transposase_1	2865	0.00259%
PhiX_read1_adapter	2212	0.00200%
RNA_PCR_Primer_Index_1_(RPI1)_2,9	2170	0.00196%
I5_Primer_Nextera_XT_Index_Kit_v2_S510	2009	0.00182%
I5_Primer_Nextera_XT_and_Nextera_Enrichment_[N/S/E]502	1809	0.00164%
RNA_PCR_Primer_(RP1)_part_#_15013198	1219	0.00110%
TruSeq_Adapter_Index_1_6	1129	0.00102%
```

```text
#filter
#Matched	475	0.00044%
#Name	Reads	ReadsPct
TruSeq_Universal_Adapter	191	0.00018%
PhiX_read2_adapter	105	0.00010%
```


Table: statMergeReads

| Name          | N50 |     Sum |         # |
|:--------------|----:|--------:|----------:|
| clumped       | 150 |  15.71G | 108702328 |
| ecco          | 150 |  15.71G | 108702328 |
| eccc          | 150 |  15.71G | 108702328 |
| ecct          | 150 |  15.27G | 105499162 |
| extended      | 190 |  19.46G | 105499162 |
| merged        | 355 |   17.9G |  51283407 |
| unmerged.raw  | 186 | 487.57M |   2932348 |
| unmerged.trim | 186 | 487.56M |   2932292 |
| U1            | 190 | 265.65M |   1466146 |
| U2            | 170 | 221.92M |   1466146 |
| Us            |   0 |       0 |         0 |
| pe.cor        | 353 |  18.44G | 105499106 |

| Group            |  Mean | Median | STDev | PercentOfPairs |
|:-----------------|------:|-------:|------:|---------------:|
| ihist.merge1.txt | 249.2 |    254 |  27.2 |         26.65% |
| ihist.merge.txt  | 349.1 |    347 |  54.2 |         97.22% |


Table: statQuorum

| Name   | CovIn | CovOut | Discard% | AvgRead | Kmer | RealG |    EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|-----:|------:|--------:|---------:|----------:|
| Q0L0   | 157.1 |  133.3 |   15.16% |     144 | "49" |  100M | 111.37M |     1.11 | 0:25'46'' |
| Q25L60 | 148.3 |  132.3 |   10.75% |     142 | "49" |  100M | 108.52M |     1.09 | 0:24'13'' |


Table: statKunitigsAnchors.md

| Name          | CovCor | Mapped% | N50Anchor |    Sum |    # | N50Others |    Sum |     # | median |  MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|-------:|--------:|----------:|-------:|-----:|----------:|-------:|------:|-------:|-----:|------:|------:|--------------------:|----------:|----------:|
| Q0L0X40P000   |   40.0 |  85.58% |     24586 | 43.98M | 4618 |      3451 | 13.73M |  7730 |   51.0 | 46.0 |   3.0 | 102.0 | "31,41,51,61,71,81" | 0:23'16'' | 0:07'10'' |
| Q0L0X40P001   |   40.0 |  85.72% |     24878 | 43.93M | 4599 |      3459 | 13.78M |  7676 |   51.0 | 46.0 |   3.0 | 102.0 | "31,41,51,61,71,81" | 0:23'12'' | 0:07'17'' |
| Q0L0X40P002   |   40.0 |  85.72% |     24771 | 43.99M | 4665 |      3380 |  13.8M |  7810 |   51.0 | 46.0 |   3.0 | 102.0 | "31,41,51,61,71,81" | 0:23'19'' | 0:07'06'' |
| Q0L0X80P000   |   80.0 |  75.14% |     11375 |  50.7M | 8981 |      1639 | 14.17M | 13980 |   92.0 | 88.0 |   3.0 | 184.0 | "31,41,51,61,71,81" | 0:39'03'' | 0:08'13'' |
| Q25L60X40P000 |   40.0 |  89.42% |     45722 |  43.9M | 3391 |      6521 | 14.52M |  6166 |   51.0 | 47.0 |   3.0 | 102.0 | "31,41,51,61,71,81" | 0:24'11'' | 0:07'29'' |
| Q25L60X40P001 |   40.0 |  89.34% |     45200 | 43.94M | 3433 |      6635 | 14.47M |  6093 |   51.0 | 46.0 |   3.0 | 102.0 | "31,41,51,61,71,81" | 0:23'43'' | 0:07'30'' |
| Q25L60X40P002 |   40.0 |  89.47% |     45156 | 43.94M | 3455 |      6603 | 14.55M |  6142 |   51.0 | 46.0 |   3.0 | 102.0 | "31,41,51,61,71,81" | 0:23'35'' | 0:07'47'' |
| Q25L60X80P000 |   80.0 |  85.85% |     19928 | 51.55M | 6850 |      2736 | 16.67M | 13237 |   96.0 | 92.0 |   3.0 | 192.0 | "31,41,51,61,71,81" | 0:39'25'' | 0:08'47'' |


Table: statTadpoleAnchors.md

| Name          | CovCor | Mapped% | N50Anchor |    Sum |    # | N50Others |    Sum |    # | median |   MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|-------:|--------:|----------:|-------:|-----:|----------:|-------:|-----:|-------:|------:|------:|------:|--------------------:|----------:|----------:|
| Q0L0X40P000   |   40.0 |  95.63% |    138904 | 43.02M | 2141 |     29710 | 16.39M | 3081 |   53.0 |  47.0 |   3.0 | 106.0 | "31,41,51,61,71,81" | 0:15'37'' | 0:08'35'' |
| Q0L0X40P001   |   40.0 |  95.57% |    134982 | 42.91M | 2070 |     28994 | 16.05M | 2838 |   53.0 |  47.0 |   3.0 | 106.0 | "31,41,51,61,71,81" | 0:15'38'' | 0:08'22'' |
| Q0L0X40P002   |   40.0 |  95.58% |    137899 | 42.92M | 2074 |     28593 | 16.14M | 2948 |   53.0 |  47.0 |   3.0 | 106.0 | "31,41,51,61,71,81" | 0:15'19'' | 0:08'28'' |
| Q0L0X80P000   |   80.0 |  96.45% |     62480 | 49.83M | 4457 |     25292 | 18.98M | 6175 |  108.0 | 100.0 |   3.0 | 216.0 | "31,41,51,61,71,81" | 0:21'06'' | 0:10'44'' |
| Q25L60X40P000 |   40.0 |  95.80% |    147135 | 42.82M | 2006 |     39065 |  15.7M | 2626 |   53.0 |  47.0 |   3.0 | 106.0 | "31,41,51,61,71,81" | 0:16'25'' | 0:08'19'' |
| Q25L60X40P001 |   40.0 |  95.74% |    145437 |  42.8M | 1952 |     36714 | 15.28M | 2584 |   53.0 |  47.0 |   3.0 | 106.0 | "31,41,51,61,71,81" | 0:16'27'' | 0:08'19'' |
| Q25L60X40P002 |   40.0 |  95.82% |    144258 | 42.84M | 1996 |     41691 |  15.5M | 2647 |   53.0 |  47.0 |   3.0 | 106.0 | "31,41,51,61,71,81" | 0:16'33'' | 0:08'37'' |
| Q25L60X80P000 |   80.0 |  96.72% |     89438 | 49.47M | 4188 |     32134 | 18.91M | 5798 |  107.0 |  99.0 |   3.0 | 214.0 | "31,41,51,61,71,81" | 0:22'04'' | 0:10'39'' |


Table: statMRKunitigsAnchors.md

| Name      | CovCor | Mapped% | N50Anchor |    Sum |    # | N50Others |    Sum |    # | median |  MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:----------|-------:|--------:|----------:|-------:|-----:|----------:|-------:|-----:|-------:|-----:|------:|------:|--------------------:|----------:|----------:|
| MRX40P000 |   40.0 |  94.36% |    131395 | 45.68M | 3120 |     36094 | 15.45M | 5595 |   53.0 | 49.0 |   3.0 | 106.0 | "31,41,51,61,71,81" | 0:34'51'' | 0:07'53'' |
| MRX40P001 |   40.0 |  94.47% |    127578 | 45.63M | 3056 |     33396 |  15.3M | 5596 |   53.0 | 49.0 |   3.0 | 106.0 | "31,41,51,61,71,81" | 0:34'40'' | 0:07'45'' |
| MRX40P002 |   40.0 |  94.41% |    132882 | 45.72M | 3092 |     33396 | 15.12M | 5557 |   53.0 | 49.0 |   3.0 | 106.0 | "31,41,51,61,71,81" | 0:34'59'' | 0:07'46'' |
| MRX40P003 |   40.0 |  94.26% |    128009 | 45.66M | 3173 |     32001 |  15.3M | 5788 |   53.0 | 49.0 |   3.0 | 106.0 | "31,41,51,61,71,81" | 0:34'42'' | 0:07'36'' |
| MRX80P000 |   80.0 |  94.18% |    103223 | 50.06M | 3145 |     29787 | 16.95M | 6623 |  103.0 | 99.0 |   3.0 | 206.0 | "31,41,51,61,71,81" | 0:55'50'' | 0:09'48'' |
| MRX80P001 |   80.0 |  93.92% |     96856 | 49.92M | 3058 |     32876 | 16.82M | 6609 |  102.0 | 98.0 |   3.0 | 204.0 | "31,41,51,61,71,81" | 0:55'45'' | 0:09'21'' |


Table: statMRTadpoleAnchors.md

| Name      | CovCor | Mapped% | N50Anchor |    Sum |    # | N50Others |    Sum |    # | median |  MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:----------|-------:|--------:|----------:|-------:|-----:|----------:|-------:|-----:|-------:|-----:|------:|------:|--------------------:|----------:|----------:|
| MRX40P000 |   40.0 |  95.79% |    166431 | 45.39M | 2974 |     47979 | 14.68M | 5380 |   53.0 | 49.0 |   3.0 | 106.0 | "31,41,51,61,71,81" | 0:21'43'' | 0:07'46'' |
| MRX40P001 |   40.0 |  95.79% |    160933 | 45.34M | 2924 |     46811 | 14.87M | 5434 |   53.0 | 49.0 |   3.0 | 106.0 | "31,41,51,61,71,81" | 0:21'27'' | 0:07'55'' |
| MRX40P002 |   40.0 |  95.78% |    163237 | 45.85M | 3192 |     47677 | 14.37M | 5620 |   54.0 | 49.0 |   3.0 | 108.0 | "31,41,51,61,71,81" | 0:21'44'' | 0:07'53'' |
| MRX40P003 |   40.0 |  95.77% |    160933 | 45.82M | 3241 |     46708 | 14.39M | 5798 |   54.0 | 50.0 |   3.0 | 108.0 | "31,41,51,61,71,81" | 0:21'32'' | 0:07'33'' |
| MRX80P000 |   80.0 |  96.15% |    126780 | 49.78M | 3020 |     51168 | 15.72M | 6061 |  103.0 | 98.0 |   3.0 | 206.0 | "31,41,51,61,71,81" | 0:27'01'' | 0:09'35'' |
| MRX80P001 |   80.0 |  96.15% |    127601 | 49.81M | 3019 |     51295 | 15.85M | 6076 |  103.0 | 98.0 |   3.0 | 206.0 | "31,41,51,61,71,81" | 0:27'04'' | 0:09'25'' |


Table: statMergeAnchors.md

| Name                     | Mapped% | N50Anchor |    Sum |    # | N50Others |    Sum |     # | median | MAD | lower | upper | RunTimeAN |
|:-------------------------|--------:|----------:|-------:|-----:|----------:|-------:|------:|-------:|----:|------:|------:|----------:|
| 7_mergeAnchors           |   0.00% |    160114 | 60.82M | 8811 |     17656 | 32.92M | 10554 |    0.0 | 0.0 |   0.0 |   0.0 |           |
| 7_mergeKunitigsAnchors   |   0.00% |    124907 | 55.76M | 6782 |      7768 | 33.11M |  9645 |    0.0 | 0.0 |   0.0 |   0.0 |           |
| 7_mergeMRKunitigsAnchors |   0.00% |    133740 | 54.49M | 5362 |     29598 | 24.99M |  6067 |    0.0 | 0.0 |   0.0 |   0.0 |           |
| 7_mergeMRTadpoleAnchors  |   0.00% |    144249 | 54.12M | 5222 |     33987 | 21.66M |  4517 |    0.0 | 0.0 |   0.0 |   0.0 |           |
| 7_mergeTadpoleAnchors    |   0.00% |    158059 | 52.99M | 5271 |     46347 | 23.76M |  2372 |    0.0 | 0.0 |   0.0 |   0.0 |           |


Table: statOtherAnchors.md

| Name         | Mapped% | N50Anchor |    Sum |    # | N50Others |    Sum |     # | median |  MAD | lower | upper | RunTimeAN |
|:-------------|--------:|----------:|-------:|-----:|----------:|-------:|------:|-------:|-----:|------:|------:|----------:|
| 8_spades     |  82.12% |    402431 | 17.48M | 2034 |     21898 | 92.76M | 13904 |   32.0 | 29.0 |   3.0 |  64.0 | 0:11'22'' |
| 8_spades_MR  |  81.26% |    571868 | 49.44M | 1963 |      4811 | 28.08M | 11616 |   86.0 | 83.0 |   3.0 | 172.0 | 0:11'43'' |
| 8_megahit    |  81.65% |    204681 | 17.09M | 1945 |     32071 |  86.5M | 17325 |   38.0 | 35.0 |   3.0 |  76.0 | 0:10'53'' |
| 8_megahit_MR |  81.20% |    317725 | 49.07M | 2016 |     47319 | 25.99M | 10487 |   88.0 | 85.0 |   3.0 | 176.0 | 0:11'01'' |
| 8_platanus   |  74.25% |   1082738 | 30.82M |  697 |    135740 |  9.52M |   716 |  106.0 | 88.5 |   3.0 | 212.0 | 0:08'31'' |


Table: statFinal

| Name                     |    N50 |       Sum |     # |
|:-------------------------|-------:|----------:|------:|
| 7_mergeAnchors.anchors   | 160114 |  60823152 |  8811 |
| 7_mergeAnchors.others    |  17656 |  32917874 | 10554 |
| anchorLong               | 246570 |  59618135 |  6922 |
| anchorFill               | 402439 |  60627368 |  4701 |
| spades.contig            |  23438 | 124044323 | 55564 |
| spades.scaffold          |  23773 | 124054017 | 55354 |
| spades.non-contained     | 113876 | 110237922 | 12056 |
| spades_MR.contig         | 281882 |  86836887 | 26093 |
| spades_MR.scaffold       | 294091 |  86867186 | 25842 |
| spades_MR.non-contained  | 359378 |  77521293 | 10271 |
| megahit.contig           |  35457 | 113508820 | 34930 |
| megahit.non-contained    |  67406 | 103591216 | 15731 |
| megahit_MR.contig        | 112324 |  95515328 | 46609 |
| megahit_MR.non-contained | 224743 |  75061532 |  9407 |
| platanus.contig          | 305927 |  47075492 |  4709 |
| platanus.scaffold        | 998620 |  40425985 |   634 |
| platanus.non-contained   | 998620 |  40340652 |   166 |

cd ${HOME}/data/dna-seq/chara/${BASE_NAME}

mkdir -p 2_illumina/fastqc
cd 2_illumina/fastqc

fastqc -t 16 \
    ../R1.fq.gz ../R2.fq.gz \
    -o .

```

## F354: combinations of different quality values and read lengths

* qual: 20, 25, and 30
* len: 60

```bash
BASE_NAME=F354
cd ${HOME}/data/dna-seq/chara/${BASE_NAME}

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
    " ::: 20 25 30 ::: 60

```

* Stats

```bash
BASE_NAME=F354
cd ${HOME}/data/dna-seq/chara/${BASE_NAME}

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
    " ::: 20 25 30 ::: 60 \
    >> stat.md

cat stat.md
```

| Name     | N50 |         Sum |         # |
|:---------|----:|------------:|----------:|
| Illumina | 150 | 18458643300 | 123057622 |
| uniq     | 150 | 17588350800 | 117255672 |
| Q20L60   | 150 | 16508279648 | 113781146 |
| Q25L60   | 150 | 15292880812 | 107713284 |
| Q30L60   | 150 | 14407270028 | 105170796 |

## F354: quorum

```bash
BASE_NAME=F354
cd ${HOME}/data/dna-seq/chara/${BASE_NAME}

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
    " ::: 20 25 30 ::: 60

```

Clear intermediate files.

```bash
BASE_NAME=F354
cd ${HOME}/data/dna-seq/chara/${BASE_NAME}

find 2_illumina -type f -name "quorum_mer_db.jf" | xargs rm
find 2_illumina -type f -name "k_u_hash_0"       | xargs rm
find 2_illumina -type f -name "*.tmp"            | xargs rm
find 2_illumina -type f -name "pe.renamed.fastq" | xargs rm
find 2_illumina -type f -name "se.renamed.fastq" | xargs rm
find 2_illumina -type f -name "pe.cor.sub.fa"    | xargs rm
```

* Stats of processed reads

```bash
BASE_NAME=F354
cd ${HOME}/data/dna-seq/chara/${BASE_NAME}

REAL_G=100000000

bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 1 header \
    > stat1.md

parallel -k --no-run-if-empty -j 3 "
    if [ ! -d 2_illumina/Q{1}L{2} ]; then
        exit;
    fi

    bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 1 2_illumina/Q{1}L{2} ${REAL_G}
    " ::: 20 25 30 ::: 60 \
     >> stat1.md

cat stat1.md
```

| Name   |  SumIn | CovIn | SumOut | CovOut | Discard% | AvgRead | Kmer | RealG |    EstG | Est/Real |   RunTime |
|:-------|-------:|------:|-------:|-------:|---------:|--------:|-----:|------:|--------:|---------:|----------:|
| Q20L60 | 16.51G | 165.1 | 13.45G |  134.5 |  18.523% |     146 | "49" |  100M |  113.2M |     1.13 | 0:44'42'' |
| Q25L60 | 15.29G | 152.9 | 13.35G |  133.5 |  12.724% |     144 | "49" |  100M | 109.46M |     1.09 | 0:40'45'' |
| Q30L60 | 14.41G | 144.1 | 13.16G |  131.6 |   8.669% |     141 | "49" |  100M | 107.09M |     1.07 | 0:37'42'' |

* kmergenie

```bash
BASE_NAME=F354
cd ${HOME}/data/dna-seq/chara/${BASE_NAME}

mkdir -p 2_illumina/kmergenie
cd 2_illumina/kmergenie

kmergenie -l 21 -k 121 -s 10 -t 8 ../R1.fq.gz -o oriR1
kmergenie -l 21 -k 121 -s 10 -t 8 ../R2.fq.gz -o oriR2
kmergenie -l 21 -k 121 -s 10 -t 8 ../Q20L60/pe.cor.fa -o Q20L60

```

## F354: down sampling

```bash
BASE_NAME=F354
cd ${HOME}/data/dna-seq/chara/${BASE_NAME}

REAL_G=100000000

for QxxLxx in $( parallel "echo 'Q{1}L{2}'" ::: 20 25 30 ::: 60 ); do
    echo "==> ${QxxLxx}"

    if [ ! -e 2_illumina/${QxxLxx}/pe.cor.fa ]; then
        echo "2_illumina/${QxxLxx}/pe.cor.fa not exists"
        continue;
    fi

    for X in 40 80 120; do
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

## F354: k-unitigs and anchors (sampled)

```bash
BASE_NAME=F354
cd ${HOME}/data/dna-seq/chara/${BASE_NAME}

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
    " ::: 20 25 30 ::: 60 ::: 40 80 120 ::: 000 001 002 003 004 005 006

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
        ../k_unitigs.fasta \
        ../pe.cor.fa \
        -p 8 \
        -o anchors.sh
    bash anchors.sh
    
    echo >&2
    " ::: 20 25 30 ::: 60 ::: 40 80 120 ::: 000 001 002 003 004 005 006

# Stats of anchors
REAL_G=100000000

bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 header \
    > stat2.md

parallel -k --no-run-if-empty -j 6 "
    if [ ! -e Q{1}L{2}X{3}P{4}/anchor/pe.anchor.fa ]; then
        exit;
    fi

    bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 Q{1}L{2}X{3}P{4} ${REAL_G}
    " ::: 20 25 30 ::: 60 ::: 40 80 120 ::: 000 001 002 003 004 005 006 \
     >> stat2.md

cat stat2.md
```

| Name           | SumCor | CovCor | N50SR |    Sum |     # | N50Anchor |    Sum |     # | N50Others |    Sum |     # |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|-------:|------:|-------:|------:|----------:|-------:|------:|----------:|-------:|------:|--------------------:|----------:|:----------|
| Q20L60X40P000  |     4G |   40.0 | 10423 | 63.51M | 19761 |     12919 | 56.61M |  9839 |       692 |   6.9M |  9922 | "31,41,51,61,71,81" | 0:51'46'' | 0:10'16'' |
| Q20L60X40P001  |     4G |   40.0 |  7772 | 63.04M | 22023 |      9944 | 55.59M | 11239 |       696 |  7.45M | 10784 | "31,41,51,61,71,81" | 0:49'57'' | 0:11'17'' |
| Q20L60X40P002  |     4G |   40.0 |  6187 |  62.6M | 24363 |      8172 | 54.22M | 12234 |       698 |  8.38M | 12129 | "31,41,51,61,71,81" | 0:48'57'' | 0:09'33'' |
| Q20L60X80P000  |     8G |   80.0 |  3006 | 80.73M | 46312 |      5782 | 60.12M | 17165 |       718 | 20.61M | 29147 | "31,41,51,61,71,81" | 1:18'09'' | 0:17'07'' |
| Q20L60X120P000 |    12G |  120.0 |  2188 | 92.49M | 56307 |      3294 | 69.65M | 24587 |       737 | 22.83M | 31720 | "31,41,51,61,71,81" | 1:24'30'' | 0:21'31'' |
| Q25L60X40P000  |     4G |   40.0 | 23694 | 63.54M | 14420 |     27919 | 58.09M |  6374 |       670 |  5.44M |  8046 | "31,41,51,61,71,81" | 0:37'14'' | 0:11'00'' |
| Q25L60X40P001  |     4G |   40.0 | 17835 | 63.38M | 15659 |     21386 | 57.82M |  7487 |       676 |  5.55M |  8172 | "31,41,51,61,71,81" | 0:36'44'' | 0:10'54'' |
| Q25L60X40P002  |     4G |   40.0 | 14118 | 63.34M | 17010 |     17384 | 57.46M |  8338 |       675 |  5.88M |  8672 | "31,41,51,61,71,81" | 0:36'11'' | 0:10'31'' |
| Q25L60X80P000  |     8G |   80.0 |  6370 | 82.59M | 37350 |     10863 | 66.02M | 13906 |       718 | 16.57M | 23444 | "31,41,51,61,71,81" | 1:00'50'' | 0:18'56'' |
| Q25L60X120P000 |    12G |  120.0 |  3273 |  96.3M | 47042 |      5259 | 78.49M | 22447 |       745 | 17.81M | 24595 | "31,41,51,61,71,81" | 1:27'09'' | 0:26'43'' |
| Q30L60X40P000  |     4G |   40.0 | 53402 | 63.25M | 11350 |     61600 | 58.24M |  3939 |       667 |  5.01M |  7411 | "31,41,51,61,71,81" | 0:39'30'' | 0:10'39'' |
| Q30L60X40P001  |     4G |   40.0 | 45319 | 63.08M | 11631 |     52302 | 58.18M |  4364 |       664 |   4.9M |  7267 | "31,41,51,61,71,81" | 0:38'47'' | 0:11'13'' |
| Q30L60X40P002  |     4G |   40.0 | 35830 | 63.04M | 12204 |     42326 | 58.03M |  4750 |       662 |  5.01M |  7454 | "31,41,51,61,71,81" | 0:38'02'' | 0:11'04'' |
| Q30L60X80P000  |     8G |   80.0 | 17227 | 81.93M | 29545 |     25548 | 67.69M |  9187 |       710 | 14.25M | 20358 | "31,41,51,61,71,81" | 1:03'06'' | 0:20'01'' |
| Q30L60X120P000 |    12G |  120.0 |  8048 | 95.56M | 36821 |     13460 | 81.26M | 16916 |       738 |  14.3M | 19905 | "31,41,51,61,71,81" | 1:29'01'' | 0:29'59'' |

## F354: merge anchors

```bash
BASE_NAME=F354
cd ${HOME}/data/dna-seq/chara/${BASE_NAME}

# merge anchors
mkdir -p merge
anchr contained \
    $(
        parallel -k --no-run-if-empty -j 6 "
            if [ -e Q{1}L{2}X{3}P{4}/anchor/pe.anchor.fa ]; then
                echo Q{1}L{2}X{3}P{4}/anchor/pe.anchor.fa
            fi
            " ::: 20 25 30 ::: 60 ::: 40 80 120 ::: 000 001 002 003 004 005 006
    ) \
    --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
    -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/anchor.contained.fasta
anchr orient merge/anchor.contained.fasta --len 1000 --idt 0.98 -o merge/anchor.orient.fasta
anchr merge merge/anchor.orient.fasta --len 1000 --idt 0.999 -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/anchor.merge.fasta

# merge others
mkdir -p merge
anchr contained \
    $(
        parallel -k --no-run-if-empty -j 6 "
            if [ -e Q{1}L{2}X{3}P{4}/anchor/pe.others.fa ]; then
                echo Q{1}L{2}X{3}P{4}/anchor/pe.others.fa
            fi
            " ::: 20 25 30 ::: 60 ::: 40 80 120 ::: 000 001 002 003 004 005 006
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
BASE_NAME=F354
cd ${HOME}/data/dna-seq/chara/${BASE_NAME}

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

| Name         |   N50 |      Sum |     # |
|:-------------|------:|---------:|------:|
| anchor.merge | 87164 | 87521663 | 14322 |
| others.merge |  1052 |  6809332 |  6041 |

* Clear QxxLxxXxx.

```bash
BASE_NAME=F354
cd ${HOME}/data/dna-seq/chara/${BASE_NAME}

rm -fr 2_illumina/Q{20,25,30,35}L{1,60,90,120}X*
rm -fr Q{20,25,30,35}L{1,60,90,120}X*
```

# F357, Botryococcus braunii, 布朗葡萄藻

## F357: download

```bash
mkdir -p ~/data/dna-seq/chara/F357/2_illumina
cd ~/data/dna-seq/chara/F357/2_illumina

ln -s ~/data/dna-seq/chara/clean_data/F357_HF5WLALXX_L7_1.clean.fq.gz R1.fq.gz
ln -s ~/data/dna-seq/chara/clean_data/F357_HF5WLALXX_L7_2.clean.fq.gz R2.fq.gz
```

* FastQC

```bash
BASE_NAME=F357
cd ${HOME}/data/dna-seq/chara/${BASE_NAME}

mkdir -p 2_illumina/fastqc
cd 2_illumina/fastqc

fastqc -t 16 \
    ../R1.fq.gz ../R2.fq.gz \
    -o .

```

| Name   |  SumFq | CovFq | AvgRead |               Kmer |  SumFa | Discard% | RealG |    EstG | Est/Real |   SumKU | SumSR |   RunTime |
|:-------|-------:|------:|--------:|-------------------:|-------:|---------:|------:|--------:|---------:|--------:|------:|----------:|
| Q20L60 | 19.55G | 195.5 |     149 | "41,61,81,101,121" | 15.67G |  19.870% |  100M | 275.51M |     2.76 | 195.53M |     0 | 3:07'15'' |
| Q20L90 | 19.17G | 191.7 |     149 | "41,61,81,101,121" | 15.43G |  19.502% |  100M | 270.66M |     2.71 | 193.14M |     0 | 3:20'02'' |
| Q25L60 | 17.98G | 179.8 |     149 | "41,61,81,101,121" | 15.46G |  14.005% |  100M |    261M |     2.61 |  196.8M |     0 | 2:43'23'' |
| Q25L90 | 17.24G | 172.4 |     149 | "41,61,81,101,121" | 14.89G |  13.660% |  100M | 253.82M |     2.54 |  192.4M |     0 | 3:29'14'' |
| Q30L60 | 15.71G | 157.1 |     149 | "41,61,81,101,121" | 15.31G |   2.512% |  100M | 254.23M |     2.54 | 198.15M |     0 | 2:47'40'' |
| Q30L90 | 14.51G | 145.1 |     149 | "41,61,81,101,121" | 14.82G |  -2.129% |  100M | 250.37M |     2.50 | 195.38M |     0 | 2:32'54'' |

| Name   | N50SR |     Sum |      # | N50Anchor |     Sum |     # | N50Others |    Sum |     # |   RunTime |
|:-------|------:|--------:|-------:|----------:|--------:|------:|----------:|-------:|------:|----------:|
| Q20L60 |  2280 | 195.53M | 119839 |     10491 | 135.72M | 35446 |       720 | 59.81M | 84393 | 0:52'02'' |
| Q20L90 |  2353 | 193.14M | 117189 |     11146 | 134.66M | 34591 |       719 | 58.48M | 82598 | 0:44'33'' |
| Q25L60 |  2877 |  196.8M | 113928 |     19286 | 139.78M | 32851 |       715 | 57.03M | 81077 | 1:02'17'' |
| Q25L90 |  3228 |  192.4M | 109483 |     21923 | 137.29M | 31163 |       715 | 55.11M | 78320 | 0:57'59'' |
| Q30L60 |  4859 | 198.15M | 106173 |     34781 | 144.88M | 30546 |       715 | 53.27M | 75627 | 1:08'00'' |
| Q30L90 |  5520 | 195.38M | 103655 |     37445 | 143.15M | 29457 |       714 | 52.23M | 74198 | 1:03'25'' |

| Name         |   N50 |       Sum |     # |
|:-------------|------:|----------:|------:|
| anchor.merge | 28436 | 158392737 | 36505 |
| others.merge |  1048 |   9455311 |  8593 |

## F357: combinations of different quality values and read lengths

* qual: 20, 25, and 30
* len: 60

```bash
BASE_NAME=F357
cd ${HOME}/data/dna-seq/chara/${BASE_NAME}

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
    " ::: 20 25 30 ::: 60


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
    " ::: 20 25 30 ::: 60 \
    >> stat.md

cat stat.md
```

| Name     | N50 |         Sum |         # |
|:---------|----:|------------:|----------:|
| Illumina | 150 | 22137245100 | 147581634 |
| uniq     | 150 | 20893186500 | 139287910 |
| Q20L60   | 150 | 19561412778 | 134496436 |
| Q25L60   | 150 | 17989247636 | 126870988 |
| Q30L60   | 150 | 16883227711 | 124260644 |

## F357: quorum

```bash
BASE_NAME=F357
cd ${HOME}/data/dna-seq/chara/${BASE_NAME}

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
    " ::: 20 25 30 ::: 60

```

Clear intermediate files.

```bash
BASE_NAME=F357
cd ${HOME}/data/dna-seq/chara/${BASE_NAME}

find 2_illumina -type f -name "quorum_mer_db.jf" | xargs rm
find 2_illumina -type f -name "k_u_hash_0"       | xargs rm
find 2_illumina -type f -name "*.tmp"            | xargs rm
find 2_illumina -type f -name "pe.renamed.fastq" | xargs rm
find 2_illumina -type f -name "se.renamed.fastq" | xargs rm
find 2_illumina -type f -name "pe.cor.sub.fa"    | xargs rm
```

* Stats of processed reads

```bash
BASE_NAME=F357
cd ${HOME}/data/dna-seq/chara/${BASE_NAME}

REAL_G=100000000

bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 1 header \
    > stat1.md

parallel -k --no-run-if-empty -j 3 "
    if [ ! -d 2_illumina/Q{1}L{2} ]; then
        exit;
    fi

    bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 1 2_illumina/Q{1}L{2} ${REAL_G}
    " ::: 20 25 30 ::: 60 \
     >> stat1.md

cat stat1.md
```

| Name   |  SumIn | CovIn | SumOut | CovOut | Discard% | AvgRead | Kmer | RealG |    EstG | Est/Real |   RunTime |
|:-------|-------:|------:|-------:|-------:|---------:|--------:|-----:|------:|--------:|---------:|----------:|
| Q20L60 | 19.56G | 195.6 | 15.66G |  156.6 |  19.935% |     150 | "49" |  100M | 275.58M |     2.76 | 1:08'16'' |
| Q25L60 | 17.99G | 179.9 | 15.46G |  154.6 |  14.049% |     150 | "49" |  100M | 261.04M |     2.61 | 0:54'12'' |
| Q30L60 | 16.89G | 168.9 | 15.31G |  153.1 |   9.375% |     149 | "49" |  100M | 254.25M |     2.54 | 0:49'16'' |

* kmergenie

```bash
BASE_NAME=F357
cd ${HOME}/data/dna-seq/chara/${BASE_NAME}

mkdir -p 2_illumina/kmergenie
cd 2_illumina/kmergenie

kmergenie -l 21 -k 121 -s 10 -t 8 ../R1.fq.gz -o oriR1
kmergenie -l 21 -k 121 -s 10 -t 8 ../R2.fq.gz -o oriR2
kmergenie -l 21 -k 121 -s 10 -t 8 ../Q30L60/pe.cor.fa -o Q30L60

```

## F357: down sampling

```bash
BASE_NAME=F357
cd ${HOME}/data/dna-seq/chara/${BASE_NAME}

REAL_G=100000000

for QxxLxx in $( parallel "echo 'Q{1}L{2}'" ::: 20 25 30 ::: 60 ); do
    echo "==> ${QxxLxx}"

    if [ ! -e 2_illumina/${QxxLxx}/pe.cor.fa ]; then
        echo "2_illumina/${QxxLxx}/pe.cor.fa not exists"
        continue;
    fi

    for X in 40 80 120; do
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

## F357: k-unitigs and anchors (sampled)

```bash
BASE_NAME=F357
cd ${HOME}/data/dna-seq/chara/${BASE_NAME}

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
    " ::: 20 25 30 ::: 60 ::: 40 80 120 ::: 000 001 002 003 004 005 006

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
        ../k_unitigs.fasta \
        ../pe.cor.fa \
        -p 8 \
        -o anchors.sh
    bash anchors.sh
    
    echo >&2
    " ::: 20 25 30 ::: 60 ::: 40 80 120 ::: 000 001 002 003 004 005 006

# Stats of anchors
REAL_G=100000000

bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 header \
    > stat2.md

parallel -k --no-run-if-empty -j 6 "
    if [ ! -e Q{1}L{2}X{3}P{4}/anchor/pe.anchor.fa ]; then
        exit;
    fi

    bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 Q{1}L{2}X{3}P{4} ${REAL_G}
    " ::: 20 25 30 ::: 60 ::: 40 80 120 ::: 000 001 002 003 004 005 006 \
     >> stat2.md

cat stat2.md
```

| Name           | SumCor | CovCor | N50SR |     Sum |      # | N50Anchor |     Sum |     # | N50Others |    Sum |     # |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|-------:|------:|--------:|-------:|----------:|--------:|------:|----------:|-------:|------:|--------------------:|----------:|:----------|
| Q20L60X40P000  |     4G |   40.0 |  7668 | 105.26M |  41284 |     12449 |  88.91M | 17799 |       704 | 16.36M | 23485 | "31,41,51,61,71,81" | 1:15'23'' | 0:09'29'' |
| Q20L60X40P001  |     4G |   40.0 |  7247 | 103.46M |  41536 |     12253 |  86.87M | 17751 |       703 | 16.59M | 23785 | "31,41,51,61,71,81" | 1:08'07'' | 0:08'30'' |
| Q20L60X40P002  |     4G |   40.0 |  6559 | 100.78M |  42009 |     10556 |  84.04M | 17928 |       703 | 16.74M | 24081 | "31,41,51,61,71,81" | 0:58'49'' | 0:07'31'' |
| Q20L60X80P000  |     8G |   80.0 |  8384 | 133.67M |  66115 |     16516 | 100.38M | 16856 |       671 | 33.29M | 49259 | "31,41,51,61,71,81" | 1:47'12'' | 0:13'54'' |
| Q20L60X120P000 |    12G |  120.0 |  2887 | 170.17M | 103764 |     12770 | 116.33M | 27078 |       708 | 53.84M | 76686 | "31,41,51,61,71,81" | 2:37'20'' | 0:17'36'' |
| Q25L60X40P000  |     4G |   40.0 | 10281 |  108.7M |  38676 |     16286 |  93.76M | 17401 |       711 | 14.94M | 21275 | "31,41,51,61,71,81" | 0:53'00'' | 0:10'00'' |
| Q25L60X40P001  |     4G |   40.0 |  9738 | 107.59M |  39809 |     15995 |  91.91M | 17444 |       708 | 15.68M | 22365 | "31,41,51,61,71,81" | 0:44'20'' | 0:09'43'' |
| Q25L60X40P002  |     4G |   40.0 |  8255 | 105.42M |  40726 |     13120 |  89.34M | 17593 |       703 | 16.08M | 23133 | "31,41,51,61,71,81" | 0:44'13'' | 0:08'43'' |
| Q25L60X80P000  |     8G |   80.0 | 10915 | 138.15M |  63850 |     22870 | 105.67M | 15943 |       672 | 32.48M | 47907 | "31,41,51,61,71,81" | 1:17'36'' | 0:15'58'' |
| Q25L60X120P000 |    12G |  120.0 |  4039 |  173.6M |  99401 |     20157 | 121.89M | 25583 |       706 |  51.7M | 73818 | "31,41,51,61,71,81" | 1:53'15'' | 0:22'57'' |
| Q30L60X40P000  |     4G |   40.0 | 16284 | 110.26M |  32257 |     24368 |  98.34M | 15315 |       709 | 11.92M | 16942 | "31,41,51,61,71,81" | 0:46'48'' | 0:11'31'' |
| Q30L60X40P001  |     4G |   40.0 | 14471 | 110.02M |  34361 |     22185 |  97.19M | 16198 |       710 | 12.84M | 18163 | "31,41,51,61,71,81" | 0:45'52'' | 0:11'21'' |
| Q30L60X40P002  |     4G |   40.0 | 11988 | 108.78M |  36573 |     17768 |  95.07M | 17118 |       716 | 13.71M | 19455 | "31,41,51,61,71,81" | 0:46'36'' | 0:11'00'' |
| Q30L60X80P000  |     8G |   80.0 | 14914 | 142.95M |  59781 |     31007 | 112.93M | 15460 |       675 | 30.02M | 44321 | "31,41,51,61,71,81" | 1:18'40'' | 0:20'41'' |
| Q30L60X120P000 |    12G |  120.0 |  6785 | 178.07M |  95012 |     31327 | 128.42M | 24353 |       708 | 49.66M | 70659 | "31,41,51,61,71,81" | 1:49'48'' | 0:28'24'' |

## F357: merge anchors

```bash
BASE_NAME=F357
cd ${HOME}/data/dna-seq/chara/${BASE_NAME}

# merge anchors
mkdir -p merge
anchr contained \
    $(
        parallel -k --no-run-if-empty -j 6 "
            if [ -e Q{1}L{2}X{3}P{4}/anchor/pe.anchor.fa ]; then
                echo Q{1}L{2}X{3}P{4}/anchor/pe.anchor.fa
            fi
            " ::: 20 25 30 ::: 60 ::: 40 80 120 ::: 000 001 002 003 004 005 006
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
            " ::: 20 25 30 ::: 60 ::: 40 80 120 ::: 000 001 002 003 004 005 006
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
BASE_NAME=F357
cd ${HOME}/data/dna-seq/chara/${BASE_NAME}

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
| anchor.merge | 84873 | 148010708 | 25297 |
| others.merge |  1047 |  15603500 | 13933 |

* Clear QxxLxxXxx.

```bash
BASE_NAME=F357
cd ${HOME}/data/dna-seq/chara/${BASE_NAME}

rm -fr 2_illumina/Q{20,25,30,35}L{1,60,90,120}X*
rm -fr Q{20,25,30,35}L{1,60,90,120}X*
```

# F1084, Staurastrum sp., 角星鼓藻

## F1084: download

```bash
mkdir -p ~/data/dna-seq/chara/F1084/2_illumina
cd ~/data/dna-seq/chara/F1084/2_illumina

ln -s ~/data/dna-seq/chara/clean_data/F1084_HF5KMALXX_L7_1.clean.fq.gz R1.fq.gz
ln -s ~/data/dna-seq/chara/clean_data/F1084_HF5KMALXX_L7_2.clean.fq.gz R2.fq.gz
```

* FastQC

```bash
BASE_NAME=F1084
cd ${HOME}/data/dna-seq/chara/${BASE_NAME}

mkdir -p 2_illumina/fastqc
cd 2_illumina/fastqc

fastqc -t 16 \
    ../R1.fq.gz ../R2.fq.gz \
    -o .

```

## F1084: combinations of different quality values and read lengths

* qual: 20, 25, and 30
* len: 60

```bash
BASE_NAME=F1084
cd ${HOME}/data/dna-seq/chara/${BASE_NAME}

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
    " ::: 20 25 30 ::: 60

```

* Stats

```bash
BASE_NAME=F1084
cd ${HOME}/data/dna-seq/chara/${BASE_NAME}

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
    " ::: 20 25 30 ::: 60 \
    >> stat.md

cat stat.md
```

| Name     | N50 |         Sum |         # |
|:---------|----:|------------:|----------:|
| Illumina | 150 | 17281584900 | 115210566 |
| uniq     | 150 | 16422145800 | 109480972 |
| Q20L60   | 150 | 15131350696 | 104864930 |
| Q25L60   | 150 | 13877549755 |  98292284 |
| Q30L60   | 150 | 13108598640 |  96322136 |

## F1084: quorum

```bash
BASE_NAME=F1084
cd ${HOME}/data/dna-seq/chara/${BASE_NAME}

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
    " ::: 20 25 30 ::: 60

```

Clear intermediate files.

```bash
BASE_NAME=F1084
cd ${HOME}/data/dna-seq/chara/${BASE_NAME}

find 2_illumina -type f -name "quorum_mer_db.jf" | xargs rm
find 2_illumina -type f -name "k_u_hash_0"       | xargs rm
find 2_illumina -type f -name "*.tmp"            | xargs rm
find 2_illumina -type f -name "pe.renamed.fastq" | xargs rm
find 2_illumina -type f -name "se.renamed.fastq" | xargs rm
find 2_illumina -type f -name "pe.cor.sub.fa"    | xargs rm
```

* Stats of processed reads

```bash
BASE_NAME=F1084
cd ${HOME}/data/dna-seq/chara/${BASE_NAME}

REAL_G=100000000

bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 1 header \
    > stat1.md

parallel -k --no-run-if-empty -j 3 "
    if [ ! -d 2_illumina/Q{1}L{2} ]; then
        exit;
    fi

    bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 1 2_illumina/Q{1}L{2} ${REAL_G}
    " ::: 20 25 30 ::: 60 \
     >> stat1.md

cat stat1.md
```

| Name   |  SumIn | CovIn | SumOut | CovOut | Discard% | AvgRead | Kmer | RealG |    EstG | Est/Real |   RunTime |
|:-------|-------:|------:|-------:|-------:|---------:|--------:|-----:|------:|--------:|---------:|----------:|
| Q20L60 | 15.13G | 151.3 | 12.06G |  120.6 |  20.275% |     149 | "49" |  100M | 168.69M |     1.69 | 0:44'09'' |
| Q25L60 | 13.88G | 138.8 | 11.93G |  119.3 |  14.024% |     149 | "49" |  100M |  164.6M |     1.65 | 0:38'39'' |
| Q30L60 | 13.12G | 131.2 | 11.85G |  118.5 |   9.667% |     149 | "49" |  100M | 162.77M |     1.63 | 0:35'43'' |

* kmergenie

```bash
BASE_NAME=F1084
cd ${HOME}/data/dna-seq/chara/${BASE_NAME}

mkdir -p 2_illumina/kmergenie
cd 2_illumina/kmergenie

kmergenie -l 21 -k 121 -s 10 -t 8 ../R1.fq.gz -o oriR1
kmergenie -l 21 -k 121 -s 10 -t 8 ../R2.fq.gz -o oriR2
kmergenie -l 21 -k 121 -s 10 -t 8 ../Q30L60/pe.cor.fa -o Q30L60

```

## F1084: down sampling

```bash
BASE_NAME=F1084
cd ${HOME}/data/dna-seq/chara/${BASE_NAME}

REAL_G=100000000

for QxxLxx in $( parallel "echo 'Q{1}L{2}'" ::: 20 25 30 ::: 60 ); do
    echo "==> ${QxxLxx}"

    if [ ! -e 2_illumina/${QxxLxx}/pe.cor.fa ]; then
        echo "2_illumina/${QxxLxx}/pe.cor.fa not exists"
        continue;
    fi

    for X in 40 80 120; do
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

## F1084: k-unitigs and anchors (sampled)

```bash
BASE_NAME=F1084
cd ${HOME}/data/dna-seq/chara/${BASE_NAME}

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
    " ::: 20 25 30 ::: 60 ::: 40 80 120 ::: 000 001 002 003 004 005 006

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
        ../k_unitigs.fasta \
        ../pe.cor.fa \
        -p 8 \
        -o anchors.sh
    bash anchors.sh

    rm -fr Q{1}L{2}X{3}P{4}/anchor
    bash ~/Scripts/cpan/App-Anchr/share/anchor.sh Q{1}L{2}X{3}P{4} 8 false
    
    echo >&2
    " ::: 20 25 30 ::: 60 ::: 40 80 120 ::: 000 001 002 003 004 005 006

# Stats of anchors
REAL_G=100000000

bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 header \
    > stat2.md

parallel -k --no-run-if-empty -j 6 "
    if [ ! -e Q{1}L{2}X{3}P{4}/anchor/pe.anchor.fa ]; then
        exit;
    fi

    bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 Q{1}L{2}X{3}P{4} ${REAL_G}
    " ::: 20 25 30 ::: 60 ::: 40 80 120 ::: 000 001 002 003 004 005 006 \
     >> stat2.md

cat stat2.md
```

| Name           | SumCor | CovCor | N50SR |     Sum |     # | N50Anchor |     Sum |     # | N50Others |    Sum |     # |                Kmer | RunTimeKU | RunTimeAN |
|:---------------|-------:|-------:|------:|--------:|------:|----------:|--------:|------:|----------:|-------:|------:|--------------------:|----------:|:----------|
| Q20L60X40P000  |     4G |   40.0 |  3449 | 136.28M | 66423 |      4704 | 108.79M | 31614 |       768 |  27.5M | 34809 | "31,41,51,61,71,81" | 1:16'51'' | 0:09'43'' |
| Q20L60X40P001  |     4G |   40.0 |  3322 | 134.93M | 67134 |      4613 | 107.25M | 31622 |       763 | 27.68M | 35512 | "31,41,51,61,71,81" | 1:11'58'' | 0:08'09'' |
| Q20L60X40P002  |     4G |   40.0 |  3237 | 133.66M | 67878 |      4574 | 105.48M | 31510 |       760 | 28.18M | 36368 | "31,41,51,61,71,81" | 1:10'41'' | 0:08'56'' |
| Q20L60X80P000  |     8G |   80.0 |  4409 | 137.89M | 61234 |      6233 | 112.73M | 28737 |       755 | 25.16M | 32497 | "31,41,51,61,71,81" | 1:46'32'' | 0:14'09'' |
| Q20L60X120P000 |    12G |  120.0 |  4167 | 137.91M | 61616 |      5680 | 113.07M | 29392 |       752 | 24.84M | 32224 | "31,41,51,61,71,81" | 2:20'13'' | 0:19'10'' |
| Q25L60X40P000  |     4G |   40.0 |  3721 | 137.31M | 63891 |      5035 | 111.12M | 31043 |       774 |  26.2M | 32848 | "31,41,51,61,71,81" | 0:57'52'' | 0:09'16'' |
| Q25L60X40P001  |     4G |   40.0 |  3550 | 136.72M | 65262 |      4833 | 109.99M | 31499 |       771 | 26.73M | 33763 | "31,41,51,61,71,81" | 0:57'21'' | 0:09'11'' |
| Q25L60X80P000  |     8G |   80.0 |  4674 | 140.93M | 60019 |      6505 |  116.6M | 28915 |       760 | 24.33M | 31104 | "31,41,51,61,71,81" | 1:16'23'' | 0:15'32'' |
| Q30L60X40P000  |     4G |   40.0 |  4022 | 137.29M | 61800 |      5526 | 111.52M | 29521 |       774 | 25.77M | 32279 | "31,41,51,61,71,81" | 0:59'41'' | 0:09'28'' |
| Q30L60X40P001  |     4G |   40.0 |  3837 | 136.87M | 63099 |      5193 | 110.96M | 30372 |       773 | 25.91M | 32727 | "31,41,51,61,71,81" | 1:00'10'' | 0:09'53'' |
| Q30L60X80P000  |     8G |   80.0 |  5277 | 142.14M | 56398 |      7200 | 119.62M | 27933 |       765 | 22.52M | 28465 | "31,41,51,61,71,81" | 1:21'17'' | 0:18'17'' |

## F1084: merge anchors

```bash
BASE_NAME=F1084
cd ${HOME}/data/dna-seq/chara/${BASE_NAME}

# merge anchors
mkdir -p merge
anchr contained \
    $(
        parallel -k --no-run-if-empty -j 6 "
            if [ -e Q{1}L{2}X{3}P{4}/anchor/pe.anchor.fa ]; then
                echo Q{1}L{2}X{3}P{4}/anchor/pe.anchor.fa
            fi
            " ::: 20 25 30 ::: 60 ::: 40 80 120 ::: 000 001 002 003 004 005 006
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
            " ::: 20 25 30 ::: 60 ::: 40 80 120 ::: 000 001 002 003 004 005 006
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
BASE_NAME=F1084
cd ${HOME}/data/dna-seq/chara/${BASE_NAME}

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

| Name         |  N50 |       Sum |     # |
|:-------------|-----:|----------:|------:|
| anchor.merge | 9476 | 127995728 | 26304 |
| others.merge | 1868 |  15897762 |  8538 |

* Clear QxxLxxXxx.

```bash
BASE_NAME=F1084
cd ${HOME}/data/dna-seq/chara/${BASE_NAME}

rm -fr 2_illumina/Q{20,25,30,35}L{1,60,90,120}X*
rm -fr Q{20,25,30,35}L{1,60,90,120}X*
```

# F1084, Staurastrum sp., 角星鼓藻

## F1084: download

```bash
mkdir -p ~/data/dna-seq/chara/F1084/2_illumina
cd ~/data/dna-seq/chara/F1084/2_illumina

ln -s ~/data/dna-seq/chara/clean_data/F1084_HF5KMALXX_L7_1.clean.fq.gz R1.fq.gz
ln -s ~/data/dna-seq/chara/clean_data/F1084_HF5KMALXX_L7_2.clean.fq.gz R2.fq.gz

```


## F1084: template

```bash
WORKING_DIR=${HOME}/data/dna-seq/chara
BASE_NAME=F1084

cd ${WORKING_DIR}/${BASE_NAME}

rm -f *.sh
anchr template \
    . \
    --basename ${BASE_NAME} \
    --queue mpi \
    --genome 100000000 \
    --fastqc \
    --kmergenie \
    --insertsize \
    --sgapreqc \
    --sgastats \
    --trim2 "--dedupe --tile" \
    --qual2 "25" \
    --len2 "60" \
    --filter "adapter,phix,artifact" \
    --mergereads \
    --ecphase "1,2,3" \
    --cov2 "40 80" \
    --tadpole \
    --splitp 100 \
    --statp 10 \
    --fillanchor \
    --parallel 24

```

## F1084: run

```bash
WORKING_DIR=${HOME}/data/dna-seq/chara
BASE_NAME=F1084

cd ${WORKING_DIR}/${BASE_NAME}
#rm -fr 4_*/ 6_*/ 7_*/ 8_*/ && rm -fr 2_illumina/trim 2_illumina/mergereads statReads.md 

bash 0_bsub.sh
#bash 0_master.sh

#bash 0_cleanup.sh

```

Table: statInsertSize

| Group           |  Mean | Median | STDev | PercentOfPairs/PairOrientation |
|:----------------|------:|-------:|------:|-------------------------------:|
| tadpole.bbtools | 305.4 |    303 |  63.3 |                         32.94% |
| tadpole.picard  | 304.1 |    302 |  63.8 |                             FR |


Table: statReads

| Name     | N50 |    Sum |         # |
|:---------|----:|-------:|----------:|
| Illumina | 150 | 17.28G | 115210566 |
| trim     | 150 |  14.5G | 100886238 |
| Q25L60   | 150 | 13.55G |  95591736 |


Table: statTrimReads

| Name           | N50 |    Sum |         # |
|:---------------|----:|-------:|----------:|
| clumpify       | 150 | 16.41G | 109417050 |
| filteredbytile | 150 | 15.47G | 103164652 |
| trim           | 150 | 14.51G | 100887272 |
| filter         | 150 |  14.5G | 100886238 |
| R1             | 150 |  7.46G |  50443119 |
| R2             | 150 |  7.05G |  50443119 |
| Rs             |   0 |      0 |         0 |


```text
#trim
#Matched	114870	0.11135%
#Name	Reads	ReadsPct
TruSeq_Universal_Adapter	16917	0.01640%
I5_Nextera_Transposase_1	10898	0.01056%
I5_Primer_Nextera_XT_and_Nextera_Enrichment_[N/S/E]501	9748	0.00945%
Reverse_adapter	9163	0.00888%
I5_Nextera_Transposase_2	8192	0.00794%
I7_Nextera_Transposase_2	7175	0.00695%
I5_Adapter_Nextera	6667	0.00646%
I7_Primer_Nextera_XT_and_Nextera_Enrichment_N701	6349	0.00615%
PhiX_read2_adapter	4638	0.00450%
I7_Adapter_Nextera_No_Barcode	4376	0.00424%
RNA_Adapter_(RA5)_part_#_15013205	3484	0.00338%
PhiX_read1_adapter	3062	0.00297%
I7_Nextera_Transposase_1	2551	0.00247%
Nextera_LMP_Read2_External_Adapter	2005	0.00194%
pcr_dimer	1969	0.00191%
PCR_Primers	1906	0.00185%
Nextera_LMP_Read1_External_Adapter	1651	0.00160%
RNA_PCR_Primer_Index_1_(RPI1)_2,9	1398	0.00136%
I5_Primer_Nextera_XT_Index_Kit_v2_S510	1209	0.00117%
Bisulfite_R1	1081	0.00105%
TruSeq_Adapter_Index_1_6	1069	0.00104%
```

```text
#filter
#Matched	519	0.00051%
#Name	Reads	ReadsPct
TruSeq_Universal_Adapter	214	0.00021%
```


Table: statMergeReads

| Name          | N50 |     Sum |         # |
|:--------------|----:|--------:|----------:|
| clumped       | 150 |   14.5G | 100847298 |
| ecco          | 150 |   14.5G | 100847298 |
| eccc          | 150 |   14.5G | 100847298 |
| ecct          | 150 |  13.64G |  94491854 |
| extended      | 190 |  17.29G |  94491854 |
| merged        | 354 |  15.29G |  44046870 |
| unmerged.raw  | 179 |   1.06G |   6398114 |
| unmerged.trim | 179 |   1.06G |   6397670 |
| U1            | 187 | 566.97M |   3198835 |
| U2            | 169 | 489.23M |   3198835 |
| Us            |   0 |       0 |         0 |
| pe.cor        | 349 |  16.39G |  94491410 |

| Group            |  Mean | Median | STDev | PercentOfPairs |
|:-----------------|------:|-------:|------:|---------------:|
| ihist.merge1.txt | 246.1 |    252 |  29.3 |         25.99% |
| ihist.merge.txt  | 347.1 |    345 |  56.3 |         93.23% |


Table: statQuorum

| Name   | CovIn | CovOut | Discard% | AvgRead | Kmer | RealG |    EstG | Est/Real |   RunTime |
|:-------|------:|-------:|---------:|--------:|-----:|------:|--------:|---------:|----------:|
| Q0L0   | 145.0 |  119.9 |   17.37% |     145 | "75" |  100M | 167.35M |     1.67 | 0:24'33'' |
| Q25L60 | 135.5 |  119.1 |   12.09% |     143 | "75" |  100M |  164.1M |     1.64 | 0:22'48'' |


Table: statKunitigsAnchors.md

| Name          | CovCor | Mapped% | N50Anchor |    Sum |     # | N50Others |    Sum |     # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|-------:|--------:|----------:|-------:|------:|----------:|-------:|------:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q0L0X40P000   |   40.0 |  62.00% |      4425 | 90.58M | 27985 |      2988 | 25.76M | 45423 |   13.0 | 2.0 |   3.0 |  26.0 | "31,41,51,61,71,81" | 0:28'07'' | 0:14'56'' |
| Q0L0X40P001   |   40.0 |  62.12% |      4394 | 90.51M | 28048 |      2890 | 25.76M | 45976 |   13.0 | 2.0 |   3.0 |  26.0 | "31,41,51,61,71,81" | 0:28'03'' | 0:14'56'' |
| Q0L0X80P000   |   80.0 |  52.13% |      6032 | 95.95M | 23802 |      2548 | 23.07M | 34338 |   24.0 | 3.0 |   5.0 |  48.0 | "31,41,51,61,71,81" | 0:45'06'' | 0:14'56'' |
| Q25L60X40P000 |   40.0 |  68.71% |      4457 | 90.59M | 27872 |      4218 | 28.07M | 43324 |   13.0 | 2.0 |   3.0 |  26.0 | "31,41,51,61,71,81" | 0:28'22'' | 0:15'57'' |
| Q25L60X40P001 |   40.0 |  68.70% |      4420 | 90.71M | 27962 |      4311 | 28.28M | 43295 |   13.0 | 2.0 |   3.0 |  26.0 | "31,41,51,61,71,81" | 0:28'31'' | 0:15'12'' |
| Q25L60X80P000 |   80.0 |  61.69% |      5675 | 95.13M | 24415 |      2802 | 28.27M | 40713 |   25.0 | 3.0 |   5.3 |  50.0 | "31,41,51,61,71,81" | 0:45'49'' | 0:16'03'' |


Table: statTadpoleAnchors.md

| Name          | CovCor | Mapped% | N50Anchor |    Sum |     # | N50Others |    Sum |     # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|-------:|--------:|----------:|-------:|------:|----------:|-------:|------:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| Q0L0X40P000   |   40.0 |  77.83% |      3188 | 84.01M | 31830 |     11556 | 33.37M | 44486 |   14.0 | 2.0 |   3.0 |  28.0 | "31,41,51,61,71,81" | 0:18'29'' | 0:16'35'' |
| Q0L0X40P001   |   40.0 |  78.02% |      3137 | 84.06M | 32088 |     12008 | 34.12M | 44745 |   14.0 | 2.0 |   3.0 |  28.0 | "31,41,51,61,71,81" | 0:18'14'' | 0:16'03'' |
| Q0L0X80P000   |   80.0 |  80.00% |      5560 | 94.99M | 24800 |     20387 | 33.82M | 44543 |   25.0 | 3.0 |   5.3 |  50.0 | "31,41,51,61,71,81" | 0:23'49'' | 0:17'05'' |
| Q25L60X40P000 |   40.0 |  78.24% |      3187 | 83.46M | 31737 |     12556 | 34.21M | 41560 |   14.0 | 2.0 |   3.0 |  28.0 | "31,41,51,61,71,81" | 0:18'31'' | 0:16'21'' |
| Q25L60X40P001 |   40.0 |  78.37% |      3175 |  83.6M | 31796 |     13496 | 34.52M | 41838 |   14.0 | 2.0 |   3.0 |  28.0 | "31,41,51,61,71,81" | 0:18'32'' | 0:16'27'' |
| Q25L60X80P000 |   80.0 |  80.55% |      5664 | 96.05M | 24977 |     20261 | 32.76M | 41665 |   26.0 | 3.0 |   5.7 |  52.0 | "31,41,51,61,71,81" | 0:24'25'' | 0:17'09'' |


Table: statMRKunitigsAnchors.md

| Name      | CovCor | Mapped% | N50Anchor |    Sum |     # | N50Others |    Sum |      # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:----------|-------:|--------:|----------:|-------:|------:|----------:|-------:|-------:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| MRX40P000 |   40.0 |  70.86% |      1605 | 73.22M | 44771 |      1247 | 83.13M | 155318 |   11.0 | 3.0 |   3.0 |  22.0 | "31,41,51,61,71,81" | 0:27'12'' | 0:15'13'' |
| MRX40P001 |   40.0 |  70.84% |      1610 | 73.27M | 44737 |      1249 | 83.14M | 155322 |   11.0 | 3.0 |   3.0 |  22.0 | "31,41,51,61,71,81" | 0:27'14'' | 0:15'39'' |
| MRX40P002 |   40.0 |  70.97% |      1606 | 73.12M | 44668 |      1251 | 83.23M | 155273 |   11.0 | 3.0 |   3.0 |  22.0 | "31,41,51,61,71,81" | 0:27'15'' | 0:15'19'' |
| MRX40P003 |   40.0 |  70.91% |      1606 | 73.15M | 44659 |      1251 | 83.13M | 155001 |   11.0 | 3.0 |   3.0 |  22.0 | "31,41,51,61,71,81" | 0:27'16'' | 0:15'36'' |
| MRX80P000 |   80.0 |  62.20% |      1506 | 78.19M | 50363 |      1211 | 54.61M | 115426 |   22.0 | 7.0 |   3.0 |  44.0 | "31,41,51,61,71,81" | 0:47'45'' | 0:14'53'' |
| MRX80P001 |   80.0 |  62.29% |      1513 |  78.2M | 50337 |      1215 | 54.72M | 115376 |   22.0 | 7.0 |   3.0 |  44.0 | "31,41,51,61,71,81" | 0:47'37'' | 0:15'07'' |


Table: statMRTadpoleAnchors.md

| Name      | CovCor | Mapped% | N50Anchor |    Sum |     # | N50Others |    Sum |     # | median | MAD | lower | upper |                Kmer | RunTimeKU | RunTimeAN |
|:----------|-------:|--------:|----------:|-------:|------:|----------:|-------:|------:|-------:|----:|------:|------:|--------------------:|----------:|----------:|
| MRX40P000 |   40.0 |  73.11% |      5353 | 91.13M | 24553 |     19482 | 28.23M | 43569 |   13.0 | 3.0 |   3.0 |  26.0 | "31,41,51,61,71,81" | 0:23'45'' | 0:14'20'' |
| MRX40P001 |   40.0 |  73.50% |      5376 | 91.04M | 24453 |     20418 | 28.74M | 43508 |   13.0 | 3.0 |   3.0 |  26.0 | "31,41,51,61,71,81" | 0:24'26'' | 0:14'05'' |
| MRX40P002 |   40.0 |  73.65% |      5358 | 91.02M | 24464 |     20476 | 28.92M | 43399 |   13.0 | 3.0 |   3.0 |  26.0 | "31,41,51,61,71,81" | 0:24'01'' | 0:14'18'' |
| MRX40P003 |   40.0 |  73.58% |      5345 | 90.98M | 24520 |     18993 | 29.08M | 43429 |   13.0 | 3.0 |   3.0 |  26.0 | "31,41,51,61,71,81" | 0:24'13'' | 0:14'00'' |
| MRX80P000 |   80.0 |  72.83% |      7194 | 95.76M | 21758 |     28650 | 25.91M | 35295 |   26.0 | 4.0 |   4.7 |  52.0 | "31,41,51,61,71,81" | 0:31'39'' | 0:15'48'' |
| MRX80P001 |   80.0 |  73.01% |      7185 | 95.75M | 21790 |     26319 | 26.23M | 35213 |   26.0 | 4.0 |   4.7 |  52.0 | "31,41,51,61,71,81" | 0:31'22'' | 0:15'49'' |


Table: statMergeAnchors.md

| Name                     | Mapped% | N50Anchor |     Sum |     # | N50Others |     Sum |     # | median | MAD | lower | upper | RunTimeAN |
|:-------------------------|--------:|----------:|--------:|------:|----------:|--------:|------:|-------:|----:|------:|------:|----------:|
| 7_mergeAnchors           |   0.00% |      7666 | 113.76M | 26632 |     28650 |  45.83M | 11782 |    0.0 | 0.0 |   0.0 |   0.0 |           |
| 7_mergeKunitigsAnchors   |   0.00% |      6997 | 103.91M | 24585 |      6446 |  44.09M | 13543 |    0.0 | 0.0 |   0.0 |   0.0 |           |
| 7_mergeMRKunitigsAnchors |   0.00% |      1929 | 103.44M | 55211 |      1386 | 102.01M | 70944 |    0.0 | 0.0 |   0.0 |   0.0 |           |
| 7_mergeMRTadpoleAnchors  |   0.00% |      7426 | 102.62M | 23635 |     34730 |  36.17M |  8480 |    0.0 | 0.0 |   0.0 |   0.0 |           |
| 7_mergeTadpoleAnchors    |   0.00% |      5661 | 105.45M | 27994 |     27326 |  45.19M | 10195 |    0.0 | 0.0 |   0.0 |   0.0 |           |


Table: statOtherAnchors.md

| Name         | Mapped% | N50Anchor |     Sum |     # | N50Others |    Sum |     # | median | MAD | lower | upper | RunTimeAN |
|:-------------|--------:|----------:|--------:|------:|----------:|-------:|------:|-------:|----:|------:|------:|----------:|
| 8_spades     |  69.37% |     10245 | 108.09M | 20431 |      9879 | 46.11M | 31952 |   22.0 | 2.0 |   5.3 |  42.0 | 0:15'35'' |
| 8_spades_MR  |  71.92% |     14026 | 120.03M | 19526 |     11300 | 35.29M | 25742 |   22.0 | 3.0 |   4.3 |  44.0 | 0:15'58'' |
| 8_megahit    |  65.06% |      5691 |  96.82M | 25366 |      8144 | 42.85M | 35911 |   21.0 | 2.0 |   5.0 |  40.5 | 0:14'02'' |
| 8_megahit_MR |  70.48% |      6878 | 117.13M | 27693 |      8586 |  35.8M | 33478 |   22.0 | 3.0 |   4.3 |  44.0 | 0:15'44'' |
| 8_platanus   |  70.46% |     18643 | 105.05M | 15055 |     13915 | 26.18M | 18025 |   22.0 | 4.0 |   3.3 |  44.0 | 0:14'06'' |


Table: statFinal

| Name                     |   N50 |       Sum |      # |
|:-------------------------|------:|----------:|-------:|
| 7_mergeAnchors.anchors   |  7666 | 113761691 |  26632 |
| 7_mergeAnchors.others    | 28650 |  45825025 |  11782 |
| anchorLong               |  9815 | 111623635 |  21632 |
| anchorFill               | 15489 | 114747320 |  14491 |
| spades.contig            |  9297 | 207676514 | 214852 |
| spades.scaffold          | 10814 | 207794834 | 212375 |
| spades.non-contained     | 18275 | 154200588 |  19551 |
| spades_MR.contig         | 17993 | 167689842 |  48214 |
| spades_MR.scaffold       | 20603 | 167893744 |  46403 |
| spades_MR.non-contained  | 20650 | 155337897 |  17657 |
| megahit.contig           |  6430 | 168637336 |  94972 |
| megahit.non-contained    | 10188 | 139673111 |  27587 |
| megahit_MR.contig        |  7127 | 180299392 |  84707 |
| megahit_MR.non-contained |  9949 | 152943686 |  28827 |
| platanus.contig          |  3609 | 180825862 | 271902 |
| platanus.scaffold        | 22828 | 146223966 | 111152 |
| platanus.non-contained   | 27491 | 131234958 |  11978 |


# showa, Botryococcus braunii Showa

* BioProject: https://www.ncbi.nlm.nih.gov/bioproject/PRJNA60039
* SRP: https://trace.ncbi.nlm.nih.gov/Traces/sra/?study=SRP003868
* Assembly: https://www.ncbi.nlm.nih.gov/assembly/GCA_002005505.1/
* WGS: https://www.ncbi.nlm.nih.gov/Traces/wgs/?val=MVGU01&display=contigs&page=1

## showa: download

* Illumina

    * [SRX1879506](https://www.ncbi.nlm.nih.gov/sra/SRX1879506) SRR3721649

```bash
mkdir -p ~/data/dna-seq/chara/showa/2_illumina
cd ~/data/dna-seq/chara/showa/2_illumina

cat << EOF > sra_ftp.txt
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR372/009/SRR3721649/SRR3721649_1.fastq.gz
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR372/009/SRR3721649/SRR3721649_2.fastq.gz
EOF

aria2c -x 9 -s 3 -c -i sra_ftp.txt

cat << EOF > sra_md5.txt
c7ec4f83101c0f5a7f1187afc344b243 SRR3721649_1.fastq.gz
da3bfe2c9c64c249e30148208ec14796 SRR3721649_2.fastq.gz
EOF

md5sum --check sra_md5.txt

ln -s SRR3721649_1.fastq.gz R1.fq.gz
ln -s SRR3721649_2.fastq.gz R2.fq.gz

```

* PacBio

```bash
mkdir -p ~/data/dna-seq/chara/showa/3_pacbio
cd ~/data/dna-seq/chara/showa/3_pacbio

cat <<EOF > sra_ftp.txt
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR372/000/SRR3721650/SRR3721650_1.fastq.gz
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR372/001/SRR3721651/SRR3721651_1.fastq.gz
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR372/002/SRR3721652/SRR3721652_1.fastq.gz
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR372/003/SRR3721653/SRR3721653_1.fastq.gz
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR372/004/SRR3721654/SRR3721654_1.fastq.gz
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR372/005/SRR3721655/SRR3721655_1.fastq.gz
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR372/006/SRR3721656/SRR3721656_1.fastq.gz
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR372/007/SRR3721657/SRR3721657_1.fastq.gz
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR405/001/SRR4053781/SRR4053781_1.fastq.gz
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR405/002/SRR4053782/SRR4053782_1.fastq.gz
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR405/003/SRR4053783/SRR4053783_1.fastq.gz
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR405/004/SRR4053784/SRR4053784_1.fastq.gz
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR405/005/SRR4053785/SRR4053785_1.fastq.gz
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR405/006/SRR4053786/SRR4053786_1.fastq.gz
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR405/007/SRR4053787/SRR4053787_1.fastq.gz
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR405/008/SRR4053788/SRR4053788_1.fastq.gz
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR405/009/SRR4053789/SRR4053789_1.fastq.gz
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR405/000/SRR4053790/SRR4053790_1.fastq.gz
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR405/001/SRR4053791/SRR4053791_1.fastq.gz
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR405/002/SRR4053792/SRR4053792_1.fastq.gz
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR405/003/SRR4053793/SRR4053793_1.fastq.gz
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR405/004/SRR4053794/SRR4053794_1.fastq.gz
EOF

aria2c -x 6 -s 3 -c -i sra_ftp.txt

cat << EOF > sra_md5.txt
0d9cfdf5235dd0e9854297998ae967de SRR3721650_1.fastq.gz
4f0c37faaf5504ebfe81738062e71f43 SRR3721651_1.fastq.gz
4bf9db8b856490a9b562e6211f8b480d SRR3721652_1.fastq.gz
87600852285dc3d0fe13bf061f4b508c SRR3721653_1.fastq.gz
8cc3898680a17e66af116965d8e32628 SRR3721654_1.fastq.gz
b935a0bb5485fad168bad2bc74a05bbe SRR3721655_1.fastq.gz
ec78f65a7970ca94adb2599ef5577103 SRR3721656_1.fastq.gz
a40e4de33906a90e68f0b8c91a255078 SRR3721657_1.fastq.gz
06d4802e264e8b4bd884d9ad24c68232 SRR4053781_1.fastq.gz
9b3f9acc85f84083bea8e3df1b2a8c1d SRR4053782_1.fastq.gz
83d2489b34c9adb84c095c90bb11b78e SRR4053783_1.fastq.gz
d23544f5cf089fe343b5cb228292bc8e SRR4053784_1.fastq.gz
8ab91ce9890f2a47117fe2f6954708d3 SRR4053785_1.fastq.gz
accc5c548e2f1e84dfb9ffb462c53060 SRR4053786_1.fastq.gz
8fdd2514780f1c25664e6346b51ecc64 SRR4053787_1.fastq.gz
f4008c9802ff14f66318338a17ef5c2c SRR4053788_1.fastq.gz
f5f1c4f50e0b9abd006300482b024258 SRR4053789_1.fastq.gz
11aa5f57b83940784e7bf0d018c92c1e SRR4053790_1.fastq.gz
387661cbca9322cfdce7072e5664ecad SRR4053791_1.fastq.gz
774f7732acecae1fc722e6a854835e4c SRR4053792_1.fastq.gz
48ef169bd6090dc6354e9e0a6eeb0732 SRR4053793_1.fastq.gz
6dbf27cc3a6de285bc96cca901e106e9 SRR4053794_1.fastq.gz
EOF

md5sum --check sra_md5.txt

gzip -d -c SRR372165{0,1,2,3,4,5,6,7}_1.fastq.gz \
    > pacbio1.fq

gzip -d -c SRR40537{81,82,83,84,85,86,87,88,89,90,91,92,93,94}_1.fastq.gz \
    > pacbio2.fq

find . -name "pacbio*.fq" | parallel -j 1 pigz -p 8

faops filter -l 0 pacbio2.fq.gz stdout \
    | pigz -c -p 8 \
    > pacbio.fasta.gz

cd ~/data/dna-seq/chara/showa/
gzip -d -c 3_pacbio/pacbio.fasta.gz | head -n 2000000 > 3_pacbio/pacbio.40x.fasta
faops n50 -S -C 3_pacbio/pacbio.40x.fasta

```

* FastQC

```bash
BASE_NAME=showa
cd ${HOME}/data/dna-seq/chara/${BASE_NAME}

mkdir -p 2_illumina/fastqc
cd 2_illumina/fastqc

fastqc -t 16 \
    ../R1.fq.gz ../R2.fq.gz \
    -o .

```

* kmergenie

```bash
BASE_NAME=showa
cd ${HOME}/data/dna-seq/chara/${BASE_NAME}

mkdir -p 2_illumina/kmergenie
cd 2_illumina/kmergenie

kmergenie -l 21 -k 121 -s 10 -t 8 ../R1.fq.gz -o oriR1
kmergenie -l 21 -k 121 -s 10 -t 8 ../R2.fq.gz -o oriR2

```

## 3GS

```bash
BASE_NAME=showa
cd ${HOME}/data/dna-seq/chara/${BASE_NAME}

canu \
    -p ${BASE_NAME} -d canu-raw-40x \
    gnuplot=$(brew --prefix)/Cellar/$(brew list --versions gnuplot | sed 's/ /\//')/bin/gnuplot \
    genomeSize=184.4m \
    -pacbio-raw 3_pacbio/pacbio.40x.fasta

faops n50 -S -C canu-raw-40x/${BASE_NAME}.trimmedReads.fasta.gz
rm -fr canu-raw-40x/correction

```

# Summary of SR

| Name     | fq size | fa size | Length | Kmer | Est. Genome |   Run time |     Sum SR | SR/Est.G |
|:---------|--------:|--------:|-------:|-----:|------------:|-----------:|-----------:|---------:|
| F63      |   33.9G |     19G |    150 |   49 |   345627684 |  4:04'22'' |  697371843 |     2.02 |
| F295     |   43.3G |     24G |    150 |   49 |   452975652 |  6:01'13'' |  742260051 |     1.64 |
| F340     |   35.9G |     20G |    150 |   75 |   566603922 |  3:21'01'' |  852873811 |     1.51 |
| F354     |   36.2G |     20G |    150 |   49 |   133802786 |  6:06'09'' |  351863887 |     2.63 |
| F357     |   43.5G |     24G |    150 |   49 |   338905264 |  5:41'49'' |  796466152 |     2.35 |
| F1084    |   33.9G |     19G |    150 |   75 |   199395661 |  4:32'01'' |  570760287 |     2.86 |
| moli_sub |    118G |     63G |    150 |  105 |   608561446 | 11:29'38'' | 2899953305 |     4.77 |

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
* 50 倍的二代数据并不充分, 与 100 倍之间还是有明显的差异的. 覆盖数不够也会导致
  SR/Est.G 低于真实值.

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

| Name  | N50 SR |    Sum SR |     #SR |   #cor.fa | #strict.fa |
|:------|-------:|----------:|--------:|----------:|-----------:|
| F63   |   1815 | 697371843 |  986675 | 115078314 |   94324950 |
| F295  |    477 | 742260051 | 1975444 | 146979656 |  119415569 |
| F340  |    388 | 852873811 | 2383927 | 122062736 |  102014388 |
| F354  |    768 | 351863887 |  584408 | 123057622 |  106900181 |
| F357  |    599 | 796466152 | 1644428 | 147581634 |  129353409 |
| F1084 |    893 | 570760287 |  882123 | 115210566 |   97481899 |

| Name  |  N50 |      Sum | #anchor | N50 | Sum | #anchor2 | N50 | Sum | #others |
|:------|-----:|---------:|--------:|----:|----:|---------:|----:|----:|--------:|
| F63   | 4003 | 52342433 |   21120 |     |     |          |     |     |         |
| F295  | 2118 | 17374987 |   10473 |     |     |          |     |     |         |
| F340  | 1105 | 76859329 |   70742 |     |     |          |     |     |         |
| F354  | 2553 | 23543840 |   11667 |     |     |          |     |     |         |
| F357  | 1541 | 53821193 |   40017 |     |     |          |     |     |         |
| F1084 | 1721 |  4412080 |    3059 |     |     |          |     |     |         |
