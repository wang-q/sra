# Magnoliids: anchr + spades + platanus

[TOC levels=1-3]: # " "
- [Magnoliids: anchr + spades + platanus](#magnoliids-anchr--spades--platanus)
- [FCM03](#fcm03)
    - [FCM03: download](#fcm03-download)
    - [FCM03: preprocess Illumina reads](#fcm03-preprocess-illumina-reads)
    - [FCM03: reads stats](#fcm03-reads-stats)
    - [FCM03: spades](#fcm03-spades)
    - [FCM03: platanus](#fcm03-platanus)
    - [FCM03: quorum](#fcm03-quorum)
    - [FCM03: adapter filtering](#fcm03-adapter-filtering)
    - [FCM03: down sampling](#fcm03-down-sampling)
    - [FCM03: k-unitigs and anchors (sampled)](#fcm03-k-unitigs-and-anchors-sampled)
    - [FCM03: merge anchors](#fcm03-merge-anchors)
    - [FCM03: final stats](#fcm03-final-stats)
    - [FCM03: clear intermediate files](#fcm03-clear-intermediate-files)
- [FCM05](#fcm05)
    - [FCM05: download](#fcm05-download)
    - [FCM05: preprocess Illumina reads](#fcm05-preprocess-illumina-reads)
    - [FCM05: spades](#fcm05-spades)
    - [FCM05: platanus](#fcm05-platanus)
    - [FCM05: quorum](#fcm05-quorum)
    - [FCM05: down sampling](#fcm05-down-sampling)
    - [FCM05: k-unitigs and anchors (sampled)](#fcm05-k-unitigs-and-anchors-sampled)
    - [FCM05: merge anchors](#fcm05-merge-anchors)
    - [FCM05: final stats](#fcm05-final-stats)
- [FCM05B](#fcm05b)
    - [FCM05B: download](#fcm05b-download)
    - [FCM05B: reads stats](#fcm05b-reads-stats)
- [FCM05C](#fcm05c)
    - [FCM05C: download](#fcm05c-download)
    - [FCM05C: reads stats](#fcm05c-reads-stats)
- [FCM05D](#fcm05d)
    - [FCM05D: download](#fcm05d-download)
    - [FCM05D: preprocess Illumina reads](#fcm05d-preprocess-illumina-reads)
    - [FCM05D: reads stats](#fcm05d-reads-stats)
    - [FCM05D: spades](#fcm05d-spades)
    - [FCM05D: platanus](#fcm05d-platanus)
    - [FCM05D: quorum](#fcm05d-quorum)
    - [FCM05D: down sampling](#fcm05d-down-sampling)
    - [FCM05D: k-unitigs and anchors (sampled)](#fcm05d-k-unitigs-and-anchors-sampled)
- [FCM07](#fcm07)
    - [FCM07: download](#fcm07-download)
    - [FCM07: combinations of different quality values and read lengths](#fcm07-combinations-of-different-quality-values-and-read-lengths)
    - [FCM07: spades](#fcm07-spades)
    - [FCM07: platanus](#fcm07-platanus)
    - [FCM07: quorum](#fcm07-quorum)
    - [FCM07: down sampling](#fcm07-down-sampling)
    - [FCM07: k-unitigs and anchors (sampled)](#fcm07-k-unitigs-and-anchors-sampled)
    - [FCM07: merge anchors](#fcm07-merge-anchors)
    - [FCM07: final stats](#fcm07-final-stats)
- [FCM13](#fcm13)
    - [FCM13: download](#fcm13-download)
    - [FCM13: combinations of different quality values and read lengths](#fcm13-combinations-of-different-quality-values-and-read-lengths)
    - [FCM13: spades](#fcm13-spades)
    - [FCM13: platanus](#fcm13-platanus)
    - [FCM13: quorum](#fcm13-quorum)
    - [FCM13: down sampling](#fcm13-down-sampling)
    - [FCM13: k-unitigs and anchors (sampled)](#fcm13-k-unitigs-and-anchors-sampled)
    - [FCM13: merge anchors](#fcm13-merge-anchors)
    - [FCM13: final stats](#fcm13-final-stats)
- [Create tarballs](#create-tarballs)


# FCM03

* *Piper longum L.*
* 荜菝
* Taxonomy ID: [49511](https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?mode=Info&id=49511)

## FCM03: download

* Settings

```bash
WORKING_DIR=${HOME}/data/dna-seq/xjy2
BASE_NAME=FCM03
REAL_G=550000000
IS_EUK="true"
COVERAGE2="10 20 25 30"
READ_QUAL="25 30"
READ_LEN="60"

```

* Illumina

```bash
mkdir -p ${WORKING_DIR}/${BASE_NAME}/2_illumina
cd ${WORKING_DIR}/${BASE_NAME}/2_illumina

ln -s ${WORKING_DIR}/data/D7g7512_FCM03_R1_001.fastq.gz R1.fq.gz
ln -s ${WORKING_DIR}/data/D7g7512_FCM03_R2_001.fastq.gz R2.fq.gz

```

* FastQC

```bash
cd ${WORKING_DIR}/${BASE_NAME}

mkdir -p 2_illumina/fastqc
cd 2_illumina/fastqc

fastqc -t 16 \
    ../R1.fq.gz ../R2.fq.gz \
    -o .

```

* kmergenie

```bash
cd ${WORKING_DIR}/${BASE_NAME}

mkdir -p 2_illumina/kmergenie
cd 2_illumina/kmergenie

parallel --no-run-if-empty --linebuffer -k -j 2 "
    kmergenie -l 21 -k 121 -s 10 -t 8 --one-pass ../{}.fq.gz -o {}
    " ::: R1 R2

```

## FCM03: preprocess Illumina reads


```bash
cd ${WORKING_DIR}/${BASE_NAME}

cd 2_illumina

anchr trim \
    --uniq \
    --nosickle \
    R1.fq.gz R2.fq.gz \
    -o trim.sh
bash trim.sh

parallel --no-run-if-empty --linebuffer -k -j 3 "
    mkdir -p Q{1}L{2}
    cd Q{1}L{2}
    
    if [ -e R1.fq.gz ]; then
        echo '    R1.fq.gz already presents'
        exit;
    fi

    anchr trim \
        -q {1} -l {2} \
        \$(
            if [ -e ../R1.scythe.fq.gz ]; then
                echo '../R1.scythe.fq.gz ../R2.scythe.fq.gz'
            elif [ -e ../R1.sample.fq.gz ]; then
                echo '../R1.sample.fq.gz ../R2.sample.fq.gz'
            elif [ -e ../R1.shuffle.fq.gz ]; then
                echo '../R1.shuffle.fq.gz ../R2.shuffle.fq.gz'
            elif [ -e ../R1.uniq.fq.gz ]; then
                echo '../R1.uniq.fq.gz ../R2.uniq.fq.gz'
            else
                echo '../R1.fq.gz ../R2.fq.gz'
            fi
        ) \
         \
        -o stdout \
        | bash
    " ::: ${READ_QUAL} ::: ${READ_LEN}

```

## FCM03: reads stats

```bash
# Stats
cd ${WORKING_DIR}/${BASE_NAME}
printf "| %s | %s | %s | %s |\n" \
    "Name" "N50" "Sum" "#" \
    > stat.md
printf "|:--|--:|--:|--:|\n" >> stat.md

printf "| %s | %s | %s | %s |\n" \
    $(echo "Illumina"; faops n50 -H -S -C 2_illumina/R1.fq.gz 2_illumina/R2.fq.gz;) >> stat.md
if [ -e 2_illumina/R1.uniq.fq.gz ]; then
    printf "| %s | %s | %s | %s |\n" \
        $(echo "uniq";    faops n50 -H -S -C 2_illumina/R1.uniq.fq.gz 2_illumina/R2.uniq.fq.gz;) >> stat.md
fi
if [ -e 2_illumina/R1.shuffle.fq.gz ]; then
    printf "| %s | %s | %s | %s |\n" \
        $(echo "shuffle"; faops n50 -H -S -C 2_illumina/R1.shuffle.fq.gz 2_illumina/R2.shuffle.fq.gz;) >> stat.md
fi
if [ -e 2_illumina/R1.sample.fq.gz ]; then
    printf "| %s | %s | %s | %s |\n" \
        $(echo "sample";   faops n50 -H -S -C 2_illumina/R1.sample.fq.gz 2_illumina/R2.sample.fq.gz;) >> stat.md
fi
if [ -e 2_illumina/R1.scythe.fq.gz ]; then
    printf "| %s | %s | %s | %s |\n" \
        $(echo "scythe";  faops n50 -H -S -C 2_illumina/R1.scythe.fq.gz 2_illumina/R2.scythe.fq.gz;) >> stat.md
fi

parallel --no-run-if-empty -k -j 3 "
    if [ ! -e 2_illumina/Q{1}L{2}/R1.sickle.fq.gz ]; then
        exit;
    fi

    printf \"| %s | %s | %s | %s |\n\" \
        \$( 
            echo Q{1}L{2};
            if [[ {1} -ge '30' ]]; then
                faops n50 -H -S -C \
                    2_illumina/Q{1}L{2}/R1.sickle.fq.gz \
                    2_illumina/Q{1}L{2}/R2.sickle.fq.gz \
                    2_illumina/Q{1}L{2}/Rs.sickle.fq.gz;
            else
                faops n50 -H -S -C \
                    2_illumina/Q{1}L{2}/R1.sickle.fq.gz \
                    2_illumina/Q{1}L{2}/R2.sickle.fq.gz;
            fi
        )
    " ::: ${READ_QUAL} ::: ${READ_LEN} \
    >> stat.md

cat stat.md

```

| Name     | N50 |         Sum |         # |
|:---------|----:|------------:|----------:|
| Illumina | 151 | 23454552764 | 155328164 |
| uniq     | 151 | 19303241134 | 127836034 |
| Q25L60   | 151 | 17442922681 | 120543118 |
| Q30L60   | 151 | 16704570709 | 118992276 |

## FCM03: spades

```bash
cd ${WORKING_DIR}/${BASE_NAME}

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

## FCM03: platanus

```bash
cd ${WORKING_DIR}/${BASE_NAME}

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

anchr contained \
    out_gapClosed.fa \
    --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
    -o stdout \
    | faops filter -a 1000 -l 0 stdin gapClosed.non-contained.fasta

```

## FCM03: quorum

```bash
cd ${WORKING_DIR}/${BASE_NAME}

parallel --no-run-if-empty --linebuffer -k -j 1 "
    cd 2_illumina/Q{1}L{2}
    echo >&2 '==> Group Q{1}L{2} <=='

    if [ ! -e R1.sickle.fq.gz ]; then
        echo >&2 '    R1.sickle.fq.gz not exists'
        exit;
    fi

    if [ -e pe.cor.fa ]; then
        echo >&2 '    pe.cor.fa exists'
        exit;
    fi

    if [[ {1} -ge '30' ]]; then
        anchr quorum \
            R1.sickle.fq.gz R2.sickle.fq.gz Rs.sickle.fq.gz \
            -p 16 \
            -o quorum.sh
    else
        anchr quorum \
            R1.sickle.fq.gz R2.sickle.fq.gz \
            -p 16 \
            -o quorum.sh
    fi

    bash quorum.sh
    
    echo >&2
    " ::: ${READ_QUAL} ::: ${READ_LEN}

# Stats of processed reads
bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 1 header \
    > stat1.md

parallel --no-run-if-empty -k -j 3 "
    if [ ! -d 2_illumina/Q{1}L{2} ]; then
        exit;
    fi

    bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 1 2_illumina/Q{1}L{2} ${REAL_G}
    " ::: ${READ_QUAL} ::: ${READ_LEN} \
     >> stat1.md

cat stat1.md

```

| Name   |  SumIn | CovIn | SumOut | CovOut | Discard% | AvgRead |  Kmer | RealG |    EstG | Est/Real |   RunTime |
|:-------|-------:|------:|-------:|-------:|---------:|--------:|------:|------:|--------:|---------:|----------:|
| Q25L60 | 17.44G |  31.7 | 14.84G |   27.0 |  14.905% |     144 | "105" |  550M | 544.02M |     0.99 | 0:51'09'' |
| Q30L60 | 16.71G |  30.4 | 14.84G |   27.0 |  11.200% |     140 |  "97" |  550M | 540.34M |     0.98 | 0:55'01'' |

## FCM03: adapter filtering

```bash
cd ${WORKING_DIR}/${BASE_NAME}

for QxxLxx in $( parallel "echo 'Q{1}L{2}'" ::: ${READ_QUAL} ::: ${READ_LEN} ); do
    echo "==> ${QxxLxx}"

    if [ -e 2_illumina/${QxxLxx}/filtering.stats.txt ]; then
        echo "2_illumina/${QxxLxx}/filtering.stats.txt already exists"
        continue;
    fi

    if [ ! -e 2_illumina/${QxxLxx}/pe.cor.fa ]; then
        echo "2_illumina/${QxxLxx}/pe.cor.fa not exists"
        continue;
    fi
    
    mv 2_illumina/${QxxLxx}/pe.cor.fa 2_illumina/${QxxLxx}/pe.cor.raw

    bbduk.sh \
        in=2_illumina/${QxxLxx}/pe.cor.raw \
        out=2_illumina/${QxxLxx}/pe.cor.fa \
        outm=2_illumina/${QxxLxx}/matched.fa \
        ref=$(brew --prefix)/Cellar/$(brew list --versions bbtools | sed 's/ /\//')/resources/adapters.fa \
        k=27 hdist=1 stats=2_illumina/${QxxLxx}/filtering.stats.txt

    rm 2_illumina/${QxxLxx}/pe.cor.raw
done

```

## FCM03: down sampling

```bash
cd ${WORKING_DIR}/${BASE_NAME}

for QxxLxx in $( parallel "echo 'Q{1}L{2}'" ::: ${READ_QUAL} ::: ${READ_LEN} ); do
    echo "==> ${QxxLxx}"

    if [ ! -e 2_illumina/${QxxLxx}/pe.cor.fa ]; then
        echo "2_illumina/${QxxLxx}/pe.cor.fa not exists"
        continue;
    fi

    for X in ${COVERAGE2}; do
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

## FCM03: k-unitigs and anchors (sampled)

```bash
cd ${WORKING_DIR}/${BASE_NAME}

# k-unitigs
parallel --no-run-if-empty --linebuffer -k -j 2 "
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
    " ::: ${READ_QUAL} ::: ${READ_LEN} ::: ${COVERAGE2} ::: $(printf "%03d " {0..100})

# anchors
parallel --no-run-if-empty --linebuffer -k -j 3 "
    echo >&2 '==> Group Q{1}L{2}X{3}P{4}'

    if [ ! -e Q{1}L{2}X{3}P{4}/pe.cor.fa ]; then
        echo >&2 '    pe.cor.fa not exists'
        exit;
    fi

    if [ -e Q{1}L{2}X{3}P{4}/anchor/anchor.fasta ]; then
        echo >&2 '    anchor.fasta already presents'
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
    " ::: ${READ_QUAL} ::: ${READ_LEN} ::: ${COVERAGE2} ::: $(printf "%03d " {0..100})

# Stats of anchors
bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 header \
    > stat2.md

parallel --no-run-if-empty -k -j 6 "
    if [ ! -e Q{1}L{2}X{3}P{4}/anchor/pe.anchor.fa ]; then
        exit;
    fi

    bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 Q{1}L{2}X{3}P{4} ${REAL_G}
    " ::: ${READ_QUAL} ::: ${READ_LEN} ::: ${COVERAGE2} ::: $(printf "%03d " {0..100}) \
    >> stat2.md

cat stat2.md

```

| Name          | SumCor | CovCor | N50SR |     Sum |      # | N50Anchor |     Sum |     # | N50Others |     Sum |      # |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|-------:|-------:|------:|--------:|-------:|----------:|--------:|------:|----------:|--------:|-------:|--------------------:|----------:|:----------|
| Q25L60X10P000 |   5.5G |   10.0 |   871 |  255.3M | 294060 |      1598 |  91.24M | 56071 |       690 | 164.06M | 237989 | "31,41,51,61,71,81" | 3:09'45'' | 0:17'37'' |
| Q25L60X10P001 |   5.5G |   10.0 |   871 | 255.25M | 294138 |      1601 |  91.08M | 55937 |       689 | 164.18M | 238201 | "31,41,51,61,71,81" | 3:13'05'' | 0:17'37'' |
| Q25L60X20P000 |    11G |   20.0 |   965 | 281.94M | 300082 |      1694 | 125.86M | 73365 |       692 | 156.08M | 226717 | "31,41,51,61,71,81" | 4:35'51'' | 0:24'44'' |
| Q25L60X25P000 | 13.75G |   25.0 |   985 | 280.44M | 293516 |      1708 | 130.35M | 75264 |       692 | 150.09M | 218252 | "31,41,51,61,71,81" | 5:02'23'' | 0:25'51'' |
| Q30L60X10P000 |   5.5G |   10.0 |   870 | 253.75M | 292252 |      1598 |  90.87M | 55802 |       688 | 162.88M | 236450 | "31,41,51,61,71,81" | 3:04'03'' | 0:17'39'' |
| Q30L60X10P001 |   5.5G |   10.0 |   871 | 254.12M | 292751 |      1605 |  90.88M | 55808 |       689 | 163.24M | 236943 | "31,41,51,61,71,81" | 2:32'31'' | 0:17'52'' |
| Q30L60X20P000 |    11G |   20.0 |   964 | 281.41M | 299387 |      1694 |  125.8M | 73373 |       692 | 155.61M | 226014 | "31,41,51,61,71,81" | 2:57'27'' | 0:24'25'' |
| Q30L60X25P000 | 13.75G |   25.0 |   986 |  280.1M | 292855 |      1707 | 130.48M | 75447 |       693 | 149.62M | 217408 | "31,41,51,61,71,81" | 3:10'28'' | 0:26'39'' |

## FCM03: merge anchors

```bash
cd ${WORKING_DIR}/${BASE_NAME}

# merge anchors
mkdir -p merge
anchr contained \
    $(
        parallel -k --no-run-if-empty -j 6 "
            if [ -e Q{1}L{2}X{3}P{4}/anchor/anchor.fasta ]; then
                echo Q{1}L{2}X{3}P{4}/anchor/anchor.fasta
            fi
            " ::: ${READ_QUAL} ::: ${READ_LEN} ::: ${COVERAGE2} ::: $(printf "%03d " {0..100})
    ) \
    --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
    -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/anchor.non-contained.fasta
anchr orient merge/anchor.non-contained.fasta --len 1000 --idt 0.98 -o merge/anchor.orient.fasta
anchr merge merge/anchor.orient.fasta --len 1000 --idt 0.999 -o merge/anchor.merge0.fasta
anchr contained merge/anchor.merge0.fasta --len 1000 --idt 0.98 \
    --proportion 0.99 --parallel 16 -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/anchor.merge.fasta

# merge others
anchr contained \
    $(
        parallel -k --no-run-if-empty -j 6 "
            if [ -e Q{1}L{2}X{3}P{4}/anchor/pe.others.fa ]; then
                echo Q{1}L{2}X{3}P{4}/anchor/pe.others.fa
            fi
            " ::: ${READ_QUAL} ::: ${READ_LEN} ::: ${COVERAGE2} ::: $(printf "%03d " {0..100})
    ) \
    --len 500 --idt 0.98 --proportion 0.99999 --parallel 16 \
    -o stdout \
    | faops filter -a 500 -l 0 stdin merge/others.non-contained.fasta

# quast
rm -fr 9_qa
quast --no-check --threads 16 \
    --eukaryote \
    --no-icarus \
    merge/anchor.merge.fasta \
    merge/others.non-contained.fasta \
    --label "merge,others" \
    -o 9_qa

```

## FCM03: final stats

* Stats

```bash
cd ${WORKING_DIR}/${BASE_NAME}

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
printf "| %s | %s | %s | %s |\n" \
    $(echo "spades.scaffold"; faops n50 -H -S -C 8_spades/scaffolds.fasta;) >> stat3.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "spades.non-contained"; faops n50 -H -S -C 8_spades/contigs.non-contained.fasta;) >> stat3.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "platanus.contig"; faops n50 -H -S -C 8_platanus/out_contig.fa;) >> stat3.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "platanus.scaffold"; faops n50 -H -S -C 8_platanus/out_gapClosed.fa;) >> stat3.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "platanus.non-contained"; faops n50 -H -S -C 8_platanus/gapClosed.non-contained.fasta;) >> stat3.md

cat stat3.md
```

| Name                   |  N50 |       Sum |       # |
|:-----------------------|-----:|----------:|--------:|
| anchor.merge           | 1762 | 185901183 |  104610 |
| others.merge           | 1055 |  50591371 |   46126 |
| spades.contig          | 4073 | 691875031 | 1465734 |
| spades.non-contained   | 9477 | 460154902 |   88826 |
| platanus.scaffold      |  401 | 345280915 | 1171002 |
| platanus.non-contained | 2381 | 128103732 |   58367 |

## FCM03: clear intermediate files

```bash
cd ${WORKING_DIR}/${BASE_NAME}

# bax2bam
rm -fr 3_pacbio/bam/*
rm -fr 3_pacbio/fasta/*
rm -fr 3_pacbio/untar/*

# quorum
find 2_illumina -type f -name "quorum_mer_db.jf" | xargs rm
find 2_illumina -type f -name "k_u_hash_0"       | xargs rm
find 2_illumina -type f -name "*.tmp"            | xargs rm
find 2_illumina -type f -name "pe.renamed.fastq" | xargs rm
find 2_illumina -type f -name "se.renamed.fastq" | xargs rm
find 2_illumina -type f -name "pe.cor.sub.fa"    | xargs rm

# down sampling
rm -fr 2_illumina/Q{15,20,25,30,35}L{30,60,90,120}X*
rm -fr Q{15,20,25,30,35}L{30,60,90,120}X*

rm -fr mergeQ*
rm -fr mergeL*

# canu
find . -type d -name "correction" -path "*canu-*" | xargs rm -fr
find . -type d -name "trimming"   -path "*canu-*" | xargs rm -fr
find . -type d -name "unitigging" -path "*canu-*" | xargs rm -fr

# spades
find . -type d -path "*8_spades/*" | xargs rm -fr

# platanus
find . -type f -path "*8_platanus/*" -name "[ps]e.fa" | xargs rm

```

# FCM05

* *Saururus chinensis*
* 三白草
* Taxonomy ID: [54806](https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?mode=Info&id=54806)

## FCM05: download

* Settings

```bash
WORKING_DIR=${HOME}/data/dna-seq/xjy2
BASE_NAME=FCM05
REAL_G=530000000
IS_EUK="true"
COVERAGE2="10 20 30 40"
READ_QUAL="25 30"
READ_LEN="60"

```

```bash
mkdir -p ~/data/dna-seq/xjy2/${BASE_NAME}/2_illumina
cd ~/data/dna-seq/xjy2/${BASE_NAME}/2_illumina

ln -s ~/data/dna-seq/xjy2/data/D7g7512_FCM05_R1_001.fastq.gz R1.fq.gz
ln -s ~/data/dna-seq/xjy2/data/D7g7512_FCM05_R2_001.fastq.gz R2.fq.gz

```

* FastQC

* kmergenie


## FCM05: preprocess Illumina reads

| Name     | N50 |         Sum |         # |
|:---------|----:|------------:|----------:|
| Illumina | 151 | 24447486786 | 161903886 |
| uniq     | 151 | 19928633606 | 131977706 |
| Q25L60   | 151 | 18132355713 | 124923112 |
| Q30L60   | 151 | 17387440203 | 123304964 |

## FCM05: spades

## FCM05: platanus

## FCM05: quorum

| Name   |  SumIn | CovIn | SumOut | CovOut | Discard% | AvgRead |  Kmer | RealG |    EstG | Est/Real |   RunTime |
|:-------|-------:|------:|-------:|-------:|---------:|--------:|------:|------:|--------:|---------:|----------:|
| Q25L60 | 18.13G |  34.2 | 14.98G |   28.3 |  17.362% |     144 | "105" |  530M | 576.61M |     1.09 | 1:04'59'' |
| Q30L60 | 17.39G |  32.8 |    15G |   28.3 |  13.773% |     141 |  "97" |  530M | 571.31M |     1.08 | 1:15'59'' |

## FCM05: down sampling

## FCM05: k-unitigs and anchors (sampled)

| Name          | SumCor | CovCor | N50SR |     Sum |      # | N50Anchor |     Sum |     # | N50Others |     Sum |      # |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|-------:|-------:|------:|--------:|-------:|----------:|--------:|------:|----------:|--------:|-------:|--------------------:|----------:|:----------|
| Q25L60X10P000 |   5.3G |   10.0 |  1419 | 347.54M | 289144 |      2598 | 207.47M | 88793 |       701 | 140.07M | 200351 | "31,41,51,61,71,81" | 6:16'04'' | 0:24'18'' |
| Q25L60X10P001 |   5.3G |   10.0 |  1425 |  347.2M | 288695 |      2596 | 207.21M | 88511 |       701 | 139.99M | 200184 | "31,41,51,61,71,81" | 7:51'15'' | 0:24'29'' |
| Q25L60X20P000 |  10.6G |   20.0 |  1943 | 388.07M | 270250 |      3532 | 265.47M | 94266 |       701 |  122.6M | 175984 | "31,41,51,61,71,81" | 6:57'52'' | 0:30'08'' |
| Q25L60X25P000 | 13.25G |   25.0 |  2032 | 390.15M | 265701 |      3553 | 272.95M | 97034 |       700 |  117.2M | 168667 | "31,41,51,61,71,81" | 8:00'14'' | 0:32'29'' |
| Q30L60X10P000 |   5.3G |   10.0 |  1421 | 345.92M | 287930 |      2599 | 206.37M | 88254 |       700 | 139.55M | 199676 | "31,41,51,61,71,81" | 4:39'45'' | 0:22'52'' |
| Q30L60X10P001 |   5.3G |   10.0 |  1425 | 346.39M | 288027 |      2605 | 206.37M | 87946 |       701 | 140.02M | 200081 | "31,41,51,61,71,81" | 4:42'44'' | 0:23'28'' |
| Q30L60X20P000 |  10.6G |   20.0 |  1953 | 387.07M | 268883 |      3563 | 264.98M | 93626 |       700 | 122.09M | 175257 | "31,41,51,61,71,81" | 5:15'02'' | 0:30'49'' |
| Q30L60X25P000 | 13.25G |   25.0 |  2049 | 389.22M | 263931 |      3604 | 272.61M | 96160 |       700 | 116.61M | 167771 | "31,41,51,61,71,81" | 5:46'20'' | 0:33'21'' |

## FCM05: merge anchors

## FCM05: final stats

* Stats

| Name                   |   N50 |       Sum |       # |
|:-----------------------|------:|----------:|--------:|
| anchor.merge           |  3716 | 314168144 |  109058 |
| others.merge           |  1067 |  49908970 |   44031 |
| spades.contig          |  5617 | 765386700 | 1179340 |
| spades.non-contained   | 14367 | 524827717 |   85289 |
| platanus.scaffold      |   844 | 351522180 | 1069499 |
| platanus.non-contained |  4577 | 168928590 |   51243 |

# FCM05B

## FCM05B: download

* Settings

```bash
WORKING_DIR=${HOME}/data/dna-seq/xjy2
BASE_NAME=FCM05B

```

* Illumina

```bash
mkdir -p ${WORKING_DIR}/${BASE_NAME}/2_illumina
cd ${WORKING_DIR}/${BASE_NAME}/2_illumina

ln -s {WORKING_DIR}/data/FCM05_H3T7VDMXX_L1_1.clean.fq.gz R1.fq.gz
ln -s {WORKING_DIR}/data/FCM05_H3T7VDMXX_L1_2.clean.fq.gz R2.fq.gz

```

* FastQC

* kmergenie

## FCM05B: reads stats

| Name     | N50 |         Sum |         # |
|:---------|----:|------------:|----------:|
| Illumina | 150 | 21181614300 | 141210762 |

# FCM05C

## FCM05C: download

* Settings

```bash
WORKING_DIR=${HOME}/data/dna-seq/xjy2
BASE_NAME=FCM05C

```

* Illumina

```bash
mkdir -p ${WORKING_DIR}/${BASE_NAME}/2_illumina
cd ${WORKING_DIR}/${BASE_NAME}/2_illumina

ln -s ${WORKING_DIR}/data/FCM05_H3TC3DMXX_L1_1.clean.fq.gz R1.fq.gz
ln -s ${WORKING_DIR}/data/FCM05_H3TC3DMXX_L1_2.clean.fq.gz R2.fq.gz

```

* FastQC

* kmergenie

## FCM05C: reads stats

| Name     | N50 |         Sum |         # |
|:---------|----:|------------:|----------:|
| Illumina | 150 | 78098850000 | 520659000 |

# FCM05D

## FCM05D: download

* Settings

```bash
WORKING_DIR=${HOME}/data/dna-seq/xjy2
BASE_NAME=FCM05D
REAL_G=530000000
IS_EUK="true"
COVERAGE2="40 80"
READ_QUAL="25"
READ_LEN="60"

```

* Illumina

```bash
mkdir -p ${WORKING_DIR}/${BASE_NAME}/2_illumina
cd ${WORKING_DIR}/${BASE_NAME}/2_illumina

gzip -d -c \
    ${WORKING_DIR}/FCM05B/2_illumina/R1.fq.gz \
    ${WORKING_DIR}/FCM05C/2_illumina/R1.fq.gz \
    > R1.fq

gzip -d -c \
    ${WORKING_DIR}/FCM05B/2_illumina/R2.fq.gz \
    ${WORKING_DIR}/FCM05C/2_illumina/R2.fq.gz \
    > R2.fq

find . -name "*.fq" | parallel -j 2 pigz -p 8

```

## FCM05D: preprocess Illumina reads

## FCM05D: reads stats

## FCM05D: spades

## FCM05D: platanus

## FCM05D: quorum

## FCM05D: down sampling

## FCM05D: k-unitigs and anchors (sampled)


# FCM05SE

## FCM05SE: download

* Settings

```bash
WORKING_DIR=${HOME}/data/dna-seq/xjy2
BASE_NAME=FCM05SE
REAL_G=530000000
IS_EUK="true"
COVERAGE2="40 80"
READ_QUAL="25 30"
READ_LEN="60"

```

* Illumina

```bash
mkdir -p ${WORKING_DIR}/${BASE_NAME}/2_illumina
cd ${WORKING_DIR}/${BASE_NAME}/2_illumina

ln -s ${WORKING_DIR}/FCM05D/2_illumina/R1.fq.gz R1.fq.gz

```

## FCM05SE: preprocess Illumina reads

```bash
cd ${WORKING_DIR}/${BASE_NAME}

cd 2_illumina

anchr trim \
    --uniq \
    --nosickle \
    R1.fq.gz \
    -o trim.sh
bash trim.sh

parallel --no-run-if-empty --linebuffer -k -j 3 "
    mkdir -p Q{1}L{2}
    cd Q{1}L{2}
    
    if [ -e R1.fq.gz ]; then
        echo '    R1.fq.gz already presents'
        exit;
    fi

    anchr trim \
        -q {1} -l {2} \
        \$(
            if [ -e ../R1.scythe.fq.gz ]; then
                echo '../R1.scythe.fq.gz'
            elif [ -e ../R1.sample.fq.gz ]; then
                echo '../R1.sample.fq.gz'
            elif [ -e ../R1.shuffle.fq.gz ]; then
                echo '../R1.shuffle.fq.gz'
            elif [ -e ../R1.uniq.fq.gz ]; then
                echo '../R1.uniq.fq.gz'
            else
                echo '../R1.fq.gz'
            fi
        ) \
         \
        -o stdout \
        | bash
    " ::: ${READ_QUAL} ::: ${READ_LEN}

```

## FCM05SE: reads stats

```bash
cd ${WORKING_DIR}/${BASE_NAME}

printf "| %s | %s | %s | %s |\n" \
    "Name" "N50" "Sum" "#" \
    > stat.md
printf "|:--|--:|--:|--:|\n" >> stat.md

printf "| %s | %s | %s | %s |\n" \
    $(echo "Illumina"; faops n50 -H -S -C 2_illumina/R1.fq.gz;) >> stat.md
if [ -e 2_illumina/R1.uniq.fq.gz ]; then
    printf "| %s | %s | %s | %s |\n" \
        $(echo "uniq";    faops n50 -H -S -C 2_illumina/R1.uniq.fq.gz;) >> stat.md
fi
if [ -e 2_illumina/R1.shuffle.fq.gz ]; then
    printf "| %s | %s | %s | %s |\n" \
        $(echo "shuffle"; faops n50 -H -S -C 2_illumina/R1.shuffle.fq.gz;) >> stat.md
fi
if [ -e 2_illumina/R1.sample.fq.gz ]; then
    printf "| %s | %s | %s | %s |\n" \
        $(echo "sample";   faops n50 -H -S -C 2_illumina/R1.sample.fq.gz;) >> stat.md
fi
if [ -e 2_illumina/R1.scythe.fq.gz ]; then
    printf "| %s | %s | %s | %s |\n" \
        $(echo "scythe";  faops n50 -H -S -C 2_illumina/R1.scythe.fq.gz;) >> stat.md
fi

parallel --no-run-if-empty -k -j 3 "
    printf \"| %s | %s | %s | %s |\n\" \
        \$( 
            echo Q{1}L{2};
            faops n50 -H -S -C \
                2_illumina/Q{1}L{2}/R1.sickle.fq.gz;
        )
    " ::: ${READ_QUAL} ::: ${READ_LEN} \
    >> stat.md

cat stat.md

```

| Name     | N50 |         Sum |         # |
|:---------|----:|------------:|----------:|
| Illumina | 150 | 49640232150 | 330934881 |
| uniq     | 150 | 41080215750 | 273868105 |
| Q25L60   | 150 | 40496607839 | 273078531 |
| Q30L60   | 150 | 38980229662 | 267984250 |

## FCM05SE: quorum

```bash
cd ${WORKING_DIR}/${BASE_NAME}

parallel --no-run-if-empty --linebuffer -k -j 1 "
    cd 2_illumina/Q{1}L{2}
    echo >&2 '==> Group Q{1}L{2} <=='

    if [ ! -e R1.sickle.fq.gz ]; then
        echo >&2 '    R1.sickle.fq.gz not exists'
        exit;
    fi

    if [ -e pe.cor.fa ]; then
        echo >&2 '    pe.cor.fa exists'
        exit;
    fi

    anchr quorum \
        R1.sickle.fq.gz \
        -p 16 \
        -o quorum.sh

    bash quorum.sh
    
    echo >&2
    " ::: ${READ_QUAL} ::: ${READ_LEN}

# Stats of processed reads
bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 1 header \
    > stat1.md

parallel --no-run-if-empty -k -j 3 "
    if [ ! -d 2_illumina/Q{1}L{2} ]; then
        exit;
    fi

    bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 1 2_illumina/Q{1}L{2} ${REAL_G}
    " ::: ${READ_QUAL} ::: ${READ_LEN} \
     >> stat1.md

cat stat1.md

```

# FCM07

* *Chimonanthus praecox*
* 蜡梅
* Taxonomy ID: [13419](https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?mode=Info&id=13419)

## FCM07: download

```bash
BASE_NAME=FCM07
REAL_G=620000000

mkdir -p ~/data/dna-seq/xjy2/${BASE_NAME}/2_illumina
cd ~/data/dna-seq/xjy2/${BASE_NAME}/2_illumina

ln -s ~/data/dna-seq/xjy2/data/D7g7512_FCM07_R1_001.fastq.gz R1.fq.gz
ln -s ~/data/dna-seq/xjy2/data/D7g7512_FCM07_R2_001.fastq.gz R2.fq.gz

```

* FastQC

* kmergenie


## FCM07: combinations of different quality values and read lengths

* qual: 25 and 30
* len: 60

| Name     | N50 |         Sum |         # |
|:---------|----:|------------:|----------:|
| Illumina | 151 | 21952701630 | 145382130 |
| uniq     | 151 | 18070341234 | 119671134 |
| Q25L60   | 151 | 16564808588 | 113839810 |
| Q30L60   | 151 | 15904066489 | 112329431 |

## FCM07: spades

## FCM07: platanus

## FCM07: quorum

| Name   |  SumIn | CovIn | SumOut | CovOut | Discard% | AvgRead |  Kmer | RealG |    EstG | Est/Real |   RunTime |
|:-------|-------:|------:|-------:|-------:|---------:|--------:|------:|------:|--------:|---------:|----------:|
| Q25L60 | 16.56G |  26.7 | 14.18G |   22.9 |  14.368% |     144 | "105" |  620M | 602.28M |     0.97 | 1:24'19'' |
| Q30L60 | 15.91G |  25.7 | 14.16G |   22.8 |  10.973% |     142 | "105" |  620M | 598.68M |     0.97 | 2:31'10'' |

* Clear intermediate files.


## FCM07: down sampling


## FCM07: k-unitigs and anchors (sampled)

| Name          | SumCor | CovCor | N50SR |     Sum |      # | N50Anchor |     Sum |     # | N50Others |     Sum |      # |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|-------:|-------:|------:|--------:|-------:|----------:|--------:|------:|----------:|--------:|-------:|--------------------:|----------:|:----------|
| Q25L60X10P000 |   6.2G |   10.0 |   984 | 326.31M | 334367 |      2074 | 145.03M | 71476 |       688 | 181.28M | 262891 | "31,41,51,61,71,81" | 6:11'46'' | 0:24'19'' |
| Q25L60X10P001 |   6.2G |   10.0 |   983 | 325.65M | 334063 |      2071 | 144.59M | 71302 |       688 | 181.05M | 262761 | "31,41,51,61,71,81" | 4:34'08'' | 0:24'09'' |
| Q25L60X20P000 |  12.4G |   20.0 |  1098 | 336.31M | 310513 |      2775 | 172.81M | 71066 |       682 |  163.5M | 239447 | "31,41,51,61,71,81" | 5:24'29'' | 0:29'23'' |
| Q30L60X10P000 |   6.2G |   10.0 |   986 | 324.22M | 332021 |      2069 | 144.51M | 71458 |       688 | 179.71M | 260563 | "31,41,51,61,71,81" | 3:39'43'' | 0:30'17'' |
| Q30L60X10P001 |   6.2G |   10.0 |   986 | 323.44M | 331666 |      2066 | 143.76M | 71050 |       687 | 179.69M | 260616 | "31,41,51,61,71,81" | 4:16'51'' | 0:31'27'' |
| Q30L60X20P000 |  12.4G |   20.0 |  1100 |  336.9M | 310523 |      2774 | 173.47M | 71406 |       683 | 163.43M | 239117 | "31,41,51,61,71,81" | 4:01'53'' | 0:29'03'' |

## FCM07: merge anchors


## FCM07: final stats

* Stats

| Name                   |   N50 |       Sum |       # |
|:-----------------------|------:|----------:|--------:|
| anchor.merge           |  2394 | 226651719 |   98385 |
| others.merge           |  1061 |  52662986 |   46920 |
| spades.contig          |  6652 | 736473733 | 1252160 |
| spades.non-contained   | 12861 | 528958723 |   82401 |
| platanus.scaffold      |  1551 | 394046181 |  975205 |
| platanus.non-contained |  3757 | 227288969 |   76987 |

* Clear QxxLxxXxx.

# FCM13

* *Machilus thunbergii*
* 红楠
* Taxonomy ID:
  [128685](https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?mode=Info&id=128685)

## FCM13: download

```bash
BASE_NAME=FCM13
REAL_G=430000000

mkdir -p ~/data/dna-seq/xjy2/${BASE_NAME}/2_illumina
cd ~/data/dna-seq/xjy2/${BASE_NAME}/2_illumina

ln -s ~/data/dna-seq/xjy2/data/D7g7512_FCM13-BY_R1_001.fastq.gz R1.fq.gz
ln -s ~/data/dna-seq/xjy2/data/D7g7512_FCM13-BY_R2_001.fastq.gz R2.fq.gz

```

* FastQC

* kmergenie


## FCM13: combinations of different quality values and read lengths

* qual: 25 and 30
* len: 60

| Name     | N50 |         Sum |         # |
|:---------|----:|------------:|----------:|
| Illumina | 151 | 25328382130 | 167737630 |
| uniq     | 151 | 21475363752 | 142220952 |
| Q25L60   | 151 | 19383906193 | 133949012 |
| Q30L60   | 151 | 18623646006 | 132409641 |

## FCM13: spades

## FCM13: platanus

## FCM13: quorum

| Name   |  SumIn | CovIn | SumOut | CovOut | Discard% | AvgRead |  Kmer | RealG |    EstG | Est/Real |   RunTime |
|:-------|-------:|------:|-------:|-------:|---------:|--------:|------:|------:|--------:|---------:|----------:|
| Q25L60 | 19.38G |  45.1 | 15.81G |   36.8 |  18.428% |     144 | "105" |  430M | 898.48M |     2.09 | 1:02'01'' |
| Q30L60 | 18.63G |  43.3 |  15.7G |   36.5 |  15.704% |     141 |  "99" |  430M | 885.66M |     2.06 | 1:05'09'' |

* Clear intermediate files.


## FCM13: down sampling


## FCM13: k-unitigs and anchors (sampled)

| Name          | SumCor | CovCor | N50SR |     Sum |      # | N50Anchor |    Sum |     # | N50Others |     Sum |      # |                Kmer |  RunTimeKU | RunTimeAN |
|:--------------|-------:|-------:|------:|--------:|-------:|----------:|-------:|------:|----------:|--------:|-------:|--------------------:|-----------:|:----------|
| Q25L60X10P000 |   4.3G |   10.0 |   605 |  61.82M |  97880 |      1214 |  1.66M |  1323 |       601 |  60.15M |  96557 | "31,41,51,61,71,81" |  1:25'50'' | 0:06'58'' |
| Q25L60X10P001 |   4.3G |   10.0 |   605 |  62.37M |  98733 |      1227 |  1.71M |  1348 |       601 |  60.66M |  97385 | "31,41,51,61,71,81" |  5:06'20'' | 0:06'44'' |
| Q25L60X10P002 |   4.3G |   10.0 |   605 |  61.69M |  97629 |      1233 |   1.7M |  1335 |       601 |  59.99M |  96294 | "31,41,51,61,71,81" |  2:40'55'' | 0:05'57'' |
| Q25L60X20P000 |   8.6G |   20.0 |   643 | 206.59M | 308983 |      1258 | 15.95M | 12176 |       627 | 190.64M | 296807 | "31,41,51,61,71,81" |  3:08'00'' | 0:17'15'' |
| Q25L60X25P000 | 10.75G |   25.0 |   663 |  263.9M | 382272 |      1303 | 29.65M | 21882 |       636 | 234.25M | 360390 | "31,41,51,61,71,81" | 21:24'23'' | 0:23'23'' |
| Q25L60X30P000 |  12.9G |   30.0 |   682 |  306.5M | 431011 |      1344 | 44.56M | 31859 |       644 | 261.94M | 399152 | "31,41,51,61,71,81" |  4:43'48'' | 0:24'34'' |
| Q30L60X10P000 |   4.3G |   10.0 |   604 |  60.84M |  96331 |      1217 |   1.7M |  1349 |       600 |  59.15M |  94982 | "31,41,51,61,71,81" |  1:04'12'' | 0:04'00'' |
| Q30L60X10P001 |   4.3G |   10.0 |   605 |  61.36M |  97058 |      1221 |  1.72M |  1361 |       601 |  59.64M |  95697 | "31,41,51,61,71,81" |  1:24'51'' | 0:04'03'' |
| Q30L60X10P002 |   4.3G |   10.0 |   604 |  60.38M |  95650 |      1228 |  1.65M |  1300 |       600 |  58.73M |  94350 | "31,41,51,61,71,81" |  1:13'43'' | 0:05'04'' |
| Q30L60X20P000 |   8.6G |   20.0 |   642 | 202.33M | 302950 |      1257 | 15.41M | 11775 |       626 | 186.92M | 291175 | "31,41,51,61,71,81" |  3:43'17'' | 0:19'14'' |
| Q30L60X25P000 | 10.75G |   25.0 |   661 | 258.28M | 375114 |      1297 | 28.32M | 20981 |       635 | 229.96M | 354133 | "31,41,51,61,71,81" |  5:19'18'' | 0:30'49'' |
| Q30L60X30P000 |  12.9G |   30.0 |   680 | 298.59M | 421566 |      1336 | 42.37M | 30472 |       643 | 256.22M | 391094 | "31,41,51,61,71,81" | 12:11'08'' | 0:47'48'' |

## FCM13: merge anchors


## FCM13: final stats

* Stats

| Name                   |  N50 |       Sum |      # |
|:-----------------------|-----:|----------:|-------:|
| anchor.merge           | 1315 |  66842601 |  48521 |
| others.merge           | 1052 |  35360272 |  32084 |
| spades.contig          | 5558 | 794532947 | 683063 |
| spades.non-contained   | 8410 | 621971771 | 131159 |
| platanus.scaffold      | 1487 |    665925 |   1867 |
| platanus.non-contained | 4281 |    371926 |    108 |

* Clear QxxLxxXxx.

# Create tarballs

```bash
for BASE_NAME in FCM03 FCM05 FCM07 FCM13; do
    echo >&2 "==> ${BASE_NAME}"
    pushd ${HOME}/data/dna-seq/xjy2/${BASE_NAME}
    
    if [ -e ../${BASE_NAME}.tar.gz ]; then
        echo >&2 "    ${BASE_NAME}.tar.gz exists"
    else
        tar -czvf \
            ../${BASE_NAME}.tar.gz \
            2_illumina/fastqc/*.html \
            8_spades/contigs.non-contained.fasta \
            8_platanus/gapClosed.non-contained.fasta \
            merge/anchor.merge.fasta \
            merge/others.merge.fasta
    fi

    popd
done

find ${HOME}/data/dna-seq/xjy2/ -type d -path "*8_spades/*" | xargs rm -fr
find ${HOME}/data/dna-seq/xjy2/ -type f -path "*8_platanus/*" -name "R[12s].fa" | xargs rm
```

