package MyBAM;
use autodie;
use Moose;
use Carp;

use Template;

use YAML::Syck;

has base_dir => ( is => 'rw', isa => 'Str' );
has bin_dir  => ( is => 'rw', isa => 'HashRef', default => sub { {} }, );
has data_dir => ( is => 'rw', isa => 'HashRef', default => sub { {} }, );
has ref_file => ( is => 'rw', isa => 'HashRef', default => sub { {} }, );

has min      => ( is => 'rw', isa => 'Int', default => 80, );
has parallel => ( is => 'rw', isa => 'Int', default => 4, );
has memory   => ( is => 'rw', isa => 'Int', default => 1, );
has tmpdir   => ( is => 'rw', isa => 'Str', default => "/tmp", );

has bash => ( is => 'ro', isa => 'Str' );

sub BUILD {

    #    my $self = shift;

    return;
}

sub write {
    my $self = shift;
    my $item = shift;
    my $file = shift
        || $self->data_dir->{bash} . "/" . "sra." . $item->{name} . ".sh";

    open my $fh, ">", $file;
    print {$fh} $self->bash;
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

### bash hints
### 2>&1                        redirect stderr to stdout
### | tee -a log.log            screen outputs also append to log file
### ; ( exit ${PIPESTATUS} )    correct program exitting status
### Only run parallel when you're sure that there are no errors.

### index reference genome
# bwa index -a bwtsw [% ref_file.seq %]
# samtools faidx [% ref_file.seq %]

cd [% base_dir %]

mkdir -p [% item.dir %]
cd [% item.dir %]

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

sub tail {
    my $self = shift;
    my $item = shift;

    my $tt = Template->new;

    my $text = <<'EOF';

end_time=`date +%s`
runtime=$((end_time-start_time))
echo "$(($runtime / 3600)) hours"

echo `date` "[% item.name %] successed. Runtime $(($runtime / 3600)) hours" \
    >> [% base_dir %]/success.log && exit 0

EOF
    my $output;
    $tt->process(
        \$text,
        {   base_dir => $self->base_dir,
            item     => $item,
        },
        \$output
    ) or die Template->error;

    $self->{bash} .= $output;
    return;
}

sub srr_dump {
    my $self = shift;
    my $item = shift;

    my $tt = Template->new;

    my $text = <<'EOF';
#----------------------------#
# srr dump
#----------------------------#
[% FOREACH lane IN item.lanes -%]
# lane [% lane.srr %]
mkdir -p [% item.dir %]/[% lane.srr %]

echo "* Start srr_dump [[% item.name %]] [[% lane.srr %]] `date`" | tee -a [% data_dir.log %]/srr_dump.log

[% IF lane.fq -%]

[% IF lane.file.1 -%]
cp [% lane.file.0 %] [% item.dir %]/[% lane.srr %]/[% lane.srr %]_1.fastq.gz
cp [% lane.file.1 %] [% item.dir %]/[% lane.srr %]/[% lane.srr %]_2.fastq.gz
[% ELSE -%]
cp [% lane.file.0 %] [% item.dir %]/[% lane.srr %]/[% lane.srr %].fastq.gz
[% END -%]

[% ELSE -%]
[% IF lane.layout == 'PAIRED' -%]
# sra to fastq (pair end)
fastq-dump [% lane.file %] \
    --split-files -O [% item.dir %]/[% lane.srr %] \
[% ELSE -%]
# sra to fastq (single end)
fastq-dump [% lane.file %] \
    -O [% item.dir %]/[% lane.srr %] \
[% END -%]
    2>&1 | tee -a [% data_dir.log %]/srr_dump.log ; ( exit ${PIPESTATUS} )
[% END -%]

[ $? -ne 0 ] && echo `date` [% item.name %] [% lane.srr %] [fastq dump] failed >> [% base_dir %]/fail.log && exit 255
echo "* End srr_dump [[% item.name %]] [[% lane.srr %]] `date`" | tee -a [% data_dir.log %]/srr_dump.log

find [% item.dir %]/[% lane.srr %]/ -type f -name "*.fastq" \
    | parallel --no-run-if-empty -j 1 pigz -p [% parallel %]
echo "* Gzip sra fastq [[% item.name %]] [[% lane.srr %]] `date`" | tee -a [% data_dir.log %]/srr_dump.log

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
            tmpdir   => $self->tmpdir,
        },
        \$output
    ) or die Template->error;

    $self->{bash} .= $output;
    return;
}

sub fastqc {
    my $self = shift;
    my $item = shift;

    my $tt = Template->new;

    my $text = <<'EOF';
#----------------------------#
# fastqc
#----------------------------#
[% FOREACH lane IN item.lanes -%]
# lane [% lane.srr %]

echo "* Start fastqc [[% item.name %]] [[% lane.srr %]] `date`" | tee -a [% data_dir.log %]/fastqc.log

[% IF lane.layout == 'PAIRED' -%]
# fastqc (pair end)
fastqc -t [% parallel %] \
[% IF item.sickle -%]
    [% item.dir %]/[% lane.srr %]/trimmed/[% lane.srr %]_1.sickle.fq.gz \
    [% item.dir %]/[% lane.srr %]/trimmed/[% lane.srr %]_2.sickle.fq.gz \
    [% item.dir %]/[% lane.srr %]/trimmed/[% lane.srr %]_single.sickle.fq.gz \
[% ELSE -%]
    [% item.dir %]/[% lane.srr %]/[% lane.srr %]_1.fastq.gz \
    [% item.dir %]/[% lane.srr %]/[% lane.srr %]_2.fastq.gz \
[% END -%]
    2>&1 | tee -a [% data_dir.log %]/fastqc.log ; ( exit ${PIPESTATUS} )

[% ELSE -%]
# fastqc (single end)
fastqc -t [% parallel %] \
[% IF item.sickle -%]
    [% item.dir %]/[% lane.srr %]/trimmed/[% lane.srr %].sickle.fq.gz \
[% ELSE -%]
    [% item.dir %]/[% lane.srr %]/[% lane.srr %].fastq.gz \
[% END -%]
    2>&1 | tee -a [% data_dir.log %]/fastqc.log ; ( exit ${PIPESTATUS} )

[% END -%]

[ $? -ne 0 ] && echo `date` [% item.name %] [% lane.srr %] [fastqc[% IF item.sickle %].sickle[% END %]] failed >> [% base_dir %]/fail.log && exit 255
echo "* End fastqc [[% item.name %]] [[% lane.srr %]] `date`" | tee -a [% data_dir.log %]/fastqc.log

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
            tmpdir   => $self->tmpdir,
        },
        \$output
    ) or die Template->error;

    $self->{bash} .= $output;
    return;
}

sub scythe_sickle {
    my $self = shift;
    my $item = shift;

    $item->{sickle} = 1;

    my $tt = Template->new;

    my $text = <<'EOF';
#----------------------------#
# tally
#----------------------------#
[% FOREACH lane IN item.lanes -%]
# lane [% lane.srr %]

if [ ! -d [% item.dir %]/[% lane.srr %]/trimmed  ];
then
    mkdir -p [% item.dir %]/[% lane.srr %]/trimmed ;
fi;

cd [% item.dir %]/[% lane.srr %]/trimmed

echo "* Start tally [[% item.name %]] [[% lane.srr %]] `date`" | tee -a [% data_dir.log %]/tally.log

[% IF lane.layout == 'PAIRED' -%]
# tally (pair end)
tally \
    --pair-by-offset --with-quality --nozip \
    -i [% item.dir %]/[% lane.srr %]/[% lane.srr %]_1.fastq.gz \
    -j [% item.dir %]/[% lane.srr %]/[% lane.srr %]_2.fastq.gz \
    -o [% item.dir %]/[% lane.srr %]/trimmed/[% lane.srr %]_1.tally.fq \
    -p [% item.dir %]/[% lane.srr %]/trimmed/[% lane.srr %]_2.tally.fq

parallel --no-run-if-empty -j 2 "
        pigz -p 4 [% item.dir %]/[% lane.srr %]/trimmed/[% lane.srr %]_{}.tally.fq
    " ::: 1 2

[% ELSE -%]
# tally (single end)
tally \
    --with-quality --nozip \
    -i [% item.dir %]/[% lane.srr %]/[% lane.srr %].fastq.gz \
    -o [% item.dir %]/[% lane.srr %]/trimmed/[% lane.srr %].tally.fq

pigz -p [% parallel %] [% item.dir %]/[% lane.srr %]/trimmed/[% lane.srr %].tally.fq

[% END -%]

[ $? -ne 0 ] && echo `date` [% item.name %] [% lane.srr %] [tally] failed >> [% base_dir %]/fail.log && exit 255
echo "* End tally [[% item.name %]] [[% lane.srr %]] `date`" | tee -a [% data_dir.log %]/tally.log

[% END -%]

#----------------------------#
# scythe
#----------------------------#
[% FOREACH lane IN item.lanes -%]
# lane [% lane.srr %]
cd [% item.dir %]/[% lane.srr %]/trimmed

echo "* Start scythe [[% item.name %]] [[% lane.srr %]] `date`" | tee -a [% data_dir.log %]/scythe.log

[% IF lane.layout == 'PAIRED' -%]
# scythe (pair end)
parallel -j 2 "
    scythe \
        [% item.dir %]/[% lane.srr %]/trimmed/[% lane.srr %]_{}.tally.fq.gz \
        -q sanger \
        -a [% ref_file.adapters %] \
        --quiet \
        | pigz -p [% parallel %] -c \
        > [% item.dir %]/[% lane.srr %]/trimmed/[% lane.srr %]_{}.scythe.fq.gz
    " ::: 1 2

[% ELSE -%]
# scythe (single end)
scythe \
    [% item.dir %]/[% lane.srr %]/trimmed/[% lane.srr %].tally.fq.gz \
    -q sanger \
    -a [% ref_file.adapters %] \
    --quiet \
    | pigz -p [% parallel %] -c \
    > [% item.dir %]/[% lane.srr %]/trimmed/[% lane.srr %].scythe.fq.gz

[% END -%]

[ $? -ne 0 ] && echo `date` [% item.name %] [% lane.srr %] [scythe] failed >> [% base_dir %]/fail.log && exit 255
echo "* End scythe [[% item.name %]] [[% lane.srr %]] `date`" | tee -a [% data_dir.log %]/scythe.log

[% END -%]

#----------------------------#
# sickle
#----------------------------#
[% FOREACH lane IN item.lanes -%]
# lane [% lane.srr %]
cd [% item.dir %]/[% lane.srr %]/trimmed

echo "* Start sickle [[% item.name %]] [[% lane.srr %]] `date`" | tee -a [% data_dir.log %]/sickle.log

[% IF lane.layout == 'PAIRED' -%]
# sickle (pair end)
sickle pe \
    -t sanger -l [% min %] -q 20 \
    -f [% item.dir %]/[% lane.srr %]/trimmed/[% lane.srr %]_1.scythe.fq.gz \
    -r [% item.dir %]/[% lane.srr %]/trimmed/[% lane.srr %]_2.scythe.fq.gz \
    -o [% item.dir %]/[% lane.srr %]/trimmed/[% lane.srr %]_1.sickle.fq \
    -p [% item.dir %]/[% lane.srr %]/trimmed/[% lane.srr %]_2.sickle.fq \
    -s [% item.dir %]/[% lane.srr %]/trimmed/[% lane.srr %]_single.sickle.fq \
    2>&1 | tee -a [% data_dir.log %]/sickle.log ; ( exit ${PIPESTATUS} )

[% ELSE -%]
# sickle (single end)
sickle se \
    -t sanger -l [% min %] -q 20 \
    -f [% item.dir %]/[% lane.srr %]/trimmed/[% lane.srr %].scythe.fq.gz \
    -o [% item.dir %]/[% lane.srr %]/trimmed/[% lane.srr %].sickle.fq
    2>&1 | tee -a [% data_dir.log %]/sickle.log ; ( exit ${PIPESTATUS} )

[% END -%]

[ $? -ne 0 ] && echo `date` [% item.name %] [% lane.srr %] [sickle] failed >> [% base_dir %]/fail.log && exit 255
echo "* End sickle [[% item.name %]] [[% lane.srr %]] `date`" | tee -a [% data_dir.log %]/sickle.log

find [% item.dir %]/[% lane.srr %]/trimmed/ -type f -name "*.sickle.fq" \
    | parallel --no-run-if-empty -j 1 pigz -p [% parallel %]
echo "* Gzip sickle [[% item.name %]] [[% lane.srr %]] `date`" | tee -a [% data_dir.log %]/sickle.log

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
            min      => $self->min,
            parallel => $self->parallel,
            memory   => $self->memory,
            tmpdir   => $self->tmpdir,
        },
        \$output
    ) or die Template->error;

    $self->{bash} .= $output;
    return;
}

sub head_tophat {
    my $self = shift;
    my $item = shift;

    my $tt = Template->new;

    my $text = <<'EOF';
#!/bin/bash
start_time=`date +%s`

### bash hints
### 2>&1                        redirect stderr to stdout
### | tee -a log.log            screen outputs also append to log file
### ; ( exit ${PIPESTATUS} )    correct program exitting status
### Only run parallel when you're sure that there are no errors.

cd [% base_dir %]

### bowtie index
# bowtie2-build [% ref_file.seq %] [% ref_file.bowtie_index %]

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

sub tophat {
    my $self = shift;
    my $item = shift;

    my $tt = Template->new;

    my $text = <<'EOF';
#----------------------------#
# tophat
#----------------------------#
[% FOREACH lane IN item.lanes -%]
# lane [% lane.srr %]

cd [% item.dir %]/[% lane.srr %]/

echo "* Start tophat [[% item.name %]] [[% lane.srr %]] `date`" | tee -a [% data_dir.log %]/tophat.log

[% IF lane.layout == 'PAIRED' -%]
# tophat (pair end)
tophat -p [% parallel %] \
    -G [% ref_file.gtf %] \
    -o [% item.dir %]/[% lane.srr %]/th_out \
    [% ref_file.bowtie_index %] \
[% IF item.sickle -%]
    [% item.dir %]/[% lane.srr %]/trimmed/[% lane.srr %]_1.sickle.fq.gz \
    [% item.dir %]/[% lane.srr %]/trimmed/[% lane.srr %]_2.sickle.fq.gz
[% ELSE -%]
    [% item.dir %]/[% lane.srr %]/[% lane.srr %]_1.fastq.gz \
    [% item.dir %]/[% lane.srr %]/[% lane.srr %]_2.fastq.gz
[% END -%]

[% ELSE -%]
# tophat (single end)
tophat -p [% parallel %] \
    -G [% ref_file.gtf %] \
    -o [% item.dir %]/[% lane.srr %]/th_out \
    [% ref_file.bowtie_index %] \
[% IF item.sickle -%]
    [% item.dir %]/[% lane.srr %]/trimmed/[% lane.srr %].sickle.fq.gz
[% ELSE -%]
    [% item.dir %]/[% lane.srr %]/[% lane.srr %].fastq.gz
[% END -%]

[% END -%]

[ $? -ne 0 ] && echo `date` [% item.name %] [% lane.srr %] [tophat] failed >> [% base_dir %]/fail.log && exit 255
echo "* End tophat [[% item.name %]] [[% lane.srr %]] `date`" | tee -a [% data_dir.log %]/tophat.log

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
            tmpdir   => $self->tmpdir,
        },
        \$output
    ) or die Template->error;

    $self->{bash} .= $output;
    return;
}

sub cufflinks {
    my $self = shift;
    my $item = shift;

    my $tt = Template->new;

    my $text = <<'EOF';
#----------------------------#
# cufflinks
#----------------------------#
[% FOREACH lane IN item.lanes -%]
# lane [% lane.srr %]

cd [% item.dir %]/[% lane.srr %]/

echo "* Start cufflinks [[% item.name %]] [[% lane.srr %]] `date`" | tee -a [% data_dir.log %]/cufflinks.log

# cufflinks
cufflinks -p [% parallel %] \
    --no-update-check [% IF ref_file.mask_gtf -%]-M [% ref_file.mask_gtf %] [% END %]\
    -o [% item.dir %]/[% lane.srr %]/cl_out \
    [% item.dir %]/[% lane.srr %]/th_out/accepted_hits.bam

[ $? -ne 0 ] && echo `date` [% item.name %] [% lane.srr %] [cufflinks] failed >> [% base_dir %]/fail.log && exit 255
echo "* End cufflinks [[% item.name %]] [[% lane.srr %]] `date`" | tee -a [% data_dir.log %]/cufflinks.log

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
            tmpdir   => $self->tmpdir,
        },
        \$output
    ) or die Template->error;

    $self->{bash} .= $output;
    return;
}

sub cuffmerge {
    my $self = shift;
    my $data = shift;

    my $tt = Template->new;

    my $text = <<'EOF';
cd [% data_dir.proc %]

#----------------------------#
# config file
#----------------------------#
if [ -e [% data_dir.proc %]/assemblies.txt ]
then
    rm [% data_dir.proc %]/assemblies.txt
fi

[% FOREACH item IN data -%]
[% FOREACH lane IN item.lanes -%]
echo [% item.dir %]/[% lane.srr %]/cl_out/transcripts.gtf >> [% data_dir.proc %]/assemblies.txt
[% END -%]
[% END -%]

#----------------------------#
# cuffmerge
#----------------------------#
if [ -d [% data_dir.proc %]/merged_asm ]
then
    rm -fr [% data_dir.proc %]/merged_asm
fi

echo "* Start cuffmerge `date`" | tee -a [% data_dir.log %]/cuffmergediff.log

cuffmerge -p [% parallel %] \
    -g [% ref_file.gtf %] \
    -s [% ref_file.seq %] \
    -o [% data_dir.proc %]/merged_asm \
    [% data_dir.proc %]/assemblies.txt

[ $? -ne 0 ] && echo `date` ] [cuffmerge] failed >> [% base_dir %]/fail.log && exit 255
echo "* End cuffmerge `date`" | tee -a [% data_dir.log %]/cuffmergediff.log


EOF
    my $output;
    $tt->process(
        \$text,
        {   base_dir => $self->base_dir,
            data     => $data,
            bin_dir  => $self->bin_dir,
            data_dir => $self->data_dir,
            ref_file => $self->ref_file,
            parallel => $self->parallel,
            memory   => $self->memory,
            tmpdir   => $self->tmpdir,
        },
        \$output
    ) or die Template->error;

    $self->{bash} .= $output;
    return;
}

sub cuffdiff {
    my $self = shift;
    my $data = shift;

    my $tt = Template->new;

    my $text = <<'EOF';
cd [% data_dir.proc %]

#----------------------------#
# cuffdiff
#----------------------------#
echo "* Start cuffdiff `date`" | tee -a [% data_dir.log %]/cuffmergediff.log

cuffdiff -p [% parallel %] \
    --no-update-check -u [% IF ref_file.mask_gtf -%]-M [% ref_file.mask_gtf %] [% END %]\
    -b [% ref_file.seq %] \
    [% data_dir.proc %]/merged_asm/merged.gtf \
    -L [% name_str = ''; name_str = name_str _ item.name _ ',' FOREACH item IN data; name_str FILTER remove('\,$') %] \
[% FOREACH item IN data -%]
[% bam_str = ''; bam_str = bam_str _ item.dir _ '/' _ lane.srr _ '/th_out/accepted_hits.bam' _ ',' FOREACH lane IN item.lanes -%]
    [% bam_str FILTER remove('\,$') %] \
[% END -%]
    -o [% data_dir.proc %]/diff_out

[ $? -ne 0 ] && echo `date` ] [cuffdiff] failed >> [% base_dir %]/fail.log && exit 255
echo "* End cuffdiff `date`" | tee -a [% data_dir.log %]/cuffmergediff.log

EOF
    my $output;
    $tt->process(
        \$text,
        {   base_dir => $self->base_dir,
            data     => $data,
            bin_dir  => $self->bin_dir,
            data_dir => $self->data_dir,
            ref_file => $self->ref_file,
            parallel => $self->parallel,
            memory   => $self->memory,
            tmpdir   => $self->tmpdir,
        },
        \$output
    ) or die Template->error;

    $self->{bash} .= $output;
    return;
}

sub cuffdiff_cxb {
    my $self = shift;
    my $data = shift;

    my $tt = Template->new;

    my $text = <<'EOF';
cd [% data_dir.proc %]

#----------------------------#
# cuffdiff_cxb
#----------------------------#
echo "* Start cuffdiff_cxb `date`" | tee -a [% data_dir.log %]/cuffmergediff.log

cuffdiff -p [% parallel %] \
    --no-update-check -u [% IF ref_file.mask_gtf -%]-M [% ref_file.mask_gtf %] [% END %]\
    -b [% ref_file.seq %] \
    [% data_dir.proc %]/merged_asm/merged.gtf \
    -L [% name_str = ''; name_str = name_str _ item.name _ ',' FOREACH item IN data; name_str FILTER remove('\,$') %] \
[% FOREACH item IN data -%]
[% bam_str = ''; bam_str = bam_str _ item.dir _ '/' _ lane.srr _ '/cq_out/abundances.cxb' _ ',' FOREACH lane IN item.lanes -%]
    [% bam_str FILTER remove('\,$') %] \
[% END -%]
    -o [% data_dir.proc %]/diff_out_cxb

[ $? -ne 0 ] && echo `date` ] [cuffdiff_cxb] failed >> [% base_dir %]/fail.log && exit 255
echo "* End cuffdiff_cxb `date`" | tee -a [% data_dir.log %]/cuffmergediff.log

EOF
    my $output;
    $tt->process(
        \$text,
        {   base_dir => $self->base_dir,
            data     => $data,
            bin_dir  => $self->bin_dir,
            data_dir => $self->data_dir,
            ref_file => $self->ref_file,
            parallel => $self->parallel,
            memory   => $self->memory,
            tmpdir   => $self->tmpdir,
        },
        \$output
    ) or die Template->error;

    $self->{bash} .= $output;
    return;
}

sub cuffnorm {
    my $self = shift;
    my $data = shift;

    my $tt = Template->new;

    my $text = <<'EOF';
cd [% data_dir.proc %]

#----------------------------#
# cuffdiff_cxb
#----------------------------#
echo "* Start cuffnorm `date`" | tee -a [% data_dir.log %]/cuffmergediff.log

cuffnorm -p [% parallel %] \
    --no-update-check \
    [% data_dir.proc %]/merged_asm/merged.gtf \
    -L [% name_str = ''; name_str = name_str _ item.name _ ',' FOREACH item IN data; name_str FILTER remove('\,$') %] \
[% FOREACH item IN data -%]
[% bam_str = ''; bam_str = bam_str _ item.dir _ '/' _ lane.srr _ '/cq_out/abundances.cxb' _ ',' FOREACH lane IN item.lanes -%]
    [% bam_str FILTER remove('\,$') %] \
[% END -%]
    -o [% data_dir.proc %]/norm_out

[ $? -ne 0 ] && echo `date` ] [cuffnorm] failed >> [% base_dir %]/fail.log && exit 255
echo "* End cuffnorm `date`" | tee -a [% data_dir.log %]/cuffmergediff.log

EOF
    my $output;
    $tt->process(
        \$text,
        {   base_dir => $self->base_dir,
            data     => $data,
            bin_dir  => $self->bin_dir,
            data_dir => $self->data_dir,
            ref_file => $self->ref_file,
            parallel => $self->parallel,
            memory   => $self->memory,
            tmpdir   => $self->tmpdir,
        },
        \$output
    ) or die Template->error;

    $self->{bash} .= $output;
    return;
}

sub cuffquant {
    my $self = shift;
    my $item = shift;

    my $tt = Template->new;

    my $text = <<'EOF';
#----------------------------#
# cuffquant
#----------------------------#
[% FOREACH lane IN item.lanes -%]
# lane [% lane.srr %]

cd [% item.dir %]/[% lane.srr %]/

echo "* Start cuffquant [[% item.name %]] [[% lane.srr %]] `date`" | tee -a [% data_dir.log %]/cuffquant.log

# cuffquant
cuffquant -p [% parallel %] \
    --no-update-check -u [% IF ref_file.mask_gtf -%]-M [% ref_file.mask_gtf %] [% END %]\
    -b [% ref_file.seq %] \
    [% data_dir.proc %]/merged_asm/merged.gtf \
    -o [% item.dir %]/[% lane.srr %]/cq_out \
    [% item.dir %]/[% lane.srr %]/th_out/accepted_hits.bam

[ $? -ne 0 ] && echo `date` [% item.name %] [% lane.srr %] [cuffquant] failed >> [% base_dir %]/fail.log && exit 255
echo "* End cuffquant [[% item.name %]] [[% lane.srr %]] `date`" | tee -a [% data_dir.log %]/cuffquant.log

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
            tmpdir   => $self->tmpdir,
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

find [% item.dir %]/[% lane.srr %] -type f -name "*.fastq.gz" -o -name "*.sai" | xargs rm

# convert sam to bam and fix mate info
java -Djava.io.tmpdir=[% tmpdir %] -Xmx[% memory %]g \
    -jar [% bin_dir.pcd %]/FixMateInformation.jar \
    INPUT=[% item.dir %]/[% lane.srr %]/[% lane.srr %].sam.gz \
    OUTPUT=[% item.dir %]/[% lane.srr %]/[% lane.srr %].bam \
    SORT_ORDER=coordinate \
    VALIDATION_STRINGENCY=LENIENT

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
            tmpdir   => $self->tmpdir,
        },
        \$output
    ) or die Template->error;

    $self->{bash} .= $output;
    return;
}

sub bwa_mem {
    my $self = shift;
    my $item = shift;

    my $tt = Template->new;

    my $text = <<'EOF';
#----------------------------#
# bwa mem
#----------------------------#

[% FOREACH lane IN item.lanes -%]
# [% item.name %] [% lane.srr %]

# align (paired) reads to reference genome
bwa mem -M -t [% parallel %] -R "[% lane.rg_str %]" \
    [% ref_file.seq %] \
[% IF item.lanes.0.layout == 'PAIRED' -%]
[% IF item.sickle -%]
    [% item.dir %]/[% lane.srr %]/trimmed/[% lane.srr %]_1.sickle.fq.gz \
    [% item.dir %]/[% lane.srr %]/trimmed/[% lane.srr %]_2.sickle.fq.gz \
[% ELSIF lane.fq -%]
    [% lane.file.0 %] \
    [% lane.file.1 %] \
[% ELSE -%]
    [% item.dir %]/[% lane.srr %]/[% lane.srr %]_1.fastq.gz \
    [% item.dir %]/[% lane.srr %]/[% lane.srr %]_2.fastq.gz \
[% END -%]
[% ELSE -%]
[% IF item.sickle -%]
    [% item.dir %]/[% lane.srr %]/trimmed/[% lane.srr %].sickle.fq.gz \
[% ELSIF lane.fq -%]
    [% lane.file.0 %] \
[% ELSE -%]
    [% item.dir %]/[% lane.srr %]/[% lane.srr %].fastq.gz \
[% END -%]
[% END -%]
    | gzip -3 > [% item.dir %]/[% lane.srr %]/[% lane.srr %].sam.gz
[ $? -ne 0 ] && echo `date` [% item.name %] [% lane.srr %] [bwa mem] failed >> [% base_dir %]/fail.log && exit 255

# clean sam
java -Djava.io.tmpdir=[% tmpdir %] -Xmx[% memory %]g \
    -jar [% bin_dir.pcd %]/picard.jar \
    CleanSam \
    INPUT=[% item.dir %]/[% lane.srr %]/[% lane.srr %].sam.gz \
    OUTPUT=[% item.dir %]/[% lane.srr %]/[% lane.srr %].clean.bam
[ $? -ne 0 ] && echo `date` [% item.name %] [% lane.srr %] [picard clean] failed >> [% base_dir %]/fail.log && exit 255

# fix mate info and sort
java -Djava.io.tmpdir=[% tmpdir %] -Xmx[% memory %]g \
    -jar [% bin_dir.pcd %]/picard.jar \
    FixMateInformation \
    INPUT=[% item.dir %]/[% lane.srr %]/[% lane.srr %].clean.bam \
    OUTPUT=[% item.dir %]/[% lane.srr %]/[% lane.srr %].mate.bam \
    SORT_ORDER=coordinate \
    VALIDATION_STRINGENCY=LENIENT
[ $? -ne 0 ] && echo `date` [% item.name %] [% lane.srr %] [picard mate] failed >> [% base_dir %]/fail.log && exit 255

# dup marking
java -Djava.io.tmpdir=[% tmpdir %] -Xmx[% memory %]g \
    -jar [% bin_dir.pcd %]/picard.jar \
    MarkDuplicates \
    INPUT=[% item.dir %]/[% lane.srr %]/[% lane.srr %].mate.bam \
    OUTPUT=[% item.dir %]/[% lane.srr %]/[% lane.srr %].dedup.bam \
    METRICS_FILE=[% item.dir %]/[% lane.srr %]/output.metrics \
    ASSUME_SORTED=true \
    REMOVE_DUPLICATES=true \
    VALIDATION_STRINGENCY=LENIENT
[ $? -ne 0 ] && echo `date` [% item.name %] [% lane.srr %] [picard dedup] failed >> [% base_dir %]/fail.log && exit 255

# rm and mv
rm [% item.dir %]/[% lane.srr %]/[% lane.srr %].sam.gz
rm [% item.dir %]/[% lane.srr %]/[% lane.srr %].clean.bam
rm [% item.dir %]/[% lane.srr %]/[% lane.srr %].mate.bam
mv [% item.dir %]/[% lane.srr %]/[% lane.srr %].dedup.bam [% item.dir %]/[% lane.srr %].srr.bam

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
            tmpdir   => $self->tmpdir,
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
#----------------------------#
# merge bam
#----------------------------#

[% IF item.lanes.size > 1 -%]
# merge with picard
java -Djava.io.tmpdir=[% tmpdir %] -Xmx[% memory %]g \
    -jar [% bin_dir.pcd %]/picard.jar \
    MergeSamFiles \
[% FOREACH lane IN item.lanes -%]
    INPUT=[% item.dir %]/[% lane.srr %].srr.bam \
[% END -%]
    OUTPUT=[% item.dir %]/[% item.name %].merge.bam \
    SORT_ORDER=coordinate \
    VALIDATION_STRINGENCY=LENIENT \
    USE_THREADING=True
[ $? -ne 0 ] && echo `date` [% item.name %] [picard merge] failed >> [% base_dir %]/fail.log && exit 255

[% ELSE -%]
# rename bam
cp [% item.dir %]/[% item.lanes.0.srr %].srr.bam [% item.dir %]/[% item.name %].merge.bam

[% END -%]

# dup marking again
java -Djava.io.tmpdir=[% tmpdir %] -Xmx[% memory %]g \
    -jar [% bin_dir.pcd %]/picard.jar \
    MarkDuplicates \
    INPUT=[% item.dir %]/[% item.name %].merge.bam \
    OUTPUT=[% item.dir %]/[% item.name %].dedup.bam \
    METRICS_FILE=[% item.dir %]/output.metrics \
    ASSUME_SORTED=true \
    REMOVE_DUPLICATES=true \
    CREATE_INDEX=true \
    VALIDATION_STRINGENCY=LENIENT
[ $? -ne 0 ] && echo `date` [% item.name %] [picard dedup again] failed >> [% base_dir %]/fail.log && exit 255

rm [% item.dir %]/[% item.name %].merge.bam

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
            tmpdir   => $self->tmpdir,
        },
        \$output
    ) or die Template->error;

    $self->{bash} .= $output;
    return;
}

sub realign_indel {
    my $self = shift;
    my $item = shift;

    my $tt = Template->new;

    my $text = <<'EOF';
# index regions for realignment
java -Djava.io.tmpdir=[% tmpdir %] -Xmx[% memory %]g \
    -jar [% bin_dir.gatk %]/GenomeAnalysisTK.jar -nt [% parallel %] \
    -T RealignerTargetCreator \
    -R [% ref_file.seq %] \
    -I [% item.dir %]/[% item.name %].dedup.bam  \
    --out [% item.dir %]/[% item.name %].intervals
[ $? -ne 0 ] && echo `date` [% item.name %] [gatk target] failed >> [% base_dir %]/fail.log && exit 255

# realign bam to get better Indel calling
java -Djava.io.tmpdir=[% tmpdir %] -Xmx[% memory %]g \
    -jar [% bin_dir.gatk %]/GenomeAnalysisTK.jar \
    -T IndelRealigner \
    -R [% ref_file.seq %] \
    -I [% item.dir %]/[% item.name %].dedup.bam \
    -targetIntervals [% item.dir %]/[% item.name %].intervals \
    --out [% item.dir %]/[% item.name %].realign.bam
[ $? -ne 0 ] && echo `date` [% item.name %] [gatk realign] failed >> [% base_dir %]/fail.log && exit 255

rm [% item.dir %]/[% item.name %].dedup.ba{m,i}

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
            tmpdir   => $self->tmpdir,
        },
        \$output
    ) or die Template->error;

    $self->{bash} .= $output;
    return;
}

sub recal_reads {
    my $self = shift;
    my $item = shift;

    my $tt = Template->new;

    my $text = <<'EOF';
# Analyze patterns of covariation in the sequence dataset
java -Djava.io.tmpdir=[% tmpdir %] -Xmx[% memory %]g \
    -jar [% bin_dir.gatk %]/GenomeAnalysisTK.jar \
    -T BaseRecalibrator \
    -R [% ref_file.seq %] \
    -I [% item.dir %]/[% item.name %].realign.bam \
    -knownSites [% ref_file.vcf %] \
    --out [% item.dir %]/[% item.name %].recal_data.table
[ $? -ne 0 ] && echo `date` [% item.name %] [gatk recal] failed >> [% base_dir %]/fail.log && exit 255

# a second pass
java -Djava.io.tmpdir=[% tmpdir %] -Xmx[% memory %]g \
    -jar [% bin_dir.gatk %]/GenomeAnalysisTK.jar \
    -T BaseRecalibrator \
    -R [% ref_file.seq %] \
    -I [% item.dir %]/[% item.name %].realign.bam \
    -knownSites [% ref_file.vcf %] \
    -BQSR [% item.name %].recal_data.table \
    --out [% item.dir %]/[% item.name %].post_recal_data.table
[ $? -ne 0 ] && echo `date` [% item.name %] [gatk 2nd recal] failed >> [% base_dir %]/fail.log && exit 255

# Generate before/after plots
java -Djava.io.tmpdir=[% tmpdir %] -Xmx[% memory %]g \
    -jar [% bin_dir.gatk %]/GenomeAnalysisTK.jar \
    -T AnalyzeCovariates \
    -R [% ref_file.seq %] \
    -before [% item.dir %]/[% item.name %].recal_data.table \
    -after [% item.dir %]/[% item.name %].post_recal_data.table \
    -plots [% item.dir %]/recalibration_plots.pdf
[ $? -ne 0 ] && echo `date` [% item.name %] [gatk recal report] failed >> [% base_dir %]/fail.log && exit 255

# Apply the recalibration to your sequence data
java -Djava.io.tmpdir=[% tmpdir %] -Xmx[% memory %]g \
    -jar [% bin_dir.gatk %]/GenomeAnalysisTK.jar -nt [% parallel %] \
    -T PrintReads \
    -R [% ref_file.seq %] \
    -I [% item.dir %]/[% item.name %].realign.bam \
    -BQSR recal_data.table \
    -o [% item.dir %]/[% item.name %].recal.bam
[ $? -ne 0 ] && echo `date` [% item.name %] [gatk printreads] failed >> [% base_dir %]/fail.log && exit 255

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
            tmpdir   => $self->tmpdir,
        },
        \$output
    ) or die Template->error;

    $self->{bash} .= $output;
    return;
}

sub call_snp_filter {
    my $self = shift;
    my $item = shift;

    my $tt = Template->new;

    my $text = <<'EOF';
# rename
if [ -e [% item.dir %]/[% item.name %].recal.bam ];
then
    mv [% item.dir %]/[% item.name %].recal.bam [% item.dir %]/[% item.name %].ready.bam;
    mv [% item.dir %]/[% item.name %].recal.bai [% item.dir %]/[% item.name %].ready.bai;
else
    mv [% item.dir %]/[% item.name %].realign.bam [% item.dir %]/[% item.name %].ready.bam;
    mv [% item.dir %]/[% item.name %].realign.bai [% item.dir %]/[% item.name %].ready.bai;
fi;
[ $? -ne 0 ] && echo `date` [% item.name %] [samtools BAQ] failed >> [% base_dir %]/fail.log && exit 255

# snp calling
java -Djava.io.tmpdir=[% tmpdir %] -Xmx[% memory %]g \
    -jar [% bin_dir.gatk %]/GenomeAnalysisTK.jar -nt [% parallel %] \
    -T UnifiedGenotyper \
    -R [% ref_file.seq %] \
    -glm SNP \
    -I [% item.dir %]/[% item.name %].ready.bam \
    -o [% item.dir %]/[% item.name %].snp.raw.vcf \
    -A AlleleBalance \
    -A Coverage \
    -A FisherStrand
[ $? -ne 0 ] && echo `date` [% item.name %] [gatk snp calling] failed >> [% base_dir %]/fail.log && exit 255

# snp hard filter
java -Djava.io.tmpdir=[% tmpdir %] -Xmx[% memory %]g \
    -jar [% bin_dir.gatk %]/GenomeAnalysisTK.jar \
    -T VariantFiltration \
    -R [% ref_file.seq %] \
    --variant [% item.dir %]/[% item.name %].snp.raw.vcf \
    -o [% item.dir %]/[% item.name %].snp.vcf \
    --filterExpression "QUAL<30.0" \
    --filterName "LowQual" \
    --filterExpression "SB>=-1.0" \
    --filterName "StrandBias" \
    --filterExpression "QD<1.0" \
    --filterName "QualByDepth" \
    --filterExpression "(MQ0 >= 4 && ((MQ0 / (1.0 * DP)) > 0.1))" \
    --filterName "HARD_TO_VALIDATE" \
    --filterExpression "HRun>=15" \
    --filterName "HomopolymerRun"

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
            tmpdir   => $self->tmpdir,
        },
        \$output
    ) or die Template->error;

    $self->{bash} .= $output;
    return;
}

sub call_indel {
    my $self = shift;
    my $item = shift;

    my $tt = Template->new;

    my $text = <<'EOF';
# indel calling
java -Djava.io.tmpdir=[% tmpdir %] -Xmx[% memory %]g \
    -jar [% bin_dir.gatk %]/GenomeAnalysisTK.jar -nt [% parallel %] \
    -T UnifiedGenotyper \
    -R [% ref_file.seq %] \
    -glm INDEL \
    -I [% item.dir %]/[% item.name %].ready.bam \
    -o [% item.dir %]/[% item.name %].indel.raw.vcf
[ $? -ne 0 ] && echo `date` [% item.name %] [gatk indel calling] failed >> [% base_dir %]/fail.log && exit 255

# indel hard filter
java -Djava.io.tmpdir=[% tmpdir %] -Xmx[% memory %]g \
    -jar [% bin_dir.gatk %]/GenomeAnalysisTK.jar \
    -T VariantFiltration \
    -R [% ref_file.seq %] \
    --variant [% item.dir %]/[% item.name %].indel.raw.vcf \
    -o [% item.dir %]/[% item.name %].indel.vcf \
    --filterExpression "QUAL<30.0" \
    --filterName "LowQual" \
    --filterExpression "SB>=-1.0" \
    --filterName "StrandBias" \
    --filterExpression "QD<1.0" \
    --filterName "QualByDepth" \
    --filterExpression "(MQ0 >= 4 && ((MQ0 / (1.0 * DP)) > 0.1))" \
    --filterName "HARD_TO_VALIDATE" \
    --filterExpression "HRun>=15" \
    --filterName "HomopolymerRun"

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
            tmpdir   => $self->tmpdir,
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
samtools mpileup -uf [% ref_file.seq %] [% item.dir %]/[% item.name %].baq.bam \
    | bcftools view -cg - \
    | vcfutils.pl vcf2fq > [% item.dir %]/[% item.name %].fq

# convert fastq to fasta
# mask bases with quality lower than 20
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
            tmpdir   => $self->tmpdir,
        },
        \$output
    ) or die Template->error;

    $self->{bash} .= $output;
    return;
}

sub vcf_to_fasta {
    my $self = shift;
    my $item = shift;

    my $tt = Template->new;

    my $text = <<'EOF';
# bam to bed
genomeCoverageBed -split -ibam [% item.dir %]/[% item.name %].ready.bam \
    -g [% ref_file.sizes %] -bg > [% item.dir %]/[% item.name %].bg.bed
[ $? -ne 0 ] && echo `date` [% item.name %] [bedtools bam to bed] failed >> [% base_dir %]/fail.log && exit 255

# uncovered region
cat [% item.dir %]/[% item.name %].bg.bed \
    | awk '($4>1)'  \
    | slopBed -i stdin -g [% ref_file.sizes %] -b 50 \
    | mergeBed \
    | complementBed  -i stdin -g [% ref_file.sizes %] \
    > [% item.dir %]/[% item.name %].1x.bed

# mask ref
maskFastaFromBed -fi  [% ref_file.seq %] \
    -bed [% item.dir %]/[% item.name %].1x.bed \
    -fo [% item.dir %]/ref.masked.fa

# index masked ref
samtools faidx [% item.dir %]/ref.masked.fa
java -jar ~/share/picard-tools-1.128/picard.jar \
    CreateSequenceDictionary \
    R=[% item.dir %]/ref.masked.fa O=[% item.dir %]/ref.masked.dict

# merge snp.vcf and indel.vcf
vcf-concat \
    [% item.dir %]/[% item.name %].snp.vcf \
    [% item.dir %]/[% item.name %].indel.vcf \
    | vcf-sort > [% item.dir %]/[% item.name %].vcf

# vcf to new fasta
java -Djava.io.tmpdir=[% tmpdir %] -Xmx[% memory %]g \
    -jar [% bin_dir.gatk %]/GenomeAnalysisTK.jar \
    -T FastaAlternateReferenceMaker \
    -R [% item.dir %]/ref.masked.fa \
    --variant [% item.dir %]/[% item.name %].vcf \
    -o [% item.dir %]/[% item.name %].vcf.fasta
[ $? -ne 0 ] && echo `date` [% item.name %] [gatk alter fasta] failed >> [% base_dir %]/fail.log && exit 255

# better fasta headers
perl -npi -e \
    'if (/^\>/) {
        if (/\s+(\w+):\d+/) {
            $_ = ">$1\n";
        }
    }' \
    [% item.dir %]/[% item.name %].vcf.fasta

rm [% item.dir %]/[% item.name %].bg.bed [% item.dir %]/ref.masked.*

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
            tmpdir   => $self->tmpdir,
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
find [% item.dir %] -type f \
    -name "*.sort.*" -o -name "*.dedup.*" \
    -o -name "*.realign.*" -o -name "*.recal.*" \
    -o -name "*.raw.*"  -o -name "*.recal" \
    -o -name "*.tranches" -o -name "*.metrics" \
    -o -name "*.csv" -o -name "*.intervals" \
    | xargs rm

echo run time is $(expr `date +%s` - $start_time) s
echo `date` [% item.name %] [all steps success] >> [% base_dir %]/fail.log

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
            tmpdir   => $self->tmpdir,
        },
        \$output
    ) or die Template->error;

    $self->{bash} .= $output;
    return;
}

sub head_trinity {
    my $self = shift;
    my $item = shift;

    my $tt = Template->new;

    my $text = <<'EOF';
#!/bin/bash
start_time=`date +%s`

cd [% base_dir %]

mkdir -p [% item.dir %];

# set stacksize to unlimited
ulimit -s unlimited

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

sub seqprep_pe {
    my $self = shift;
    my $item = shift;

    $item->{trimmed} = 1;

    my $tt = Template->new;

    my $text = <<'EOF';
# seqprep pe

[% FOREACH lane IN item.lanes -%]
# lane [% lane.srr %]

if [ ! -d [% item.dir %]/[% lane.srr %] ];
then
    mkdir [% item.dir %]/[% lane.srr %];
fi;

if [ ! -d [% item.dir %]/[% lane.srr %]/trimmed  ];
then
    mkdir [% item.dir %]/[% lane.srr %]/trimmed ;
fi;

[% bin_dir.seqprep %]/SeqPrep \
[% IF lane.fq -%]
    -f [% lane.file.0 %] \
    -r [% lane.file.1 %] \
[% ELSE -%]
    -f [% item.dir %]/[% lane.srr %]/[% lane.srr %]_1.fastq.gz \
    -r [% item.dir %]/[% lane.srr %]/[% lane.srr %]_2.fastq.gz \
[% END -%]
[% IF lane.adapters.A -%]
    -A [% lane.adapters.A %] \
    -B [% lane.adapters.B %] \
[% END -%]
    -1 [% item.dir %]/[% lane.srr %]/trimmed/1.fq.gz \
    -2 [% item.dir %]/[% lane.srr %]/trimmed/2.fq.gz \
    -3 [% item.dir %]/[% lane.srr %]/trimmed/1.discard.fq.gz \
    -4 [% item.dir %]/[% lane.srr %]/trimmed/2.discard.fq.gz \
    -E [% item.dir %]/[% lane.srr %]/trimmed/alignments_trimmed.txt.gz \
    -q 20 -L 20 \
    2>&1 | tee -a [% base_dir %]/SeqPrep.log ; ( exit ${PIPESTATUS} )

[ $? -ne 0 ] && echo `date` [% item.name %] [% lane.srr %] [seqprep] failed >> [% base_dir %]/fail.log && exit 255

cd [% item.dir %]/[% lane.srr %]/trimmed

# sickle (pair end)
sickle pe \
    -t sanger \
    -q 20 \
    -l 20 \
    -f [% item.dir %]/[% lane.srr %]/trimmed/1.fq.gz \
    -r [% item.dir %]/[% lane.srr %]/trimmed/2.fq.gz \
    -o [% item.dir %]/[% lane.srr %]/trimmed/[% lane.srr %]_1.sickle.fq \
    -p [% item.dir %]/[% lane.srr %]/trimmed/[% lane.srr %]_2.sickle.fq \
    -s [% item.dir %]/[% lane.srr %]/trimmed/[% lane.srr %]_single.sickle.fq \
    2>&1 | tee -a [% data_dir.log %]/sickle.log ; ( exit ${PIPESTATUS} )

[ $? -ne 0 ] && echo `date` [% item.name %] [% lane.srr %] [sickle] failed >> [% base_dir %]/fail.log && exit 255

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
            tmpdir   => $self->tmpdir,
        },
        \$output
    ) or die Template->error;

    $self->{bash} .= $output;
    return;
}

# All lanes should be the same, PAIRED or SINGLE
sub trinity {
    my $self = shift;
    my $item = shift;

    my $tt = Template->new;

    my $text = <<'EOF';
#----------------------------#
# trinity
#----------------------------#
# [% item.name %]

cd [% item.dir %]

perl [% bin_dir.trinity %]/Trinity --seqType fq \
    --max_memory [% memory %]G \
    --CPU [% parallel %] \
    --bypass_java_version_check \
    --min_contig_length 200 \
[% IF item.lanes.0.layout == 'PAIRED' -%]
[% IF item.sickle -%]
    --left  [% str = ''; str = str _ item.dir _ '/' _ lane.srr _ '/trimmed/' _ lane.srr _ '_1.sickle.fq.gz,' FOREACH lane IN item.lanes; str FILTER remove('\,$') -%] \
    --right [% str = ''; str = str _ item.dir _ '/' _ lane.srr _ '/trimmed/' _ lane.srr _ '_2.sickle.fq.gz,' FOREACH lane IN item.lanes; str FILTER remove('\,$') -%] \
[% ELSIF lane.fq -%]
    --left  [% lane.file.0 %] \
    --right [% lane.file.1 %] \
[% ELSE -%]
    --left  [% item.dir %]/[% lane.srr %]/[% lane.srr %]_1.fastq.gz \
    --right [% item.dir %]/[% lane.srr %]/[% lane.srr %]_2.fastq.gz \
[% END -%]
[% ELSE -%]
[% IF item.sickle -%]
    --single [% str = ''; str = str _ item.dir _ '/' _ lane.srr _ '/trimmed/' _ lane.srr _ '.sickle.fq.gz,' FOREACH lane IN item.lanes; str FILTER remove('\,$') -%] \
[% ELSIF lane.fq -%]
    --single [% lane.file.0 %] \
[% ELSE -%]
    --single [% str = ''; str = str _ item.dir _ '/' _ lane.srr _ '/' _ lane.srr _ 'fastq.gz,' FOREACH lane IN item.lanes; str FILTER remove('\,$') -%] \
[% END -%]
[% END -%]
    --output [% item.dir %]/trinity \
    2>&1 | tee -a [% data_dir.log %]/trinity.log ; ( exit ${PIPESTATUS} )

[ $? -ne 0 ] && echo `date` [% item.name %] [trinity] failed >> [% base_dir %]/fail.log && exit 255

rm -fr [% item.dir %]/trinity/chrysalis

perl [% bin_dir.trinity %]/util/TrinityStats.pl \
    [% item.dir %]/trinity/Trinity.fasta \
    > [% item.dir %]/trinity/Trinity.Stats

mkdir -p [% item.dir %]/result
cp [% item.dir %]/trinity/Trinity.fasta  [% item.dir %]/result
cp [% item.dir %]/trinity/Trinity.Stats  [% item.dir %]/result
cp [% item.dir %]/trinity/Trinity.timing [% item.dir %]/result

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
            tmpdir   => $self->tmpdir,
        },
        \$output
    ) or die Template->error;

    $self->{bash} .= $output;
    return;
}

sub trinity_rsem {
    my $self = shift;
    my $item = shift;

    my $tt = Template->new;

    my $text = <<'EOF';
#----------------------------#
# trinity rsem
#----------------------------#
# [% item.name %]

if [ ! -d [% item.dir %]/rsem  ];
then
    mkdir -p [% item.dir %]/rsem ;
fi;

cd [% item.dir %]/rsem

perl [% bin_dir.trinity %]/util/align_and_estimate_abundance.pl \
    --seqType fq \
    --thread_count [% parallel %] \
    --est_method RSEM --aln_method bowtie --trinity_mode --prep_reference \
[% IF item.lanes.0.layout == 'PAIRED' -%]
[% IF item.sickle -%]
    --left  [% str = ''; str = str _ item.dir _ '/' _ lane.srr _ '/trimmed/' _ lane.srr _ '_1.sickle.fq.gz,' FOREACH lane IN item.lanes; str FILTER remove('\,$') -%] \
    --right [% str = ''; str = str _ item.dir _ '/' _ lane.srr _ '/trimmed/' _ lane.srr _ '_2.sickle.fq.gz,' FOREACH lane IN item.lanes; str FILTER remove('\,$') -%] \
[% ELSIF lane.fq -%]
    --left  [% lane.file.0 %] \
    --right [% lane.file.1 %] \
[% ELSE -%]
    --left  [% item.dir %]/[% lane.srr %]/[% lane.srr %]_1.fastq.gz \
    --right [% item.dir %]/[% lane.srr %]/[% lane.srr %]_2.fastq.gz \
[% END -%]
[% ELSE -%]
[% IF item.sickle -%]
    --single [% str = ''; str = str _ item.dir _ '/' _ lane.srr _ '/trimmed/' _ lane.srr _ '.sickle.fq.gz,' FOREACH lane IN item.lanes; str FILTER remove('\,$') -%] \
[% ELSIF lane.fq -%]
    --single [% lane.file.0 %] \
[% ELSE -%]
    --single [% str = ''; str = str _ item.dir _ '/' _ lane.srr _ '/' _ lane.srr _ 'fastq.gz,' FOREACH lane IN item.lanes; str FILTER remove('\,$') -%] \
[% END -%]
[% END -%]
    --transcripts [% item.dir %]/trinity/Trinity.fasta \
    2>&1 | tee -a [% data_dir.log %]/trinity_rsme.log ; ( exit ${PIPESTATUS} )

[ $? -ne 0 ] && echo `date` [% item.name %] [trinity_rsem] failed >> [% base_dir %]/fail.log && exit 255

perl [% bin_dir.script %]/trinity_unigene.pl \
    -r [% item.dir %]/rsem/RSEM.isoforms.results \
    -f [% item.dir %]/trinity/Trinity.fasta \
    -o [% item.dir %]/rsem/Trinity.unigene.fasta \
    -u

perl [% bin_dir.trinity %]/util/TrinityStats.pl \
    [% item.dir %]/rsem/Trinity.unigene.fasta \
    > [% item.dir %]/rsem/Trinity.unigene.Stats

mkdir -p [% item.dir %]/result
cp [% item.dir %]/rsem/Trinity.unigene.fasta [% item.dir %]/result
cp [% item.dir %]/rsem/Trinity.unigene.Stats [% item.dir %]/result

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
            tmpdir   => $self->tmpdir,
        },
        \$output
    ) or die Template->error;

    $self->{bash} .= $output;
    return;
}

sub soap_kmerfreq {
    my $self = shift;
    my $item = shift;

    my $tt = Template->new;

    my $text = <<'EOF';
#----------------------------------------------------------#
# build Kmer frequency table
#----------------------------------------------------------#

[% FOREACH lane IN item.lanes -%]
# lane [% lane.srr %]
echo -e "[% item.dir %]/[% lane.srr %]/[% lane.srr %]_1.fastq" > [% item.dir %]/[% lane.srr %]/ReadFiles.lst
echo -e "[% item.dir %]/[% lane.srr %]/[% lane.srr %]_2.fastq" >> [% item.dir %]/[% lane.srr %]/ReadFiles.lst

[% bin_dir.soap %]/KmerFreq_AR [% item.dir %]/[% lane.srr %]/ReadFiles.lst \
    -t [% parallel %] -k 17 -c -1 -q 33 -m 1 \
    -p [% item.dir %]/[% lane.srr %]/[% lane.srr %] \
    > [% item.dir %]/[% lane.srr %]/ReadsKmerfreq.log
[ $? -ne 0 ] && echo `date` [% item.name %] [% lane.srr %] [kmer freq] failed >> [% base_dir %]/fail.log && exit 255

[% END -%]

EOF
    my $output;
    $tt->process(
        \$text,
        {   base_dir => $self->base_dir,
            item     => $item,
            bin_dir  => $self->bin_dir,
            data_dir => $self->data_dir,
            parallel => $self->parallel,
            memory   => $self->memory,
            tmpdir   => $self->tmpdir,
        },
        \$output
    ) or die Template->error;

    $self->{bash} .= $output;
    return;
}

sub soap_corrector {
    my $self = shift;
    my $item = shift;

    my $tt = Template->new;

    my $text = <<'EOF';
#----------------------------------------------------------#
# correct reads
#----------------------------------------------------------#

[% FOREACH lane IN item.lanes -%]
# lane [% lane.srr %]

[% bin_dir.soap %]/Corrector_AR \
    [% item.dir %]/[% lane.srr %]/[% lane.srr %].freq.cz \
    [% item.dir %]/[% lane.srr %]/[% lane.srr %].freq.cz.len \
    [% item.dir %]/[% lane.srr %]/ReadFiles.lst \
    -t [% parallel %] -k 17 -l 3 -a 0 -e 1 -w 0 -Q 33 -q 30 -x 8 -o 1 \
    > [% item.dir %]/[% lane.srr %]/Reads_Correct.log \
    2> [% item.dir %]/[% lane.srr %]/Reads_Correct.err
[ $? -ne 0 ] && echo `date` [% item.name %] [% lane.srr %] [correct reads] failed >> [% base_dir %]/fail.log && exit 255

[% END -%]

EOF
    my $output;
    $tt->process(
        \$text,
        {   base_dir => $self->base_dir,
            item     => $item,
            bin_dir  => $self->bin_dir,
            data_dir => $self->data_dir,
            parallel => $self->parallel,
            memory   => $self->memory,
            tmpdir   => $self->tmpdir,
        },
        \$output
    ) or die Template->error;

    $self->{bash} .= $output;
    return;
}

sub soap_denovo {
    my $self = shift;
    my $item = shift;

    my $tt = Template->new;

    my $text = <<'EOF';
#----------------------------------------------------------#
# assemble reads
#----------------------------------------------------------#

#----------------------------#
# config file
#----------------------------#
echo -e "max_rd_len=100\n" > [% item.dir %]/Lib.cfg

[% FOREACH lane IN item.lanes -%]
# lane [% lane.srr %]
echo -e "[LIB]\navg_ins=[% lane.ilegnth %]"                       >> [% item.dir %]/Lib.cfg
echo -e "asm_flags=3\nreverse_seq=0\nrank=1"                      >> [% item.dir %]/Lib.cfg
echo -e "q1=[% item.dir %]/[% lane.srr %]/[% lane.srr %]_1.fastq" >> [% item.dir %]/Lib.cfg
echo -e "q2=[% item.dir %]/[% lane.srr %]/[% lane.srr %]_2.fastq" >> [% item.dir %]/Lib.cfg

[% END -%]

#----------------------------#
# SOAPdenovo
#----------------------------#
[% bin_dir.soap %]/SOAPdenovo-63mer all \
    -s [% item.dir %]/Lib.cfg \
    -p [% parallel %] -d 1 -F -K 31 -R \
    -o [% item.dir %]/[% item.name %] \
    >  [% item.dir %]/asm.log \
    2> [% item.dir %]/asm.err
[ $? -ne 0 ] && echo `date` [% item.name %] [% lane.srr %] [assemble reads] failed >> [% base_dir %]/fail.log && exit 255

#----------------------------#
# GapCloser
#----------------------------#
cp [% item.dir %]/Lib.cfg [% item.dir %]/GapCloser.cfg

[% bin_dir.soap %]/GapCloser \
    -a [% item.dir %]/[% item.name %].scafSeq \
    -b [% item.dir %]/GapCloser.cfg \
    -t [% parallel %] -l 100 -p 31 \
    -o [% item.dir %]/[% item.name %].scafSeq.GC.fa \
    > [% item.dir %]/GapCloser.log
[ $? -ne 0 ] && echo `date` [% item.name %] [% lane.srr %] [GapCloser] failed >> [% base_dir %]/fail.log && exit 255

EOF
    my $output;
    $tt->process(
        \$text,
        {   base_dir => $self->base_dir,
            item     => $item,
            bin_dir  => $self->bin_dir,
            data_dir => $self->data_dir,
            parallel => $self->parallel,
            memory   => $self->memory,
            tmpdir   => $self->tmpdir,
        },
        \$output
    ) or die Template->error;

    $self->{bash} .= $output;
    return;
}

sub screen_sra {
    my $self = shift;
    my $data = shift;

    my $tt = Template->new;

    my $text = <<'EOF';
#----------------------------#
# Quality assessment & improvement
#----------------------------#
[% FOREACH item IN data -%]
# [% item.name %]
cd [% data_dir.log %]
screen -L -dmS sra_[% item.name %] bash [% data_dir.bash %]/sra.[% item.name %].sh

[% END -%]

#----------------------------#
# Monitoring
#----------------------------#
cd [% base_dir %]

### Quit a session
# screen -S sra_ -X quit

### Kill all sessions started with sra_
# screen -ls | grep Detached | sort | grep sra_ | perl -nl -e '/^\s+(\d+)/ and system qq{screen -S $1 -X quit}'

### Count running sessions
# screen -ls | grep Detached | sort | grep -v pts- | wc -l

### What's done
# find [% data_dir.sra %]  -type f -regextype posix-extended -regex ".*\/[DES]RR.*" | sort | wc -l
# find [% data_dir.proc %] -type f -name "*fastq.gz" | sort | wc -l
# find [% data_dir.proc %] -type f -name "*_[12].fastq.gz" | sort | wc -l
# find [% data_dir.proc %] -type f -name "*_fastqc.zip" | sort | grep -v trimmed | wc -l
# find [% data_dir.proc %] -type f -name "*_[12]_fastqc.zip" | sort | grep -v trimmed | wc -l
#
# find [% data_dir.proc %] -type f -name "*scythe.fq.gz" | sort | grep trimmed | wc -l
# find [% data_dir.proc %] -type f -name "*sickle.fq.gz" | sort | grep trimmed | wc -l
# find [% data_dir.proc %] -type f -name "*fq_fastqc.zip" | sort | grep trimmed | wc -l

### total size
# find [% data_dir.sra %]  -type f -regextype posix-extended -regex ".*\/[DES]RR.*" | perl -nl -MNumber::Format -e '$sum += (stat($_))[7]; END{print Number::Format::format_bytes($sum)}'
# find [% data_dir.proc %] -type f -name "*fastq.gz" | perl -nl -MNumber::Format -e '$sum += (stat($_))[7]; END{print Number::Format::format_bytes($sum)}'
# find [% data_dir.proc %] -type f -name "*sickle.fq.gz" | perl -nl -MNumber::Format -e '$sum += (stat($_))[7]; END{print Number::Format::format_bytes($sum)}'

### Clean
# find [% data_dir.proc %] -type d -name "*fastqc" | sort | xargs rm -fr
# find [% data_dir.proc %] -type f -name "*fastqc.zip" | sort | xargs rm
# find [% data_dir.proc %] -type f -name "*fastq.gz" | sort | grep -v trimmed | xargs rm
# find [% data_dir.proc %] -type f -name "*matches.txt" | sort | xargs rm

EOF
    my $output;
    $tt->process(
        \$text,
        {   base_dir => $self->base_dir,
            data     => $data,
            bin_dir  => $self->bin_dir,
            data_dir => $self->data_dir,
            parallel => $self->parallel,
            memory   => $self->memory,
        },
        \$output
    ) or die Template->error;

    $self->{bash} .= $output;
    return;
}

sub screen_bwa {
    my $self = shift;
    my $data = shift;

    my $tt = Template->new;

    my $text = <<'EOF';
#----------------------------#
# bwa
#----------------------------#
[% FOREACH item IN data -%]
# [% item.name %]
cd [% data_dir.log %]
screen -L -dmS bwa_[% item.name %] bash [% data_dir.bash %]/bwa.[% item.name %].sh

[% END -%]

#----------------------------#
# Monitoring
#----------------------------#
cd [% base_dir %]

### Quit a session
# screen -S bwa_ -X quit

### Kill all sessions started with bwa_
# screen -ls | grep Detached | sort | grep bwa_ | perl -nl -e '/^\s+(\d+)/ and system qq{screen -S $1 -X quit}'

EOF
    my $output;
    $tt->process(
        \$text,
        {   base_dir => $self->base_dir,
            data     => $data,
            bin_dir  => $self->bin_dir,
            data_dir => $self->data_dir,
            parallel => $self->parallel,
            memory   => $self->memory,
        },
        \$output
    ) or die Template->error;

    $self->{bash} .= $output;
    return;
}

sub screen_trinity {
    my $self = shift;
    my $data = shift;

    my $tt = Template->new;

    my $text = <<'EOF';
#----------------------------#
# trinity
#----------------------------#
[% FOREACH item IN data -%]
# [% item.name %]
cd [% data_dir.log %]
screen -L -dmS tri_[% item.name %] bash [% data_dir.bash %]/tri.[% item.name %].sh

[% END -%]

#----------------------------#
# Monitoring
#----------------------------#
cd [% base_dir %]

### Quit a session
# screen -S tri_ -X quit

### Kill all sessions started with tri_
# screen -ls | grep Detached | sort | grep tri_ | perl -nl -e '/^\s+(\d+)/ and system qq{screen -S $1 -X quit}'

### Clean
# find [% data_dir.proc %] -type f -name "*sickle.fq" | sort | grep trimmed | xargs rm
# find [% data_dir.proc %] -type f -name "*jellyfish*" | sort | grep trinity | xargs rm
# find [% data_dir.proc %] -type f -name "*both.fa" | sort | grep trinity | xargs rm
# find [% data_dir.proc %] -type f -name "*single.fa" | sort | grep trinity | xargs rm
# find [% data_dir.proc %] -type d -name "read_partitions" | sort | grep trinity | xargs rm -fr

# find [% data_dir.proc %] -type f -name "*bowtie.bam*" | sort | grep rsem | xargs rm

EOF
    my $output;
    $tt->process(
        \$text,
        {   base_dir => $self->base_dir,
            data     => $data,
            bin_dir  => $self->bin_dir,
            data_dir => $self->data_dir,
            parallel => $self->parallel,
            memory   => $self->memory,
        },
        \$output
    ) or die Template->error;

    $self->{bash} .= $output;
    return;
}

1;
