# Chara

## super-reads

* Ler-0-2, SRR611087

```bash
mkdir -p ~/data/dna-seq/atha_ler_0/superreads/SRR611087
cd ~/data/dna-seq/atha_ler_0/superreads/SRR611087

perl ~/Scripts/sra/superreads.pl \
    ~/data/dna-seq/atha_ler_0/process/Ler-0-2/SRR611087/SRR611087_1.fastq.gz \
    ~/data/dna-seq/atha_ler_0/process/Ler-0-2/SRR611087/SRR611087_2.fastq.gz \
    -s 450 -d 50 -p 16

secs=$(expr $(stat -c %Y environment.sh) - $(stat -c %Y assemble.sh))
printf "%d:%d'%d''\n" $(($secs/3600)) $(($secs%3600/60)) $(($secs%60))

faops n50 -N 50 -S -C work1/superReadSequences.fasta
```

* Ler-0-2, SRR616965

```bash
mkdir -p ~/data/dna-seq/atha_ler_0/superreads/SRR616965
cd ~/data/dna-seq/atha_ler_0/superreads/SRR616965

perl ~/Scripts/sra/superreads.pl \
    ~/data/dna-seq/atha_ler_0/process/Ler-0-2/SRR616965/SRR616965_1.fastq.gz \
    ~/data/dna-seq/atha_ler_0/process/Ler-0-2/SRR616965/SRR616965_2.fastq.gz \
    -s 450 -d 50 -p 16

secs=$(expr $(stat -c %Y environment.sh) - $(stat -c %Y assemble.sh))
printf "%d:%d'%d''\n" $(($secs/3600)) $(($secs%3600/60)) $(($secs%60))

faops n50 -N 50 -S -C work1/superReadSequences.fasta
```

* F63, Closterium sp., 新月藻

```bash
mkdir -p ~/data/dna-seq/chara/superreads/F63
cd ~/data/dna-seq/chara/superreads/F63

perl ~/Scripts/sra/superreads.pl \
    ~/data/dna-seq/chara/clean_data/F63_HF5WLALXX_L5_1.clean.fq.gz \
    ~/data/dna-seq/chara/clean_data/F63_HF5WLALXX_L5_2.clean.fq.gz \
    -s 300 -d 30 -p 16

faops n50 -N 50 -S -C work1/superReadSequences.fasta
```

* F340, Zygnema extenue, 亚小双星藻

```bash
mkdir -p ~/data/dna-seq/chara/superreads/F340
cd ~/data/dna-seq/chara/superreads/F340

perl ~/Scripts/sra/superreads.pl \
    ~/data/dna-seq/chara/clean_data/F340-hun_HF3JLALXX_L6_1.clean.fq.gz \
    ~/data/dna-seq/chara/clean_data/F340-hun_HF3JLALXX_L6_2.clean.fq.gz \
    -s 300 -d 30 -p 16

secs=$(expr $(stat -c %Y environment.sh) - $(stat -c %Y assemble.sh))
printf "%d:%d'%d''\n" $(($secs/3600)) $(($secs%3600/60)) $(($secs%60))

faops n50 -N 50 -S -C work1/superReadSequences.fasta
```

| Name      | L. Reads | kmer | fq size | fa size | Est. Genome |   #reads | Run time |    Sum SR | SR/Est.G |
|:----------|---------:|-----:|--------:|--------:|------------:|---------:|:--------:|----------:|---------:|
| SRR611087 |      100 |   71 | 20.4 GB | 10.8 GB |   125423153 |          |          |           |          |
| SRR616965 |      100 |   71 | 10.2 GB | 5.42 GB |   118742701 | 25750807 |          | 186951724 |     1.57 |
| F63       |      150 |   49 | 33.9 GB | 18.1 GB |   345627684 | 13840871 |  4:30'   | 697371843 |     2.02 |
| F340      |      150 |   75 | 35.9 GB | 19.3 GB |   566603922 | 22024705 |  3:21'   | 852873811 |     1.51 |

* kmer 越大的污染越多
* kmer 估计基因组比真实的大得越多的污染越多
* SR/Est.G 有两个因素. 细菌与单倍体会趋向于 2, paralog 与杂合会趋向于 4.

## Anchors

```bash
mkdir -p sr
cd sr

ln -s ../pe.cor.fa .
ln -s ../work1/superReadSequences.fasta .

faops size superReadSequences.fasta > sr.chr.sizes

# tolerates 1 substitution
cat pe.cor.fa \
    | perl -nle '/>/ or next; /sub.+sub/ and next; />(\w+)/ and print $1;' \
    > pe.strict.txt

# Too large for `faops some`
split -n10 -d pe.strict.txt pe.part

# No Ns; longer than 100 bp (70% of read length)
rm pe.strict.fa
for part in $(printf "%.2d " {0..9})
do 
    faops some pe.cor.fa pe.part${part} stdout \
        | faops filter -n 0 -a 100 -l 0 stdin stdout
done >> pe.strict.fa
rm pe.part??

faops n50 -N 50 -S -C superReadSequences.fasta
faops n50 -N 0 -C pe.cor.fa
faops n50 -N 0 -C pe.strict.fa

# index
bbmap.sh ref=superReadSequences.fasta

#----------------------------#
# unambiguous
#----------------------------#
bbmap.sh \
    maxindel=0 strictmaxindel perfectmode \
    ambiguous=toss \
    ref=superReadSequences.fasta in=pe.strict.fa \
    outm=unambiguous.sam outu=unmapped.sam

java -jar ~/share/picard-tools-1.128/picard.jar \
    CleanSam \
    INPUT=unambiguous.sam \
    OUTPUT=_clean.bam
java -jar ~/share/picard-tools-1.128/picard.jar \
    SortSam \
    INPUT=_clean.bam \
    OUTPUT=_sort.bam \
    SORT_ORDER=coordinate \
    VALIDATION_STRINGENCY=LENIENT
rm _clean.bam
mv _sort.bam unambiguous.sort.bam

genomeCoverageBed -bga -split -g sr.chr.sizes -ibam unambiguous.sort.bam \
    | perl -nlae '
        $F[3] == 0 and next;
        $F[3] == 1 and next;
        printf qq{%s:%s-%s\n}, $F[0], $F[1] + 1, $F[2];
    ' \
    > unambiguous.cover.txt

#----------------------------#
# ambiguous
#----------------------------#
cat unmapped.sam \
    | perl -nle '
        /^@/ and next;
        @fields = split "\t";
        print $fields[0];
    ' \
    > pe.unmapped.txt

# Too large for `faops some`
split -n10 -d pe.unmapped.txt pe.part

rm pe.unmapped.fa
for part in $(printf "%.2d " {0..9})
do 
    faops some pe.strict.fa pe.part${part} stdout
done >> pe.unmapped.fa
rm pe.part??

bbmap.sh \
    maxindel=0 strictmaxindel perfectmode \
    ref=superReadSequences.fasta in=pe.unmapped.fa \
    outm=ambiguous.sam outu=unmapped2.sam

java -jar ~/share/picard-tools-1.128/picard.jar \
    CleanSam \
    INPUT=ambiguous.sam \
    OUTPUT=_clean.bam
java -jar ~/share/picard-tools-1.128/picard.jar \
    SortSam \
    INPUT=_clean.bam \
    OUTPUT=_sort.bam \
    SORT_ORDER=coordinate \
    VALIDATION_STRINGENCY=LENIENT
rm _clean.bam
mv _sort.bam ambiguous.sort.bam

genomeCoverageBed -bga -split -g sr.chr.sizes -ibam ambiguous.sort.bam \
    | perl -nlae '
        $F[3] == 0 and next;
        printf qq{%s:%s-%s\n}, $F[0], $F[1] + 1, $F[2];
    ' \
    > ambiguous.cover.txt

jrunlist cover unambiguous.cover.txt 
runlist stat unambiguous.cover.txt.yml -s sr.chr.sizes -o unambiguous.cover.csv

jrunlist cover ambiguous.cover.txt 
runlist stat ambiguous.cover.txt.yml -s sr.chr.sizes -o ambiguous.cover.csv

runlist compare --op diff unambiguous.cover.txt.yml ambiguous.cover.txt.yml -o unique.cover.yml
runlist stat unique.cover.yml -s sr.chr.sizes -o unique.cover.csv
 
cat unique.cover.csv \
    | perl -nla -F"," -e '
        $F[0] eq q{chr} and next;
        $F[0] eq q{all} and next;
        $F[2] < 500 and next;
        $F[3] < 0.95 and next;
        print $F[0];
    ' \
    | sort -n \
    > anchor.txt

faops some superReadSequences.fasta anchor.txt pe.anchor.fa
faops n50 -N 50 -S -C pe.anchor.fa

```

| Name      | N50 SR |     #SR |   #cor.fa | #strict.fa | Sum anchor | N50 anchor |
|:----------|-------:|--------:|----------:|-----------:|-----------:|-----------:|
| SRR611087 |        |         |           |            |            |            |
| SRR616965 |   1643 |  488218 |  50872510 |   48928772 |   86327581 |       3446 |
| F63       |   1815 |  986675 | 115078314 |   94324950 |   52342433 |       4003 |
| F340      |    388 | 2383927 | 122062736 |  102014388 |   76859329 |       1105 |
