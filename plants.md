# Plants 2+3

[TOC levels=1-3]: # " "

- [Plants 2+3](#plants-23)
- [F63, Closterium sp., 新月藻](#f63-closterium-sp-新月藻)
    - [F63: download](#f63-download)
    - [F63: combinations of different quality values and read lengths](#f63-combinations-of-different-quality-values-and-read-lengths)
    - [F63: down sampling](#f63-down-sampling)
    - [F63: generate super-reads](#f63-generate-super-reads)
    - [F63: create anchors](#f63-create-anchors)
    - [F63: results](#f63-results)
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
    - [F354: combinations of different quality values and read lengths](#f354-combinations-of-different-quality-values-and-read-lengths)
    - [F354: quorum](#f354-quorum)
    - [F354: down sampling](#f354-down-sampling)
    - [F354: k-unitigs and anchors (sampled)](#f354-k-unitigs-and-anchors-sampled)
    - [F354: merge anchors](#f354-merge-anchors)
- [F357, Botryococcus braunii, 布朗葡萄藻](#f357-botryococcus-braunii-布朗葡萄藻)
    - [F357: download](#f357-download)
    - [F357: combinations of different quality values and read lengths](#f357-combinations-of-different-quality-values-and-read-lengths)
    - [F357: down sampling](#f357-down-sampling)
    - [F357: generate super-reads](#f357-generate-super-reads)
    - [F357: create anchors](#f357-create-anchors)
    - [F357: results](#f357-results)
    - [F357: merge anchors](#f357-merge-anchors)
- [F1084, Staurastrum sp., 角星鼓藻](#f1084-staurastrumsp-角星鼓藻)
    - [F1084: download](#f1084-download)
    - [F1084: combinations of different quality values and read lengths](#f1084-combinations-of-different-quality-values-and-read-lengths)
    - [F1084: quorum](#f1084-quorum)
    - [F1084: down sampling](#f1084-down-sampling)
    - [F1084: k-unitigs and anchors (sampled)](#f1084-k-unitigs-and-anchors-sampled)
    - [F1084: merge anchors](#f1084-merge-anchors)
- [moli, 茉莉](#moli-茉莉)
    - [moli: download](#moli-download)
    - [moli: combinations of different quality values and read lengths](#moli-combinations-of-different-quality-values-and-read-lengths)
    - [moli: down sampling](#moli-down-sampling)
    - [moli: generate super-reads](#moli-generate-super-reads)
    - [moli: create anchors](#moli-create-anchors)
    - [moli: results](#moli-results)
    - [moli: merge anchors](#moli-merge-anchors)
- [ZS97, *Oryza sativa* Indica Group, Zhenshan 97](#zs97-oryza-sativa-indica-group-zhenshan-97)
    - [ZS97: download](#zs97-download)
    - [ZS97: combinations of different quality values and read lengths](#zs97-combinations-of-different-quality-values-and-read-lengths)
    - [ZS97: down sampling](#zs97-down-sampling)
    - [ZS97: generate super-reads](#zs97-generate-super-reads)
    - [ZS97: create anchors](#zs97-create-anchors)
    - [ZS97: results](#zs97-results)
    - [ZS97: merge anchors](#zs97-merge-anchors)
- [showa, Botryococcus braunii Showa](#showa-botryococcus-braunii-showa)
    - [showa: download](#showa-download)
    - [3GS](#3gs)
- [Summary of SR](#summary-of-sr)
- [Anchors](#anchors)


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
* len: 100, 120, and 140

```bash
BASE_DIR=$HOME/data/dna-seq/chara/F63

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
BASE_DIR=$HOME/data/dna-seq/chara/F63
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
| Illumina | 150 | 17261747100 | 115078314 |
| uniq     | 150 | 16706582100 | 111377214 |
| scythe   | 150 | 16683988065 | 111377214 |
| Q20L100  | 150 | 14064106170 |  95943160 |
| Q20L120  | 150 | 12784791661 |  86061004 |
| Q20L140  | 150 | 11338005962 |  75648034 |
| Q25L100  | 150 | 12129446162 |  83843372 |
| Q25L120  | 150 | 10368679856 |  70230526 |
| Q25L140  | 150 |  8346905236 |  55688048 |
| Q30L100  | 150 |  9784082281 |  69007902 |
| Q30L120  | 150 |  7472579656 |  51114488 |
| Q30L140  | 150 |  5113461839 |  34134008 |

## F63: down sampling

```bash
BASE_DIR=$HOME/data/dna-seq/chara/F63
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

## F63: generate super-reads

```bash
BASE_DIR=$HOME/data/dna-seq/chara/F63
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
BASE_DIR=$HOME/data/dna-seq/chara/F63

find . -type f -name "quorum_mer_db.jf"          | xargs rm
find . -type f -name "k_u_hash_0"                | xargs rm
find . -type f -name "readPositionsInSuperReads" | xargs rm
find . -type f -name "*.tmp"                     | xargs rm
find . -type f -name "pe.renamed.fastq"          | xargs rm
find . -type f -name "pe.cor.sub.fa"             | xargs rm
```

## F63: create anchors

```bash
BASE_DIR=$HOME/data/dna-seq/chara/F63
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

## F63: results

* Stats of super-reads

```bash
BASE_DIR=$HOME/data/dna-seq/chara/F63
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
BASE_DIR=$HOME/data/dna-seq/chara/F63
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
| Q20L100 | 14.06G | 140.6 |     149 |   49 | 10.85G |  22.878% |  100M | 264.94M |     2.65 | 305.46M |     0 | 3:04'26'' |
| Q20L120 | 12.78G | 127.8 |     149 |   49 | 10.04G |  21.463% |  100M | 255.94M |     2.56 | 287.95M |     0 | 2:51'00'' |
| Q20L140 | 11.34G | 113.4 |     149 |   49 |  9.06G |  20.096% |  100M | 244.75M |     2.45 | 270.05M |     0 | 2:36'45'' |
| Q25L100 | 12.13G | 121.3 |     149 |   49 | 10.12G |  16.541% |  100M | 251.57M |     2.52 | 276.69M |     0 | 2:35'01'' |
| Q25L120 | 10.37G | 103.7 |     149 |   49 |  8.74G |  15.716% |  100M | 237.36M |     2.37 | 257.71M |     0 | 2:18'33'' |
| Q25L140 |  8.35G |  83.5 |     149 |   49 |  7.09G |  15.063% |  100M | 217.35M |     2.17 | 233.92M |     0 | 1:54'37'' |
| Q30L100 |  9.78G |  97.8 |     149 |   49 |  8.59G |  12.206% |  100M | 232.33M |     2.32 | 250.83M |     0 | 1:52'26'' |
| Q30L120 |  7.47G |  74.7 |     149 |   49 |  6.57G |  12.043% |  100M | 207.46M |     2.07 | 222.47M |     0 | 1:19'47'' |
| Q30L140 |  5.11G |  51.1 |     149 |   49 |  4.48G |  12.298% |  100M | 173.01M |     1.73 | 184.71M |     0 | 0:59'48'' |

| Name    | N50SRclean |     Sum |      # | N50Anchor |     Sum |     # | N50Anchor2 |   Sum |    # | N50Others |     Sum |      # |   RunTime |
|:--------|-----------:|--------:|-------:|----------:|--------:|------:|-----------:|------:|-----:|----------:|--------:|-------:|----------:|
| Q20L100 |       1672 | 305.46M | 928875 |      6673 | 169.11M | 40418 |       1371 | 6.25M | 4429 |       208 | 130.11M | 884028 | 1:08'20'' |
| Q20L120 |       1878 | 287.95M | 752570 |      7401 | 165.59M | 38479 |       1378 | 6.79M | 4807 |       242 | 115.58M | 709284 | 1:06'39'' |
| Q20L140 |       2004 | 270.05M | 614804 |      8693 |  158.4M | 35398 |       1393 | 7.16M | 5030 |       285 | 104.49M | 574376 | 0:50'47'' |
| Q25L100 |       2331 | 276.69M | 610187 |      8895 | 169.94M | 37157 |       1361 | 5.63M | 4048 |       273 | 101.13M | 568982 | 0:41'05'' |
| Q25L120 |       2357 | 257.71M | 509081 |     10880 | 157.56M | 32621 |       1367 | 6.47M | 4639 |       320 |  93.68M | 471821 | 0:42'21'' |
| Q25L140 |       2352 | 233.92M | 430962 |     14555 | 139.42M | 25681 |       1343 | 6.31M | 4580 |       355 |  88.19M | 400701 | 0:36'40'' |
| Q30L100 |       2606 | 250.83M | 474545 |     13391 | 156.48M | 30585 |       1318 | 5.16M | 3807 |       323 |  89.19M | 440153 | 0:34'41'' |
| Q30L120 |       2788 | 222.47M | 398532 |     17406 | 133.62M | 22151 |       1315 | 4.69M | 3485 |       358 |  84.16M | 372896 | 0:48'06'' |
| Q30L140 |       3308 | 184.71M | 319433 |     14423 | 111.11M | 17506 |       1307 | 3.12M | 2314 |       346 |  70.49M | 299613 | 0:33'59'' |

## F63: merge anchors

```bash
BASE_DIR=$HOME/data/dna-seq/chara/F63
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
BASE_DIR=$HOME/data/dna-seq/chara/F63
cd ${BASE_DIR}

rm -fr 2_illumina/Q{20,25,30}L*
rm -fr Q{20,25,30}L*
```

* Stats

```bash
BASE_DIR=$HOME/data/dna-seq/chara/F63
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
| anchor.merge | 16425 | 190316977 | 33560 |
| others.merge |  1299 |  36603695 | 27612 |

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

* FastQC

```bash
BASE_NAME=F354
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

    if [ -e Q{1}L{2}X{3}P{4}/anchor/pe.anchor.fa ]; then
        exit;
    fi

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

## F357: combinations of different quality values and read lengths

* qual: 20, 25, and 30
* len: 60 and 90

```bash
BASE_DIR=$HOME/data/dna-seq/chara/F357

cd ${BASE_DIR}
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

cd ${BASE_DIR}
if [ ! -e 2_illumina/R1.scythe.fq.gz ]; then
    parallel --no-run-if-empty -j 2 "
        scythe \
            2_illumina/{}.uniq.fq.gz \
            -q sanger \
            -a /home/wangq/.plenv/versions/5.18.4/lib/perl5/site_perl/5.18.4/auto/share/dist/App-Anchr/illumina_adapters.fa \
            --quiet \
            | pigz -p 8 -c \
            > 2_illumina/{}.scythe.fq.gz
        " ::: R1 R2
fi

cd ${BASE_DIR}
parallel --no-run-if-empty -j 3 "
    mkdir -p 2_illumina/Q{1}L{2}
    cd 2_illumina/Q{1}L{2}
    
    if [ -e R1.fq.gz ]; then
        echo '    R1.fq.gz already presents'
        exit;
    fi

    anchr trim \
        --noscythe -p 8 \
        -q {1} -l {2} \
        ../R1.scythe.fq.gz ../R2.scythe.fq.gz \
        -o stdout \
        | bash
    " ::: 20 25 30 ::: 60 90

```

* Stats

```bash
BASE_DIR=$HOME/data/dna-seq/chara/F357
cd ${BASE_DIR}

printf "| %s | %s | %s | %s |\n" \
    "Name" "N50" "Sum" "#" \
    > stat.md
printf "|:--|--:|--:|--:|\n" >> stat.md

printf "| %s | %s | %s | %s |\n" \
    $(echo "Illumina"; faops n50 -H -S -C 2_illumina/R1.fq.gz 2_illumina/R2.fq.gz;) >> stat.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "uniq";     faops n50 -H -S -C 2_illumina/R1.uniq.fq.gz 2_illumina/R2.uniq.fq.gz;) >> stat.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "scythe";   faops n50 -H -S -C 2_illumina/R1.scythe.fq.gz 2_illumina/R2.scythe.fq.gz;) >> stat.md

parallel -k --no-run-if-empty -j 3 "
    printf \"| %s | %s | %s | %s |\n\" \
        \$( echo Q{1}L{2}; \
            faops n50 -H -S -C \
                ${BASE_DIR}/2_illumina/Q{1}L{2}/R1.fq.gz \
                ${BASE_DIR}/2_illumina/Q{1}L{2}/R2.fq.gz;
        )
    " ::: 20 25 30 ::: 60 90 \
    >> ${BASE_DIR}/stat.md

cat stat.md
```

| Name     | N50 |         Sum |         # |
|:---------|----:|------------:|----------:|
| Illumina | 150 | 22137245100 | 147581634 |
| uniq     | 150 | 20893186500 | 139287910 |
| scythe   | 150 | 20874578888 | 139287910 |
| Q20L60   | 150 | 19551261683 | 134470224 |
| Q20L90   | 150 | 19172674419 | 130991406 |
| Q25L60   | 150 | 17982435621 | 126850214 |
| Q25L90   | 150 | 17240761228 | 119891432 |
| Q30L60   | 150 | 15705476728 | 114892408 |
| Q30L90   | 150 | 14511548894 | 103581814 |

## F357: down sampling

```bash
BASE_DIR=$HOME/data/dna-seq/chara/F357
cd ${BASE_DIR}

# works on bash 3
ARRAY=(
    "2_illumina/Q20L60:Q20L60"
    "2_illumina/Q20L90:Q20L90"
    "2_illumina/Q25L60:Q25L60"
    "2_illumina/Q25L90:Q25L90"
    "2_illumina/Q30L60:Q30L60"
    "2_illumina/Q30L90:Q30L90"
)

for group in "${ARRAY[@]}" ; do
    GROUP_DIR=$(perl -e "@p = split q{:}, q{${group}}; print \$p[0];")
    GROUP_ID=$( perl -e "@p = split q{:}, q{${group}}; print \$p[1];")
    printf "==> %s \t %s\n" "$GROUP_DIR" "$GROUP_ID"

    echo "==> Group ${GROUP_ID}"
    DIR_COUNT="${BASE_DIR}/${GROUP_ID}"
    mkdir -p ${DIR_COUNT}
    
    if [ -e ${DIR_COUNT}/R1.fq.gz ]; then
        echo '    R1.fq.gz exists'        
        continue;
    fi
    
    ln -s ${BASE_DIR}/${GROUP_DIR}/R1.fq.gz ${DIR_COUNT}/R1.fq.gz
    ln -s ${BASE_DIR}/${GROUP_DIR}/R2.fq.gz ${DIR_COUNT}/R2.fq.gz
    ln -s ${BASE_DIR}/${GROUP_DIR}/Rs.fq.gz ${DIR_COUNT}/Rs.fq.gz

done

```

## F357: generate super-reads

```bash
BASE_DIR=$HOME/data/dna-seq/chara/F357
cd ${BASE_DIR}

perl -e '
    for my $n (
        qw{
        Q20L60 Q20L90
        Q25L60 Q25L90
        Q30L60 Q30L90
        }
        )
    {
        printf qq{%s\n}, $n;
    }
    ' \
    | parallel --no-run-if-empty -j 1 "
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
        string='My long string'
        if [[ {} == *'Q30'* ]]; then
            anchr superreads \
                R1.fq.gz R2.fq.gz Rs.fq.gz \
                --nosr -p 16 \
                --kmer 41,61,81,101,121 \
                -o superreads.sh
        else
            anchr superreads \
                R1.fq.gz R2.fq.gz \
                --nosr -p 16 \
                --kmer 41,61,81,101,121 \
                -o superreads.sh
        fi
        bash superreads.sh
    "

```

Clear intermediate files.

```bash
BASE_DIR=$HOME/data/dna-seq/chara/F357

find . -type f -name "quorum_mer_db.jf"          | xargs rm
find . -type f -name "k_u_hash_0"                | xargs rm
find . -type f -name "readPositionsInSuperReads" | xargs rm
find . -type f -name "*.tmp"                     | xargs rm
find . -type f -name "pe.renamed.fastq"          | xargs rm
find . -type f -name "pe.cor.sub.fa"             | xargs rm
```

## F357: create anchors

```bash
BASE_DIR=$HOME/data/dna-seq/chara/F357
cd ${BASE_DIR}

perl -e '
    for my $n (
        qw{
        Q20L60 Q20L90
        Q25L60 Q25L90
        Q30L60 Q30L90
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

## F357: results

* Stats of super-reads

```bash
BASE_DIR=$HOME/data/dna-seq/chara/F357
cd ${BASE_DIR}

REAL_G=100000000

bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 1 header \
    > ${BASE_DIR}/stat1.md

perl -e '
    for my $n (
        qw{
        Q20L60 Q20L90
        Q25L60 Q25L90
        Q30L60 Q30L90
        }
        )
    {
        printf qq{%s\n}, $n;
    }
    ' \
    | parallel -k --no-run-if-empty -j 1 "
        if [ ! -d ${BASE_DIR}/{} ]; then
            exit;
        fi

        bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 1 ${BASE_DIR}/{} ${REAL_G}
    " >> ${BASE_DIR}/stat1.md

cat stat1.md
```

* Stats of anchors

```bash
BASE_DIR=$HOME/data/dna-seq/chara/F357
cd ${BASE_DIR}

bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 header \
    > ${BASE_DIR}/stat2.md

perl -e '
    for my $n (
        qw{
        Q20L60 Q20L90
        Q25L60 Q25L90
        Q30L60 Q30L90
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

## F357: merge anchors

```bash
BASE_DIR=$HOME/data/dna-seq/chara/F357
cd ${BASE_DIR}

# merge anchors
mkdir -p merge
anchr contained \
    Q20L60/anchor/pe.anchor.fa \
    Q20L90/anchor/pe.anchor.fa \
    Q25L60/anchor/pe.anchor.fa \
    Q25L90/anchor/pe.anchor.fa \
    Q30L60/anchor/pe.anchor.fa \
    Q30L90/anchor/pe.anchor.fa \
    --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
    -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/anchor.contained.fasta
anchr orient merge/anchor.contained.fasta --len 1000 --idt 0.98 -o merge/anchor.orient.fasta
anchr merge merge/anchor.orient.fasta --len 1000 --idt 0.999 -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/anchor.merge.fasta

# merge others
anchr contained \
    Q20L60/anchor/pe.others.fa \
    Q20L90/anchor/pe.others.fa \
    Q25L60/anchor/pe.others.fa \
    Q25L90/anchor/pe.others.fa \
    Q30L60/anchor/pe.others.fa \
    Q30L90/anchor/pe.others.fa \
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
    Q20L60/anchor/pe.anchor.fa \
    Q20L90/anchor/pe.anchor.fa \
    Q25L60/anchor/pe.anchor.fa \
    Q25L90/anchor/pe.anchor.fa \
    Q30L60/anchor/pe.anchor.fa \
    Q30L90/anchor/pe.anchor.fa \
    merge/anchor.merge.fasta \
    merge/others.merge.fasta \
    --label "Q20L60,Q20L90,Q25L60,Q25L90,Q30L60,Q30L90,merge,others" \
    -o 9_qa

```

* Clear QxxLxxx.

```bash
BASE_DIR=$HOME/data/dna-seq/chara/F357
cd ${BASE_DIR}

#rm -fr 2_illumina/Q{20,25,30}L*
rm -fr Q{20,25,30}L*
```

* Stats

```bash
BASE_DIR=$HOME/data/dna-seq/chara/F357
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
| anchor.merge | 28436 | 158392737 | 36505 |
| others.merge |  1048 |   9455311 |  8593 |

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

    if [ -e Q{1}L{2}X{3}P{4}/anchor/pe.anchor.fa ]; then
        exit;
    fi

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
# quast
rm -fr 9_qa
quast --no-check --threads 16 \
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
| anchor.merge | 8976 | 122233147 | 26448 |
| others.merge | 1204 |   4466297 |  3577 |

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

# moli, 茉莉

SR had failed twice due to the calculating results from awk were larger
than the MAX_INT

* for jellyfish
* for --number-reads of
  `getSuperReadInsertCountsFromReadPlacementFileTwoPasses`

```bash
mkdir -p ~/data/dna-seq/chara/medfood
cd ~/data/dna-seq/chara/medfood

# 200 M Reads
zcat ~/zlc/medfood/moli/lane5ml_R1.fq.gz \
    | head -n 800000000 \
    | pigz -p 4 -c \
    > R1.fq.gz

zcat ~/zlc/medfood/moli/lane5ml_R2.fq.gz \
    | head -n 800000000 \
    | gzip > R2.fq.gz

perl ~/Scripts/sra/superreads.pl \
    R1.fq.gz \
    R2.fq.gz \
    -s 300 -d 30 -p 16 --jf 10_000_000_000
```


## moli: download

```bash
mkdir -p ~/data/dna-seq/chara/moli/2_illumina
cd ~/data/dna-seq/chara/moli/2_illumina

ln -s ~/data/dna-seq/chara/medfood/lane5ml_R1.fq.gz R1.fq.gz
ln -s ~/data/dna-seq/chara/medfood/lane5ml_R2.fq.gz R2.fq.gz
```

## moli: combinations of different quality values and read lengths

* qual: 20 and 25
* len: 100, 120, and 140

```bash
BASE_DIR=$HOME/data/dna-seq/chara/moli

cd ${BASE_DIR}
tally \
    --pair-by-offset --with-quality --nozip --unsorted \
    -sumstat 2_illumina/tally.sumstat.txt \
    -i 2_illumina/R1.fq.gz \
    -j 2_illumina/R2.fq.gz \
    -o 2_illumina/R1.uniq.fq \
    -p 2_illumina/R2.uniq.fq

parallel --no-run-if-empty -j 2 "
    pigz -p 4 2_illumina/{}.uniq.fq
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
        ../R1.uniq.fq.gz ../R2.uniq.fq.gz \
        -o stdout \
        | bash
    " ::: 20 25 ::: 100 120 140

```

* Stats

```bash
BASE_DIR=$HOME/data/dna-seq/chara/moli
cd ${BASE_DIR}

printf "| %s | %s | %s | %s |\n" \
    "Name" "N50" "Sum" "#" \
    > stat.md
printf "|:--|--:|--:|--:|\n" >> stat.md

printf "| %s | %s | %s | %s |\n" \
    $(echo "Illumina"; faops n50 -H -S -C 2_illumina/R1.fq.gz 2_illumina/R2.fq.gz;) >> stat.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "uniq";   faops n50 -H -S -C 2_illumina/R1.uniq.fq.gz 2_illumina/R2.uniq.fq.gz;) >> stat.md

for qual in 20 25; do
    for len in 100 120 140; do
        DIR_COUNT="${BASE_DIR}/2_illumina/Q${qual}L${len}"

        printf "| %s | %s | %s | %s |\n" \
            $(echo "Q${qual}L${len}"; faops n50 -H -S -C ${DIR_COUNT}/R1.fq.gz  ${DIR_COUNT}/R2.fq.gz;) \
            >> stat.md
    done
done

cat stat.md
```

| Name     | N50 |          Sum |         # |
|:---------|----:|-------------:|----------:|
| Illumina | 150 | 131208907200 | 874726048 |
| uniq     | 150 | 108022731300 | 720151542 |
| Q20L100  | 150 |  99447660517 | 669337434 |
| Q20L120  | 150 |  96283521937 | 644827784 |
| Q20L140  | 150 |  90797417755 | 605412990 |
| Q25L100  | 150 |  89342502638 | 605173772 |
| Q25L120  | 150 |  84446237212 | 567043586 |
| Q25L140  | 150 |  76712262430 | 511489372 |

## moli: down sampling

```bash
BASE_DIR=$HOME/data/dna-seq/chara/moli
cd ${BASE_DIR}

# works on bash 3
ARRAY=(
    "2_illumina/Q20L100:Q20L100"
    "2_illumina/Q20L120:Q20L120"
    "2_illumina/Q20L140:Q20L140"
    "2_illumina/Q25L100:Q25L100"
    "2_illumina/Q25L120:Q25L120"
    "2_illumina/Q25L140:Q25L140"
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

## moli: generate super-reads

```bash
BASE_DIR=$HOME/data/dna-seq/chara/moli
cd ${BASE_DIR}

perl -e '
    for my $n (
        qw{
        Q20L100 Q20L120 Q20L140
        Q25L100 Q25L120 Q25L140
        }
        )
    {
        printf qq{%s\n}, $n;
    }
    ' \
    | parallel --no-run-if-empty -j 1 "
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
            --nosr -p 16 --jf 10_000_000_000 \
            -o superreads.sh
        bash superreads.sh
    "

```

Clear intermediate files.

```bash
BASE_DIR=$HOME/data/dna-seq/chara/moli

find . -type f -name "quorum_mer_db.jf"          | xargs rm
find . -type f -name "k_u_hash_0"                | xargs rm
find . -type f -name "readPositionsInSuperReads" | xargs rm
find . -type f -name "*.tmp"                     | xargs rm
find . -type f -name "pe.renamed.fastq"          | xargs rm
find . -type f -name "pe.cor.sub.fa"             | xargs rm
```

## moli: create anchors

```bash
BASE_DIR=$HOME/data/dna-seq/chara/moli
cd ${BASE_DIR}

perl -e '
    for my $n (
        qw{
        Q20L100 Q20L120 Q20L140
        Q25L100 Q25L120 Q25L140
        }
        )
    {
        printf qq{%s\n}, $n;
    }
    ' \
    | parallel --no-run-if-empty -j 1 "
        echo '==> Group {}'

        if [ -e ${BASE_DIR}/{}/anchor/pe.anchor.fa ]; then
            exit;
        fi

        rm -fr ${BASE_DIR}/{}/anchor
        bash ~/Scripts/cpan/App-Anchr/share/anchor.sh ${BASE_DIR}/{} 16 false
    "

```

## moli: results

* Stats of super-reads

```bash
BASE_DIR=$HOME/data/dna-seq/chara/moli
cd ${BASE_DIR}

REAL_G=600000000

bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 1 header \
    > ${BASE_DIR}/stat1.md

perl -e '
    for my $n (
        qw{
        Q20L100 Q20L120 Q20L140
        Q25L100 Q25L120 Q25L140
        }
        )
    {
        printf qq{%s\n}, $n;
    }
    ' \
    | parallel -k --no-run-if-empty -j 1 "
        if [ ! -d ${BASE_DIR}/{} ]; then
            exit;
        fi

        bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 1 ${BASE_DIR}/{} ${REAL_G}
    " >> ${BASE_DIR}/stat1.md

cat stat1.md
```

* Stats of anchors

```bash
BASE_DIR=$HOME/data/dna-seq/chara/moli
cd ${BASE_DIR}

bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 header \
    > ${BASE_DIR}/stat2.md

perl -e '
    for my $n (
        qw{
        Q20L100 Q20L120 Q20L140
        Q25L100 Q25L120 Q25L140
        }
        )
    {
        printf qq{%s\n}, $n;
    }
    ' \
    | parallel -k --no-run-if-empty -j 4 "
        if [ ! -e ${BASE_DIR}/{}/anchor/pe.anchor.fa ]; then
            exit;
        fi

        bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 ${BASE_DIR}/{}
    " >> ${BASE_DIR}/stat2.md

cat stat2.md
```

## moli: merge anchors

```bash
BASE_DIR=$HOME/data/dna-seq/chara/moli
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
    --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
    -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/anchor.contained.fasta
anchr orient merge/anchor.contained.fasta --len 1000 --idt 0.98 -o merge/anchor.orient.fasta
anchr merge merge/anchor.orient.fasta --len 1000 --idt 0.999 -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/anchor.merge.fasta

# merge anchor2 and others
anchr contained \
    Q20L100/anchor/pe.anchor2.fa \
    Q20L120/anchor/pe.anchor2.fa \
    Q20L140/anchor/pe.anchor2.fa \
    Q25L100/anchor/pe.anchor2.fa \
    Q25L120/anchor/pe.anchor2.fa \
    Q25L140/anchor/pe.anchor2.fa \
    Q20L100/anchor/pe.others.fa \
    Q20L120/anchor/pe.others.fa \
    Q20L140/anchor/pe.others.fa \
    Q25L100/anchor/pe.others.fa \
    Q25L120/anchor/pe.others.fa \
    Q25L140/anchor/pe.others.fa \
    --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
    -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/others.contained.fasta
anchr orient merge/others.contained.fasta --len 1000 --idt 0.98 -o merge/others.orient.fasta
anchr merge merge/others.orient.fasta --len 1000 --idt 0.999 -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/others.merge.fasta

# quast
rm -fr 9_qa
quast --no-check --threads 16 \
    Q20L100/anchor/pe.anchor.fa \
    Q25L100/anchor/pe.anchor.fa \
    merge/anchor.merge.fasta \
    merge/others.merge.fasta \
    --label "Q20L100,Q25L100,merge,others" \
    -o 9_qa

```

* Clear QxxLxxx.

```bash
BASE_DIR=$HOME/data/dna-seq/chara/moli
cd ${BASE_DIR}

rm -fr 2_illumina/Q{20,25,30}L*
rm -fr Q{20,25,30}L*
```

* Stats

```bash
BASE_DIR=$HOME/data/dna-seq/chara/moli
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

# ZS97, *Oryza sativa* Indica Group, Zhenshan 97

## ZS97: download

* Reference genome

    * GenBank assembly accession: GCA_001623345.1
    * Assembly name: ZS97RS1

```bash
mkdir -p ~/data/dna-seq/chara/ZS97/1_genome
cd ~/data/dna-seq/chara/ZS97/1_genome

aria2c -x 9 -s 3 -c ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/001/623/345/GCA_001623345.1_ZS97RS1/GCA_001623345.1_ZS97RS1_genomic.fna.gz

TAB=$'\t'
cat <<EOF > replace.tsv
CM003910.1${TAB}1
CM003911.1${TAB}2
CM003912.1${TAB}3
CM003913.1${TAB}4
CM003914.1${TAB}5
CM003915.1${TAB}6
CM003916.1${TAB}7
CM003917.1${TAB}8
CM003918.1${TAB}9
CM003919.1${TAB}10
CM003920.1${TAB}11
CM003921.1${TAB}12
EOF

faops replace GCA_001623345.1_ZS97RS1_genomic.fna.gz replace.tsv stdout \
    | faops some stdin <(for chr in $(seq 1 1 12); do echo $chr; done) \
        genome.fa

```

* Illumina

    * small-insert (~300 bp) pair-end WGS (2x100 bp read length)
    * ENA hasn't synced with SRA for SRX1639981 (SRR3234372), download from NCBI ftp.
    * `ftp://ftp-trace.ncbi.nih.gov`
    * `/sra/sra-instant/reads/ByRun/sra/{SRR|ERR|DRR}/<first 6 characters of accession>/<accession>/<accession>.sra`

```bash
mkdir -p ~/data/dna-seq/chara/ZS97/2_illumina
cd ~/data/dna-seq/chara/ZS97/2_illumina

aria2c -x 9 -s 3 -c ftp://ftp-trace.ncbi.nih.gov/sra/sra-instant/reads/ByRun/sra/SRR/SRR323/SRR3234372/SRR3234372.sra

fastq-dump --split-files ./SRR3234372.sra  
find . -name "*.fastq" | parallel -j 2 pigz -p 4

ln -s SRR3234372_1.fastq.gz R1.fq.gz
ln -s SRR3234372_2.fastq.gz R2.fq.gz
```

## ZS97: combinations of different quality values and read lengths

* qual: 20, 25, and 30
* len: 80, 90, and 100
* Peak memory: 138 GiB

```bash
BASE_DIR=$HOME/data/dna-seq/chara/ZS97

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
        ../R1.uniq.fq.gz ../R2.uniq.fq.gz \
        -o stdout \
        | bash
    " ::: 20 25 30 ::: 80 90 100

```

* Stats

```bash
BASE_DIR=$HOME/data/dna-seq/chara/ZS97
cd ${BASE_DIR}

printf "| %s | %s | %s | %s |\n" \
    "Name" "N50" "Sum" "#" \
    > stat.md
printf "|:--|--:|--:|--:|\n" >> stat.md

printf "| %s | %s | %s | %s |\n" \
    $(echo "Genome";   faops n50 -H -S -C 1_genome/genome.fa;) >> stat.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "Illumina"; faops n50 -H -S -C 2_illumina/R1.fq.gz 2_illumina/R2.fq.gz;) >> stat.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "uniq";   faops n50 -H -S -C 2_illumina/R1.uniq.fq.gz 2_illumina/R2.uniq.fq.gz;) >> stat.md

for qual in 20 25 30; do
    for len in 80 90 100; do
        DIR_COUNT="${BASE_DIR}/2_illumina/Q${qual}L${len}"

        printf "| %s | %s | %s | %s |\n" \
            $(echo "Q${qual}L${len}"; faops n50 -H -S -C ${DIR_COUNT}/R1.fq.gz  ${DIR_COUNT}/R2.fq.gz;) \
            >> stat.md
    done
done

cat stat.md
```

| Name     |      N50 |         Sum |         # |
|:---------|---------:|------------:|----------:|
| Genome   | 27449063 |   346663259 |        12 |
| Illumina |      101 | 34167671982 | 338293782 |
| uniq     |      101 | 33822673960 | 334877960 |
| Q20L80   |      101 | 27509564301 | 274005300 |
| Q20L90   |      101 | 26420936235 | 262191534 |
| Q20L100  |      101 | 24875667710 | 246295934 |
| Q25L80   |      101 | 25468071680 | 254040008 |
| Q25L90   |      101 | 24165258568 | 239891008 |
| Q25L100  |      101 | 22398762768 | 221771944 |
| Q30L80   |      101 | 21543805317 | 216094884 |
| Q30L90   |      101 | 19651096465 | 195479350 |
| Q30L100  |      101 | 17178948122 | 170094520 |

## ZS97: down sampling

```bash
BASE_DIR=$HOME/data/dna-seq/chara/ZS97
cd ${BASE_DIR}

# works on bash 3
ARRAY=(
    "2_illumina/Q20L80:Q20L80"
    "2_illumina/Q20L90:Q20L90"
    "2_illumina/Q20L100:Q20L100"
    "2_illumina/Q25L80:Q25L80"
    "2_illumina/Q25L90:Q25L90"
    "2_illumina/Q25L100:Q25L100"
    "2_illumina/Q30L80:Q30L80"
    "2_illumina/Q30L90:Q30L90"
    "2_illumina/Q30L100:Q30L100"
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

## ZS97: generate super-reads

```bash
BASE_DIR=$HOME/data/dna-seq/chara/ZS97
cd ${BASE_DIR}

perl -e '
    for my $n (
        qw{
        Q20L80 Q20L90 Q20L100
        Q25L80 Q25L90 Q25L100
        Q30L80 Q30L90 Q30L100
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
BASE_DIR=$HOME/data/dna-seq/chara/ZS97

find . -type f -name "quorum_mer_db.jf"          | xargs rm
find . -type f -name "k_u_hash_0"                | xargs rm
find . -type f -name "readPositionsInSuperReads" | xargs rm
find . -type f -name "*.tmp"                     | xargs rm
find . -type f -name "pe.renamed.fastq"          | xargs rm
find . -type f -name "pe.cor.sub.fa"             | xargs rm
```

## ZS97: create anchors

```bash
BASE_DIR=$HOME/data/dna-seq/chara/ZS97
cd ${BASE_DIR}

perl -e '
    for my $n (
        qw{
        Q20L80 Q20L90 Q20L100
        Q25L80 Q25L90 Q25L100
        Q30L80 Q30L90 Q30L100
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

## ZS97: results

* Stats of super-reads

```bash
BASE_DIR=$HOME/data/dna-seq/chara/ZS97
cd ${BASE_DIR}

REAL_G=346663259

bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 1 header \
    > ${BASE_DIR}/stat1.md

perl -e '
    for my $n (
        qw{
        Q20L80 Q20L90 Q20L100
        Q25L80 Q25L90 Q25L100
        Q30L80 Q30L90 Q30L100
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
BASE_DIR=$HOME/data/dna-seq/chara/ZS97
cd ${BASE_DIR}

bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 header \
    > ${BASE_DIR}/stat2.md

perl -e '
    for my $n (
        qw{
        Q20L80 Q20L90 Q20L100
        Q25L80 Q25L90 Q25L100
        Q30L80 Q30L90 Q30L100
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

| Name    |  SumFq | CovFq | AvgRead | Kmer |  SumFa | Discard% |   RealG |    EstG | Est/Real |   SumKU | SumSR |    RunTime |
|:--------|-------:|------:|--------:|-----:|-------:|---------:|--------:|--------:|---------:|--------:|------:|-----------:|
| Q20L80  | 27.51G |  79.4 |     100 |   71 | 24.81G |   9.816% | 346.66M | 299.04M |     0.86 | 494.05M |     0 |  7:03'18'' |
| Q20L90  | 26.42G |  76.2 |     100 |   71 | 23.88G |   9.618% | 346.66M | 296.67M |     0.86 | 485.54M |     0 |  7:00'46'' |
| Q20L100 | 24.88G |  71.8 |     100 |   71 | 22.53G |   9.429% | 346.66M | 293.56M |     0.85 | 475.96M |     0 |  5:57'27'' |
| Q25L80  | 25.47G |  73.5 |     100 |   71 | 23.28G |   8.606% | 346.66M | 295.26M |     0.85 | 476.37M |     0 | 11:25'02'' |
| Q25L90  | 24.17G |  69.7 |     100 |   71 |  22.1G |   8.555% | 346.66M | 291.74M |     0.84 | 467.42M |     0 |  9:33'15'' |
| Q25L100 |  22.4G |  64.6 |     101 |   71 | 20.49G |   8.526% | 346.66M | 287.75M |     0.83 | 458.16M |     0 |  9:07'50'' |
| Q30L80  | 21.54G |  62.1 |     100 |   71 | 19.96G |   7.330% | 346.66M | 286.34M |     0.83 | 453.34M |     0 |  4:33'34'' |
| Q30L90  | 19.65G |  56.7 |     100 |   71 |  18.2G |   7.403% | 346.66M | 279.92M |     0.81 | 440.08M |     0 |  3:34'32'' |
| Q30L100 | 17.18G |  49.6 |     100 |   71 | 15.89G |   7.512% | 346.66M | 272.98M |     0.79 |  426.6M |     0 |  3:23'28'' |

| Name    | N50SRclean |     Sum |       # | N50Anchor |     Sum |     # | N50Anchor2 |    Sum |  # | N50Others |     Sum |       # |   RunTime |
|:--------|-----------:|--------:|--------:|----------:|--------:|------:|-----------:|-------:|---:|----------:|--------:|--------:|----------:|
| Q20L80  |        787 | 494.05M | 2279248 |      3775 | 235.04M | 78151 |       1240 |  3.54K |  3 |       116 |    259M | 2201094 | 2:58'42'' |
| Q20L90  |        814 | 485.54M | 2206092 |      3737 | 232.18M | 77882 |       1240 |  5.05K |  4 |       120 | 253.35M | 2128206 | 3:11'57'' |
| Q20L100 |        822 | 475.96M | 2134325 |      3629 | 227.49M | 77934 |       1122 |  6.04K |  5 |       126 | 248.47M | 2056386 | 3:07'38'' |
| Q25L80  |        843 | 476.37M | 2114878 |      3671 | 229.19M | 77775 |       1240 |  1.24K |  1 |       128 | 247.18M | 2037102 | 2:36'55'' |
| Q25L90  |        851 | 467.42M | 2052009 |      3586 | 224.83M | 77689 |       1191 |  6.99K |  6 |       132 | 242.59M | 1974314 | 2:36'11'' |
| Q25L100 |        838 | 458.16M | 1994680 |      3446 | 219.02M | 77690 |       1121 | 10.31K |  9 |       136 | 239.13M | 1916981 | 2:34'30'' |
| Q30L80  |        760 | 453.34M | 1984260 |      3260 | 210.69M | 77948 |       1186 |   3.5K |  3 |       139 | 242.64M | 1906309 | 2:13'18'' |
| Q30L90  |        777 | 440.08M | 1892634 |      3163 | 204.68M | 77429 |       1143 |  6.93K |  6 |       141 |  235.4M | 1815199 | 2:07'40'' |
| Q30L100 |        753 |  426.6M | 1819140 |      2993 |  195.4M | 76909 |       1184 | 12.95K | 11 |       141 | 231.19M | 1742220 | 1:58'50'' |

## ZS97: merge anchors

```bash
BASE_DIR=$HOME/data/dna-seq/chara/ZS97
cd ${BASE_DIR}

# merge anchors
mkdir -p merge
anchr contained \
    Q20L80/anchor/pe.anchor.fa \
    Q20L90/anchor/pe.anchor.fa \
    Q20L100/anchor/pe.anchor.fa \
    Q25L80/anchor/pe.anchor.fa \
    Q25L90/anchor/pe.anchor.fa \
    Q25L100/anchor/pe.anchor.fa \
    Q30L80/anchor/pe.anchor.fa \
    Q30L90/anchor/pe.anchor.fa \
    Q30L100/anchor/pe.anchor.fa \
    --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
    -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/anchor.contained.fasta
anchr orient merge/anchor.contained.fasta --len 1000 --idt 0.98 -o merge/anchor.orient.fasta
anchr merge merge/anchor.orient.fasta --len 1000 --idt 0.999 -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/anchor.merge.fasta

# merge anchor2 and others
anchr contained \
    Q20L80/anchor/pe.anchor2.fa \
    Q20L90/anchor/pe.anchor2.fa \
    Q20L100/anchor/pe.anchor2.fa \
    Q25L80/anchor/pe.anchor2.fa \
    Q25L90/anchor/pe.anchor2.fa \
    Q25L100/anchor/pe.anchor2.fa \
    Q30L80/anchor/pe.anchor2.fa \
    Q30L90/anchor/pe.anchor2.fa \
    Q30L100/anchor/pe.anchor2.fa \
    Q20L80/anchor/pe.others.fa \
    Q20L90/anchor/pe.others.fa \
    Q20L100/anchor/pe.others.fa \
    Q25L80/anchor/pe.others.fa \
    Q25L90/anchor/pe.others.fa \
    Q25L100/anchor/pe.others.fa \
    Q30L80/anchor/pe.others.fa \
    Q30L90/anchor/pe.others.fa \
    Q30L100/anchor/pe.others.fa \
    --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
    -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/others.contained.fasta
anchr orient merge/others.contained.fasta --len 1000 --idt 0.98 -o merge/others.orient.fasta
anchr merge merge/others.orient.fasta --len 1000 --idt 0.999 -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/others.merge.fasta

# sort on ref
bash ~/Scripts/cpan/App-Anchr/share/sort_on_ref.sh merge/anchor.merge.fasta 1_genome/genome.fa merge/anchor.sort
nucmer -l 200 1_genome/genome.fa merge/anchor.sort.fa
mummerplot -png out.delta -p anchor.sort --large

# mummerplot files
rm *.[fr]plot
rm out.delta
rm *.gp

mv anchor.sort.png merge/

# quast
quast --no-check --threads 16 \
    -R 1_genome/genome.fa \
    merge/anchor.merge.fasta \
    merge/others.merge.fasta \
    --label "merge,others" \
    -o 9_qa

```

* Clear QxxLxxx.

```bash
BASE_DIR=$HOME/data/dna-seq/chara/ZS97
cd ${BASE_DIR}

rm -fr 2_illumina/Q{20,25,30}L*
rm -fr Q{20,25,30}L*
```

* Stats

```bash
BASE_DIR=$HOME/data/dna-seq/chara/ZS97
cd ${BASE_DIR}

printf "| %s | %s | %s | %s |\n" \
    "Name" "N50" "Sum" "#" \
    > stat3.md
printf "|:--|--:|--:|--:|\n" >> stat3.md

printf "| %s | %s | %s | %s |\n" \
    $(echo "Genome";   faops n50 -H -S -C 1_genome/genome.fa;) >> stat3.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "anchor.merge"; faops n50 -H -S -C merge/anchor.merge.fasta;) >> stat3.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "others.merge"; faops n50 -H -S -C merge/others.merge.fasta;) >> stat3.md

cat stat3.md
```

| Name         |      N50 |       Sum |     # |
|:-------------|---------:|----------:|------:|
| Genome       | 27449063 | 346663259 |    12 |
| anchor.merge |     4229 | 240033952 | 73761 |
| others.merge |     1007 |   2823559 |  2793 |


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

## 3GS

```bash
BASE_DIR=$HOME/data/dna-seq/chara/showa
cd ${BASE_DIR}

canu \
    -p showa -d canu-raw-40x \
    gnuplot=$(brew --prefix)/Cellar/$(brew list --versions gnuplot | sed 's/ /\//')/bin/gnuplot \
    genomeSize=184.4m \
    -pacbio-raw 3_pacbio/pacbio.40x.fasta

faops n50 -S -C canu-raw-40x/ecoli.trimmedReads.fasta.gz
faops n50 -S -C canu-raw-80x/ecoli.trimmedReads.fasta.gz

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

