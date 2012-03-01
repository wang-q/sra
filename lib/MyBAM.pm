package MyBAM;
use autodie;
use Moose;
use Carp;

use Template;
use File::Remove qw(remove);

use YAML qw(Dump Load DumpFile LoadFile);

has base_dir => ( is => 'rw', isa => 'Str' );
has bin_dir  => ( is => 'rw', isa => 'HashRef', default => sub { {} }, );
has data_dir => ( is => 'rw', isa => 'HashRef', default => sub { {} }, );
has ref_file => ( is => 'rw', isa => 'HashRef', default => sub { {} }, );

has parallel => ( is => 'rw', isa => 'Int', default => 4, );
has memory   => ( is => 'rw', isa => 'Int', default => 1, );

has bash => ( is => 'ro', isa => 'Str' );
has imr => ( is => 'ro', isa => 'Str' );

sub BUILD {
    my $self = shift;

    return;
}

sub write {
    my $self = shift;
    my $item = shift;
    my $bash = shift || 'bash';
    my $file = shift || $self->data_dir->{bash} . "/" . $item->{name} . "_sra.sh";

    open my $fh, ">", $file;
    print {$fh} $self->{$bash};
    close $fh;

    return;
}

sub head {
    my $self = shift;
    my $item = shift;

    my $tt = Template->new;

    my $text = <<'EOF';
#!/bin/bash
start_time=`date +%s`

cd [% base_dir %]

# index reference genome
# bwa index -a bwtsw [% ref_file.seq %]
# samtools faidx [% ref_file.seq %]

if [ -d [% item.dir %] ];
then
    rm -fr [% item.dir %] ;
fi;
mkdir [% item.dir %]

EOF
    my $output;
    $tt->process(
        \$text,
        {   base_dir => $self->base_dir,
            ref_file => $self->ref_file,
            item     => $item,
        },
        \$output
    ) or die Template->error;

    $self->{bash} .= $output;
    return;
}

sub srr_dump_pe {
    my $self = shift;
    my $item = shift;

    my $tt = Template->new;

    my $text = <<'EOF';
[% FOREACH lane IN item.lanes -%]
# lane [% lane.srr %]
mkdir [% item.dir %]/[% lane.srr %]

# sra to fastq (pair end)
[% bin_dir.stk %]/fastq-dump [% lane.file %] \
    --split-files --gzip -O [% item.dir %]/[% lane.srr %]
[ $? -ne 0 ] && echo `date` [% item.name %] [% lane.srr %] [fastq dump] failed >> [% base_dir %]/fail.log && exit 255

[% END -%]

EOF
    my $output;
    $tt->process(
        \$text,
        {   base_dir => $self->base_dir,
            item     => $item,
            bin_dir  => $self->bin_dir,
            data_dir => $self->data_dir,
            ref_file => $self->ref_file,
            parallel => $self->parallel,
            memory   => $self->memory,
        },
        \$output
    ) or die Template->error;

    $self->{bash} .= $output;
    return;

}

sub bwa_aln_pe {
    my $self = shift;
    my $item = shift;

    my $tt = Template->new;

    my $text = <<'EOF';
[% FOREACH lane IN item.lanes -%]
# align pair reads to reference genome
bwa aln -q 15 -t [% parallel %] [% ref_file.seq %] [% item.dir %]/[% lane.srr %]/[% lane.srr %]_1.fastq.gz \
    > [% item.dir %]/[% lane.srr %]/[% lane.srr %]_1.sai
[ $? -ne 0 ] && echo `date` [% item.name %] [% lane.srr %] [bwa aln] failed >> [% base_dir %]/fail.log && exit 255

# align pair reads to reference genome
bwa aln -q 15 -t [% parallel %] [% ref_file.seq %] [% item.dir %]/[% lane.srr %]/[% lane.srr %]_2.fastq.gz \
    > [% item.dir %]/[% lane.srr %]/[% lane.srr %]_2.sai
[ $? -ne 0 ] && echo `date` [% item.name %] [% lane.srr %] [bwa aln] failed >> [% base_dir %]/fail.log && exit 255

# convert sai to sam
# add read groups info
bwa sampe -r "[% lane.rg_str %]" \
    [% ref_file.seq %] \
    [% item.dir %]/[% lane.srr %]/[% lane.srr %]*.sai \
    [% item.dir %]/[% lane.srr %]/[% lane.srr %]*.fastq.gz \
    | gzip > [% item.dir %]/[% lane.srr %]/[% lane.srr %].sam.gz
[ $? -ne 0 ] && echo `date` [% item.name %] [bwa sampe] failed >> [% base_dir %]/fail.log && exit 255

# convert sam to bam
samtools view -uS [% item.dir %]/[% lane.srr %]/[% lane.srr %].sam.gz \
    | samtools sort - [% item.dir %]/[% lane.srr %]/[% lane.srr %].tmp1
samtools fixmate [% item.dir %]/[% lane.srr %]/[% lane.srr %].tmp1.bam - \
    | samtools sort - [% item.dir %]/[% lane.srr %]/[% lane.srr %]

# clean
mv [% item.dir %]/[% lane.srr %]/[% lane.srr %].bam [% item.dir %]/[% lane.srr %].srr.bam
rm -fr [% item.dir %]/[% lane.srr %]/

[% END -%]

EOF
    my $output;
    $tt->process(
        \$text,
        {   base_dir => $self->base_dir,
            item     => $item,
            bin_dir  => $self->bin_dir,
            data_dir => $self->data_dir,
            ref_file => $self->ref_file,
            parallel => $self->parallel,
            memory   => $self->memory,
        },
        \$output
    ) or die Template->error;

    $self->{bash} .= $output;
    return;
}

sub merge_bam {
    my $self = shift;
    my $item = shift;

    my $tt = Template->new;

    my $text = <<'EOF';
[% IF item.lanes.size > 1 -%]
# merge with samtools
perl -e 'print "[% FOREACH lane IN item.lanes %]\[% lane.rg_str %]\n[% END %]"' > [% item.dir %]/rg.txt
samtools merge -rh [% item.dir %]/rg.txt [% item.dir %]/[% item.name %].merge.bam [% FOREACH lane IN item.lanes %] [% item.dir %]/[% lane.srr %].srr.bam [% END %]

# sort bam
samtools sort [% item.dir %]/[% item.name %].merge.bam [% item.dir %]/[% item.name %].sort
rm [% item.dir %]/[% item.name %].merge.bam

[% ELSE -%]
# rename bam
cp [% item.dir %]/[% item.lanes.0.srr %].srr.bam [% item.dir %]/[% item.name %].sort.bam

[% END -%]
# index bam
samtools index [% item.dir %]/[% item.name %].sort.bam

EOF
    my $output;
    $tt->process(
        \$text,
        {   base_dir => $self->base_dir,
            item     => $item,
            bin_dir  => $self->bin_dir,
            data_dir => $self->data_dir,
            ref_file => $self->ref_file,
            parallel => $self->parallel,
            memory   => $self->memory,
        },
        \$output
    ) or die Template->error;

    $self->{bash} .= $output;
    return;
}

sub realign_dedup {
    my $self = shift;
    my $item = shift;

    my $tt = Template->new;

    my $text = <<'EOF';
# index regions for realignment
java -Xmx[% memory %]g -jar [% bin_dir.gatk %]/GenomeAnalysisTK.jar -nt [% parallel %] \
    -T RealignerTargetCreator \
    -R [% ref_file.seq %] \
    -I [% item.dir %]/[% item.name %].sort.bam  \
    --out [% item.dir %]/[% item.name %].intervals
[ $? -ne 0 ] && echo `date` [% item.name %] [gatk target] failed >> [% base_dir %]/fail.log && exit 255

# realign bam to get better Indel calling
java -Xmx[% memory %]g -jar [% bin_dir.gatk %]/GenomeAnalysisTK.jar \
    -T IndelRealigner \
    -R [% ref_file.seq %] \
    -I [% item.dir %]/[% item.name %].sort.bam \
    -targetIntervals [% item.dir %]/[% item.name %].intervals \
    --out [% item.dir %]/[% item.name %].realign.bam
[ $? -ne 0 ] && echo `date` [% item.name %] [gatk realign] failed >> [% base_dir %]/fail.log && exit 255

# dup marking
java -Xmx[% memory %]g -jar [% bin_dir.pcd %]/MarkDuplicates.jar \
    INPUT=[% item.dir %]/[% item.name %].realign.bam \
    OUTPUT=[% item.dir %]/[% item.name %].dedup.bam \
    METRICS_FILE=[% item.dir %]/output.metrics \
    ASSUME_SORTED=true \
    REMOVE_DUPLICATES=true \
    VALIDATION_STRINGENCY=LENIENT
[ $? -ne 0 ] && echo `date` [% item.name %] [picard dedup] failed >> [% base_dir %]/fail.log && exit 255

# reindex the realigned dedup BAM
samtools index [% item.dir %]/[% item.name %].dedup.bam

EOF
    my $output;
    $tt->process(
        \$text,
        {   base_dir => $self->base_dir,
            item     => $item,
            bin_dir  => $self->bin_dir,
            data_dir => $self->data_dir,
            ref_file => $self->ref_file,
            parallel => $self->parallel,
            memory   => $self->memory,
        },
        \$output
    ) or die Template->error;

    $self->{bash} .= $output;
    return;
}

sub recal {
    my $self = shift;
    my $item = shift;

    my $tt = Template->new;

    my $text = <<'EOF';
# recalibration - Count covariates
java -Xmx[% memory %]g -jar [% bin_dir.gatk %]/GenomeAnalysisTK.jar -nt [% parallel %] \
    -T CountCovariates  \
    -R [% ref_file.seq %] \
    -I [% item.dir %]/[% item.name %].dedup.bam \
    -knownSites [% ref_file.vcf %] \
    -recalFile [% item.dir %]/recal_data.csv \
    -cov ReadGroupCovariate \
    -cov QualityScoreCovariate \
    -cov CycleCovariate \
    -cov DinucCovariate
[ $? -ne 0 ] && echo `date` [% item.name %] [gatk covariates] failed >> [% base_dir %]/fail.log && exit 255

# recalibration - Tabulate recalibration
java -Xmx[% memory %]g -jar [% bin_dir.gatk %]/GenomeAnalysisTK.jar \
    -T TableRecalibration  \
    -R [% ref_file.seq %] \
    -I [% item.dir %]/[% item.name %].dedup.bam \
    -o [% item.dir %]/[% item.name %].recal.bam \
    -baq RECALCULATE \
    -recalFile [% item.dir %]/recal_data.csv
[ $? -ne 0 ] && echo `date` [% item.name %] [gatk recal] failed >> [% base_dir %]/fail.log && exit 255

EOF
    my $output;
    $tt->process(
        \$text,
        {   base_dir => $self->base_dir,
            item     => $item,
            bin_dir  => $self->bin_dir,
            data_dir => $self->data_dir,
            ref_file => $self->ref_file,
            parallel => $self->parallel,
            memory   => $self->memory,
        },
        \$output
    ) or die Template->error;

    $self->{bash} .= $output;
    return;
}

sub fastq_fasta {
    my $self = shift;
    my $item = shift;

    my $tt = Template->new;

    my $text = <<'EOF';
# generate fastq from bam
samtools mpileup -uf [% ref_file.seq %] [% item.dir %]/[% item.name %].recal.bam \
    | bcftools view -cg - \
    | vcfutils.pl vcf2fq > [% item.dir %]/[% item.name %].fq

# convert fastq to fasta 
# mask bases with quality lower than 20 to lowercases
seqtk fq2fa [% item.dir %]/[% item.name %].fq 20 > [% item.dir %]/[% item.name %].fa

EOF
    my $output;
    $tt->process(
        \$text,
        {   base_dir => $self->base_dir,
            item     => $item,
            bin_dir  => $self->bin_dir,
            data_dir => $self->data_dir,
            ref_file => $self->ref_file,
            parallel => $self->parallel,
            memory   => $self->memory,
        },
        \$output
    ) or die Template->error;

    $self->{bash} .= $output;
    return;
}

sub clean {
    my $self = shift;
    my $item = shift;

    my $tt = Template->new;

    my $text = <<'EOF';
# let's clean up
#find [% item.dir %] -type f \
#    -name "*.sort.*" -o -name "*.dedup.*" \
#    -o -name "*.realign.*" \
#    -o -name "*.csv" -o -name "*.intervals" \
#    | xargs rm

echo run time is $(expr `date +%s` - $start_time) s
EOF
    my $output;
    $tt->process(
        \$text,
        {   base_dir => $self->base_dir,
            item     => $item,
            bin_dir  => $self->bin_dir,
            data_dir => $self->data_dir,
            ref_file => $self->ref_file,
            parallel => $self->parallel,
            memory   => $self->memory,
        },
        \$output
    ) or die Template->error;

    $self->{bash} .= $output;
    return;
}

sub imr_denom_desc {
    my $self = shift;
    my $item = shift;

    my $tt = Template->new;

    my $text = <<'EOF';
#---example2.t---
outputfolder [% item.dir %]/
reference [% ref_file.seq %]
iterations 5
threads 8
maxreads 4000000

[% FOREACH lane IN item.lanes -%]
#Group [% loop.index + 1 %]
grouppara_[% loop.index + 1 %] ID:[% lane.srr %],LB:[% lane.srx %],PL:[% lane.platform %],SM:[% item.name %]
loaddata_[% loop.index + 1 %] [% item.dir %]/[% lane.srr %]/[% lane.srr %]_1.fastq.gz [% item.dir %]/[% lane.srr %]/[% lane.srr %]_2.fastq.gz

[% END -%]
## ---end--
EOF
    my $output;
    $tt->process(
        \$text,
        {   base_dir => $self->base_dir,
            item     => $item,
            bin_dir  => $self->bin_dir,
            data_dir => $self->data_dir,
            ref_file => $self->ref_file,
            parallel => $self->parallel,
            memory   => $self->memory,
        },
        \$output
    ) or die Template->error;

    $self->{imr} .= $output;
    return;
}

sub srr_dump_pe_q64 {
    my $self = shift;
    my $item = shift;

    my $tt = Template->new;

    my $text = <<'EOF';
[% FOREACH lane IN item.lanes -%]
# lane [% lane.srr %]
mkdir [% item.dir %]/[% lane.srr %]

# sra to fastq (pair end)
[% bin_dir.stk %]/fastq-dump [% lane.file %] \
    --split-files --offset 64 --gzip -O [% item.dir %]/[% lane.srr %]
[ $? -ne 0 ] && echo `date` [% item.name %] [% lane.srr %] [fastq dump] failed >> [% base_dir %]/fail.log && exit 255

[% END -%]

EOF
    my $output;
    $tt->process(
        \$text,
        {   base_dir => $self->base_dir,
            item     => $item,
            bin_dir  => $self->bin_dir,
            data_dir => $self->data_dir,
            ref_file => $self->ref_file,
            parallel => $self->parallel,
            memory   => $self->memory,
        },
        \$output
    ) or die Template->error;

    $self->{bash} .= $output;
    return;

}

sub imr_run {
    my $self = shift;
    my $item = shift;

    my $tt = Template->new;

    my $text = <<'EOF';
# imr
imr easyrun [% item.desc_file %] -m bwa

EOF
    my $output;
    $tt->process(
        \$text,
        {   base_dir => $self->base_dir,
            item     => $item,
            bin_dir  => $self->bin_dir,
            data_dir => $self->data_dir,
            ref_file => $self->ref_file,
            parallel => $self->parallel,
            memory   => $self->memory,
        },
        \$output
    ) or die Template->error;

    $self->{bash} .= $output;
    return;
}

1;
