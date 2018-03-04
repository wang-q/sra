# cpDNA

[TOC levels=1-3]: # " "
- [cpDNA](#cpdna)
- [*Medicago truncatula*](#medicago-truncatula)
- [HM050](#hm050)
    - [HM050: download](#hm050-download)
    - [HM050: template](#hm050-template)
    - [HM050: run](#hm050-run)
- [HM340](#hm340)
    - [HM340: download](#hm340-download)
    - [HM340: template](#hm340-template)
    - [HM340: run](#hm340-run)


* Rsync to hpcc

```bash
rsync -avP \
    ~/data/dna-seq/cpDNA/Medicago/ \
    wangq@202.119.37.251:data/dna-seq/cpDNA/Medicago

# rsync -avP wangq@202.119.37.251:data/dna-seq/cpDNA/ ~/data/dna-seq/cpDNA

```

# *Medicago truncatula*

* Genome: GCF_000219495.3, 389.98 Mb
* Chloroplast: NC_003119, 124033 bp
* Mitochondrion: NC_029641, 271618 bp

* Reference genome

```bash
mkdir -p ~/data/dna-seq/cpDNA/Medicago
cd ~/data/dna-seq/cpDNA/Medicago

for ACCESSION in "NC_003119" "NC_029641"; do
    URL=$(printf "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nucleotide&rettype=%s&id=%s&retmode=text" "fasta" "${ACCESSION}");
    curl $URL -o ${ACCESSION}.fa
done

aria2c -x 9 -s 3 -c ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/219/495/GCF_000219495.3_MedtrA17_4.0/GCF_000219495.3_MedtrA17_4.0_genomic.fna.gz

TAB=$'\t'
cat <<EOF > replace.tsv
NC_016407.2${TAB}1
NC_016408.2${TAB}2
NC_016409.2${TAB}3
NC_016410.2${TAB}4
NC_016411.2${TAB}5
NC_016412.2${TAB}6
NC_016413.2${TAB}7
NC_016414.2${TAB}8
NC_003119.8${TAB}Pt
NC_029641.1${TAB}Mt
EOF

cat NC_003119.fa NC_029641.fa |
    faops replace stdin replace.tsv stdout |
    faops order stdin <(echo Pt; echo Mt) genome.fa

faops replace GCF_000219495.3*_genomic.fna.gz replace.tsv stdout |
    faops order stdin <(echo {1..8}) ref.fa

```

* Illumina

```bash
cd ~/data/dna-seq/cpDNA/Medicago

cat << EOF > sra_ftp.txt
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR155/008/SRR1552478/SRR1552478_1.fastq.gz
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR155/008/SRR1552478/SRR1552478_2.fastq.gz
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR152/005/SRR1524305/SRR1524305_1.fastq.gz
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR152/005/SRR1524305/SRR1524305_2.fastq.gz
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR103/003/SRR1034293/SRR1034293_1.fastq.gz
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR103/003/SRR1034293/SRR1034293_2.fastq.gz
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR216/006/SRR2163426/SRR2163426_1.fastq.gz
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR216/006/SRR2163426/SRR2163426_2.fastq.gz
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR166/008/SRR1664358/SRR1664358_1.fastq.gz
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR166/008/SRR1664358/SRR1664358_2.fastq.gz
EOF

aria2c -x 9 -s 3 -c -i sra_ftp.txt

cat << EOF > sra_md5.txt
3f570ce4060ffcb741f43501b3afe94f  SRR1552478_1.fastq.gz
b45ce0743d9f446e62473963ce7ac40b  SRR1552478_2.fastq.gz
f03019da3054b8659b80ffdaf388599f  SRR1524305_1.fastq.gz
ff624191ea6080c87663ad78e844ac80  SRR1524305_2.fastq.gz
52581dcbcb9506dffe3d920fc0d83921  SRR1034293_1.fastq.gz
3582cc84b309658811259d38d514cf62  SRR1034293_2.fastq.gz
28ce4e3b8138df654780401245113bf9  SRR2163426_1.fastq.gz
8756862c6043ffa96a8b1a5413865cd2  SRR2163426_2.fastq.gz
a86d4a063e107f2ce77ef1ca0051df86  SRR1664358_1.fastq.gz
5b6ec25a47d48194b7afea6bbaa6a6a3  SRR1664358_2.fastq.gz
EOF

md5sum --check sra_md5.txt

```
