#!/usr/bin/env bash

USAGE="Usage: $0 RESULT_DIR N_THREADS TOLERATE_SUBS MIN_LENGTH_READ"

# bash anchor.sh ~/data/rna-seq/medfood/process/Arabidopsis_thaliana/result/Trinity.fasta 100 1000 2000

if [ "$#" -lt 1 ]; then
    echo >&2 "$USAGE"
    exit 1
fi

# check whether faops is installed
hash faops 2>/dev/null || {
    echo >&2 "faops is required but it's not installed.";
    echo >&2 "Install with homebrew: brew install wang-q/tap/faops";
    exit 1;
}

# check whether bbmap.sh is installed
hash bbmap.sh 2>/dev/null || {
    echo >&2 "bbmap.sh is required but it's not installed.";
    echo >&2 "Install with homebrew: brew install homebrew/science/bbtools";
    exit 1;
}

# check whether genomeCoverageBed is installed
hash genomeCoverageBed 2>/dev/null || {
    echo >&2 "genomeCoverageBed is required but it's not installed.";
    echo >&2 "Install with homebrew: brew install homebrew/science/bedtools";
    exit 1;
}

# check whether jrunlist is installed
hash jrunlist 2>/dev/null || {
    echo >&2 "jrunlist is required but it's not installed.";
    echo >&2 "Install with homebrew: brew install wang-q/tap/jrunlist";
    exit 1;
}

# check whether runlist is installed
hash runlist 2>/dev/null || {
    echo >&2 "runlist is required but it's not installed.";
    echo >&2 "Install with cpanm: cpanm App::RL";
    exit 1;
}

# set default parameters
RESULT_DIR=$1
N_THREADS=${2:-8}
TOLERATE_SUBS=${2:-true}
MIN_LENGTH_READ=${3:-100}

echo >&2 "==> Parameters <=="
echo >&2 "    RESULT_DIR=${RESULT_DIR}"
echo >&2 "    N_THREADS=${N_THREADS}"
echo >&2 "    TOLERATE_SUBS=${TOLERATE_SUBS}"
echo >&2 "    MIN_LENGTH_READ=${MIN_LENGTH_READ}"

[ -e ${RESULT_DIR}/pe.cor.fa ] || {
    echo >&2 "Can't find pe.cor.fa in [${RESULT_DIR}].";
    exit 1;
}

[ -e ${RESULT_DIR}/work1/superReadSequences.fasta ] || {
    echo >&2 "Can't find superReadSequences.fasta in [${RESULT_DIR}/work1].";
    exit 1;
}

echo >&2 "==> Prepare files"
mkdir -p ${RESULT_DIR}/sr
cd ${RESULT_DIR}/sr

ln -s ../pe.cor.fa .
ln -s ../work1/superReadSequences.fasta .

faops size superReadSequences.fasta > sr.chr.sizes

if [ "${TOLERATE_SUBS}" = true ]; then
    # tolerates 1 substitution
    cat pe.cor.fa \
        | perl -nle '/>/ or next; /sub.+sub/ and next; />(\w+)/ and print $1;' \
        > pe.strict.txt
else
    # discard any reads with substitutions
    cat pe.cor.fa \
        | perl -nle '/>/ or next; /sub/ and next; />(\w+)/ and print $1;' \
        > pe.strict.txt
fi

# Too large for `faops some`
split -n10 -d pe.strict.txt pe.part

# No Ns; longer than MIN_LENGTH_READ (70% of read length)
rm pe.strict.fa
for part in $(printf "%.2d " {0..9})
do
    faops some -l 0 pe.cor.fa pe.part${part} stdout \
        | faops filter -n 0 -a ${MIN_LENGTH_READ} -l 0 stdin stdout
    rm pe.part${part}
done >> pe.strict.fa

#----------------------------#
# unambiguous
#----------------------------#
echo >&2 "==> unambiguous regions"

# index
bbmap.sh ref=superReadSequences.fasta

bbmap.sh \
    maxindel=0 strictmaxindel perfectmode \
    threads=${N_THREADS} \
    ambiguous=toss \
    ref=superReadSequences.fasta in=pe.strict.fa \
    outm=unambiguous.sam outu=unmapped.sam

java -jar ~/share/picard-tools-1.128/picard.jar \
    CleanSam \
    INPUT=unambiguous.sam \
    OUTPUT=_clean.bam
java -jar ~/share/picard-tools-1.128/picard.jar \
    SortSam \
    INPUT=_clean.bam \
    OUTPUT=_sort.bam \
    SORT_ORDER=coordinate \
    VALIDATION_STRINGENCY=LENIENT
rm _clean.bam
mv _sort.bam unambiguous.sort.bam

genomeCoverageBed -bga -split -g sr.chr.sizes -ibam unambiguous.sort.bam \
    | perl -nlae '
        $F[3] == 0 and next;
        $F[3] == 1 and next;
        printf qq{%s:%s-%s\n}, $F[0], $F[1] + 1, $F[2];
    ' \
    > unambiguous.cover.txt

#----------------------------#
# ambiguous
#----------------------------#
echo >&2 "==> ambiguous regions"

cat unmapped.sam \
    | perl -nle '
        /^@/ and next;
        @fields = split "\t";
        print $fields[0];
    ' \
    > pe.unmapped.txt

# Too large for `faops some`
split -n10 -d pe.unmapped.txt pe.part

rm pe.unmapped.fa
for part in $(printf "%.2d " {0..9})
do
    faops some -l 0 pe.strict.fa pe.part${part} stdout
    rm pe.part${part}
done >> pe.unmapped.fa

bbmap.sh \
    maxindel=0 strictmaxindel perfectmode \
    threads=${N_THREADS} \
    ref=superReadSequences.fasta in=pe.unmapped.fa \
    outm=ambiguous.sam outu=unmapped2.sam

java -jar ~/share/picard-tools-1.128/picard.jar \
    CleanSam \
    INPUT=ambiguous.sam \
    OUTPUT=_clean.bam
java -jar ~/share/picard-tools-1.128/picard.jar \
    SortSam \
    INPUT=_clean.bam \
    OUTPUT=_sort.bam \
    SORT_ORDER=coordinate \
    VALIDATION_STRINGENCY=LENIENT
rm _clean.bam
mv _sort.bam ambiguous.sort.bam

genomeCoverageBed -bga -split -g sr.chr.sizes -ibam ambiguous.sort.bam \
    | perl -nlae '
        $F[3] == 0 and next;
        printf qq{%s:%s-%s\n}, $F[0], $F[1] + 1, $F[2];
    ' \
    > ambiguous.cover.txt

#----------------------------#
# anchor
#----------------------------#
echo >&2 "==> pe.anchor.fa"

jrunlist cover unambiguous.cover.txt
runlist stat unambiguous.cover.txt.yml -s sr.chr.sizes -o unambiguous.cover.csv

jrunlist cover ambiguous.cover.txt
runlist stat ambiguous.cover.txt.yml -s sr.chr.sizes -o ambiguous.cover.csv

runlist compare --op diff unambiguous.cover.txt.yml ambiguous.cover.txt.yml -o unique.cover.yml
runlist stat unique.cover.yml -s sr.chr.sizes -o unique.cover.csv

cat unique.cover.csv \
    | perl -nla -F"," -e '
        $F[0] eq q{chr} and next;
        $F[0] eq q{all} and next;
        $F[2] < 1000 and next;
        $F[3] < 0.95 and next;
        print $F[0];
    ' \
    | sort -n \
    > anchor.txt

faops some -l 0 superReadSequences.fasta anchor.txt pe.anchor.fa

#----------------------------#
# anchor2
#----------------------------#
echo >&2 "==> pe.anchor2.fa & pe.others.fa"

jrunlist span unique.cover.yml --op excise -n 1000 -o stdout \
    | runlist stat stdin -s sr.chr.sizes -o unique2.cover.csv

cat unique2.cover.csv \
    | perl -nla -F"," -e '
        $F[0] eq q{chr} and next;
        $F[0] eq q{all} and next;
        $F[2] < 1000 and next;
        print $F[0];
    ' \
    | sort -n \
    > unique2.txt

cat unique2.txt \
    | perl -nl -MPath::Tiny -e '
        BEGIN {
            %seen = ();
            @ls = grep {/\S/}
                  path(q{anchor.txt})->lines({ chomp => 1});
            $seen{$_}++ for @ls;
        }

        $seen{$_} and next;
        print;
    ' \
    > anchor2.txt

faops some -l 0 superReadSequences.fasta anchor2.txt pe.anchor2.fa

faops some -l 0 -i superReadSequences.fasta anchor.txt stdout \
    | faops some -l 0 -i stdin anchor2.txt pe.others.fa

rm unique2.cover.csv unique2.txt

#----------------------------#
# record unique regions
#----------------------------#
echo >&2 "==> record unique regions"

cat pe.anchor2.fa \
    | perl -nl -MPath::Tiny -e '
        BEGIN {
            %seen = ();
            @ls = grep {/\S/}
                  path(q{unique.cover.yml})->lines({ chomp => 1});
            for (@ls) {
                /^(\d+):\s+([\d,-]+)/ or next;
                $seen{$1} = $2;
            }
            $flag = 0;
        }

        if (/^>(\d+)/) {
            if ($seen{$1}) {
                print qq{>$1|$seen{$1}};
                $flag = 1;
            }
        }
        elsif (/^\w+/) {
            if ($flag) {
                print;
                $flag = 0;
            }
        }
    ' \
    > pe.anchor2.record.fa

cat pe.others.fa \
    | perl -nl -MPath::Tiny -e '
        BEGIN {
            %seen = ();
            @ls = grep {/\S/}
                  path(q{unique.cover.yml})->lines({ chomp => 1});
            for (@ls) {
                /^(\d+):\s+([\d,-]+)/ or next;
                $seen{$1} = $2;
            }
            $flag = 0;
        }

        if (/^>(\d+)/) {
            if ($seen{$1}) {
                print qq{>$1|$seen{$1}};
            }
            else {
                print;
            }
            $flag = 1;
        }
        elsif (/^\w+/) {
            if ($flag) {
                print;
                $flag = 0;
            }
        }
    ' \
    > pe.others.record.fa

#----------------------------#
# clear intermediate files
#----------------------------#
echo >&2 "==> clear intermediate files"

find . -type f -name "ambiguous.sam" | xargs rm
find . -type f -name "unambiguous.sam" | xargs rm
find . -type f -name "unmapped.sam" | xargs rm
find . -type f -name "pe.unmapped.fa" | xargs rm
