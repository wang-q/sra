#!/usr/bin/perl
use strict;
use warnings;
use autodie;

use Getopt::Long::Descriptive;
use YAML::Syck;

use Text::CSV_XS;

use FindBin;
use lib "$FindBin::RealBin/lib";
use MySRA;

#----------------------------------------------------------#
# GetOpt section
#----------------------------------------------------------#

(   my Getopt::Long::Descriptive::Opts $opt,
    my Getopt::Long::Descriptive::Usage $usage
    )
    = Getopt::Long::Descriptive::describe_options(
    "Grab information from sra/ena.\n\n"
        . "Usage: perl %c <infile.csv> [options] > <outfile.yml>\n"
        . "\t<infile> == stdin means read from STDIN"
        . "\tfirst column should be SRA object ID, /[DES]R\w\d+/"
        . "\tsecond column should be the name of one group",
    [ 'help|h', 'display this message' ],
    [],
    [   'erp',
        'use erp instead of srp, for sra objects containing more than 200 srx',
    ],
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
my $mysra  = MySRA->new;
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
    next unless $row->[0] =~ /[DES]R\w\d+/;

    my ( $key, $name ) = ( $row->[0], $row->[1] );
    if ( !defined $name ) {
        $name = $key;
    }
    warn "$key\t$name\n";

    my @srx = @{ $mysra->srp_worker($key) };
    warn "@srx\n";

    my $sample
        = exists $master->{$name}
        ? $master->{$name}
        : {};
    for (@srx) {
        $sample->{$_} = $mysra->erx_worker($_);
    }
    $master->{$name} = $sample;
    warn  "\n";
}
close $csv_fh;

print YAML::Syck::Dump($master);

__END__
