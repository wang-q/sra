#!/usr/bin/env perl
use strict;
use warnings;
use autodie;

use Getopt::Long::Descriptive;
use FindBin;
use YAML::Syck qw();

use AlignDB::IntSpan;
use Graph;
use GraphViz;
use Path::Tiny qw();

#----------------------------------------------------------#
# GetOpt section
#----------------------------------------------------------#
my $usage_desc = <<EOF;
Ovelaps to String Graph

Usage: perl %c [options] <ovlp file>
EOF

my @opt_spec = (
    [ 'help|h', 'display this message' ],
    [],
    [ 'skip_contained', 'skip contained reads',         { default => 0, }, ],
    [ 'min_len=i',      'minimum length of reads',      { default => 1000, }, ],
    [ 'min_ovlp=i',     'minimum length of overlaps',   { default => 800, }, ],
    [ 'min_idt=f',      'minimum identity of overlaps', { default => 0.7, }, ],
    { show_defaults => 1, },
);

( my Getopt::Long::Descriptive::Opts $opt, my Getopt::Long::Descriptive::Usage $usage, )
    = Getopt::Long::Descriptive::describe_options( $usage_desc, @opt_spec, );

$usage->die if $opt->{help};

if ( @ARGV != 1 ) {
    my $message = "This script need one input file.\n\tIt found";
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

if ( $opt->{range} ) {
    eval { AlignDB::IntSpan->new( $opt->{range} ); };
    if ($@) {
        $usage->die( { pre_text => "Invalid --range [$opt->{range}]\n" } );
    }
}

#print YAML::Syck::Dump $opt;

#----------------------------------------------------------#
# start
#----------------------------------------------------------#
my $ovlps = [];
my %contained;

my $read_range = AlignDB::IntSpan->new;
if ( $opt->{range} ) {
    $read_range->add_runlist( $opt->{range} );
}

#----------------------------#
# load overlaps
#----------------------------#
{
    my $in_fh;
    if ( lc $ARGV[0] eq 'stdin' ) {
        $in_fh = *STDIN{IO};
    }
    else {
        open $in_fh, "<", $ARGV[0];
    }

    my %seen_pair;

    while ( my $line = <$in_fh> ) {
        chomp $line;
        my @fields = split "\t", $line;
        my ( $f_id,     $g_id, $ovlp_len, $identity ) = @fields[ 0 .. 3 ];
        my ( $f_strand, $f_B,  $f_E,      $f_len )    = @fields[ 4 .. 7 ];
        my ( $g_strand, $g_B,  $g_E,      $g_len )    = @fields[ 8 .. 11 ];
        my $contained = $fields[12];

        if ( $opt->{range} ) {
            next unless $read_range->contains($f_id);
        }

        # ignore need self overlapping
        next if $f_id eq $g_id;

        # record contained reads
        if ( $contained eq "contained" ) {
            $contained{$f_id}++;
            next;
        }
        elsif ( $contained eq "contains" ) {
            $contained{$g_id}++;
            next;
        }

        # skip overlaps with less identities
        if ( $identity < $opt->{min_idt} ) {
            next;
        }

        # skip short overlaps
        if ( $ovlp_len < $opt->{min_ovlp} ) {
            next;
        }

        # skip short reads
        if ( $f_len < $opt->{min_len} ) {
            next;
        }
        if ( $g_len < $opt->{min_len} ) {
            next;
        }

        # String graph is bidirectional, skip duplicated overlaps
        my $pair = join( "-", sort ( $f_id, $g_id ) );
        next if $seen_pair{$pair};
        $seen_pair{$pair}++;

        #        # opposite strands, swapping
        #        if ( $g_strand == 1 ) {
        #            ( $g_B, $g_E, ) = ( $g_E, $g_B, );
        #        }

        # store this overlap
        push @{$ovlps}, \@fields;
    }
    close $in_fh;
}

#----------------------------#
# Building a string graph
#----------------------------#
my $graph = Graph->new( directed => 1 );
for my $ovlp ( @{$ovlps} ) {
    my @fields = @{$ovlp};
    my ( $f_id,     $g_id, $ovlp_len, $identity ) = @fields[ 0 .. 3 ];
    my ( $f_strand, $f_B,  $f_E,      $f_len )    = @fields[ 4 .. 7 ];
    my ( $g_strand, $g_B,  $g_E,      $g_len )    = @fields[ 8 .. 11 ];

    if ( $opt->{skip_contained} ) {
        next if $contained{$f_id};
        next if $contained{$g_id};
    }

    # Myers, 2005. Section 2
    if ( $f_B > 0 ) {

        #          f.B        f.E
        # f ========+---------->
        # g         -----------+=======>
        #          g.B        g.E

        #        $graph->add_edge( $f_id, $g_id );
        $graph->add_edge( "$f_id:E", "$g_id:E", );
        $graph->set_edge_attributes(
            "$f_id:E",
            "$g_id:E",
            {   label    => [ $g_id, $g_E, $g_len ],
                length   => abs( $g_E - $g_len ),
                ovlp_len => $ovlp_len,
                identity => $identity,
            }
        );

        $graph->add_edge( "$g_id:B", "$f_id:B", );
        $graph->set_edge_attributes(
            "$g_id:B",
            "$f_id:B",
            {   label    => [ $f_id, $f_B, 0 ],
                length   => abs( $f_B - 0 ),
                ovlp_len => $ovlp_len,
                identity => $identity,
            }
        );

    }
    else {

        #          f.B        f.E
        # f         -----------+=======>
        # g ========+---------->
        #          g.B        g.E
        $graph->add_edge( $g_id, $f_id );
    }
}

print YAML::Syck::Dump {
    nodes                 => scalar $graph->vertices,
    edges                 => scalar $graph->edges,
    is_dag                => $graph->is_dag,
    is_simple_graph       => $graph->is_simple_graph,
    is_cyclic             => $graph->is_cyclic,
    is_strongly_connected => $graph->is_strongly_connected,
    is_weakly_connected   => $graph->is_weakly_connected,
    is_transitive         => $graph->is_transitive,
    exterior_vertices     => scalar $graph->exterior_vertices(),
    interior_vertices     => scalar $graph->interior_vertices(),
    isolated_vertices     => scalar $graph->isolated_vertices(),
};

#print YAML::Syck::Dump [ $graph->weakly_connected_components() ];

