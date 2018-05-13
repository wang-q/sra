# *De novo* assemblies of aphids

[TOC levels=1-3]: # " "
- [*De novo* assemblies of aphids](#de-novo-assemblies-of-aphids)
- [*Acyrthosiphon pisum* (pea aphid)](#acyrthosiphon-pisum-pea-aphid)
- [Switzerland](#switzerland)
    - [Switzerland: download](#switzerland-download)
    - [Switzerland: template](#switzerland-template)
    - [Switzerland: run](#switzerland-run)


# *Acyrthosiphon pisum* (pea aphid)

* Genome: GCF_000142985.2, 541.692 Mb
* Mitochondrion: NC_011594.1, 16971 bp

* Reference genome

```bash
mkdir -p ~/data/dna-seq/aphid/data
cd ~/data/dna-seq/aphid/data

aria2c -x 9 -s 3 -c ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/142/985/GCF_000142985.2_Acyr_2.0/GCF_000142985.2_Acyr_2.0_genomic.fna.gz

```

* Grab SRP information
    * https://www.ncbi.nlm.nih.gov/bioproject/PRJNA454786
        * 6 SRX
        * poolseq of 20 or 14 individuals
        * collected on Medicago sativa
    * https://www.ncbi.nlm.nih.gov/bioproject/PRJNA385905

```bash
mkdir -p ~/data/dna-seq/aphid/sra
cd ~/data/dna-seq/aphid/sra

cat << EOF > source.csv
SRP144419,aphid_medicago,
SRP106773,aphid_others,
EOF

perl ~/Scripts/sra/sra_info.pl source.csv -v -s erp --fq \
    > sra_info.yml

# check before running these
perl ~/Scripts/sra/sra_prep.pl sra_info.yml

```

* SRP144419/PRJNA454786

| Location      | SRX        | SRR        | Bases (Gb) |
|:--------------|:-----------|:-----------|:-----------|
| Switzerland   | SRX4028530 | SRR7100182 | 28.1       |
| Ranspach      | SRX4028529 | SRR7100183 | 28         |
| Mirecourt     | SRX4028528 | SRR7100184 | 27         |
| Castelnaudary | SRX4028527 | SRR7100185 | 26.6       |
| Gers          | SRX4028526 | SRR7100186 | 23.8       |
| Lusignan      | SRX4028525 | SRR7100187 | 25.5       |

* SRP106773/PRJNA385905

| Host                  | 中文名 | Individuals | SRX        | SRR        | Bases (Gb) |
|:----------------------|:------|:------------|:-----------|:-----------|:-----------|
| Vicia cracca          |       | 29          | SRX4038418 | SRR7110604 | 36.9       |
| Onobrychis viciifolia |       | 37          | SRX4038417 | SRR7110605 | 41.4       |
| Securigea varia       |       | 26          | SRX4038416 | SRR7110606 | 39         |
| Ononis spinosa        |       | 27          | SRX4038415 | SRR7110607 | 43.3       |

* Illumina

```bash
mkdir -p ~/data/dna-seq/aphid/data
cd ~/data/dna-seq/aphid/data

cat << EOF > sra_ftp.txt
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR710/007/SRR7100187/SRR7100187_1.fastq.gz
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR710/007/SRR7100187/SRR7100187_2.fastq.gz
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR710/006/SRR7100186/SRR7100186_1.fastq.gz
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR710/006/SRR7100186/SRR7100186_2.fastq.gz
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR710/005/SRR7100185/SRR7100185_1.fastq.gz
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR710/005/SRR7100185/SRR7100185_2.fastq.gz
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR710/004/SRR7100184/SRR7100184_1.fastq.gz
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR710/004/SRR7100184/SRR7100184_2.fastq.gz
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR710/003/SRR7100183/SRR7100183_1.fastq.gz
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR710/003/SRR7100183/SRR7100183_2.fastq.gz
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR710/002/SRR7100182/SRR7100182_1.fastq.gz
ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR710/002/SRR7100182/SRR7100182_2.fastq.gz
EOF

aria2c -x 9 -s 3 -c -i sra_ftp.txt

cat << EOF > sra_md5.txt
d3901a8112fda02f7fb6898e1f5be236 SRR7100187_1.fastq.gz
baaf5b3dec3396e0eeb6c8fbc301e1e5 SRR7100187_2.fastq.gz
8d623e590402eb542d9c52b373661d2a SRR7100186_1.fastq.gz
834f5d34038993dedfce47d186aa4639 SRR7100186_2.fastq.gz
ea8898a381e5940c8375cfe888631713 SRR7100185_1.fastq.gz
102312244dbf29049a4157e1c359b0c7 SRR7100185_2.fastq.gz
09383f6a975427b3d5525bd3a77577bd SRR7100184_1.fastq.gz
5f2da219c010f249af56eb7b4edb0028 SRR7100184_2.fastq.gz
f9ac2f070944b0c41ecd3e68cbc811e7 SRR7100183_1.fastq.gz
179340ecab8ed41e08e34b1a61eda8e9 SRR7100183_2.fastq.gz
023762eb0484aa950e7870e556c69844 SRR7100182_1.fastq.gz
6fc1b743b0fdb90bd0f68e752af6929d SRR7100182_2.fastq.gz
EOF

md5sum --check sra_md5.txt

```


* Rsync to hpcc

```bash
rsync -avP \
    ~/data/dna-seq/aphid/ \
    wangq@202.119.37.251:data/dna-seq/aphid

# rsync -avP wangq@202.119.37.251:data/dna-seq/aphid/ ~/data/dna-seq/aphid

```


# Switzerland

## Switzerland: download

```bash
mkdir -p ~/data/dna-seq/aphid/Switzerland/2_illumina
cd ~/data/dna-seq/aphid/Switzerland/2_illumina

ln -fs ../../data/SRR7100182_1.fastq.gz R1.fq.gz
ln -fs ../../data/SRR7100182_2.fastq.gz R2.fq.gz

```


## Switzerland: template


```bash
WORKING_DIR=${HOME}/data/dna-seq/aphid
BASE_NAME=Switzerland

cd ${WORKING_DIR}/${BASE_NAME}

rm -f *.sh
anchr template \
    . \
    --basename ${BASE_NAME} \
    --queue mpi \
    --genome 541_692_000 \
    --fastqc \
    --kmergenie \
    --insertsize \
    --sgapreqc \
    --trim2 "--dedupe" \
    --qual2 "25" \
    --len2 "60" \
    --filter "adapter,phix,artifact" \
    --mergereads \
    --ecphase "1,2,3" \
    --cov2 "all" \
    --tadpole \
    --statp 1 \
    --redoanchors \
    --fillanchor \
    --xmx 110g \
    --parallel 24

```

## Switzerland: run

```bash
WORKING_DIR=${HOME}/data/dna-seq/aphid
BASE_NAME=Switzerland

cd ${WORKING_DIR}/${BASE_NAME}
# rm -fr 4_*/ 6_*/ 7_*/ 8_*/ && rm -fr 2_illumina/trim 2_illumina/mergereads statReads.md 
# find . -type d -name "anchor" | xargs rm -fr

bash 0_bsub.sh
# bkill -J "${BASE_NAME}-*"

# bash 0_master.sh
# bash 0_cleanup.sh

```

