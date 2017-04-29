#!/usr/bin/perl
use strict;
use warnings;
use autodie;

use Getopt::Long::Descriptive;
use YAML::Syck;

use Number::Format;
use List::MoreUtils::PP;
use Path::Tiny;
use Text::CSV_XS;
use WWW::Mechanize;

#----------------------------------------------------------#
# GetOpt section
#----------------------------------------------------------#
(
    #@type Getopt::Long::Descriptive::Opts
    my $opt,

    #@type Getopt::Long::Descriptive::Usage
    my $usage,
    )
    = Getopt::Long::Descriptive::describe_options(
    "Grab information from sra/ena.\n\n"
        . "Usage: perl %c <infile.csv> [options] > <outfile.yml>\n" . "\n"
        . "\t<infile> == stdin means read from STDIN\n"
        . "\tfirst column should be SRA object ID, /[DES]R\\w\\d+/\n"
        . "\tsecond column should be the name of one group\n" . "\n"
        . "\tsource list:\n"
        . "\tsrp: SRA objects, SRP, SRS, SRX\n"
        . "\tsrs: arbitrary strings in sample names\n"
        . "\terp: only wotks with SRP, can retrive more than 200 srx\n",
    [ 'help|h',    'display this message' ],
    [ 'verbose|v', 'verbose mode' ],
    [],
    [ 'source|s=s', "srp, srs or erp", { default => 'srp' } ],
    [ 'fq',         "fastq instead of sra", ],
    { show_defaults => 1, }
    );

$usage->die if $opt->{help};

if ( @ARGV != 1 ) {
    my $message = "This command need one filename.\n\tIt found";
    $message .= sprintf " [%s]", $_ for @ARGV;
    $message .= ".\n";
    $usage->die( { pre_text => $message } );
}
for (@ARGV) {
    next if lc $_ eq "stdin";
    if ( !Path::Tiny::path($_)->is_file ) {
        $usage->die( { pre_text => "The input file [$_] doesn't exist.\n" } );
    }
}

#----------------------------------------------------------#
# start
#----------------------------------------------------------#
my $master = {};

my $csv_fh;
if ( lc $ARGV[0] eq 'stdin' ) {
    $csv_fh = *STDIN;
}
else {
    open $csv_fh, "<", $ARGV[0];
}

my $csv = Text::CSV_XS->new( { binary => 1 } )
    or die "Cannot use CSV: " . Text::CSV_XS->error_diag;
while ( my $row = $csv->getline($csv_fh) ) {
    next if $row->[0] =~ /^#/;
    if ( $opt->{source} ne "srs" ) {
        next unless $row->[0] =~ /[DES]R\w\d+/;
    }

    my ( $key, $name ) = ( $row->[0], $row->[1] );
    if ( !defined $name ) {
        $name = $key;
    }
    warn "key: [$key]\tname: [$name]\n";

    my @srx;
    if ( $opt->{source} eq "srp" ) {
        @srx = srp_worker( $key, $opt->{verbose} );
    }
    elsif ( $opt->{source} eq "erp" ) {
        @srx = erp_worker( $key, $opt->{verbose} );
    }
    elsif ( $opt->{source} eq "srs" ) {
        @srx = srs_worker( $key, $opt->{verbose} );
    }
    else {
        my $message = sprintf "Unkown --sources [%s]\n", $opt->{source};
        die $message;
    }
    warn "@srx\n";

    my $sample
        = exists $master->{$name}
        ? $master->{$name}
        : {};
    for (@srx) {
        $sample->{$_} = erx_worker( $_, $opt->{fq}, $opt->{verbose} );
    }
    $master->{$name} = $sample;
    warn "\n";
}
close $csv_fh;

print YAML::Syck::Dump($master);
exit;

#----------------------------------------------------------#
# Subroutines
#----------------------------------------------------------#

# if the srp contains more than 200 srx, use erp_worker
sub srp_worker {
    my $term    = shift;
    my $verbose = shift;

    my $mech = WWW::Mechanize->new;
    $mech->stack_depth(0);    # no history to save memory

    my $url_part1 = "http://www.ncbi.nlm.nih.gov/sra?term=";
    my $url_part2 = "&from=begin&to=end&dispmax=200";
    my $url       = $url_part1 . $term . $url_part2;
    warn "$url\n" if $verbose;
    $mech->get($url);

    my @links = $mech->find_all_links( url_regex => qr{sra\/[DES]RX\d+}, );
    my @srx = map { /sra\/([DES]RX\d+)/; $1 } map { $_->url } @links;

    return @srx;
}

sub erp_worker {
    my $term    = shift;
    my $verbose = shift;

    my $mech = WWW::Mechanize->new;
    $mech->stack_depth(0);    # no history to save memory

    my $url_part1 = "http://www.ebi.ac.uk/ena/data/warehouse/filereport?accession=";
    my $url_part2 = "&result=read_run&fields=secondary_study_accession,experiment_accession";
    my $url       = $url_part1 . $term . $url_part2;
    warn "$url\n" if $verbose;
    $mech->get($url);
    my @lines = split /\n/, $mech->content;

    my @srx;
    for (@lines) {
        if (/^$term\t([DES]RX\d+)/) {
            push @srx, $1;
        }
    }
    @srx = List::MoreUtils::PP::uniq(@srx);

    return @srx;
}

# query sample name, not srs
sub srs_worker {
    my $term    = shift;
    my $verbose = shift;

    $term =~ s/\s+/+/;

    my $mech = WWW::Mechanize->new;
    $mech->stack_depth(0);    # no history to save memory

    my $url_part1 = "http://www.ncbi.nlm.nih.gov/biosample/?term=";
    my $url_part2 = "&from=begin&to=end&dispmax=200";
    my $url       = $url_part1 . $term . $url_part2;
    warn "$url\n" if $verbose;
    $mech->get($url);

    # this link exists in both summary and detailed pages
    $mech->follow_link(
        text_regex => qr{SRA},
        url_regex  => qr{biosample_sra},
    );

    my @links = $mech->find_all_links( url_regex => qr{sra/[DES]RX}, );
    my @srx = grep {/./} map { $_->url =~ /([DES]RX\d+)/ ? $1 : undef } @links;
    @srx = List::MoreUtils::PP::uniq(@srx);

    return @srx;
}

sub erx_worker {
    my $term    = shift;
    my $fq      = shift;
    my $verbose = shift;

    my $mech = WWW::Mechanize->new;
    $mech->stack_depth(0);    # no history to save memory

    my $url_part1 = "http://www.ebi.ac.uk/ena/data/warehouse/filereport?accession=";
    my $url_part2
        = "&result=read_run&fields=secondary_study_accession,secondary_sample_accession,"
        . "experiment_accession,run_accession,scientific_name,"
        . "instrument_platform,instrument_model,"
        . "library_name,library_layout,nominal_length,library_source,library_selection,"
        . "read_count,base_count,"
        . ( $fq ? "fastq_md5,fastq_ftp" : "sra_md5,sra_ftp" )
        . "&download=txt";
    my $url = $url_part1 . $term . $url_part2;
    warn "$url\n" if $verbose;

    $mech->get($url);
    my @lines = split /\n/, $mech->content;

    # header line
    shift @lines;

    # prompt SRR
    chomp for @lines;
    if ( !scalar @lines ) {
        warn "Can't get any SRR, please check.\n";
        return;
    }

    my $info = {
        sample   => "",
        library  => "",
        platform => "",
        layout   => "",
        srr_info => {},
    };

    {
        my @f = split /\t/, $lines[0];
        $info->{srp}                = $f[0];
        $info->{srs}                = $f[1];
        $info->{srx}                = $f[2];
        $info->{scientific_name}    = $f[4];
        $info->{platform}           = $f[5];
        $info->{"instrument model"} = $f[6];
        $info->{library}            = $f[7];
        $info->{layout}             = $f[8];
        $info->{"nominal length"}   = $f[9];
        $info->{source}             = $f[10];
        $info->{selection}          = $f[11];
    }

    my ( @srr, @downloads, @md5s );
    for my $line (@lines) {
        my @f = split /\t/, $line;
        warn " " x 4 . "$f[3]\n";
        push @srr, $f[3];

        # ftp path and md5
        my @parts15 = map { "ftp://" . $_ } grep {defined} split ";", $f[15];
        push @downloads, @parts15;

        my @basenames = map { ( split "/", $_ )[-1] } @parts15;
        my @parts14 = grep {defined} split ";", $f[14];
        for my $i ( 0 .. $#basenames ) {
            push @md5s, ( sprintf "%s %s", $parts14[$i], $basenames[$i] );
        }

        $info->{srr_info}{ $f[3] } = {
            spot => $f[12],
            base => Number::Format::format_bytes( $f[13] ),
        };
    }
    $info->{srr}       = \@srr;
    $info->{downloads} = \@downloads;
    $info->{md5s}      = \@md5s;

    return $info;
}

__END__
