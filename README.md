# Processing NCBI sra/EBI ena data

## medfood: medicine food homology

Routine things

    ```bash
    cd ~/Scripts/sra
    perl medfood_info.pl

    perl sra_prep.pl -i medfood.yml --md5

    mkdir -p ~/data/rna-seq/medfood/sra
    cd ~/data/rna-seq/medfood/sra
    cp ~/Scripts/sra/medfood.ftp.txt .
    aria2c -x 12 -s 4 -c -i medfood.ftp.txt
    ```

ENA didn't display DRX correctly, so manually add information for DRX026628 and DRX014826

* http://www.ncbi.nlm.nih.gov/sra/?term=DRX026628
* http://www.ncbi.nlm.nih.gov/sra/?term=DRX014826

    ```bash
    echo Perilla_frutescens,DRX026628,ILLUMINA,PAIRED,199,DRR029569,4000000,808M >> medfood.csv
    echo Perilla_frutescens,DRX026628,ILLUMINA,PAIRED,199,DRR029570,2135878,431.4M >> medfood.csv

    echo Pueraria_lobata,DRX014826,ILLUMINA,PAIRED,101,DRR016460,23802502,2.4G >> medfood.csv
    ```

Use `prefetch` of sra toolkit to download three DRR files.

    ```bash
    prefetch DRR029569 DRR029570 DRR016460

    mv ~/ncbi/public/sra/DRR*.sra ~/data/rna-seq/medfood/sra
    ```
