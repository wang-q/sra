#!/usr/bin/perl
use strict;
use warnings;
use autodie;

use Getopt::Long::Descriptive;
use YAML::Syck;

use Path::Tiny;
use Text::CSV_XS;
use URI;

#----------------------------------------------------------#
# GetOpt section
#----------------------------------------------------------#

(   my Getopt::Long::Descriptive::Opts $opt,
    my Getopt::Long::Descriptive::Usage $usage
    )
    = Getopt::Long::Descriptive::describe_options(
    "Prepare for sra.\n\n"
        . "Two files will be generated, .csv for information and .ftp.txt for aria2c.\n"
        . "You can edit the generated .csv file for custom filters.\n"
        . "Download with aria2:\n\taria2c -x 12 -s 4 -c -i dpgp.ftp.txt\n\n"
        . "Usage: perl %c <.yml config file> [options]",
    [ 'help|h', 'display this message' ],
    [],
    [ 'platform|p=s', 'illumina or 454', ],
    [ 'layout|l=s',   'pair or single', ],
    [ 'md5',          'generate a md5sum file', ],
    { show_defaults => 1, }
    );

$usage->die if $opt->{help};

if ( @ARGV != 1 ) {
    my $message = "This command need one input file.\n\tIt found";
    $message .= sprintf " [%s]", $_ for @ARGV;
    $message .= ".\n";
    $usage->die( { pre_text => $message } );
}
for (@ARGV) {
    if ( !Path::Tiny::path($_)->is_file ) {
        $usage->die( { pre_text => "The input file [$_] doesn't exist.\n" } );
    }
}

#----------------------------------------------------------#
# start
#----------------------------------------------------------#
my $yml = LoadFile( $ARGV[0] );
my $basename = path( $ARGV[0] )->basename( ".yml", ".yaml" );
$basename .= "." . $opt->{platform} if $opt->{platform};
$basename .= "." . $opt->{layout}   if $opt->{layout};

my $csv = Text::CSV_XS->new( { binary => 1 } )
    or die "Cannot use CSV: " . Text::CSV_XS->error_diag;
$csv->eol("\n");

open my $csv_fh, ">", "$basename.csv";
open my $ftp_fh, ">", "$basename.ftp.txt";
my $md5_fh;
if ( $opt->{md5} ) {
    open $md5_fh, ">", "$basename.md5.txt";
}

$csv->print( $csv_fh, [qw{ name srx platform layout ilength srr spot base }] );
for my $name ( sort keys %{$yml} ) {
    print "$name\n";

    for my $srx ( sort keys %{ $yml->{$name} } ) {
        my $info = $yml->{$name}{$srx};
        print " " x 4, "$srx\n";
        if ( !defined $yml->{$name}{$srx} ) {
            print " " x 8, "Empty record\n";
            next;
        }

        my $platform = $info->{platform};
        my $layout   = $info->{layout};
        my $ilength  = $info->{"nominal length"};
        print " " x 8, $platform, " " x 8, $layout, "\n";

        if ( $opt->{platform} ) {
            next unless $platform =~ qr/$opt->{platform}/i;
        }
        if ( $opt->{layout} ) {
            next unless $layout =~ qr/$opt->{layout}/i;
        }

        for my $i ( 0 .. scalar @{ $info->{srr} } - 1 ) {
            my $srr = $info->{srr}[$i];
            my $url = $info->{downloads}[$i];

            my $spot = $info->{srr_info}{$srr}{spot};
            my $base = $info->{srr_info}{$srr}{base};

            $csv->print(
                $csv_fh,
                [   $name,    $srx, $platform, $layout,
                    $ilength, $srr, $spot,     $base,
                ]
            );
            print {$ftp_fh} $url, "\n";

            if ( $opt->{md5} ) {
                printf {$md5_fh} "%s\t%s\n", $info->{srr_info}{$srr}{md5}, $srr;
            }
        }
    }
}

close $csv_fh;
close $ftp_fh;
if ( $opt->{md5} ) {
    close $md5_fh;
}

__END__
