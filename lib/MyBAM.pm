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
has tmpdir   => ( is => 'rw', isa => 'Str', default => "/tmp", );

has bash => ( is => 'ro', isa => 'Str' );

sub BUILD {
    my $self = shift;

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

cd [% base_dir %]

### index reference genome
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
            tmpdir   => $self->tmpdir,
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
mkdir [% item.dir %]/[% lane.srr %]

echo "* Start srr_dump [[% item.name %]] [[% lane.srr %]] `date`" | tee -a [% data_dir.log %]/srr_dump.log

[% IF lane.layout == 'PAIRED' -%]
# sra to fastq (pair end)
fastq-dump [% lane.file %] \
    --split-files --gzip -O [% item.dir %]/[% lane.srr %] \
[% ELSE -%]
# sra to fastq (single end)
fastq-dump [% lane.file %] \
    --gzip -O [% item.dir %]/[% lane.srr %] \
[% END -%]
    2>&1 | tee -a [% data_dir.log %]/srr_dump.log ; ( exit ${PIPESTATUS} )

[ $? -ne 0 ] && echo `date` [% item.name %] [% lane.srr %] [fastq dump] failed >> [% base_dir %]/fail.log && exit 255
echo "* End srr_dump [[% item.name %]] [[% lane.srr %]] `date`" | tee -a [% data_dir.log %]/srr_dump.log

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

sub srr_dump_parallel {
    my $self = shift;
    my $item = shift;

    my $tt = Template->new;

    my $text = <<'EOF';
#----------------------------#
# srr dump (parallel)
#----------------------------#

# make dir for each lanes
[% FOREACH lane IN item.lanes -%]
mkdir [% item.dir %]/[% lane.srr %]
[% END -%]

# sra to fastq (pair end)
echo -e '[% FOREACH lane IN item.lanes %][% IF lane.layout == 'PAIRED' %][% lane.srr %]\t[% lane.file %]\n[% END %][% END %]' \
    | grep '.' \
    | parallel --jobs [% parallel %] --keep-order --colsep '\t' \
        'echo "* Start srr_dump [[% item.name %]] [{1}] `date`"; [% bin_dir.stk %]/fastq-dump {2} --split-files --gzip -O [% item.dir %]/{1}; echo "* End srr_dump [[% item.name %]] [{1}] `date`";' \
    2>&1 | tee -a [% data_dir.log %]/srr_dump.log

# sra to fastq (single end)
echo -e '[% FOREACH lane IN item.lanes %][% IF lane.layout == 'SINGLE' %][% lane.srr %]\t[% lane.file %]\n[% END %][% END %]' \
    | grep '.' \
    | parallel --jobs [% parallel %] --keep-order --colsep '\t' \
        'echo "* Start srr_dump [[% item.name %]] [{1}] `date`"; [% bin_dir.stk %]/fastq-dump {2} --gzip -O [% item.dir %]/{1}; echo "* End srr_dump [[% item.name %]] [{1}] `date`";' \
    2>&1 | tee -a [% data_dir.log %]/srr_dump.log

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
# scythe
#----------------------------#
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

cd [% item.dir %]/[% lane.srr %]/trimmed

echo "* Start scythe [[% item.name %]] [[% lane.srr %]] `date`" | tee -a [% data_dir.log %]/scythe.log

[% IF lane.layout == 'PAIRED' -%]
# scythe (pair end)
scythe \
    [% item.dir %]/[% lane.srr %]/[% lane.srr %]_1.fastq.gz \
    -q sanger \
    -M 20 \
    -a [% ref_file.adapters %] \
    -m [% item.dir %]/[% lane.srr %]/trimmed/[% lane.srr %]_1.matches.txt \
    --quiet \
    | gzip -c --fast > [% item.dir %]/[% lane.srr %]/trimmed/[% lane.srr %]_1.scythe.fq.gz

scythe \
    [% item.dir %]/[% lane.srr %]/[% lane.srr %]_2.fastq.gz \
    -q sanger \
    -M 20 \
    -a [% ref_file.adapters %] \
    -m [% item.dir %]/[% lane.srr %]/trimmed/[% lane.srr %]_2.matches.txt \
    --quiet \
    | gzip -c --fast > [% item.dir %]/[% lane.srr %]/trimmed/[% lane.srr %]_2.scythe.fq.gz

[% ELSE -%]
# scythe (single end)
scythe \
    [% item.dir %]/[% lane.srr %]/[% lane.srr %].fastq.gz \
    -q sanger \
    -M 20 \
    -a [% ref_file.adapters %] \
    -m [% item.dir %]/[% lane.srr %]/trimmed/[% lane.srr %].matches.txt \
    --quiet \
    | gzip -c --fast > [% item.dir %]/[% lane.srr %]/trimmed/[% lane.srr %].scythe.fq.gz

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
    -t sanger -l 20 -q 20 \
    -f [% item.dir %]/[% lane.srr %]/trimmed/[% lane.srr %]_1.scythe.fq.gz \
    -r [% item.dir %]/[% lane.srr %]/trimmed/[% lane.srr %]_2.scythe.fq.gz \
    -o [% item.dir %]/[% lane.srr %]/trimmed/[% lane.srr %]_1.sickle.fq \
    -p [% item.dir %]/[% lane.srr %]/trimmed/[% lane.srr %]_2.sickle.fq \
    -s [% item.dir %]/[% lane.srr %]/trimmed/[% lane.srr %]_single.sickle.fq \
    2>&1 | tee -a [% data_dir.log %]/sickle.log ; ( exit ${PIPESTATUS} )

[% ELSE -%]
# sickle (single end)
sickle se \
    -t sanger -l 20 -q 20 \
    -f [% item.dir %]/[% lane.srr %]/trimmed/[% lane.srr %].scythe.fq.gz \
    -o [% item.dir %]/[% lane.srr %]/trimmed/[% lane.srr %].sickle.fq
    2>&1 | tee -a [% data_dir.log %]/sickle.log ; ( exit ${PIPESTATUS} )

[% END -%]

[ $? -ne 0 ] && echo `date` [% item.name %] [% lane.srr %] [sickle] failed >> [% base_dir %]/fail.log && exit 255
echo "* End sickle [[% item.name %]] [[% lane.srr %]] `date`" | tee -a [% data_dir.log %]/sickle.log

find [% item.dir %]/[% lane.srr %]/trimmed/ -type f -name "*.sickle.fq" | parallel -j [% parallel %] gzip -f
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
[% bin_dir.tophat %]/tophat -p [% parallel %] \
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
[% bin_dir.tophat %]/tophat -p [% parallel %] \
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
[% bin_dir.cuff %]/cufflinks -p [% parallel %] \
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

[% bin_dir.cuff %]/cuffmerge -p [% parallel %] \
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

[% bin_dir.cuff %]/cuffdiff -p [% parallel %] \
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

[% bin_dir.cuff %]/cuffdiff -p [% parallel %] \
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

[% bin_dir.cuff %]/cuffnorm -p [% parallel %] \
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
[% bin_dir.cuff %]/cuffquant -p [% parallel %] \
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

sub sam_dump_pe {
    my $self = shift;
    my $item = shift;

    my $tt = Template->new;

    my $text = <<'EOF';
[% FOREACH lane IN item.lanes -%]
# lane [% lane.srr %]
mkdir [% item.dir %]/[% lane.srr %]

# sra to fastq (pair end)
java -Djava.io.tmpdir=[% tmpdir %] -Xmx[% memory %]g \
    -jar [% bin_dir.pcd %]/SamToFastq.jar \
    INPUT=[% lane.file %] \
    FASTQ=[% item.dir %]/[% lane.srr %]/[% lane.srr %]_1.fastq \
    SECOND_END_FASTQ=[% item.dir %]/[% lane.srr %]/[% lane.srr %]_2.fastq \
    VALIDATION_STRINGENCY=LENIENT

[ $? -ne 0 ] && echo `date` [% item.name %] [% lane.srr %] [fastq dump] failed >> [% base_dir %]/fail.log && exit 255

gzip [% item.dir %]/[% lane.srr %]/[% lane.srr %]_1.fastq
gzip [% item.dir %]/[% lane.srr %]/[% lane.srr %]_2.fastq

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

# convert sam to bam
samtools view -uS [% item.dir %]/[% lane.srr %]/[% lane.srr %].sam.gz \
    | samtools sort - [% item.dir %]/[% lane.srr %]/[% lane.srr %].tmp1
rm [% item.dir %]/[% lane.srr %]/[% lane.srr %].sam.gz
samtools fixmate [% item.dir %]/[% lane.srr %]/[% lane.srr %].tmp1.bam - \
    | samtools sort - [% item.dir %]/[% lane.srr %]/[% lane.srr %]
rm [% item.dir %]/[% lane.srr %]/[% lane.srr %].tmp1.bam

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

sub bwa_aln_pe_picard {
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
            tmpdir   => $self->tmpdir,
        },
        \$output
    ) or die Template->error;

    $self->{bash} .= $output;
    return;
}

sub merge_bam_picard {
    my $self = shift;
    my $item = shift;

    my $tt = Template->new;

    my $text = <<'EOF';
[% IF item.lanes.size > 1 -%]
# merge with picard
java -Djava.io.tmpdir=[% tmpdir %] -Xmx[% memory %]g \
    -jar [% bin_dir.pcd %]/MergeSamFiles.jar \
[% FOREACH lane IN item.lanes -%]
    INPUT=[% lane.file %] \
[% END -%]
    OUTPUT=[% item.dir %]/[% item.name %].sort.bam \
    VALIDATION_STRINGENCY=LENIENT \
    SORT_ORDER=coordinate \
    USE_THREADING=True

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
            tmpdir   => $self->tmpdir,
        },
        \$output
    ) or die Template->error;

    $self->{bash} .= $output;
    return;
}

sub merge_exist_bam_picard {
    my $self = shift;
    my $item = shift;

    my $tt = Template->new;

    my $text = <<'EOF';
[% IF item.lanes.size > 1 -%]
# merge with picard
java -Djava.io.tmpdir=[% tmpdir %] -Xmx[% memory %]g \
    -jar [% bin_dir.pcd %]/MergeSamFiles.jar \
[% FOREACH lane IN item.lanes -%]
    INPUT=[% lane.file %] \
[% END -%]
    OUTPUT=[% item.dir %]/[% item.name %].sort.bam \
    VALIDATION_STRINGENCY=LENIENT \
    SORT_ORDER=coordinate \
    USE_THREADING=True

[% ELSE -%]
# rename bam
cp [% lane.file %] [% item.dir %]/[% item.name %].sort.bam

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
            tmpdir   => $self->tmpdir,
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
java -Djava.io.tmpdir=[% tmpdir %] -Xmx[% memory %]g \
    -jar [% bin_dir.gatk %]/GenomeAnalysisTK.jar -nt [% parallel %] \
    -T RealignerTargetCreator \
    -R [% ref_file.seq %] \
    -I [% item.dir %]/[% item.name %].sort.bam  \
    --out [% item.dir %]/[% item.name %].intervals
[ $? -ne 0 ] && echo `date` [% item.name %] [gatk target] failed >> [% base_dir %]/fail.log && exit 255

# realign bam to get better Indel calling
java -Djava.io.tmpdir=[% tmpdir %] -Xmx[% memory %]g \
    -jar [% bin_dir.gatk %]/GenomeAnalysisTK.jar \
    -T IndelRealigner \
    -R [% ref_file.seq %] \
    -I [% item.dir %]/[% item.name %].sort.bam \
    -targetIntervals [% item.dir %]/[% item.name %].intervals \
    --out [% item.dir %]/[% item.name %].realign.bam
[ $? -ne 0 ] && echo `date` [% item.name %] [gatk realign] failed >> [% base_dir %]/fail.log && exit 255
rm [% item.dir %]/[% item.name %].sort.bam

# dup marking
java -Djava.io.tmpdir=[% tmpdir %] -Xmx[% memory %]g \
    -jar [% bin_dir.pcd %]/MarkDuplicates.jar \
    INPUT=[% item.dir %]/[% item.name %].realign.bam \
    OUTPUT=[% item.dir %]/[% item.name %].dedup.bam \
    METRICS_FILE=[% item.dir %]/output.metrics \
    ASSUME_SORTED=true \
    REMOVE_DUPLICATES=true \
    VALIDATION_STRINGENCY=LENIENT
[ $? -ne 0 ] && echo `date` [% item.name %] [picard dedup] failed >> [% base_dir %]/fail.log && exit 255
rm [% item.dir %]/[% item.name %].realign.bam

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
            tmpdir   => $self->tmpdir,
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
java -Djava.io.tmpdir=[% tmpdir %] -Xmx[% memory %]g \
    -jar [% bin_dir.gatk %]/GenomeAnalysisTK.jar -nt [% parallel %] \
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
java -Djava.io.tmpdir=[% tmpdir %] -Xmx[% memory %]g \
    -jar [% bin_dir.gatk %]/GenomeAnalysisTK.jar \
    -T TableRecalibration  \
    -R [% ref_file.seq %] \
    -I [% item.dir %]/[% item.name %].dedup.bam \
    -o [% item.dir %]/[% item.name %].recal.bam \
    -baq RECALCULATE \
    -recalFile [% item.dir %]/recal_data.csv
[ $? -ne 0 ] && echo `date` [% item.name %] [gatk recal] failed >> [% base_dir %]/fail.log && exit 255
rm [% item.dir %]/[% item.name %].dedup.bam

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

sub calmd_baq {
    my $self = shift;
    my $item = shift;

    my $tt = Template->new;

    my $text = <<'EOF';
# BAQ
if [ -e [% item.dir %]/[% item.name %].recal.bam ];
then
    samtools calmd -Abr [% item.dir %]/[% item.name %].recal.bam [% ref_file.seq %] > [% item.dir %]/[% item.name %].baq.bam;
else
    samtools calmd -Abr [% item.dir %]/[% item.name %].dedup.bam [% ref_file.seq %] > [% item.dir %]/[% item.name %].baq.bam;
fi;
[ $? -ne 0 ] && echo `date` [% item.name %] [samtools BAQ] failed >> [% base_dir %]/fail.log && exit 255

if [ -e [% item.dir %]/[% item.name %].recal.bam ];
then
    rm [% item.dir %]/[% item.name %].recal.bam;
else
    rm [% item.dir %]/[% item.name %].dedup.bam;
fi;

samtools index [% item.dir %]/[% item.name %].baq.bam

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

sub call_snp_recal {
    my $self = shift;
    my $item = shift;

    my $tt = Template->new;

    my $text = <<'EOF';
## call snp and skip indel calling by -I
#samtools  mpileup -I -ugf [% ref_file.seq %] [% item.dir %]/[% item.name %].baq.bam \
#    | bcftools view -vc - > [% item.dir %]/[% item.name %].snp.vcf

# snp calling
java -Djava.io.tmpdir=[% tmpdir %] -Xmx[% memory %]g \
    -jar [% bin_dir.gatk %]/GenomeAnalysisTK.jar -nt [% parallel %] \
    -T UnifiedGenotyper \
    -R [% ref_file.seq %] \
    -glm SNP \
    -I [% item.dir %]/[% item.name %].baq.bam \
    -o [% item.dir %]/[% item.name %].snp.raw.vcf \
    -A AlleleBalance \
    -A DepthOfCoverage \
    -A FisherStrand
[ $? -ne 0 ] && echo `date` [% item.name %] [gatk snp calling] failed >> [% base_dir %]/fail.log && exit 255

# snp recal
java -Djava.io.tmpdir=[% tmpdir %] -Xmx[% memory %]g \
    -jar [% bin_dir.gatk %]/GenomeAnalysisTK.jar -nt [% parallel %] \
    -T VariantRecalibrator \
    -R [% ref_file.seq %] \
    -input [% item.dir %]/[% item.name %].snp.raw.vcf \
    -resource:ensembl,known=true,training=true,truth=true,prior=6.0 [% ref_file.vcf %] \
    -an QD -an HaplotypeScore -an MQRankSum -an ReadPosRankSum -an MQ \
    -recalFile [% item.dir %]/[% item.name %].snp.recal \
    -tranchesFile [% item.dir %]/[% item.name %].snp.tranches \
    -rscriptFile [% item.dir %]/[% item.name %].snp.plots.R

# apply snp recal
java -Djava.io.tmpdir=[% tmpdir %] -Xmx[% memory %]g \
    -jar [% bin_dir.gatk %]/GenomeAnalysisTK.jar \
    -T ApplyRecalibration \
    -R [% ref_file.seq %] \
    -input [% item.dir %]/[% item.name %].snp.raw.vcf \
    --ts_filter_level 99.0 \
    -tranchesFile [% item.dir %]/[% item.name %].snp.tranches \
    -recalFile [% item.dir %]/[% item.name %].snp.recal \
    -o [% item.dir %]/[% item.name %].snp.vcf

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
## call snp and skip indel calling by -I
#samtools  mpileup -I -ugf [% ref_file.seq %] [% item.dir %]/[% item.name %].baq.bam \
#    | bcftools view -vc - > [% item.dir %]/[% item.name %].snp.vcf

# snp calling
java -Djava.io.tmpdir=[% tmpdir %] -Xmx[% memory %]g \
    -jar [% bin_dir.gatk %]/GenomeAnalysisTK.jar -nt [% parallel %] \
    -T UnifiedGenotyper \
    -R [% ref_file.seq %] \
    -glm SNP \
    -I [% item.dir %]/[% item.name %].baq.bam \
    -o [% item.dir %]/[% item.name %].snp.raw.vcf \
    -A AlleleBalance \
    -A DepthOfCoverage \
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
    -I [% item.dir %]/[% item.name %].baq.bam \
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
genomeCoverageBed -split -ibam [% item.dir %]/[% item.name %].baq.bam \
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

# vcf to new fasta
java -Djava.io.tmpdir=[% tmpdir %] -Xmx[% memory %]g \
    -jar [% bin_dir.gatk %]/GenomeAnalysisTK.jar \
    -T FastaAlternateReferenceMaker \
    -R [% item.dir %]/ref.masked.fa \
    --variant [% item.dir %]/[% item.name %].indel.vcf \
    --variant [% item.dir %]/[% item.name %].snp.vcf \
    -o [% item.dir %]/[% item.name %].vcf.fasta
[ $? -ne 0 ] && echo `date` [% item.name %] [gatk alter fasta] failed >> [% base_dir %]/fail.log && exit 255

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

if [ ! -d [% item.dir %] ];
then
    mkdir [% item.dir %];
fi;

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
# item [% item.name %]

cd [% item.dir %]/[% lane.srr %]

perl [% bin_dir.trinity %]/Trinity --seqType fq \
    --max_memory [% memory %]G \
    --CPU [% parallel %] \
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
    --output [% item.dir %]/[% lane.srr %]/trinity \
    2>&1 | tee -a [% data_dir.log %]/trinity.log ; ( exit ${PIPESTATUS} )
    
[ $? -ne 0 ] && echo `date` [% item.name %] [% lane.srr %] [trinity] failed >> [% base_dir %]/fail.log && exit 255

rm -fr [% item.dir %]/[% lane.srr %]/chrysalis

perl [% bin_dir.trinity %]/util/TrinityStats.pl \
    [% item.dir %]/[% lane.srr %]/Trinity.fasta \
    > [% item.dir %]/[% lane.srr %]/Trinity.Stats

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
# item [% item.name %]

if [ ! -d [% item.dir %]/[% lane.srr %]/rsem  ];
then
    mkdir [% item.dir %]/[% lane.srr %]/rsem ;
fi;

cd [% item.dir %]/[% lane.srr %]/rsem

perl [% bin_dir.trinity %]/util/deprecated/RSEM_util/run_RSEM_align_n_estimate.pl \
    --seqType fq \
    --thread_count [% parallel %] \
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
    --transcripts [% item.dir %]/[% lane.srr %]/Trinity.fasta \
    2>&1 | tee -a [% data_dir.log %]/trinity_rsme.log ; ( exit ${PIPESTATUS} )

[ $? -ne 0 ] && echo `date` [% item.name %] [% lane.srr %] [trinity_rsem] failed >> [% base_dir %]/fail.log && exit 255

perl [% bin_dir.script %]/trinity_unigene.pl \
    -r [% item.dir %]/[% lane.srr %]/rsem/RSEM.isoforms.results \
    -f [% item.dir %]/[% lane.srr %]/Trinity.fasta \
    -o [% item.dir %]/[% lane.srr %]/rsem/Trinity.unigene.fasta \
    -u 

perl [% bin_dir.trinity %]/util/TrinityStats.pl \
    [% item.dir %]/[% lane.srr %]/rsem/Trinity.unigene.fasta \
    > [% item.dir %]/[% lane.srr %]/rsem/Trinity.unigene.Stats

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

sub soap_head {
    my $self = shift;
    my $item = shift;

    my $tt = Template->new;

    my $text = <<'EOF';
#!/bin/bash
start_time=`date +%s`

cd [% base_dir %]

if [ ! -d [% item.dir %] ];
then
    mkdir [% item.dir %];
fi;

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

sub soap_srr_dump_pe {
    my $self = shift;
    my $item = shift;

    my $tt = Template->new;

    my $text = <<'EOF';
#----------------------------------------------------------#
# srr dump
#----------------------------------------------------------#
    
[% FOREACH lane IN item.lanes -%]
# lane [% lane.srr %]
mkdir [% item.dir %]/[% lane.srr %]

# sra to fastq (pair end)
[% bin_dir.stk %]/fastq-dump [% lane.file %] \
    --split-files -O [% item.dir %]/[% lane.srr %]
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

1;
