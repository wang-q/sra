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
    - [F354: down sampling](#f354-down-sampling)
    - [F354: generate super-reads](#f354-generate-super-reads)
    - [F354: create anchors](#f354-create-anchors)
    - [F354: results](#f354-results)
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
    - [F1084: down sampling](#f1084-down-sampling)
    - [F1084: generate super-reads](#f1084-generate-super-reads)
    - [F1084: create anchors](#f1084-create-anchors)
    - [F1084: results](#f1084-results)
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

## F354: combinations of different quality values and read lengths

* qual: 20, 25, and 30
* len: 60 and 90

```bash
BASE_DIR=$HOME/data/dna-seq/chara/F354

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
BASE_DIR=$HOME/data/dna-seq/chara/F354
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
| Illumina | 150 | 18458643300 | 123057622 |
| uniq     | 150 | 17588350800 | 117255672 |
| scythe   | 150 | 17573329056 | 117255672 |
| Q20L60   | 150 | 16500940475 | 113760264 |
| Q20L90   | 150 | 16130269250 | 110315612 |
| Q25L60   | 150 | 15288148644 | 107698238 |
| Q25L90   | 150 | 14633775486 | 101458342 |
| Q30L60   | 150 | 13641553993 |  98681978 |
| Q30L90   | 150 | 12714214258 |  89728110 |

## F354: down sampling

```bash
BASE_DIR=$HOME/data/dna-seq/chara/F354
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

## F354: generate super-reads

```bash
BASE_DIR=$HOME/data/dna-seq/chara/F354
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

## F354: results

* Stats of super-reads

```bash
BASE_DIR=$HOME/data/dna-seq/chara/F354
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
BASE_DIR=$HOME/data/dna-seq/chara/F354
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
    | parallel -k --no-run-if-empty -j 4 "
        if [ ! -e ${BASE_DIR}/{}/anchor/pe.anchor.fa ]; then
            exit;
        fi

        bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 ${BASE_DIR}/{}
    " >> ${BASE_DIR}/stat2.md

cat stat2.md
```

| Name   |  SumFq | CovFq | AvgRead |               Kmer |  SumFa | Discard% | RealG |    EstG | Est/Real |  SumKU | SumSR |   RunTime |
|:-------|-------:|------:|--------:|-------------------:|-------:|---------:|------:|--------:|---------:|-------:|------:|----------:|
| Q20L60 |  16.5G | 165.0 |     149 | "41,61,81,101,121" | 13.45G |  18.483% |  100M | 113.17M |     1.13 | 98.49M |     0 | 2:10'00'' |
| Q20L90 | 16.13G | 161.3 |     149 | "41,61,81,101,121" | 13.24G |  17.902% |  100M | 111.95M |     1.12 | 98.04M |     0 | 2:00'12'' |
| Q25L60 | 15.29G | 152.9 |     149 | "41,61,81,101,121" | 13.35G |  12.706% |  100M | 109.44M |     1.09 |    99M |     0 | 2:00'53'' |
| Q25L90 | 14.63G | 146.3 |     149 | "41,61,81,101,121" | 12.84G |  12.249% |  100M | 107.54M |     1.08 | 97.23M |     0 | 1:59'43'' |
| Q30L60 | 13.64G | 136.4 |     149 | "41,61,81,101,121" | 13.16G |   3.507% |  100M | 107.09M |     1.07 |  96.5M |     0 | 1:51'56'' |
| Q30L90 | 12.71G | 127.1 |     149 | "41,61,81,101,121" | 12.75G |  -0.262% |  100M |  105.9M |     1.06 | 95.23M |     0 | 1:49'42'' |

| Name   | N50SR |    Sum |     # | N50Anchor |    Sum |     # | N50Others |    Sum |     # |   RunTime |
|:-------|------:|-------:|------:|----------:|-------:|------:|----------:|-------:|------:|----------:|
| Q20L60 |  2646 | 98.49M | 53936 |      4028 | 77.55M | 24827 |       739 | 20.94M | 29109 | 0:45'01'' |
| Q20L90 |  2732 | 98.04M | 52720 |      4219 | 77.61M | 24358 |       741 | 20.44M | 28362 | 0:57'05'' |
| Q25L60 |  4455 |    99M | 42654 |      7229 | 83.33M | 20926 |       743 | 15.68M | 21728 | 1:04'07'' |
| Q25L90 |  5047 | 97.23M | 40630 |      8739 | 82.04M | 19590 |       743 | 15.18M | 21040 | 0:33'43'' |
| Q30L60 | 14852 |  96.5M | 34680 |     25277 | 82.39M | 14978 |       736 | 14.11M | 19702 | 0:40'43'' |
| Q30L90 | 16920 | 95.23M | 33982 |     27953 | 81.12M | 14273 |       734 |  14.1M | 19709 | 0:37'39'' |

## F354: merge anchors

```bash
BASE_DIR=$HOME/data/dna-seq/chara/F354
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

* Stats

```bash
BASE_DIR=$HOME/data/dna-seq/chara/F354
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

| Name         |   N50 |      Sum |     # |
|:-------------|------:|---------:|------:|
| anchor.merge | 22876 | 88627022 | 16699 |
| others.merge |  1051 |  3339709 |  3042 |

* Clear QxxLxxx.

```bash
BASE_DIR=$HOME/data/dna-seq/chara/F354
cd ${BASE_DIR}

rm -fr 2_illumina/Q{20,25,30}L*
rm -fr Q{20,25,30}L*
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
| Q20L100  | 150 | 18821779024 | 128065192 |
| Q20L120  | 150 | 17413050886 | 117147166 |
| Q20L140  | 150 | 15575746654 | 103911868 |
| Q25L100  | 150 | 16714664673 | 115471956 |
| Q25L120  | 150 | 14461226581 |  97970652 |
| Q25L140  | 150 | 11649989635 |  77717480 |
| Q30L100  | 150 | 13733904796 |  97022702 |
| Q30L120  | 150 | 10542460646 |  72171522 |
| Q30L140  | 150 |  7180694622 |  47919736 |

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

| Name    |  SumFq | CovFq | AvgRead | Kmer |  SumFa | Discard% | RealG |    EstG | Est/Real |   SumKU | SumSR |   RunTime |
|:--------|-------:|------:|--------:|-----:|-------:|---------:|------:|--------:|---------:|--------:|------:|----------:|
| Q20L100 | 18.82G | 188.2 |     149 |   49 | 15.21G |  19.175% |  100M | 267.19M |     2.67 |  371.6M |     0 | 8:15'30'' |
| Q20L120 | 17.41G | 174.1 |     149 |   49 | 14.25G |  18.157% |  100M | 255.82M |     2.56 | 339.45M |     0 | 6:18'13'' |
| Q20L140 | 15.58G | 155.8 |     149 |   49 | 12.92G |  17.027% |  100M |  242.5M |     2.42 | 307.17M |     0 | 3:47'58'' |
| Q25L100 | 16.71G | 167.1 |     149 |   49 | 14.47G |  13.435% |  100M | 249.62M |     2.50 | 310.94M |     0 | 6:14'53'' |
| Q25L120 | 14.46G | 144.6 |     149 |   49 | 12.61G |  12.776% |  100M | 234.43M |     2.34 | 282.74M |     0 | 5:45'28'' |
| Q25L140 | 11.65G | 116.5 |     149 |   49 | 10.23G |  12.210% |  100M | 214.35M |     2.14 | 251.02M |     0 | 3:54'30'' |
| Q30L100 | 13.73G | 137.3 |     149 |   49 | 12.49G |   9.053% |  100M | 228.06M |     2.28 | 267.78M |     0 | 4:13'50'' |
| Q30L120 | 10.54G | 105.4 |     149 |   49 |   9.6G |   8.911% |  100M | 205.03M |     2.05 | 235.62M |     0 | 2:11'10'' |
| Q30L140 |  7.18G |  71.8 |     149 |   49 |  6.52G |   9.143% |  100M | 174.89M |     1.75 | 196.68M |     0 | 1:32'35'' |

| Name    | N50SRclean |     Sum |       # | N50Anchor |     Sum |     # | N50Anchor2 |   Sum |    # | N50Others |     Sum |       # |   RunTime |
|:--------|-----------:|--------:|--------:|----------:|--------:|------:|-----------:|------:|-----:|----------:|--------:|--------:|----------:|
| Q20L100 |        425 |  371.6M | 2130398 |      7249 | 113.28M | 29778 |       1315 | 7.48M | 5546 |       150 | 250.84M | 2095074 | 1:34'54'' |
| Q20L120 |        506 | 339.45M | 1720424 |      8494 | 112.26M | 27711 |       1312 | 7.11M | 5289 |       182 | 220.08M | 1687424 | 1:36'16'' |
| Q20L140 |        590 | 307.17M | 1349535 |     10252 | 110.41M | 24970 |       1307 | 6.43M | 4784 |       226 | 190.33M | 1319781 | 1:35'27'' |
| Q25L100 |        648 | 310.94M | 1273854 |     10220 | 117.95M | 27508 |       1292 | 6.01M | 4528 |       243 | 186.98M | 1241818 | 1:52'07'' |
| Q25L120 |        722 | 282.74M | 1022520 |     12128 | 114.36M | 23955 |       1290 | 5.29M | 3987 |       283 | 163.08M |  994578 | 1:52'13'' |
| Q25L140 |        819 | 251.02M |  798830 |     13167 | 110.46M | 20283 |       1273 | 3.89M | 2962 |       307 | 136.67M |  775585 | 1:47'03'' |
| Q30L100 |        850 | 267.78M |  858997 |     13746 | 119.43M | 23213 |       1258 | 3.97M | 3060 |       305 | 144.38M |  832724 | 0:59'58'' |
| Q30L120 |       1034 | 235.62M |  681003 |     14102 | 114.67M | 18985 |       1265 | 2.75M | 2109 |       305 |  118.2M |  659909 | 0:46'33'' |
| Q30L140 |       2098 | 196.68M |  505143 |     15119 | 106.17M | 15373 |       1316 | 1.93M | 1418 |       285 |  88.59M |  488352 | 0:41'34'' |

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

rm -fr 2_illumina/Q{20,25,30}L*
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
| anchor.merge | 16593 | 145592036 | 28540 |
| others.merge |  1231 |  25985051 | 20525 |

# F1084, Staurastrum sp., 角星鼓藻

## F1084: download

```bash
mkdir -p ~/data/dna-seq/chara/F1084/2_illumina
cd ~/data/dna-seq/chara/F1084/2_illumina

ln -s ~/data/dna-seq/chara/clean_data/F1084_HF5KMALXX_L7_1.clean.fq.gz R1.fq.gz
ln -s ~/data/dna-seq/chara/clean_data/F1084_HF5KMALXX_L7_2.clean.fq.gz R2.fq.gz
```

## F1084: combinations of different quality values and read lengths

* qual: 20, 25, and 30
* len: 100, 120, and 140

```bash
BASE_DIR=$HOME/data/dna-seq/chara/F1084

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

cd ${BASE_DIR}
parallel --no-run-if-empty -j 4 "
    mkdir -p 2_illumina/Q{1}L{2}O
    cd 2_illumina/Q{1}L{2}O
    
    if [ -e R1.fq.gz ]; then
        echo '    R1.fq.gz already presents'
        exit;
    fi

    anchr trim \
        --noscythe \
        -q {1} -l {2} \
        ../R1.fq.gz ../R2.fq.gz \
        -o stdout \
        | bash
    " ::: 20 25 30 ::: 100 120 140

```

* Stats

```bash
BASE_DIR=$HOME/data/dna-seq/chara/F1084
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
        DIR_COUNT="${BASE_DIR}/2_illumina/Q${qual}L${len}O"

        printf "| %s | %s | %s | %s |\n" \
            $(echo "Q${qual}L${len}O"; faops n50 -H -S -C ${DIR_COUNT}/R1.fq.gz  ${DIR_COUNT}/R2.fq.gz;) \
            >> stat.md
    done
done

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
| Illumina | 150 | 17281584900 | 115210566 |
| uniq     | 150 | 16422145800 | 109480972 |
| scythe   | 150 | 16401871866 | 109480972 |
| Q20L100O | 150 | 15168115753 | 103278954 |
| Q20L120O | 150 | 13960797625 |  93878766 |
| Q20L140O | 150 | 12479211815 |  83207716 |
| Q25L100O | 150 | 13521866701 |  93152002 |
| Q25L120O | 150 | 11848736656 |  80096870 |
| Q25L140O | 150 |  9808741699 |  65404754 |
| Q30L100O | 150 | 11449799223 |  80182086 |
| Q30L120O | 150 |  9284400979 |  63249254 |
| Q30L140O | 150 |  6817448916 |  45471918 |
| Q20L100  | 150 | 14310527602 |  97549228 |
| Q20L120  | 150 | 13116655244 |  88250756 |
| Q20L140  | 150 | 11689215490 |  77964900 |
| Q25L100  | 150 | 12703065267 |  87583500 |
| Q25L120  | 150 | 11084492655 |  74947744 |
| Q25L140  | 150 |  9184633759 |  61258106 |
| Q30L100  | 150 | 10733525443 |  75138028 |
| Q30L120  | 150 |  8706632894 |  59278404 |
| Q30L140  | 150 |  6482401714 |  43244288 |

## F1084: down sampling

```bash
BASE_DIR=$HOME/data/dna-seq/chara/F1084
cd ${BASE_DIR}

# works on bash 3
ARRAY=(
    "2_illumina/Q20L100O:Q20L100O"
    "2_illumina/Q20L120O:Q20L120O"
    "2_illumina/Q20L140O:Q20L140O"
    "2_illumina/Q25L100O:Q25L100O"
    "2_illumina/Q25L120O:Q25L120O"
    "2_illumina/Q25L140O:Q25L140O"
    "2_illumina/Q30L100O:Q30L100O"
    "2_illumina/Q30L120O:Q30L120O"
    "2_illumina/Q30L140O:Q30L140O"
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

## F1084: generate super-reads

```bash
BASE_DIR=$HOME/data/dna-seq/chara/F1084
cd ${BASE_DIR}

perl -e '
    for my $n (
        qw{
        Q20L100O Q20L120O Q20L140O
        Q25L100O Q25L120O Q25L140O
        Q30L100O Q30L120O Q30L140O
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
BASE_DIR=$HOME/data/dna-seq/chara/F1084

find . -type f -name "quorum_mer_db.jf"          | xargs rm
find . -type f -name "k_u_hash_0"                | xargs rm
find . -type f -name "readPositionsInSuperReads" | xargs rm
find . -type f -name "*.tmp"                     | xargs rm
find . -type f -name "pe.renamed.fastq"          | xargs rm
find . -type f -name "pe.cor.sub.fa"             | xargs rm
```

## F1084: create anchors

```bash
BASE_DIR=$HOME/data/dna-seq/chara/F1084
cd ${BASE_DIR}

perl -e '
    for my $n (
        qw{
        Q20L100O Q20L120O Q20L140O
        Q25L100O Q25L120O Q25L140O
        Q30L100O Q30L120O Q30L140O
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

## F1084: results

* Stats of super-reads

```bash
BASE_DIR=$HOME/data/dna-seq/chara/F1084
cd ${BASE_DIR}

REAL_G=100000000

bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 1 header \
    > ${BASE_DIR}/stat1.md

perl -e '
    for my $n (
        qw{
        Q20L100O Q20L120O Q20L140O
        Q25L100O Q25L120O Q25L140O
        Q30L100O Q30L120O Q30L140O
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
BASE_DIR=$HOME/data/dna-seq/chara/F1084
cd ${BASE_DIR}

bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 header \
    > ${BASE_DIR}/stat2.md

perl -e '
    for my $n (
        qw{
        Q20L100O Q20L120O Q20L140O
        Q25L100O Q25L120O Q25L140O
        Q30L100O Q30L120O Q30L140O
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

| Name     |  SumFq | CovFq | AvgRead | Kmer |  SumFa | Discard% | RealG |    EstG | Est/Real |   SumKU | SumSR |   RunTime |
|:---------|-------:|------:|--------:|-----:|-------:|---------:|------:|--------:|---------:|--------:|------:|----------:|
| Q20L100O | 15.17G | 151.7 |     132 |   63 | 12.42G |  18.120% |  100M | 167.87M |     1.68 | 250.36M |     0 | 3:12'53'' |
| Q20L120O | 13.96G | 139.6 |     145 |   75 | 11.64G |  16.644% |  100M | 165.48M |     1.65 | 239.86M |     0 | 3:02'42'' |
| Q20L140O | 12.48G | 124.8 |     149 |   75 |  10.6G |  15.073% |  100M | 163.03M |     1.63 | 228.38M |     0 | 2:35'55'' |
| Q25L100O | 13.52G | 135.2 |     130 |   61 | 11.83G |  12.502% |  100M | 164.04M |     1.64 | 228.38M |     0 | 2:06'33'' |
| Q25L120O | 11.85G | 118.5 |     143 |   75 | 10.49G |  11.507% |  100M | 161.86M |     1.62 | 221.81M |     0 | 1:58'46'' |
| Q25L140O |  9.81G |  98.1 |     149 |   75 |  8.78G |  10.522% |  100M |  159.1M |     1.59 | 214.53M |     0 | 1:36'09'' |
| Q30L100O | 11.45G | 114.5 |     128 |   61 | 10.47G |   8.557% |  100M | 161.07M |     1.61 | 217.62M |     0 | 1:50'32'' |
| Q30L120O |  9.28G |  92.8 |     143 |   75 |  8.55G |   7.953% |  100M | 158.38M |     1.58 | 212.48M |     0 | 1:27'07'' |
| Q30L140O |  6.82G |  68.2 |     149 |   75 |  6.31G |   7.372% |  100M | 154.22M |     1.54 | 205.56M |     0 | 0:59'05'' |
| Q20L100  | 14.31G | 143.1 |     149 |   49 | 11.58G |  19.067% |  100M | 166.55M |     1.67 | 241.88M |     0 | 2:59'12'' |
| Q20L120  | 13.12G | 131.2 |     149 |   49 | 10.81G |  17.572% |  100M | 164.16M |     1.64 | 230.68M |     0 | 2:20'40'' |
| Q20L140  | 11.69G | 116.9 |     149 |   49 |  9.82G |  15.979% |  100M | 161.73M |     1.62 | 221.57M |     0 | 2:22'50'' |
| Q25L100  |  12.7G | 127.0 |     149 |   49 | 11.03G |  13.190% |  100M |  162.8M |     1.63 | 223.53M |     0 | 2:38'41'' |
| Q25L120  | 11.08G | 110.8 |     149 |   49 |  9.73G |  12.175% |  100M | 160.62M |     1.61 | 216.62M |     0 | 2:32'42'' |
| Q25L140  |  9.18G |  91.8 |     149 |   49 |  8.16G |  11.137% |  100M | 157.93M |     1.58 | 210.46M |     0 | 1:54'21'' |
| Q30L100  | 10.73G | 107.3 |     149 |   49 |  9.77G |   9.023% |  100M | 159.97M |     1.60 | 214.32M |     0 | 2:20'16'' |
| Q30L120  |  8.71G |  87.1 |     149 |   49 |  7.98G |   8.379% |  100M | 157.32M |     1.57 | 208.98M |     0 | 1:48'35'' |
| Q30L140  |  6.48G |  64.8 |     149 |   49 |  5.98G |   7.696% |  100M | 153.42M |     1.53 | 202.76M |     0 | 1:20'20'' |

| Name     | N50SRclean |     Sum |       # | N50Anchor |     Sum |     # | N50Anchor2 |     Sum |   # | N50Others |     Sum |       # |   RunTime |
|:---------|-----------:|--------:|--------:|----------:|--------:|------:|-----------:|--------:|----:|----------:|--------:|--------:|----------:|
| Q20L100O |        449 | 250.36M | 1158930 |      5152 | 100.06M | 28354 |       1293 | 337.58K | 254 |       136 | 149.96M | 1130322 | 0:58'35'' |
| Q20L120O |        703 | 239.86M |  851150 |      5171 | 108.75M | 30497 |       1254 | 273.72K | 213 |       164 | 130.84M |  820440 | 0:51'12'' |
| Q20L140O |        889 | 228.38M |  735157 |      5057 | 109.85M | 31087 |       1245 | 312.85K | 244 |       180 | 118.22M |  703826 | 0:59'33'' |
| Q25L100O |        695 | 228.38M |  909522 |      5485 | 102.73M | 28449 |       1268 | 283.69K | 218 |       155 | 125.36M |  880855 | 0:37'31'' |
| Q25L120O |       1069 | 221.81M |  661651 |      5081 | 112.16M | 31358 |       1272 | 241.44K | 185 |       188 | 109.41M |  630108 | 0:41'50'' |
| Q25L140O |       1189 | 214.53M |  606962 |      4782 |  111.4M | 31957 |       1245 | 410.12K | 317 |       196 | 102.72M |  574688 | 0:36'36'' |
| Q30L100O |        911 | 217.62M |  786249 |      5658 | 105.53M | 28441 |       1257 | 243.73K | 188 |       164 | 111.84M |  757620 | 0:32'43'' |
| Q30L120O |       1274 | 212.48M |  588548 |      4883 | 112.26M | 31740 |       1238 | 303.38K | 238 |       196 |  99.91M |  556570 | 0:32'26'' |
| Q30L140O |       1182 | 205.56M |  562369 |      4418 | 106.22M | 32170 |       1287 |  913.4K | 695 |       207 |  98.42M |  529504 | 0:25'32'' |
| Q20L100  |        360 | 241.88M | 1409314 |      5670 |  90.55M | 24670 |       1371 | 525.23K | 377 |       114 |  150.8M | 1384267 | 0:44'43'' |
| Q20L120  |        449 | 230.68M | 1234178 |      6054 |  91.81M | 24615 |       1342 | 549.84K | 394 |       126 | 138.32M | 1209169 | 0:43'43'' |
| Q20L140  |        544 | 221.57M | 1102455 |      6160 |  92.91M | 24686 |       1340 | 586.41K | 426 |       134 | 128.07M | 1077343 | 0:40'55'' |
| Q25L100  |        551 | 223.53M | 1115652 |      6065 |  94.55M | 25236 |       1309 | 425.99K | 316 |       132 | 128.55M | 1090100 | 0:36'57'' |
| Q25L120  |        637 | 216.62M | 1023565 |      6168 |  95.49M | 25096 |       1311 | 474.89K | 352 |       137 | 120.66M |  998117 | 0:39'07'' |
| Q25L140  |        704 | 210.46M |  956953 |      5988 |  95.38M | 24841 |       1316 | 565.54K | 416 |       140 | 114.52M |  931696 | 0:36'00'' |
| Q30L100  |        697 | 214.32M |  988892 |      6572 |  97.46M | 24635 |       1279 | 367.96K | 277 |       136 | 116.49M |  963980 | 0:35'47'' |
| Q30L120  |        737 | 208.98M |  938407 |      6347 |  96.21M | 24153 |       1294 | 481.46K | 362 |       139 | 112.29M |  913892 | 0:36'05'' |
| Q30L140  |        740 | 202.76M |  897524 |      5681 |  92.26M | 24379 |       1334 |    1.1M | 802 |       143 |  109.4M |  872343 | 0:24'29'' |

## F1084: merge anchors

```bash
BASE_DIR=$HOME/data/dna-seq/chara/F1084
cd ${BASE_DIR}

# merge anchors
mkdir -p merge
anchr contained \
    Q20L100O/anchor/pe.anchor.fa \
    Q20L120O/anchor/pe.anchor.fa \
    Q20L140O/anchor/pe.anchor.fa \
    Q25L100O/anchor/pe.anchor.fa \
    Q25L120O/anchor/pe.anchor.fa \
    Q25L140O/anchor/pe.anchor.fa \
    Q30L100O/anchor/pe.anchor.fa \
    Q30L120O/anchor/pe.anchor.fa \
    Q30L140O/anchor/pe.anchor.fa \
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

# quast
rm -fr 9_qa
quast --no-check --threads 16 \
    Q20L100O/anchor/pe.anchor.fa \
    Q25L100O/anchor/pe.anchor.fa \
    Q30L100O/anchor/pe.anchor.fa \
    Q20L100/anchor/pe.anchor.fa \
    Q25L100/anchor/pe.anchor.fa \
    Q30L100/anchor/pe.anchor.fa \
    merge/anchor.merge.fasta \
    merge/others.merge.fasta \
    --label "Q20L100O,Q25L100O,Q30L100O,Q20L100,Q25L100,Q30L100,merge,others" \
    -o 9_qa

```

* Clear QxxLxxx.

```bash
BASE_DIR=$HOME/data/dna-seq/chara/F1084
cd ${BASE_DIR}

rm -fr 2_illumina/Q{20,25,30}L*
rm -fr Q{20,25,30}L*
```

* Stats

```bash
BASE_DIR=$HOME/data/dna-seq/chara/F1084
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

| Name         |  N50 |       Sum |     # |
|:-------------|-----:|----------:|------:|
| anchor.merge | 8976 | 122233147 | 26448 |
| others.merge | 1204 |   4466297 |  3577 |

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

