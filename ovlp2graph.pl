#!/usr/bin/env perl
use strict;
use warnings;
use autodie;

use Getopt::Long::Descriptive;
use FindBin;
use YAML::Syck qw();

use AlignDB::IntSpan;
use Graph;
use Path::Tiny qw();

#----------------------------------------------------------#
# GetOpt section
#----------------------------------------------------------#
my $usage_desc = <<EOF;
Ovelaps to string graph

Usage: perl %c [options] <ovlp>
EOF

my @opt_spec = (
    [ 'help|h', 'display this message' ],
    [],
    [ 'range|r=s', 'ranges of reads', ],
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

#----------------------------------------------------------#
# start
#----------------------------------------------------------#
my $graph = Graph->new( directed => 1 );
my $read_range = AlignDB::IntSpan->new;

if ( $opt->{range} ) {
    $read_range->add_runlist( $opt->{range} );
}

my $in_fh;
if ( lc $ARGV[0] eq 'stdin' ) {
    $in_fh = *STDIN{IO};
}
else {
    open $in_fh, "<", $ARGV[0];
}

while ( my $line = <$in_fh> ) {
    chomp $line;
    my ( $f_id, $g_id, undef, undef, undef, $f_B ) = split "\t", $line;

    if ( $opt->{range} ) {
        next unless ( $read_range->contains($f_id) );
    }

    if ( $f_B > 0 ) {

        #          f.B        f.E
        # f ========+---------->
        # g         -----------+=======>
        #          g.B        g.E
        $graph->add_edge( $f_id, $g_id );
    }
    else {

        #          f.B        f.E
        # f         -----------+=======>
        # g ========+---------->
        #          g.B        g.E
        $graph->add_edge( $g_id, $f_id );
    }
}

close $in_fh;

#if ( $opt->{range} ) {
#    printf "#ID\tin\tout\n";
#    for my $node ( $read_range->elements ) {
#        printf "%s\t%d\t%d\n", $node, $graph->in_degree($node), $graph->out_degree($node);
#    }
#}

print YAML::Syck::Dump {
    nodes                 => scalar $graph->vertices,
    edges                 => scalar $graph->edges,
    is_dag                => $graph->is_dag,
    is_simple_graph       => $graph->is_simple_graph,
    is_cyclic             => $graph->is_cyclic,
    is_strongly_connected => $graph->is_strongly_connected,
    is_weakly_connected   => $graph->is_weakly_connected,
    exterior_vertices     => scalar $graph->exterior_vertices(),
    interior_vertices     => scalar $graph->interior_vertices(),
    isolated_vertices     => scalar $graph->isolated_vertices(),
};

#print YAML::Syck::Dump [ $graph->weakly_connected_components() ];

if ( $graph->is_directed_acyclic_graph ) {

    #    print YAML::Syck::Dump [ $graph->topological_sort ];
    #    my $apsp = $graph->all_pairs_shortest_paths();

    #    print YAML::Syck::Dump $apsp;
    if ( $opt->{range} ) {
        my @nodes = $read_range->elements;
        for my $i ( 0 .. $#nodes ) {

            #            for my $j ( $i + 1 .. $#nodes ) {
            #
            #            }
        }
    }
}

#while ( $graph->is_cyclic ) {
#    my @nodes = sort { $a <=> $b } $graph->find_a_cycle;
#    print YAML::Syck::Dump \@nodes;
#
#    for my $i ( 0 .. $#nodes - 1 ) {
#        $graph->delete_edge( $nodes[$i],       $nodes[ $i + 1 ], );
#        $graph->delete_edge( $nodes[ $i + 1 ], $nodes[$i], );
#    }
#
#    for my $i ( 0 .. $#nodes - 1 ) {
#        $graph->add_edge( $nodes[$i], $nodes[ $i + 1 ], );
#    }
#}

