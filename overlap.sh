#!/usr/bin/env bash

USAGE="Usage: $0 FASTA_FILE OVLP_LEN OVLP_IDT OUT_NAME"

if [ "$#" -lt 3 ]; then
    echo >&2 "$USAGE"
    exit 1
fi

#----------------------------#
# Colors in term
#----------------------------#
# http://stackoverflow.com/questions/5947742/how-to-change-the-output-color-of-echo-in-linux
GREEN=
RED=
NC=
if tty -s < /dev/fd/1 2> /dev/null; then
    GREEN='\033[0;32m'
    RED='\033[0;31m'
    NC='\033[0m' # No Color
fi

log_warn () {
    echo >&2 -e "${RED}==> $@ <==${NC}"
}

log_info () {
    echo >&2 -e "${GREEN}==> $@${NC}"
}

log_debug () {
    echo >&2 -e "==> $@"
}

#----------------------------#
# Parameters
#----------------------------#
FASTA_FILE=$1
OVLP_LEN=${2:-500}
OVLP_IDT=${3:-.99}
OUT_NAME=${4:-ovlp.tsv}

[ -e ${FASTA_FILE} ] || {
    log_warn "Can't find [${FASTA_FILE}].";
    exit 1;
}

#----------------------------#
# Run
#----------------------------#
# create tmp dir
MY_TMP_DIR=`mktemp -d 2>/dev/null || mktemp -d -t 'mytmpdir'`

log_info "Temp dir: ${MY_TMP_DIR}"

log_info "Sort by lengths"
faops order ${FASTA_FILE} \
    <(faops size ${FASTA_FILE} | sort -n -r -k2,2 | cut -f 1) \
    ${MY_TMP_DIR}/original.fasta

log_info "Preprocess reads to format them for dazzler"
pushd ${MY_TMP_DIR}

if [ -e stdin.* ]; then
    rm stdin.*
fi
cat original.fasta | perl ~/Scripts/sra/falcon_name_fasta.pl -i stdin
cat stdin.outfile \
    | faops filter -l 0 stdin renamed.fasta
rm stdin.outfile

log_info "Make the dazzler DB"
DBrm myDB
fasta2DB myDB renamed.fasta
DBdust myDB
# each block is of size 50 MB
DBsplit -s50 myDB
BLOCK_NUMBER=$(cat myDB.db | perl -nl -e '/^blocks\s+=\s+(\d+)/ and print $1')

log_info "Run daligner"
if [ -e myDB.las ]; then
    rm myDB.las
fi
if [ -e myDB.*.las ]; then
    rm myDB.*.las
fi

HPC.daligner myDB -v -M16 -T8 -e${OVLP_IDT} -l${OVLP_LEN} -s${OVLP_LEN} -mdust > job.sh
bash job.sh
if [ -e myDB.1.las ]; then
    LAcat -v myDB.#.las > myDB.las
fi

# If the -o option is set then only alignments that are *proper overlaps*
# (a sequence end occurs at the each end of the alignment) are displayed.
LAshow -o myDB.db myDB.las > show.txt

perl ~/Scripts/sra/las2ovlp.pl renamed.fasta show.txt -r stdin.replace.tsv > ovlp.tsv

log_info "Create outputs"
popd
mv ${MY_TMP_DIR}/ovlp.tsv ${OUT_NAME}

# clean tmp dir
rm -fr ${MY_TMP_DIR}
