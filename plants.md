# Plants 2+3

[TOC levels=1-3]: # " "
- [Plants 2+3](#plants-23)
- [ZS97, *Oryza sativa* Indica Group, Zhenshan 97](#zs97-oryza-sativa-indica-group-zhenshan-97)
    - [ZS97: download](#zs97-download)
    - [ZS97: preprocess Illumina reads](#zs97-preprocess-illumina-reads)
    - [ZS97: reads stats](#zs97-reads-stats)
    - [ZS97: spades](#zs97-spades)
    - [ZS97: platanus](#zs97-platanus)
    - [ZS97: quorum](#zs97-quorum)
    - [ZS97: down sampling](#zs97-down-sampling)
    - [ZS97: k-unitigs and anchors (sampled)](#zs97-k-unitigs-and-anchors-sampled)
    - [ZS97: merge anchors](#zs97-merge-anchors)
    - [ZS97: final stats](#zs97-final-stats)
    - [ZS97: clear intermediate files](#zs97-clear-intermediate-files)
- [CgiA, Cercis gigantea, 巨紫荆 A](#cgia-cercis-gigantea-巨紫荆-a)
    - [CgiA: download](#cgia-download)
    - [CgiA: combinations of different quality values and read lengths](#cgia-combinations-of-different-quality-values-and-read-lengths)
    - [CgiA: spades](#cgia-spades)
    - [CgiA: platanus](#cgia-platanus)
    - [CgiA: quorum](#cgia-quorum)
    - [CgiA: down sampling](#cgia-down-sampling)
    - [CgiA: k-unitigs and anchors (sampled)](#cgia-k-unitigs-and-anchors-sampled)
    - [CgiA: merge anchors](#cgia-merge-anchors)
    - [CgiA: final stats](#cgia-final-stats)
- [CgiB, Cercis gigantea](#cgib-cercis-gigantea)
    - [CgiB: download](#cgib-download)
    - [CgiB: combinations of different quality values and read lengths](#cgib-combinations-of-different-quality-values-and-read-lengths)
    - [CgiB: spades](#cgib-spades)
    - [CgiB: platanus](#cgib-platanus)
    - [CgiB: final stats](#cgib-final-stats)
    - [Merge CgiA and CgiB](#merge-cgia-and-cgib)
- [CgiC, Cercis gigantea](#cgic-cercis-gigantea)
    - [CgiC: download](#cgic-download)
    - [CgiC: combinations of different quality values and read lengths](#cgic-combinations-of-different-quality-values-and-read-lengths)
    - [CgiC: spades](#cgic-spades)
    - [CgiC: platanus](#cgic-platanus)
    - [CgiC: final stats](#cgic-final-stats)
- [CgiD, Cercis gigantea](#cgid-cercis-gigantea)
    - [CgiD: download](#cgid-download)
    - [CgiD: combinations of different quality values and read lengths](#cgid-combinations-of-different-quality-values-and-read-lengths)
    - [CgiD: spades](#cgid-spades)
    - [CgiD: platanus](#cgid-platanus)
    - [CgiD: final stats](#cgid-final-stats)
    - [Merge CgiC and CgiD](#merge-cgic-and-cgid)
- [Cgi](#cgi)
    - [Cgi: Merge CgiAB and CgiCD](#cgi-merge-cgiab-and-cgicd)
    - [Cgi: preprocess PacBio reads](#cgi-preprocess-pacbio-reads)
    - [Cgi: 3GS](#cgi-3gs)
- [moli, 茉莉](#moli-茉莉)
    - [moli: download](#moli-download)
    - [moli: combinations of different quality values and read lengths](#moli-combinations-of-different-quality-values-and-read-lengths)
    - [moli: down sampling](#moli-down-sampling)
    - [moli: generate super-reads](#moli-generate-super-reads)
    - [moli: create anchors](#moli-create-anchors)
    - [moli: results](#moli-results)
    - [moli: merge anchors](#moli-merge-anchors)


# ZS97, *Oryza sativa* Indica Group, Zhenshan 97

## ZS97: download

* Settings

```bash
BASE_NAME=ZS97
REAL_G=346663259
COVERAGE2="30 40 50 60 70"
#COVERAGE3="40 80"
READ_QUAL="25 30"
READ_LEN="60"
#EXPAND_WITH="40"

```

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

* FastQC

```bash
cd ${HOME}/data/dna-seq/chara/${BASE_NAME}

mkdir -p 2_illumina/fastqc
cd 2_illumina/fastqc

fastqc -t 16 \
    ../R1.fq.gz ../R2.fq.gz \
    -o .

```

* kmergenie

```bash
cd ${HOME}/data/dna-seq/chara/${BASE_NAME}

mkdir -p 2_illumina/kmergenie
cd 2_illumina/kmergenie

parallel -j 2 "
    kmergenie -l 21 -k 121 -s 10 -t 8 ../{}.fq.gz -o {}
    " ::: R1 R2

```

## ZS97: preprocess Illumina reads

* Peak memory: 138 GiB

```bash
cd ${HOME}/data/dna-seq/chara/${BASE_NAME}

if [ ! -e 2_illumina/R1.uniq.fq.gz ]; then
    tally \
        --pair-by-offset --with-quality --nozip --unsorted \
        -i 2_illumina/R1.fq.gz \
        -j 2_illumina/R2.fq.gz \
        -o 2_illumina/R1.uniq.fq \
        -p 2_illumina/R2.uniq.fq
    
    parallel --no-run-if-empty -j 2 "
            pigz -p 4 2_illumina/{}.uniq.fq
        " ::: R1 R2
fi

cat <<EOF > 2_illumina/illumina_adapters.fa
>multiplexing-forward
GATCGGAAGAGCACACGTCT
>solexa-forward
AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT
>truseq-forward-contam
AGATCGGAAGAGCACACGTCTGAACTCCAGTCAC
>truseq-reverse-contam
AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGTA
>nextera-forward-read-contam
CTGTCTCTTATACACATCTCCGAGCCCACGAGAC
>nextera-reverse-read-contam
CTGTCTCTTATACACATCTGACGCTGCCGACGA
>solexa-reverse
AGATCGGAAGAGCGGTTCAGCAGGAATGCCGAG

>TruSeq_Adapter_Index_7
AGATCGGAAGAGCACACGTCTGAACTCCAGTCACCAGATCATCTCGTATGC
>Illumina_Single_End_PCR_Primer_1
AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGTAGATCTCGGTGGTCGCCG

EOF

if [ ! -e 2_illumina/R1.scythe.fq.gz ]; then
    parallel --no-run-if-empty -j 2 "
        scythe \
            2_illumina/{}.uniq.fq.gz \
            -q sanger \
            -a 2_illumina/illumina_adapters.fa \
            --quiet \
            | pigz -p 4 -c \
            > 2_illumina/{}.scythe.fq.gz
        " ::: R1 R2
fi

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
    " ::: ${READ_QUAL} ::: ${READ_LEN}

```

## ZS97: reads stats

```bash
cd ${HOME}/data/dna-seq/chara/${BASE_NAME}

printf "| %s | %s | %s | %s |\n" \
    "Name" "N50" "Sum" "#" \
    > stat.md
printf "|:--|--:|--:|--:|\n" >> stat.md

printf "| %s | %s | %s | %s |\n" \
    $(echo "Genome";   faops n50 -H -S -C 1_genome/genome.fa;) >> stat.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "Illumina"; faops n50 -H -S -C 2_illumina/R1.fq.gz 2_illumina/R2.fq.gz;) >> stat.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "uniq";     faops n50 -H -S -C 2_illumina/R1.uniq.fq.gz 2_illumina/R2.uniq.fq.gz;) >> stat.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "scythe";   faops n50 -H -S -C 2_illumina/R1.scythe.fq.gz 2_illumina/R2.scythe.fq.gz;) >> stat.md

parallel --no-run-if-empty -k -j 3 "
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
    " ::: ${READ_QUAL} ::: ${READ_LEN} \
    >> stat.md

cat stat.md

```

| Name     |      N50 |         Sum |         # |
|:---------|---------:|------------:|----------:|
| Genome   | 27449063 |   346663259 |        12 |
| Illumina |      101 | 34167671982 | 338293782 |
| uniq     |      101 | 33822673960 | 334877960 |
| scythe   |      101 | 32399254278 | 334877960 |
| Q25L60   |      101 | 27030520638 | 273011730 |
| Q30L60   |      101 | 25959559694 | 268552482 |

## ZS97: spades

```bash
cd ${HOME}/data/dna-seq/chara/${BASE_NAME}

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

## ZS97: platanus

```bash
cd ${HOME}/data/dna-seq/chara/${BASE_NAME}

mkdir -p 8_platanus
cd 8_platanus

if [ ! -e pe.fa ]; then
    faops interleave \
        -p pe \
        ../2_illumina/Q25L60/R1.fq.gz \
        ../2_illumina/Q25L60/R2.fq.gz \
        > pe.fa
    
    faops interleave \
        -p se \
        ../2_illumina/Q25L60/Rs.fq.gz \
        > se.fa
fi

platanus assemble -t 16 -m 100 \
    -f pe.fa se.fa \
    2>&1 | tee ass_log.txt

platanus scaffold -t 16 \
    -c out_contig.fa -b out_contigBubble.fa \
    -ip1 pe.fa \
    2>&1 | tee sca_log.txt

platanus gap_close -t 16 \
    -c out_scaffold.fa \
    -ip1 pe.fa \
    2>&1 | tee gap_log.txt

anchr contained \
    out_gapClosed.fa \
    --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
    -o stdout \
    | faops filter -a 1000 -l 0 stdin gapClosed.non-contained.fasta

```

## ZS97: quorum

```bash
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

    if [[ {1} == '30' ]]; then
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
    " ::: ${READ_QUAL} ::: ${READ_LEN}

# Stats of processed reads
bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 1 header \
    > stat1.md

parallel -k --no-run-if-empty -j 3 "
    if [ ! -d 2_illumina/Q{1}L{2} ]; then
        exit;
    fi

    bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 1 2_illumina/Q{1}L{2} ${REAL_G}
    " ::: ${READ_QUAL} ::: ${READ_LEN} \
    >> stat1.md

cat stat1.md
```

| Name   |  SumIn | CovIn | SumOut | CovOut | Discard% | AvgRead | Kmer |   RealG |    EstG | Est/Real |   RunTime |
|:-------|-------:|------:|-------:|-------:|---------:|--------:|-----:|--------:|--------:|---------:|----------:|
| Q25L60 | 27.03G |  78.0 | 24.71G |   71.3 |   8.588% |     100 | "71" | 346.66M | 298.19M |     0.86 | 1:21'13'' |
| Q30L60 | 25.98G |  74.9 |  24.1G |   69.5 |   7.236% |     100 | "71" | 346.66M | 295.49M |     0.85 | 1:22'38'' |

## ZS97: down sampling

```bash
cd ${HOME}/data/dna-seq/chara/${BASE_NAME}

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

## ZS97: k-unitigs and anchors (sampled)

```bash
cd ${HOME}/data/dna-seq/chara/${BASE_NAME}

# k-unitigs (sampled)
parallel --no-run-if-empty -j 2 "
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

# anchors (sampled)
parallel --no-run-if-empty -j 3 "
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
    " ::: ${READ_QUAL} ::: ${READ_LEN} ::: ${COVERAGE2} ::: $(printf "%03d " {0..100})

# Stats of anchors
bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 header \
    > stat2.md

parallel -k --no-run-if-empty -j 6 "
    if [ ! -e Q{1}L{2}X{3}P{4}/anchor/pe.anchor.fa ]; then
        exit;
    fi

    bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 Q{1}L{2}X{3}P{4} ${REAL_G}
    " ::: ${READ_QUAL} ::: ${READ_LEN} ::: ${COVERAGE2} ::: $(printf "%03d " {0..100}) \
    >> stat2.md

cat stat2.md
```

| Name          | SumCor | CovCor | N50SR |     Sum |      # | N50Anchor |     Sum |     # | N50Others |    Sum |     # |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|-------:|-------:|------:|--------:|-------:|----------:|--------:|------:|----------:|-------:|------:|--------------------:|----------:|:----------|
| Q25L60X10P000 |  3.47G |   10.0 |  1734 | 215.63M | 157603 |      2488 | 148.25M | 65347 |       745 | 67.38M | 92256 | "31,41,51,61,71,81" | 2:41'43'' | 0:16'53'' |
| Q25L60X10P001 |  3.47G |   10.0 |  1772 |  218.3M | 157502 |      2526 | 151.62M | 66090 |       743 | 66.68M | 91412 | "31,41,51,61,71,81" | 2:49'55'' | 0:17'23'' |
| Q25L60X10P002 |  3.47G |   10.0 |  1766 |  218.1M | 157413 |      2528 | 151.46M | 66094 |       743 | 66.64M | 91319 | "31,41,51,61,71,81" | 2:40'11'' | 0:17'08'' |
| Q25L60X10P003 |  3.47G |   10.0 |  1765 | 218.07M | 157686 |      2519 | 150.98M | 65848 |       743 | 67.09M | 91838 | "31,41,51,61,71,81" | 2:42'55'' | 0:16'03'' |
| Q25L60X10P004 |  3.47G |   10.0 |  1792 | 220.37M | 157947 |      2544 | 153.69M | 66591 |       743 | 66.68M | 91356 | "31,41,51,61,71,81" | 2:45'08'' | 0:17'19'' |
| Q25L60X10P005 |  3.47G |   10.0 |  1794 | 220.51M | 157850 |      2540 | 154.13M | 66831 |       742 | 66.38M | 91019 | "31,41,51,61,71,81" | 2:53'41'' | 0:17'23'' |
| Q25L60X10P006 |  3.47G |   10.0 |  1797 | 220.35M | 157663 |      2558 | 153.67M | 66385 |       743 | 66.67M | 91278 | "31,41,51,61,71,81" | 3:01'24'' | 0:15'18'' |
| Q25L60X20P000 |  6.93G |   20.0 |  2938 | 263.02M | 138459 |      3687 | 213.25M | 70953 |       744 | 49.77M | 67506 | "31,41,51,61,71,81" | 5:58'50'' | 0:22'50'' |
| Q25L60X20P001 |  6.93G |   20.0 |  2965 | 263.54M | 137933 |      3713 | 214.17M | 71011 |       744 | 49.38M | 66922 | "31,41,51,61,71,81" | 5:19'06'' | 0:22'45'' |
| Q25L60X20P002 |  6.93G |   20.0 |  3037 |  265.7M | 137188 |      3780 | 216.78M | 70876 |       743 | 48.92M | 66312 | "31,41,51,61,71,81" | 6:04'38'' | 0:20'45'' |
| Q25L60X30P000 |  10.4G |   30.0 |  3625 | 276.72M | 126387 |      4333 | 234.84M | 69684 |       743 | 41.88M | 56703 | "31,41,51,61,71,81" | 6:54'23'' | 0:26'32'' |
| Q25L60X30P001 |  10.4G |   30.0 |  3726 | 278.13M | 124559 |      4422 | 237.42M | 69427 |       742 | 40.71M | 55132 | "31,41,51,61,71,81" | 7:32'01'' | 0:27'35'' |
| Q25L60X60P000 |  20.8G |   60.0 |  4668 | 286.82M | 108526 |      5297 | 254.88M | 65645 |       745 | 31.94M | 42881 | "31,41,51,61,71,81" | 6:50'07'' | 0:30'15'' |
| Q30L60X10P000 |  3.47G |   10.0 |  1688 |  207.1M | 153919 |      2444 | 140.91M | 63040 |       742 | 66.19M | 90879 | "31,41,51,61,71,81" | 1:54'28'' | 0:14'21'' |
| Q30L60X10P001 |  3.47G |   10.0 |  1718 | 209.22M | 153772 |      2471 | 143.55M | 63517 |       741 | 65.67M | 90255 | "31,41,51,61,71,81" | 2:32'13'' | 0:15'11'' |
| Q30L60X10P002 |  3.47G |   10.0 |  1713 | 209.32M | 154062 |      2474 | 143.43M | 63612 |       741 | 65.88M | 90450 | "31,41,51,61,71,81" | 2:45'35'' | 0:14'40'' |
| Q30L60X10P003 |  3.47G |   10.0 |  1730 | 210.42M | 154189 |      2475 |  144.9M | 64182 |       740 | 65.52M | 90007 | "31,41,51,61,71,81" | 2:27'07'' | 0:16'02'' |
| Q30L60X10P004 |  3.47G |   10.0 |  1742 | 212.49M | 155081 |      2490 | 146.67M | 64564 |       741 | 65.82M | 90517 | "31,41,51,61,71,81" | 2:36'29'' | 0:16'46'' |
| Q30L60X10P005 |  3.47G |   10.0 |  1746 | 212.27M | 154436 |      2503 | 146.74M | 64495 |       740 | 65.53M | 89941 | "31,41,51,61,71,81" | 2:55'20'' | 0:14'40'' |
| Q30L60X20P000 |  6.93G |   20.0 |  2644 | 252.33M | 141816 |      3386 | 200.23M | 70927 |       743 |  52.1M | 70889 | "31,41,51,61,71,81" | 5:15'24'' | 0:21'05'' |
| Q30L60X20P001 |  6.93G |   20.0 |  2681 | 253.65M | 141370 |      3435 | 201.84M | 71072 |       747 | 51.81M | 70298 | "31,41,51,61,71,81" | 5:12'12'' | 0:22'02'' |
| Q30L60X20P002 |  6.93G |   20.0 |  2744 | 255.92M | 140438 |      3490 | 204.86M | 71123 |       745 | 51.06M | 69315 | "31,41,51,61,71,81" | 5:33'02'' | 0:19'55'' |
| Q30L60X30P000 |  10.4G |   30.0 |  3154 | 266.57M | 133166 |      3849 | 221.21M | 71631 |       744 | 45.36M | 61535 | "31,41,51,61,71,81" | 6:23'08'' | 0:24'50'' |
| Q30L60X30P001 |  10.4G |   30.0 |  3268 | 269.51M | 131494 |      3966 |    225M | 71243 |       744 | 44.51M | 60251 | "31,41,51,61,71,81" | 7:07'54'' | 0:27'36'' |
| Q30L60X60P000 |  20.8G |   60.0 |  3977 |  280.5M | 118592 |      4598 | 244.18M | 69643 |       745 | 36.32M | 48949 | "31,41,51,61,71,81" | 6:53'31'' | 0:31'33'' |

## ZS97: merge anchors

```bash
cd ${HOME}/data/dna-seq/chara/${BASE_NAME}

# merge anchors
mkdir -p merge
anchr contained \
    $(
        parallel --no-run-if-empty -k -j 6 "
            if [ -e Q{1}L{2}X{3}P{4}/anchor/pe.anchor.fa ]; then
                echo Q{1}L{2}X{3}P{4}/anchor/pe.anchor.fa
            fi
            " ::: ${READ_QUAL} ::: ${READ_LEN} ::: ${COVERAGE2} ::: $(printf "%03d " {0..100})
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
        parallel --no-run-if-empty -k -j 6 "
            if [ -e Q{1}L{2}X{3}P{4}/anchor/pe.others.fa ]; then
                echo Q{1}L{2}X{3}P{4}/anchor/pe.others.fa
            fi
            " ::: ${READ_QUAL} ::: ${READ_LEN} ::: ${COVERAGE2} ::: $(printf "%03d " {0..100})
    ) \
    --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
    -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/others.contained.fasta
anchr orient merge/others.contained.fasta --len 1000 --idt 0.98 -o merge/others.orient.fasta
anchr merge merge/others.orient.fasta --len 1000 --idt 0.999 -o merge/others.merge0.fasta
anchr contained merge/others.merge0.fasta --len 1000 --idt 0.98 \
    --proportion 0.99 --parallel 16 -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/others.merge.fasta

# anchor sort on ref
bash ~/Scripts/cpan/App-Anchr/share/sort_on_ref.sh merge/anchor.merge.fasta 1_genome/genome.fa merge/anchor.sort
nucmer -l 200 1_genome/genome.fa merge/anchor.sort.fa
mummerplot -png out.delta -p anchor.sort --large

# mummerplot files
rm *.[fr]plot
rm out.delta
rm *.gp
mv anchor.sort.png merge/

# quast
rm -fr 9_qa
quast --no-check --threads 16 \
    --eukaryote \
    --no-icarus \
    -R 1_genome/genome.fa \
    merge/anchor.merge.fasta \
    merge/others.merge.fasta \
    --label "merge,others" \
    -o 9_qa

```

## ZS97: final stats

* Stats

```bash
cd ${HOME}/data/anchr/${BASE_NAME}

printf "| %s | %s | %s | %s |\n" \
    "Name" "N50" "Sum" "#" \
    > stat3.md
printf "|:--|--:|--:|--:|\n" >> stat3.md

printf "| %s | %s | %s | %s |\n" \
    $(echo "Genome";   faops n50 -H -S -C 1_genome/genome.fa;) >> stat3.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "Paralogs";   faops n50 -H -S -C 1_genome/paralogs.fas;) >> stat3.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "anchor.merge"; faops n50 -H -S -C merge/anchor.merge.fasta;) >> stat3.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "others.merge"; faops n50 -H -S -C merge/others.merge.fasta;) >> stat3.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "anchorLong"; faops n50 -H -S -C anchorLong/contig.fasta;) >> stat3.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "spades.config"; faops n50 -H -S -C 8_spades/configs.fasta;) >> stat3.md
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

| Name                   |      N50 |       Sum |       # |
|:-----------------------|---------:|----------:|--------:|
| Genome                 | 27449063 | 346663259 |      12 |
| anchor.merge           |     5533 | 262303705 |   66077 |
| others.merge           |     1158 | 103014560 |   85485 |
| spades.contig          |    12421 | 343065556 |  246828 |
| spades.scaffold        |    13039 | 343127110 |  245326 |
| spades.non-contained   |    14589 | 300686248 |   37507 |
| platanus.contig        |     1419 | 422154233 | 1526431 |
| platanus.scaffold      |     7687 | 325245861 |  396499 |
| platanus.non-contained |     9554 | 270282635 |   43521 |

* quast

```bash
cd ${HOME}/data/dna-seq/chara/${BASE_NAME}

rm -fr 9_qa_contig
quast --no-check --threads 16 \
    --eukaryote \
    --no-icarus \
    -R 1_genome/genome.fa \
    merge/anchor.merge.fasta \
    8_spades/contigs.non-contained.fasta \
    8_platanus/gapClosed.non-contained.fasta \
    --label "merge,spades,platanus" \
    -o 9_qa_contig

```

## ZS97: clear intermediate files

```bash
cd ${HOME}/data/dna-seq/chara/${BASE_NAME}

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
rm -fr 2_illumina/Q{20,25,30,35}L{30,60,90,120}X*
rm -fr Q{20,25,30,35}L{30,60,90,120}X*

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

# CgiA, Cercis gigantea, 巨紫荆 A

## CgiA: download

```bash
BASE_NAME=CgiA
mkdir -p ${HOME}/data/dna-seq/chara/${BASE_NAME}
cd ${HOME}/data/dna-seq/chara/${BASE_NAME}

mkdir -p 2_illumina
cd 2_illumina

ln -s ../../medfood/Cgi_R1_head50.fastq.gz R1.fq.gz
ln -s ../../medfood/Cgi_R2_head50.fastq.gz R2.fq.gz
```

* FastQC

```bash
BASE_NAME=CgiA
cd ${HOME}/data/dna-seq/chara/${BASE_NAME}

mkdir -p 2_illumina/fastqc
cd 2_illumina/fastqc

fastqc -t 16 \
    ../R1.fq.gz ../R2.fq.gz \
    -o .

```

* kmergenie

```bash
BASE_NAME=CgiA
cd ${HOME}/data/dna-seq/chara/${BASE_NAME}

mkdir -p 2_illumina/kmergenie
cd 2_illumina/kmergenie

kmergenie -l 21 -k 121 -s 10 -t 8 ../R1.fq.gz -o oriR1
kmergenie -l 21 -k 121 -s 10 -t 8 ../R2.fq.gz -o oriR2

```

## CgiA: combinations of different quality values and read lengths

* qual: 20, 25, and 30
* len: 60

```bash
BASE_NAME=CgiA
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

cat ${HOME}/.plenv/versions/5.18.4/lib/perl5/site_perl/5.18.4/auto/share/dist/App-Anchr/illumina_adapters.fa \
    > 2_illumina/illumina_adapters.fa
echo ">TruSeq_Adapter_Index_15" >> 2_illumina/illumina_adapters.fa
echo "GATCGGAAGAGCACACGTCTGAACTCCAGTCACACGCTCGAATCTCGTAT" >> 2_illumina/illumina_adapters.fa
echo ">Illumina_Single_End_PCR_Primer_1" >> 2_illumina/illumina_adapters.fa
echo "GATCGGAAGAGCGTCGTGTAGGGAAAGAGTGTAGATCTCGGTGGTCGCCG" >> 2_illumina/illumina_adapters.fa

if [ ! -e 2_illumina/R1.scythe.fq.gz ]; then
    parallel --no-run-if-empty -j 2 "
        scythe \
            2_illumina/{}.uniq.fq.gz \
            -q sanger \
            -a 2_illumina/illumina_adapters.fa \
            --quiet \
            | pigz -p 4 -c \
            > 2_illumina/{}.scythe.fq.gz
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
        ../R1.scythe.fq.gz ../R2.scythe.fq.gz \
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
printf "| %s | %s | %s | %s |\n" \
    $(echo "scythe";   faops n50 -H -S -C 2_illumina/R1.scythe.fq.gz 2_illumina/R2.scythe.fq.gz;) >> stat.md

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
| Illumina | 151 | 58890000000 | 390000000 |
| uniq     | 151 | 57639361828 | 381717628 |
| scythe   | 151 | 56855792587 | 381717628 |
| Q20L60   | 151 | 47181285790 | 332231596 |
| Q25L60   | 151 | 39049905338 | 284195248 |
| Q30L60   | 151 | 37761899864 | 286580535 |

## CgiA: spades

```bash
BASE_NAME=CgiA
cd ${HOME}/data/dna-seq/chara/${BASE_NAME}

spades.py \
    -t 16 \
    -k 21,33,55,77 \
    -1 2_illumina/Q25L60/R1.fq.gz \
    -2 2_illumina/Q25L60/R2.fq.gz \
    -s 2_illumina/Q25L60/Rs.fq.gz \
    -o 8_spades
```

## CgiA: platanus

```bash
BASE_NAME=CgiA
cd ${HOME}/data/dna-seq/chara/${BASE_NAME}

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

```text
#### PROCESS INFORMATION ####
VmPeak:         158.718 GByte
VmHWM:           62.453 GByte
```

## CgiA: quorum

```bash
BASE_NAME=CgiA
REAL_G=500000000
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

| Name   |  SumIn | CovIn | SumOut | CovOut | Discard% | AvgRead | Kmer | RealG |    EstG | Est/Real |   RunTime |
|:-------|-------:|------:|-------:|-------:|---------:|--------:|-----:|------:|--------:|---------:|----------:|
| Q25L60 | 39.05G |  78.1 | 33.11G |   66.2 |  15.211% |     137 | "91" |  500M | 368.39M |     0.74 | 2:59'12'' |
| Q30L60 | 37.82G |  75.6 | 34.74G |   69.5 |   8.147% |     132 | "81" |  500M | 355.97M |     0.71 | 1:59'00'' |

* Clear intermediate files.

```bash
BASE_NAME=CgiA
cd ${HOME}/data/dna-seq/chara/${BASE_NAME}

find 2_illumina -type f -name "quorum_mer_db.jf" | xargs rm
find 2_illumina -type f -name "k_u_hash_0"       | xargs rm
find 2_illumina -type f -name "*.tmp"            | xargs rm
find 2_illumina -type f -name "pe.renamed.fastq" | xargs rm
find 2_illumina -type f -name "se.renamed.fastq" | xargs rm
find 2_illumina -type f -name "pe.cor.sub.fa"    | xargs rm
```

## CgiA: down sampling

```bash
BASE_NAME=CgiA
REAL_G=500000000
cd ${HOME}/data/dna-seq/chara/${BASE_NAME}

for QxxLxx in $( parallel "echo 'Q{1}L{2}'" ::: 25 30 ::: 60 ); do
    echo "==> ${QxxLxx}"

    if [ ! -e 2_illumina/${QxxLxx}/pe.cor.fa ]; then
        echo "2_illumina/${QxxLxx}/pe.cor.fa not exists"
        continue;
    fi

    for X in 30 60; do
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

## CgiA: k-unitigs and anchors (sampled)

```bash
BASE_NAME=CgiA
REAL_G=500000000
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
    " ::: 25 30 ::: 60 ::: 30 60 ::: 000 001 002 003 004 005 006

# anchors (sampled)
parallel --no-run-if-empty -j 2 "
    echo >&2 '==> Group Q{1}L{2}X{3}P{4}'

    if [ -e Q{1}L{2}X{3}P{4}/anchor/pe.anchor.fa ]; then
        exit;
    fi

    if [ ! -e Q{1}L{2}/k_unitigs.fasta ]; then
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
    " ::: 25 30 ::: 60 ::: 30 60 ::: 000 001 002 003 004 005 006

# Stats of anchors
bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 header \
    > stat2.md

parallel -k --no-run-if-empty -j 6 "
    if [ ! -e Q{1}L{2}X{3}P{4}/anchor/pe.anchor.fa ]; then
        exit;
    fi

    bash ~/Scripts/cpan/App-Anchr/share/sr_stat.sh 2 Q{1}L{2}X{3}P{4} ${REAL_G}
    " ::: 25 30 ::: 60 ::: 30 60 ::: 000 001 002 003 004 005 006 \
     >> stat2.md

cat stat2.md
```

| Name          | SumCor | CovCor | N50SR |     Sum |      # | N50Anchor |    Sum |     # | N50Others |    Sum |      # |                Kmer | RunTimeKU | RunTimeAN |
|:--------------|-------:|-------:|------:|--------:|-------:|----------:|-------:|------:|----------:|-------:|-------:|--------------------:|----------:|:----------|
| Q25L60X30P000 |    15G |   30.0 |   839 | 138.13M | 157958 |      1747 | 51.85M | 28791 |       665 | 86.29M | 129167 | "31,41,51,61,71,81" | 2:38'40'' | 0:16'03'' |
| Q25L60X30P001 |    15G |   30.0 |   840 | 138.22M | 158010 |      1746 | 51.94M | 28839 |       665 | 86.28M | 129171 | "31,41,51,61,71,81" | 2:35'17'' | 0:15'34'' |
| Q25L60X60P000 |    30G |   60.0 |   828 | 134.34M | 155963 |      1683 | 49.63M | 28646 |       662 | 84.71M | 127317 | "31,41,51,61,71,81" | 4:10'17'' | 0:28'06'' |
| Q30L60X30P000 |    15G |   30.0 |   841 | 139.25M | 158884 |      1766 |  52.4M | 28832 |       665 | 86.85M | 130052 | "31,41,51,61,71,81" | 2:29'24'' | 0:16'41'' |
| Q30L60X30P001 |    15G |   30.0 |   842 | 139.56M | 159066 |      1758 | 52.69M | 28965 |       665 | 86.87M | 130101 | "31,41,51,61,71,81" | 2:31'05'' | 0:16'40'' |
| Q30L60X60P000 |    30G |   60.0 |   843 |  138.4M | 158013 |      1719 | 53.13M | 29953 |       663 | 85.27M | 128060 | "31,41,51,61,71,81" | 4:00'07'' | 0:29'19'' |

## CgiA: merge anchors

```bash
BASE_NAME=CgiA
cd ${HOME}/data/dna-seq/chara/${BASE_NAME}

# merge anchors
mkdir -p merge
anchr contained \
    $(
        parallel -k --no-run-if-empty -j 6 "
            if [ -e Q{1}L{2}X{3}P{4}/anchor/pe.anchor.fa ]; then
                echo Q{1}L{2}X{3}P{4}/anchor/pe.anchor.fa
            fi
            " ::: 25 30 ::: 60 ::: 30 60 ::: 000 001 002 003 004 005 006
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
            " ::: 25 30 ::: 60 ::: 30 60 ::: 000 001 002 003 004 005 006
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

## CgiA: final stats

* Stats

```bash
BASE_NAME=CgiA
cd ${HOME}/data/dna-seq/chara/${BASE_NAME}

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
    $(echo "platanus.contig"; faops n50 -H -S -C 8_platanus/out_contig.fa;) >> stat3.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "platanus.scaffold"; faops n50 -H -S -C 8_platanus/out_gapClosed.fa;) >> stat3.md

cat stat3.md
```

| Name               |  N50 |       Sum |       # |
|:-------------------|-----:|----------:|--------:|
| anchor.merge       | 1779 |  61598601 |   33537 |
| others.merge       | 1034 |   6873722 |    6352 |
| spades.contig      | 1620 | 435929605 |  673266 |
| spades.scaffold    | 1761 | 439173057 |  662729 |
| platanus.contig    |  565 | 592588841 | 1792829 |
| platanus.gapClosed | 5499 | 414129420 |  901777 |

* Clear QxxLxxXxx.

```bash
BASE_NAME=CgiA
cd ${HOME}/data/dna-seq/chara/${BASE_NAME}

rm -fr 2_illumina/Q{20,25,30,35}L{30,60,90,120}X*
rm -fr Q{20,25,30,35}L{30,60,90,120}X*
```

# CgiB, Cercis gigantea

## CgiB: download

```bash
BASE_NAME=CgiB
mkdir -p ${HOME}/data/dna-seq/chara/${BASE_NAME}
cd ${HOME}/data/dna-seq/chara/${BASE_NAME}

mkdir -p 2_illumina
cd 2_illumina

ln -s ../../medfood/Cgi_R1_tail50.fastq.gz R1.fq.gz
ln -s ../../medfood/Cgi_R2_tail50.fastq.gz R2.fq.gz
```

* FastQC

```bash
BASE_NAME=CgiB
cd ${HOME}/data/dna-seq/chara/${BASE_NAME}

mkdir -p 2_illumina/fastqc
cd 2_illumina/fastqc

fastqc -t 16 \
    ../R1.fq.gz ../R2.fq.gz \
    -o .

```

## CgiB: combinations of different quality values and read lengths

* qual: 25
* len: 60

```bash
BASE_NAME=CgiB
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

cat ${HOME}/.plenv/versions/5.18.4/lib/perl5/site_perl/5.18.4/auto/share/dist/App-Anchr/illumina_adapters.fa \
    > 2_illumina/illumina_adapters.fa
echo ">TruSeq_Adapter_Index_15" >> 2_illumina/illumina_adapters.fa
echo "GATCGGAAGAGCACACGTCTGAACTCCAGTCACACGCTCGAATCTCGTAT" >> 2_illumina/illumina_adapters.fa
echo ">Illumina_Single_End_PCR_Primer_1" >> 2_illumina/illumina_adapters.fa
echo "GATCGGAAGAGCGTCGTGTAGGGAAAGAGTGTAGATCTCGGTGGTCGCCG" >> 2_illumina/illumina_adapters.fa

if [ ! -e 2_illumina/R1.scythe.fq.gz ]; then
    parallel --no-run-if-empty -j 2 "
        scythe \
            2_illumina/{}.uniq.fq.gz \
            -q sanger \
            -a 2_illumina/illumina_adapters.fa \
            --quiet \
            | pigz -p 4 -c \
            > 2_illumina/{}.scythe.fq.gz
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
        ../R1.scythe.fq.gz ../R2.scythe.fq.gz \
        -o stdout \
        | bash
    " ::: 25 ::: 60

# Stats
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
    " ::: 25 ::: 60 \
    >> stat.md

cat stat.md
```

| Name     | N50 |         Sum |         # |
|:---------|----:|------------:|----------:|
| Illumina | 151 | 58890000000 | 390000000 |
| uniq     | 151 | 57719368574 | 382247474 |
| scythe   | 151 | 56959610487 | 382247474 |
| Q25L60   | 151 | 39466026049 | 289798244 |

## CgiB: spades

```bash
BASE_NAME=CgiB
cd ${HOME}/data/dna-seq/chara/${BASE_NAME}

spades.py \
    -t 16 \
    -k 21,33,55,77 \
    -1 2_illumina/Q25L60/R1.fq.gz \
    -2 2_illumina/Q25L60/R2.fq.gz \
    -s 2_illumina/Q25L60/Rs.fq.gz \
    -o 8_spades
```

## CgiB: platanus

```bash
BASE_NAME=CgiB
cd ${HOME}/data/dna-seq/chara/${BASE_NAME}

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

```text
#### PROCESS INFORMATION ####
VmPeak:         158.829 GByte
VmHWM:           61.949 GByte
```

## CgiB: final stats

* Stats

```bash
BASE_NAME=CgiB
cd ${HOME}/data/dna-seq/chara/${BASE_NAME}

printf "| %s | %s | %s | %s |\n" \
    "Name" "N50" "Sum" "#" \
    > stat3.md
printf "|:--|--:|--:|--:|\n" >> stat3.md

printf "| %s | %s | %s | %s |\n" \
    $(echo "spades.contig"; faops n50 -H -S -C 8_spades/contigs.fasta;) >> stat3.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "spades.scaffold"; faops n50 -H -S -C 8_spades/scaffolds.fasta;) >> stat3.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "platanus.contig"; faops n50 -H -S -C 8_platanus/out_contig.fa;) >> stat3.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "platanus.scaffold"; faops n50 -H -S -C 8_platanus/out_gapClosed.fa;) >> stat3.md

cat stat3.md
```

| Name              |  N50 |       Sum |       # |
|:------------------|-----:|----------:|--------:|
| spades.contig     | 1526 | 451828980 |  705723 |
| spades.scaffold   | 1633 | 454928469 |  695914 |
| platanus.contig   |  562 | 592944982 | 1795551 |
| platanus.scaffold | 6298 | 417471995 |  941034 |

## Merge CgiA and CgiB

```bash
cd ${HOME}/data/dna-seq/chara/CgiB

# merge anchors
mkdir -p merge
anchr contained \
    ../CgiA/8_spades/scaffolds.fasta \
    8_spades/scaffolds.fasta \
    ../CgiA/8_platanus/out_gapClosed.fa \
    8_platanus/out_gapClosed.fa \
    --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
    -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/anchor.contained.fasta
anchr orient merge/anchor.contained.fasta \
    --len 1000 --idt 0.98 --parallel 16 \
    -o merge/anchor.orient.fasta
anchr merge merge/anchor.orient.fasta \
    --len 1000 --idt 0.999 --parallel 16 \
    -o merge/anchor.merge0.fasta
anchr contained merge/anchor.merge0.fasta \
    --len 1000 --idt 0.98 --proportion 0.99 --parallel 16 -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/anchor.merge.fasta

rm -fr 9_qa
quast --no-check --threads 16 \
    --eukaryote \
    --no-icarus \
    ../CgiA/8_spades/scaffolds.fasta \
    8_spades/scaffolds.fasta \
    ../CgiA/8_platanus/out_gapClosed.fa \
    8_platanus/out_gapClosed.fa \
    merge/anchor.merge.fasta \
    --label "spades.CgiA,spades.CgiB,platanus.CgiA,platanus.CgiB,merge" \
    -o 9_qa

```

# CgiC, Cercis gigantea

## CgiC: download

```bash
BASE_NAME=CgiC
mkdir -p ${HOME}/data/dna-seq/chara/${BASE_NAME}
cd ${HOME}/data/dna-seq/chara/${BASE_NAME}

mkdir -p 2_illumina
cd 2_illumina

ln -s ../../medfood/CgiC_R1.fq.gz R1.fq.gz
ln -s ../../medfood/CgiC_R2.fq.gz R2.fq.gz
```

## CgiC: combinations of different quality values and read lengths

* qual: 25
* len: 60

```bash
BASE_NAME=CgiC
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

cat ${HOME}/.plenv/versions/5.18.4/lib/perl5/site_perl/5.18.4/auto/share/dist/App-Anchr/illumina_adapters.fa \
    > 2_illumina/illumina_adapters.fa
echo ">TruSeq_Adapter_Index_15" >> 2_illumina/illumina_adapters.fa
echo "GATCGGAAGAGCACACGTCTGAACTCCAGTCACACGCTCGAATCTCGTAT" >> 2_illumina/illumina_adapters.fa
echo ">Illumina_Single_End_PCR_Primer_1" >> 2_illumina/illumina_adapters.fa
echo "GATCGGAAGAGCGTCGTGTAGGGAAAGAGTGTAGATCTCGGTGGTCGCCG" >> 2_illumina/illumina_adapters.fa

if [ ! -e 2_illumina/R1.scythe.fq.gz ]; then
    parallel --no-run-if-empty -j 2 "
        scythe \
            2_illumina/{}.uniq.fq.gz \
            -q sanger \
            -a 2_illumina/illumina_adapters.fa \
            --quiet \
            | pigz -p 4 -c \
            > 2_illumina/{}.scythe.fq.gz
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
        ../R1.scythe.fq.gz ../R2.scythe.fq.gz \
        -o stdout \
        | bash
    " ::: 25 ::: 60

# Stats
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
    " ::: 25 ::: 60 \
    >> stat.md

cat stat.md
```

| Name     | N50 |         Sum |         # |
|:---------|----:|------------:|----------:|
| Illumina | 150 | 45000000000 | 300000000 |
| uniq     | 150 | 42202865700 | 281352438 |
| scythe   | 150 | 41628539307 | 281352438 |
| Q25L60   | 150 | 34914644451 | 245278936 |

## CgiC: spades

```bash
BASE_NAME=CgiC
cd ${HOME}/data/dna-seq/chara/${BASE_NAME}

spades.py \
    -t 16 \
    -k 21,33,55,77 \
    -1 2_illumina/Q25L60/R1.fq.gz \
    -2 2_illumina/Q25L60/R2.fq.gz \
    -s 2_illumina/Q25L60/Rs.fq.gz \
    -o 8_spades
```

## CgiC: platanus

```bash
BASE_NAME=CgiC
cd ${HOME}/data/dna-seq/chara/${BASE_NAME}

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

```text
#### PROCESS INFORMATION ####
VmPeak:          19.969 GByte
VmHWM:            9.248 GByte
```

## CgiC: final stats

* Stats

```bash
BASE_NAME=CgiC
cd ${HOME}/data/dna-seq/chara/${BASE_NAME}

printf "| %s | %s | %s | %s |\n" \
    "Name" "N50" "Sum" "#" \
    > stat3.md
printf "|:--|--:|--:|--:|\n" >> stat3.md

printf "| %s | %s | %s | %s |\n" \
    $(echo "spades.contig"; faops n50 -H -S -C 8_spades/contigs.fasta;) >> stat3.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "spades.scaffold"; faops n50 -H -S -C 8_spades/scaffolds.fasta;) >> stat3.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "platanus.contig"; faops n50 -H -S -C 8_platanus/out_contig.fa;) >> stat3.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "platanus.scaffold"; faops n50 -H -S -C 8_platanus/out_gapClosed.fa;) >> stat3.md

cat stat3.md
```

| Name              |  N50 |       Sum |       # |
|:------------------|-----:|----------:|--------:|
| spades.contig     | 1529 | 453999116 |  718189 |
| spades.scaffold   | 1640 | 457087770 |  708368 |
| platanus.contig   |  553 | 586857429 | 1819727 |
| platanus.scaffold | 5238 | 432432679 | 1120978 |

# CgiD, Cercis gigantea

## CgiD: download

```bash
BASE_NAME=CgiD
mkdir -p ${HOME}/data/dna-seq/chara/${BASE_NAME}
cd ${HOME}/data/dna-seq/chara/${BASE_NAME}

mkdir -p 2_illumina
cd 2_illumina

ln -s ../../medfood/CgiD_R1.fq.gz R1.fq.gz
ln -s ../../medfood/CgiD_R2.fq.gz R2.fq.gz
```

## CgiD: combinations of different quality values and read lengths

* qual: 25
* len: 60

```bash
BASE_NAME=CgiD
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

cat ${HOME}/.plenv/versions/5.18.4/lib/perl5/site_perl/5.18.4/auto/share/dist/App-Anchr/illumina_adapters.fa \
    > 2_illumina/illumina_adapters.fa
echo ">TruSeq_Adapter_Index_15" >> 2_illumina/illumina_adapters.fa
echo "GATCGGAAGAGCACACGTCTGAACTCCAGTCACACGCTCGAATCTCGTAT" >> 2_illumina/illumina_adapters.fa
echo ">Illumina_Single_End_PCR_Primer_1" >> 2_illumina/illumina_adapters.fa
echo "GATCGGAAGAGCGTCGTGTAGGGAAAGAGTGTAGATCTCGGTGGTCGCCG" >> 2_illumina/illumina_adapters.fa

if [ ! -e 2_illumina/R1.scythe.fq.gz ]; then
    parallel --no-run-if-empty -j 2 "
        scythe \
            2_illumina/{}.uniq.fq.gz \
            -q sanger \
            -a 2_illumina/illumina_adapters.fa \
            --quiet \
            | pigz -p 4 -c \
            > 2_illumina/{}.scythe.fq.gz
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
        ../R1.scythe.fq.gz ../R2.scythe.fq.gz \
        -o stdout \
        | bash
    " ::: 25 ::: 60

# Stats
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
    " ::: 25 ::: 60 \
    >> stat.md

cat stat.md
```

| Name     | N50 |         Sum |         # |
|:---------|----:|------------:|----------:|
| Illumina | 150 | 45000000000 | 300000000 |
| uniq     | 150 | 42802892700 | 285352618 |
| scythe   | 150 | 42149668084 | 285352618 |
| Q25L60   | 150 | 35083711046 | 245385420 |

## CgiD: spades

```bash
BASE_NAME=CgiD
cd ${HOME}/data/dna-seq/chara/${BASE_NAME}

spades.py \
    -t 16 \
    -k 21,33,55,77 \
    -1 2_illumina/Q25L60/R1.fq.gz \
    -2 2_illumina/Q25L60/R2.fq.gz \
    -s 2_illumina/Q25L60/Rs.fq.gz \
    -o 8_spades
```

## CgiD: platanus

```bash
BASE_NAME=CgiD
cd ${HOME}/data/dna-seq/chara/${BASE_NAME}

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

```text
#### PROCESS INFORMATION ####
VmPeak:          20.172 GByte
VmHWM:            9.394 GByte
```

## CgiD: final stats

* Stats

```bash
BASE_NAME=CgiD
cd ${HOME}/data/dna-seq/chara/${BASE_NAME}

printf "| %s | %s | %s | %s |\n" \
    "Name" "N50" "Sum" "#" \
    > stat3.md
printf "|:--|--:|--:|--:|\n" >> stat3.md

printf "| %s | %s | %s | %s |\n" \
    $(echo "spades.contig"; faops n50 -H -S -C 8_spades/contigs.fasta;) >> stat3.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "spades.scaffold"; faops n50 -H -S -C 8_spades/scaffolds.fasta;) >> stat3.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "platanus.contig"; faops n50 -H -S -C 8_platanus/out_contig.fa;) >> stat3.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "platanus.scaffold"; faops n50 -H -S -C 8_platanus/out_gapClosed.fa;) >> stat3.md

cat stat3.md
```

| Name              |  N50 |       Sum |       # |
|:------------------|-----:|----------:|--------:|
| spades.contig     | 1500 | 456253937 |  737180 |
| spades.scaffold   | 1603 | 459347483 |  727395 |
| platanus.contig   |  533 | 592606020 | 1851674 |
| platanus.scaffold | 4839 | 434810119 | 1135031 |

## Merge CgiC and CgiD

```bash
cd ${HOME}/data/dna-seq/chara/CgiD

# merge anchors
mkdir -p merge
anchr contained \
    ../CgiC/8_spades/scaffolds.fasta \
    8_spades/scaffolds.fasta \
    ../CgiC/8_platanus/out_gapClosed.fa \
    8_platanus/out_gapClosed.fa \
    --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
    -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/anchor.contained.fasta
anchr orient merge/anchor.contained.fasta \
    --len 1000 --idt 0.98 --parallel 16 \
    -o merge/anchor.orient.fasta
anchr merge merge/anchor.orient.fasta \
    --len 1000 --idt 0.999 --parallel 16 \
    -o merge/anchor.merge0.fasta
anchr contained merge/anchor.merge0.fasta \
    --len 1000 --idt 0.98 --proportion 0.99 --parallel 16 -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/anchor.merge.fasta

rm -fr 9_qa
quast --no-check --threads 16 \
    --eukaryote \
    --no-icarus \
    ../CgiC/8_spades/scaffolds.fasta \
    8_spades/scaffolds.fasta \
    ../CgiC/8_platanus/out_gapClosed.fa \
    8_platanus/out_gapClosed.fa \
    merge/anchor.merge.fasta \
    --label "spades.CgiC,spades.CgiD,platanus.CgiC,platanus.CgiD,merge" \
    -o 9_qa

```

# Cgi

## Cgi: Merge CgiAB and CgiCD

```bash
cd ${HOME}/data/dna-seq/chara/Cgi

# merge anchors
mkdir -p merge
anchr contained \
    ../CgiB/merge/anchor.merge.fasta \
    ../CgiD/merge/anchor.merge.fasta \
    --len 1000 --idt 0.98 --proportion 0.99999 --parallel 16 \
    -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/anchor.contained.fasta
anchr orient merge/anchor.contained.fasta \
    --len 1000 --idt 0.98 --parallel 16 \
    -o merge/anchor.orient.fasta
anchr merge merge/anchor.orient.fasta \
    --len 1000 --idt 0.999 --parallel 16 \
    -o merge/anchor.merge0.fasta
anchr contained merge/anchor.merge0.fasta \
    --len 1000 --idt 0.98 --proportion 0.99 --parallel 16 -o stdout \
    | faops filter -a 1000 -l 0 stdin merge/anchor.merge.fasta

rm -fr 9_qa
quast --no-check --threads 16 \
    --eukaryote \
    --no-icarus \
    ../CgiB/merge/anchor.merge.fasta \
    ../CgiD/merge/anchor.merge.fasta \
    merge/anchor.merge.fasta \
    --label "CgiAB,CgiCD,merge" \
    -o 9_qa

```

## Cgi: preprocess PacBio reads

```bash
cd ${HOME}/data/dna-seq/chara/Cgi

mkdir -p 3_pacbio

samtools fasta \
    ${HOME}/data/dna-seq/chara/CgiSequel/54167_2_B01/m54167_170825_204337.subreads.bam \
    > 3_pacbio/m54167.fasta
samtools fasta \
    ${HOME}/data/dna-seq/chara/CgiSequel/r54172_20170821_090202_1_A01/m54172_170821_091102.subreads.bam \
    > 3_pacbio/m54172.fasta

cat 3_pacbio/m54167.fasta 3_pacbio/m54172.fasta \
    | faops filter -l 0 -a 1000 stdin 3_pacbio/pacbio.fasta

# minimap: Real time: 2522.743 sec; CPU: 33237.704 sec. 72G .paf file
# jrange: about 2 hours
# faops: real    2m18.233s
anchr trimlong --parallel 16 -v \
    --jvm '-d64 -server -Xms1g -Xmx64g -XX:-UseGCOverheadLimit' \
    3_pacbio/pacbio.fasta \
    -o 3_pacbio/pacbio.trim.fasta

```

## Cgi: 3GS

```bash
BASE_NAME=Cgi
REAL_G=500000000
cd ${HOME}/data/dna-seq/chara/Cgi

canu \
    -p ${BASE_NAME} -d canu-raw \
    gnuplot=$(brew --prefix)/Cellar/$(brew list --versions gnuplot | sed 's/ /\//')/bin/gnuplot \
    genomeSize=${REAL_G} \
    -pacbio-raw 3_pacbio/pacbio.fasta

canu \
    -p ${BASE_NAME} -d canu-trim \
    gnuplot=$(brew --prefix)/Cellar/$(brew list --versions gnuplot | sed 's/ /\//')/bin/gnuplot \
    genomeSize=${REAL_G} \
    -pacbio-raw 3_pacbio/pacbio.trim.fasta

rm -fr canu-raw/correction
rm -fr canu-trim/correction

printf "| %s | %s | %s | %s |\n" \
    "Name" "N50" "Sum" "#" \
    > stat.md
printf "|:--|--:|--:|--:|\n" >> stat.md

printf "| %s | %s | %s | %s |\n" \
    $(echo "PacBio";      faops n50 -H -S -C 3_pacbio/pacbio.fasta;) >> stat.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "PacBio.trim"; faops n50 -H -S -C 3_pacbio/pacbio.trim.fasta;) >> stat.md

printf "| %s | %s | %s | %s |\n" \
    $(echo "correctedReads";      faops n50 -H -S -C canu-raw/${BASE_NAME}.correctedReads.fasta.gz;) >> stat.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "correctedReads.trim"; faops n50 -H -S -C canu-trim/${BASE_NAME}.correctedReads.fasta.gz;) >> stat.md

printf "| %s | %s | %s | %s |\n" \
    $(echo "trimmedReads";      faops n50 -H -S -C canu-raw/${BASE_NAME}.trimmedReads.fasta.gz;) >> stat.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "trimmedReads.trim"; faops n50 -H -S -C canu-trim/${BASE_NAME}.trimmedReads.fasta.gz;) >> stat.md

printf "| %s | %s | %s | %s |\n" \
    $(echo "contigs";      faops n50 -H -S -C canu-raw/${BASE_NAME}.contigs.fasta;) >> stat.md
printf "| %s | %s | %s | %s |\n" \
    $(echo "contigs.trim"; faops n50 -H -S -C canu-trim/${BASE_NAME}.contigs.fasta;) >> stat.md

```

| Name                |   N50 |         Sum |      # |
|:--------------------|------:|------------:|-------:|
| PacBio              | 16814 | 11647545821 | 990085 |
| PacBio.trim         | 14117 |  8181836779 | 835086 |
| correctedReads      |  8102 |  1632889184 | 289312 |
| correctedReads.trim | 14234 |  7894714239 | 782147 |
| trimmedReads        |  6896 |  1035588316 | 212397 |
| trimmedReads.trim   |  7215 |  1610374094 | 308121 |
| contigs             | 18506 |    14781217 |   1029 |
| contigs.trim        | 17224 |    22371544 |   1553 |

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
