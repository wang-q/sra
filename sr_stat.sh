#!/usr/bin/env bash

USAGE="Usage: $0 STAT_TASK(1|2|3|4) RESULT_DIR(header) [GENOME_SIZE]"

if [ "$#" -lt 1 ]; then
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
# External dependencies
#----------------------------#
hash faops 2>/dev/null || {
    echo >&2 "faops is required but it's not installed.";
    echo >&2 "Install with homebrew: brew install wang-q/tap/faops";
    exit 1;
}

perl -MNumber::Format -e "1" 2>/dev/null || {
    echo >&2 "Number::Format is required but it's not installed.";
    echo >&2 "Install with cpanm: cpanm Number::Format";
    exit 1;
}

#----------------------------#
# Parameters
#----------------------------#
STAT_TASK=$1
RESULT_DIR=$2
GENOME_SIZE=$3

#----------------------------#
# Run
#----------------------------#
if [ "${STAT_TASK}" = "1" ]; then
    if [ "${RESULT_DIR}" = "header" ]; then
        printf "| %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | \n" \
            "Name" "fqSize" "faSize" "Length" "Kmer" "EstG" "#reads" "RunTime" "SumSR" "SR/EstG"
        printf "|:--|--:|--:|--:|--:|--:|--:|--:|--:|--:|\n"
    elif [ -e "${RESULT_DIR}/environment.sh" ]; then
        log_debug "${RESULT_DIR}"
        cd "${RESULT_DIR}"

        SECS=$(expr $(stat -c %Y environment.sh) - $(stat -c %Y assemble.sh))
        EST_G=$( cat environment.sh \
            | perl -n -e '/ESTIMATED_GENOME_SIZE=\"(\d+)\"/ and print $1' )
        SUM_SR=$( faops n50 -H -N 0 -S work1/superReadSequences.fasta)

        printf "| %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | \n" \
            $( basename $( pwd ) ) \
            $( if [[ -e pe.renamed.fastq ]]; then \
                    du -h pe.renamed.fastq | cut -f1; \
                else echo 0; \
                fi ) \
            $( du -h pe.cor.fa | cut -f1 ) \
            $( cat environment.sh \
                | perl -n -e '/PE_AVG_READ_LENGTH=\"(\d+)\"/ and print $1' ) \
            $( cat environment.sh \
                | perl -n -e '/KMER=\"(\d+)\"/ and print $1' ) \
            ${EST_G} \
            $( cat environment.sh \
                | perl -n -e '/TOTAL_READS=\"(\d+)\"/ and print $1' ) \
            $( printf "%d:%02d'%02d''\n" $((${SECS}/3600)) $((${SECS}%3600/60)) $((${SECS}%60)) ) \
            ${SUM_SR} \
            $( perl -e "printf qq{%.2f}, ${SUM_SR} * 1.0 / ${EST_G}" )
    else
        log_warn "RESULT_DIR not exists"
    fi

elif [ "${STAT_TASK}" = "2" ]; then
    if [ "${RESULT_DIR}" = "header" ]; then
        printf "| %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | \n" \
            "Name" \
            "TotalFq" "TotalFa" "RatioDiscard" "TotalSubs" "RatioSubs" \
            "RealG" "CovFq" "CovFa" \
            "EstG" "SumSR" "Est/Real" "SumSR/Real" "N50SR"
        printf "|:--|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|\n"
    elif [ "${GENOME_SIZE}" -ne "${GENOME_SIZE}" ]; then
        log_warn "Need a integer for GENOME_SIZE"
        exit 1;
    elif [ -e "${RESULT_DIR}/work1/superReadSequences.fasta" ]; then
        log_debug "${RESULT_DIR}"
        cd "${RESULT_DIR}"

        TOTAL_FQ=$( if [[ -e pe.renamed.fastq ]]; then \
                faops n50 -H -N 0 -S pe.renamed.fastq; \
            else echo 0; \
            fi )
        TOTAL_FA=$( faops n50 -H -N 0 -S pe.cor.fa )
        EST_G=$( cat environment.sh \
            | perl -n -e '/ESTIMATED_GENOME_SIZE=\"(\d+)\"/ and print $1' )
        SUM_SR=$( faops n50 -H -N 0 -S work1/superReadSequences.fasta )
        N50_SR=$( faops n50 -H -N 50 work1/superReadSequences.fasta )
        TOTAL_SUBS=$( cat pe.cor.fa | tr ' ' '\n' | grep ":sub:" | wc -l )

        printf "| %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | \n" \
            $( basename $( pwd ) ) \
            \
            $( perl -MNumber::Format -e "print Number::Format::format_bytes(${TOTAL_FQ})") \
            $( perl -MNumber::Format -e "print Number::Format::format_bytes(${TOTAL_FA})") \
            $( perl -e "printf qq{%.4f}, 1 - ${TOTAL_FA} / ${TOTAL_FQ}" ) \
            $( perl -MNumber::Format -e "print Number::Format::format_bytes(${TOTAL_SUBS})") \
            $( perl -e "printf qq{%.4f}, ${TOTAL_SUBS} / ${TOTAL_FA}" ) \
            \
            $( perl -MNumber::Format -e "print Number::Format::format_bytes(${GENOME_SIZE})") \
            $( perl -e "printf qq{%.1f}, ${TOTAL_FQ} / ${GENOME_SIZE}" ) \
            $( perl -e "printf qq{%.1f}, ${TOTAL_FA} / ${GENOME_SIZE}" ) \
            \
            $( perl -MNumber::Format -e "print Number::Format::format_bytes(${EST_G})") \
            $( perl -MNumber::Format -e "print Number::Format::format_bytes(${SUM_SR})") \
            $( perl -e "printf qq{%.2f}, ${EST_G} / ${GENOME_SIZE}" ) \
            $( perl -e "printf qq{%.2f}, ${SUM_SR} / ${GENOME_SIZE}" ) \
            ${N50_SR}
    else
        log_warn "RESULT_DIR not exists"
    fi

else
    log_warn "Unsupported STAT_TASK"
fi
