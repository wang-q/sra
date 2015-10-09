package MySRA;
use Moose;
use Carp;

use WWW::Mechanize;
use Number::Format qw(:subs);

use YAML qw(Dump Load DumpFile LoadFile);

has 'proxy' => ( is => 'rw', isa => 'Str', );

sub BUILD {
    my $self = shift;

    return;
}

# if the srp contains more than 200 srx, use erp_worker
sub srp_worker {
    my $self = shift;
    my $term = shift;

    my $mech = WWW::Mechanize->new;
    $mech->stack_depth(0);    # no history to save memory
    $mech->proxy( [ 'http', 'ftp' ], $self->proxy ) if $self->proxy;

    my $url_part1 = "http://www.ncbi.nlm.nih.gov/sra?term=";
    my $url_part2 = "&from=begin&to=end&dispmax=200";
    my $url       = $url_part1 . $term . $url_part2;
    print $url, "\n";

    my @srx;

    $mech->get($url);

    my @links = $mech->find_all_links( url_regex => qr{sra\/[DES]RX\d+}, );

    printf "OK, get %d SRX\n", scalar @links;
    @srx = map { /sra\/([DES]RX\d+)/; $1 } map { $_->url } @links;

    return \@srx;
}

sub erp_worker {
    my $self = shift;
    my $term = shift;

    my $mech = WWW::Mechanize->new;
    $mech->stack_depth(0);    # no history to save memory
    $mech->proxy( [ 'http', 'ftp' ], $self->proxy ) if $self->proxy;

    my $url_part1 = "http://www.ebi.ac.uk/ena/data/warehouse/filereport?accession=";
    my $url_part2 = "&result=read_run&fields=secondary_study_accession,experiment_accession";
    my $url       = $url_part1 . $term . $url_part2;
    print $url, "\n";

    $mech->get($url);
    my @line = split /\n/, $mech->content;

    my @srx;
    for (@line) {
        if (/^$term\t([DES]RX\d+)/) {
            push @srx, $1;

        }
    }
    printf "OK, get %d SRX\n", scalar @srx;

    return \@srx;
}

# query sample name, not srs
sub srs_worker {
    my $self = shift;
    my $term = shift;

    my $mech = WWW::Mechanize->new;
    $mech->stack_depth(0);    # no history to save memory
    $mech->proxy( [ 'http', 'ftp' ], $self->proxy ) if $self->proxy;

    my $url_part1 = "http://www.ncbi.nlm.nih.gov/biosample/?term=";
    my $url_part2 = "&from=begin&to=end&dispmax=200";
    my $url       = $url_part1 . $term . $url_part2;
    print $url, "\n";

    my @srx;

    $mech->get($url);

    # this link exists in both summary and detailed pages
    $mech->follow_link(
        text_regex => qr{[DES]RS\d+},
        url_regex  => => qr{sample},
    );

    {
        my @links = $mech->find_all_links(
            text_regex => qr{[DES]RX\d+},
            url_regex  => qr{report},
        );

        printf "OK, get %d SRX\n", scalar @links;
        @srx = map { $_->text } @links;
    }

    return \@srx;
}

sub erx_worker {
    my $self = shift;
    my $term = shift;

    my $mech = WWW::Mechanize->new;
    $mech->stack_depth(0);    # no history to save memory
    $mech->proxy( [ 'http', 'ftp' ], $self->proxy ) if $self->proxy;

    my $url_part1 = "http://www.ebi.ac.uk/ena/data/warehouse/filereport?accession=";
    my $url_part2
        = "&result=read_run&fields=secondary_study_accession,secondary_sample_accession,"
        . "experiment_accession,run_accession,scientific_name,"
        . "instrument_platform,instrument_model,"
        . "library_name,library_layout,nominal_length,library_source,library_selection,"
        . "read_count,base_count,sra_md5,sra_ftp&download=txt";
    my $url = $url_part1 . $term . $url_part2;
    print $url, "\n";

    $mech->get($url);
    my @lines = split /\n/, $mech->content;

    # header line
    shift @lines;

    # prompt SRR
    chomp for @lines;
    if ( scalar @lines ) {
        printf "OK, get %d SRR\n", scalar @lines;
    }
    else {
        print "Can't get any SRR, please check.\n";
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

    my ( @srr, @downloads );
    for my $line (@lines) {
        my @f = split /\t/, $line;
        print " " x 4, "$f[3]\n";
        push @srr,       $f[3];
        push @downloads, "ftp://" . $f[15];
        $info->{srr_info}{ $f[3] } = {
            spot => $f[12],
            base => format_bytes( $f[13] ),
            md5  => $f[14],
        };
    }
    $info->{srr}       = \@srr;
    $info->{downloads} = \@downloads;

    return $info;
}

1;
