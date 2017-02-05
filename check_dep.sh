#!/usr/bin/env bash

# Check external dependencies

#----------------------------#
# anchor.sh
#----------------------------#
hash faops 2>/dev/null || {
    echo >&2 "faops is required but it's not installed.";
    echo >&2 "Install with homebrew: brew install wang-q/tap/faops";
    exit 1;
}

hash bbmap.sh 2>/dev/null || {
    echo >&2 "bbmap.sh is required but it's not installed.";
    echo >&2 "Install with homebrew: brew install homebrew/science/bbtools";
    exit 1;
}

hash genomeCoverageBed 2>/dev/null || {
    echo >&2 "genomeCoverageBed is required but it's not installed.";
    echo >&2 "Install with homebrew: brew install homebrew/science/bedtools";
    exit 1;
}

hash jrunlist 2>/dev/null || {
    echo >&2 "jrunlist is required but it's not installed.";
    echo >&2 "Install with homebrew: brew install wang-q/tap/jrunlist";
    exit 1;
}

hash runlist 2>/dev/null || {
    echo >&2 "runlist is required but it's not installed.";
    echo >&2 "Install with cpanm: cpanm App::RL";
    exit 1;
}

#----------------------------#
# link_anchor.sh
#----------------------------#
# faops

hash fasta2DB 2>/dev/null || {
    echo >&2 "DAZZ_DB is required but it's not installed.";
    echo >&2 "Install with homebrew: brew install wang-q/tap/dazz_db@20161112";
    exit 1;
}

hash daligner 2>/dev/null || {
    echo >&2 "daligner is required but it's not installed.";
    echo >&2 "Install with homebrew: brew install wang-q/tap/daligner@20170203";
    exit 1;
}

perl -MAlignDB::IntSpan -e "1" 2>/dev/null || {
    echo >&2 "AlignDB::IntSpan is required but it's not installed.";
    echo >&2 "Install with cpanm: cpanm AlignDB::IntSpan";
    exit 1;
}

perl -MGraph -e "1" 2>/dev/null || {
    echo >&2 "Graph is required but it's not installed.";
    echo >&2 "Install with cpanm: cpanm Graph";
    exit 1;
}

#----------------------------#
# sr_stat.sh
#----------------------------#
# faops

perl -MNumber::Format -e "1" 2>/dev/null || {
    echo >&2 "Number::Format is required but it's not installed.";
    echo >&2 "Install with cpanm: cpanm Number::Format";
    exit 1;
}

#----------------------------#
# sort_on_ref.sh
#----------------------------#
# faops

hash sparsemem 2>/dev/null || {
    echo >&2 "sparsemem is required but it's not installed.";
    echo >&2 "Install with homebrew: brew install wang-q/tap/sparsemem";
    exit 1;
}

hash fasops 2>/dev/null || {
    echo >&2 "fasops is required but it's not installed.";
    echo >&2 "Install with cpanm: cpanm App::Fasops";
    exit 1;
}

hash rangeops 2>/dev/null || {
    echo >&2 "rangeops is required but it's not installed.";
    echo >&2 "Install with cpanm: cpanm App::Rangeops";
    exit 1;
}
