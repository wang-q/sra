# dazzler: dazz_db and daligner

## dazz_db

`DBsplit`

* If the `-x` option is set then all reads less than the given length are ignored
* each block is of size `-s` * 1Mbp except for the last which necessarily contains a smaller residual

### Rename sequences for dazzler

Create two files, `renamed.fasta`, `stdin.replace.tsv`.

```bash
mkdir -p ~/data/test/dazzler
cd ~/data/test/dazzler

cat ~/data/dna-seq/dmel_iso_1/superreads/trimmed_5000000/work1/superReadSequences.fasta \
    | perl ~/Scripts/sra/falcon_name_fasta.pl -i stdin
cat stdin.outfile \
    | faops filter -l 0 stdin renamed.fasta
rm stdin.outfile
```

### Create and split DB

`myDB.db` and its hidden companions.

```bash
cd ~/data/test/dazzler

log_info "Make the dazzler DB"
DBrm myDB
fasta2DB myDB renamed.fasta
DBdust myDB
# each block is of size 50 MB
DBsplit -s50 myDB

BLOCK_NUMBER=$(cat myDB.db | perl -nl -e '/^blocks\s+=\s+(\d+)/ and print $1')
```

## daligner

`HPC.daligner`

* local alignments involving at least `-l` base pairs (default 1000)
* An average correlation rate of `-e` (default 70%) set to 80%
* The default number of threads is 4, set by `-T` option (power of 2)
* Set the `-t` parameter which suppresses the use of any *k*-mer that occurs more than *t* times in
  either the subject or target block.
* Let the program automatically select a value of *t* that meets a given memory usage limit
  specified (in Gb) by the `-M` parameter
* one or more interval tracks specified with the `-m` option (m for mask)

### Create jobs by `HPC.daligner` and execute it

Three .las (`myDB.[1-3].las`) files are generated then concatenated to `myDB.las`.

```bash
cd ~/data/test/dazzler

if [ -e myDB.*.las ]; then
    rm myDB.*.las
fi
HPC.daligner myDB -v -M16 -e.96 -l500 -s500 -mdust > job.sh
bash job.sh

LAcat -v myDB.#.las > myDB.las
```

Contents of `job.sh`

```bash
# Daligner jobs (3)
daligner -v -e0.96 -l500 -s500 -M16 -mdust myDB.1 myDB.1
daligner -v -e0.96 -l500 -s500 -M16 -mdust myDB.2 myDB.1 myDB.2
daligner -v -e0.96 -l500 -s500 -M16 -mdust myDB.3 myDB.1 myDB.2 myDB.3
# Check initial .las files jobs (3) (optional but recommended)
LAcheck -vS myDB myDB.1.myDB.1 myDB.1.myDB.2 myDB.1.myDB.3
LAcheck -vS myDB myDB.2.myDB.1 myDB.2.myDB.2 myDB.2.myDB.3
LAcheck -vS myDB myDB.3.myDB.1 myDB.3.myDB.2 myDB.3.myDB.3
# Level 1 merge jobs (3)
LAmerge -v myDB.1 myDB.1.myDB.1 myDB.1.myDB.2 myDB.1.myDB.3
LAmerge -v myDB.2 myDB.2.myDB.1 myDB.2.myDB.2 myDB.2.myDB.3
LAmerge -v myDB.3 myDB.3.myDB.1 myDB.3.myDB.2 myDB.3.myDB.3
# Check level 2 .las files jobs (3) (optional but recommended)
LAcheck -vS myDB myDB.1
LAcheck -vS myDB myDB.2
LAcheck -vS myDB myDB.3
# Remove level 1 .las files (optional)
rm myDB.1.myDB.1.las myDB.1.myDB.2.las myDB.1.myDB.3.las
rm myDB.2.myDB.1.las myDB.2.myDB.2.las myDB.2.myDB.3.las
rm myDB.3.myDB.1.las myDB.3.myDB.2.las myDB.3.myDB.3.las
```

Results.

```bash
cd ~/data/test/dazzler

LAshow myDB.db myDB.las
LAshow -o myDB.db myDB.las
LAshow -co myDB.db myDB.las
```
