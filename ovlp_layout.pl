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
Ovelap--Layout(--Consensus)

Usage: perl %c [options] <ovlp file>
EOF

my @opt_spec = (
    [ 'help|h', 'display this message' ],
    [],
    [ 'range|r=s', 'ranges of reads', { required => 1 }, ],
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
my $ovlps = [];
my %contained;

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

        # ignore need self overlapping
        next if $f_id eq $g_id;

        # record contained reads
        if ( $contained eq "contained" ) {
            $contained{$f_id}++;
        }
        elsif ( $contained eq "contains" ) {
            $contained{$g_id}++;
        }

        # String graph is bidirectional, skip duplicated overlaps
        my $pair = join( "-", sort ( $f_id, $g_id ) );
        next if $seen_pair{$pair};
        $seen_pair{$pair}++;

        # store this overlap
        push @{$ovlps}, \@fields;
    }
    close $in_fh;
}

#----------------------------#
# layout
#----------------------------#
my $graph = Graph->new( directed => 1 );
my $anchor_range = AlignDB::IntSpan->new->add_runlist( $opt->{range} );

for my $ovlp ( @{$ovlps} ) {
    my @fields = @{$ovlp};

    my ( $f_id,     $g_id, $ovlp_len, $identity ) = @fields[ 0 .. 3 ];
    my ( $f_strand, $f_B,  $f_E,      $f_len )    = @fields[ 4 .. 7 ];
    my ( $g_strand, $g_B,  $g_E,      $g_len )    = @fields[ 8 .. 11 ];
    my $contained = $fields[12];

    # skip contained linkers
    #    if ( !$anchor_range->contains($f_id) and $contained{$f_id} ) {
    #        next;
    #    }
    #    if ( !$anchor_range->contains($g_id) and $contained{$g_id} ) {
    #        next;
    #    }

    if ( $f_B > 0 ) {

        if ( $f_E == $f_len ) {

            #          f.B        f.E
            # f ========+---------->
            # g         -----------+=======>
            #          g.B        g.E
            $graph->add_weighted_edge( $f_id, $g_id, $g_len - $g_E );
        }
        else {
            #          f.B        f.E
            # f ========+----------+=======>
            # g         ----------->
            #          g.B        g.E
            $graph->add_weighted_edge( $g_id, $f_id, $f_len - $f_E );
        }
    }
    else {
        if ( $g_E == $g_len ) {

            #          f.B        f.E
            # f         -----------+=======>
            # g ========+---------->
            #          g.B        g.E
            $graph->add_weighted_edge( $g_id, $f_id, $f_len - $f_E );
        }
        else {
            #          f.B        f.E
            # f         ----------->
            # g ========+----------+=======>
            #          g.B        g.E
            $graph->add_weighted_edge( $f_id, $g_id, $g_len - $g_E );
        }
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
    exterior_vertices     => scalar $graph->exterior_vertices(),
    interior_vertices     => scalar $graph->interior_vertices(),
    isolated_vertices     => scalar $graph->isolated_vertices(),
};

{
    my $anchor_graph = Graph->new( directed => 1 );

    my @nodes = $graph->vertices;

    my @linkers = grep { !$anchor_range->contains($_) } @nodes;

    for my $l (@linkers) {
        my @p = grep { $anchor_range->contains($_) } $graph->predecessors($l);
        my @s = grep { $anchor_range->contains($_) } $graph->successors($l);

        for my $p (@p) {
            for my $s (@s) {
                printf "    Add by linkers: %s -> %s\n", $p, $s;
                $anchor_graph->add_edge( $p, $s );
            }
        }

        if ( @p > 1 ) {
            printf "    [%s] predecessors\n", scalar @p;
            @p = map { $_->[0] }
                sort { $b->[1] <=> $a->[1] }
                map { [ $_, $graph->get_edge_weight( $_, $l ) ] } @p;
            for my $i ( 0 .. $#p - 1 ) {
                printf "    Add by p distances: %s -> %s\n", $p[$i], $p[ $i + 1 ];
                $anchor_graph->add_edge( $p[$i], $p[ $i + 1 ] );
            }
        }

        if ( @s > 1 ) {
            printf {STDERR} "* There should be only one successor, as anchors arn't overlapped\n";
            printf "    [%s] successors\n", scalar @s;
            @s = map { $_->[0] }
                sort { $a->[1] <=> $b->[1] }
                map { [ $_, $graph->get_edge_weight( $l, $_, ) ] } @s;
            for my $i ( 0 .. $#s - 1 ) {
                printf "    Add by s distances: %s -> %s\n", $s[$i], $s[ $i + 1 ];
                $anchor_graph->add_edge( $s[$i], $s[ $i + 1 ] );
            }
        }

    }
    g2gv( $anchor_graph, $ARGV[0] . ".png" );
    printf "Reduced %d edges\n", transitively_reduce($anchor_graph);
    g2gv( $anchor_graph, $ARGV[0] . ".reduced.png" );
}
g2gv( $graph, $ARGV[0] . ".all.png" );

sub transitively_reduce {

    #@type Graph
    my $g = shift;

    my $count = 0;
    my $prev_count;
    while (1) {
        last if defined $prev_count and $prev_count == $count;
        $prev_count = $count;

        for my $v ( $g->vertices ) {
            next if $g->out_degree($v) < 2;

          #            printf "Node %s, in %d, out %d\n", $v, $g->in_degree($v), $g->out_degree($v);

            my @s = sort { $a <=> $b } $g->successors($v);

            #            printf "    Successers %s\n", join( " ", @s );

            for my $i ( 0 .. $#s ) {
                for my $j ( 0 .. $#s ) {
                    next if $i == $j;
                    if ( $g->is_reachable( $s[$i], $s[$j] ) ) {
                        $g->delete_edge( $v, $s[$j] );

                    #                        printf "    Exiests edge %s -> %s\n", $s[$i], $s[$j];
                    #                        printf "        So remove edge %s -> %s\n", $v, $s[$j];
                        $count++;
                    }
                }
            }
        }
    }

    return $count;
}

sub g2gv {

    #@type Graph
    my $g  = shift;
    my $fn = shift;

    my $gv = GraphViz->new( directed => 1 );

    for my $v ( $g->vertices ) {
        $gv->add_node($v);
    }

    for my $e ( $g->edges ) {
        $gv->add_edge( @{$e} );
    }

    Path::Tiny::path($fn)->spew_raw( $gv->as_png );
}
