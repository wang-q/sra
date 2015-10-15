# Processing NCBI sra/EBI ena data

## Projects

### medfood: medicine food homology. Rna-seq survey.

Download.

```bash
cd ~/Scripts/sra
perl medfood_info.pl

perl sra_prep.pl -i medfood.yml --md5

mkdir -p ~/data/rna-seq/medfood/sra
cd ~/data/rna-seq/medfood/sra
cp ~/Scripts/sra/medfood.ftp.txt .
aria2c -x 9 -s 3 -c -i medfood.ftp.txt

cd ~/data/rna-seq/medfood/sra
cp ~/Scripts/sra/medfood.md5.txt .
md5sum --check medfood.md5.txt
```

ENA didn't display DRX correctly, so manually downlaod files and add information for DRX026628 and DRX014826.

Use `prefetch` of sra toolkit to download DRR files.

```bash
prefetch DRR029569 DRR029570 DRR016460

cp ~/ncbi/public/sra/DRR*.sra ~/data/rna-seq/medfood/sra
```

* http://www.ncbi.nlm.nih.gov/sra/?term=DRX026628
* http://www.ncbi.nlm.nih.gov/sra/?term=DRX014826

```bash
cd ~/Scripts/sra

cp medfood.csv medfood_all.csv
echo Perilla_frutescens,DRX026628,ILLUMINA,PAIRED,199,DRR029569,4000000,808M >> medfood_all.csv
echo Perilla_frutescens,DRX026628,ILLUMINA,PAIRED,199,DRR029570,2135878,431.4M >> medfood_all.csv

# NCBI metainfo error
# http://trace.ncbi.nlm.nih.gov/Traces/study/?acc=DRX014826
echo Pueraria_lobata,DRX014826,ILLUMINA,SINGLE,,DRR016460,23802502,2.4G >> medfood_all.csv
```

Generate bash files and run a sample.

```bash
cd ~/data/rna-seq/medfood
perl ~/Scripts/sra/medfood_seq.pl

sh bash/sra.Cichorium_intybus.sh

```

Open `~/data/rna-seq/medfood/screen.sh.txt` and paste bash lines to terminal.

When the size of `screen.sra_Cichorium_intybus-0.log` reach 6.5K, the process should be finished.

```bash
# fq
# Cichorium_intybus
screen -L -dmS sra_Cichorium_intybus sh /home/wangq/data/rna-seq/medfood/bash/sra.Cichorium_intybus.sh

# screen.sra_Hippophae_rhamnoides-0.log

# ...

# trinity
# Cichorium_intybus
screen -L -dmS tri_Cichorium_intybus sh /home/wangq/data/rna-seq/medfood/bash/tri.Cichorium_intybus.sh

# ...
```
