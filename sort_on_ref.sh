#!/usr/bin/env bash

USAGE="Usage: $0 FA_FILE REF_FILE OUT_BASE"

if [ "$#" -lt 3 ]; then
    echo >&2 "$USAGE"
    exit 1
fi

# check whether faops is installed
hash faops 2>/dev/null || {
    echo >&2 "faops is required but it's not installed.";
    echo >&2 "Install with homebrew: brew install wang-q/tap/faops";
    exit 1;
}

# check whether sparsemem is installed
hash sparsemem 2>/dev/null || {
    echo >&2 "sparsemem is required but it's not installed.";
    echo >&2 "Install with homebrew: brew install wang-q/tap/sparsemem";
    exit 1;
}

# check whether fasops is installed
hash fasops 2>/dev/null || {
    echo >&2 "fasops is required but it's not installed.";
    echo >&2 "Install with cpanm: cpanm App::Fasops";
    exit 1;
}

# check whether rangeops is installed
hash rangeops 2>/dev/null || {
    echo >&2 "rangeops is required but it's not installed.";
    echo >&2 "Install with cpanm: cpanm App::Rangeops";
    exit 1;
}

# set parameters
FA_FILE=$1
REF_FILE=$2
OUT_BASE=${3:-sort}

[ -e ${FA_FILE} ] || {
    log_warn "Can't find [${FA_FILE}].";
    exit 1;
}

[ -e ${REF_FILE} ] || {
    log_warn "Can't find [${REF_FILE}].";
    exit 1;
}

#----------------------------#
# Run
#----------------------------#
# create tmp dir
mytmpdir=`mktemp -d 2>/dev/null || mktemp -d -t 'mytmpdir'`

perl ~/Scripts/egaz/sparsemem_exact.pl \
    -f ${FA_FILE} -g ${REF_FILE} \
    --length 500 -o ${mytmpdir}/replace.tsv

cat ${mytmpdir}/replace.tsv \
    | perl -nla -e '/\(\-\)/ and print $F[0];' \
    > ${mytmpdir}/rc.list

faops some -l 0 -i ${FA_FILE} ${mytmpdir}/rc.list stdout \
    > ${mytmpdir}/strand.fa
faops some ${FA_FILE} ${mytmpdir}/rc.list stdout \
    | faops rc -l 0 stdin stdout \
    >> ${mytmpdir}/strand.fa

# recreate replace.tsv. now all positive strands
perl ~/Scripts/egaz/sparsemem_exact.pl \
    -f ${mytmpdir}/strand.fa -g ${REF_FILE} \
    --length 500 -o ${mytmpdir}/replace.tsv

faops filter -b ${mytmpdir}/strand.fa ${mytmpdir}/strand.fas

fasops replace ${mytmpdir}/strand.fas ${mytmpdir}/replace.tsv -o ${mytmpdir}/replace.fas

faops size ${mytmpdir}/replace.fas | cut -f 1 > ${mytmpdir}/heads.list
rangeops sort ${mytmpdir}/heads.list -o stdout > ${mytmpdir}/heads.sort
grep -Fx -f ${mytmpdir}/heads.sort -v ${mytmpdir}/heads.list >> ${mytmpdir}/heads.sort

for word in $( cat ${mytmpdir}/heads.sort ); do
    faops some -l 0 ${mytmpdir}/replace.fas <(echo ${word}) stdout
done > ${mytmpdir}/sort.fa

mv ${mytmpdir}/sort.fa ${OUT_BASE}.fa
mv ${mytmpdir}/replace.tsv ${OUT_BASE}.replace.tsv

# clean tmp dir
rm -fr ${mytmpdir}
