#!/usr/bin/perl
use strict;
use warnings;
use autodie;

use Getopt::Long;
use Pod::Usage;
use YAML qw(Dump Load DumpFile LoadFile);

use AlignDB::Run;
use AlignDB::Util qw(:all);

use Time::Duration;
use File::Find::Rule;
use File::Spec;
use File::Basename;
use File::Path qw(make_path remove_tree);
use File::Temp qw( tempfile tempdir );
use File::Copy;
use Path::Class;
use String::Compare;

use FindBin;

#----------------------------------------------------------#
# GetOpt section
#----------------------------------------------------------#
my $id = "NA19703";

my $base_dir = File::Spec->catdir( $ENV{HOME}, "data/CG" );

my $bin_dir = {
    cga  => File::Spec->catdir( $ENV{HOME}, "bin" ),
    gatk => File::Spec->catdir( $ENV{HOME}, "share/GenomeAnalysisTK" ),
    pcd  => File::Spec->catdir( $ENV{HOME}, "share/picard" ),
};

my $ref_file = {
    seq   => File::Spec->catfile( $base_dir, "ref", "build37.fa" ),
    sizes => File::Spec->catfile( $base_dir, "ref", "chr.sizes" ),
    crr   => File::Spec->catfile( $base_dir, "ref", "build37.crr" ),
};
my $data_dir = {};

# run in parallel mode
my $parallel = 4;

my $memory = 1;

# running tasks
my $run = "all";

my $man  = 0;
my $help = 0;

GetOptions(
    'help|?'       => \$help,
    'man'          => \$man,
    'base=s'       => \$base_dir,
    'i|id=i'       => \$id,
    'p|parallel=i' => \$parallel,
    'r|run=s'      => \$run,
) or pod2usage(2);

pod2usage(1) if $help;
pod2usage( -exitstatus => 0, -verbose => 2 ) if $man;

#----------------------------------------------------------#
# Init
#----------------------------------------------------------#
my $start_time = time;
print "\n", "=" x 30, "\n";
print "Processing...\n";

# prepare to run tasks in @tasks
my @tasks;
if ( $run eq 'all' ) {
    @tasks = ( 1 .. 20 );
}

#elsif ( $run eq 'basic' ) {
#    @tasks = ( 1 .. 3 );
#}
else {
    $run =~ s/\"\'//s;
    if ( AlignDB::IntSpan->valid($run) ) {
        my $set = AlignDB::IntSpan->new($run);
        @tasks = $set->elements;
    }
    else {
        @tasks = grep {/\d/} split /\s/, $run;
    }
}

my ($asm_dir)
    = grep {/ASM.+$id\/?$/} File::Find::Rule->directory->in($base_dir);
die "Can't find dir for $id\n" unless $asm_dir;
$data_dir->{asm}    = $asm_dir;
$data_dir->{proc}   = File::Spec->catdir( $base_dir, "process", $id );
$data_dir->{evi}    = File::Spec->catdir( $data_dir->{proc}, "evi" );
$data_dir->{evibam} = File::Spec->catdir( $data_dir->{proc}, "evibam" );
$data_dir->{rawvcf}    = File::Spec->catdir( $data_dir->{proc}, "rawvcf" );
$data_dir->{vcf}    = File::Spec->catdir( $data_dir->{proc}, "vcf" );

print Dump $data_dir;

for ( keys %{$data_dir} ) {
    make_path( $data_dir->{$_} ) unless -e $_;
}

#----------------------------#
# extract
#----------------------------#
my $step_extract = sub {
    my @files
        = File::Find::Rule->file->name('*EVIDENCE*')->in( $data_dir->{asm} );
    printf "\n----%4s EVIDENCE files ----\n", scalar @files;
    return unless @files;

    my $worker = sub {
        my $job = shift;
        my $opt = shift;

        my $file     = $job;
        my $proc_dir = $data_dir->{proc};
        my $evi_dir  = $data_dir->{evi};

        my $tempdir = tempdir( "extract.XXXXXXXX", DIR => $proc_dir );

        print "Extract to $tempdir\n";
        my $cmd
            = qq{tar xf $file -C $tempdir --wildcards --no-anchored "*Dnbs*" };
        exec_cmd($cmd);

        my @evi_files = File::Find::Rule->file->in($tempdir);
        for (@evi_files) {
            move( $_, $evi_dir );
        }
        remove_tree($tempdir);
        print "EVIDENCE files extracted.\n\n";

        return;
    };

    my @jobs = sort @files;
    my $run  = AlignDB::Run->new(
        parallel => $parallel,
        jobs     => \@jobs,
        code     => $worker,
    );
    $run->run;

    return;
};

#----------------------------#
# extract
#----------------------------#
my $step_evidence2sam = sub {

    my @files = File::Find::Rule->file->name('*Dnbs*')->in( $data_dir->{evi} );
    printf "\n----%4s Dnbs files ----\n", scalar @files;
    return unless @files;

    my $worker = sub {
        my $job = shift;
        my $opt = shift;

        my $file       = $job;
        my $proc_dir   = $data_dir->{proc};
        my $evibam_dir = $data_dir->{evibam};
        my $ref_file   = $ref_file->{crr};
        $file =~ /\-(chr\w+)\-/;
        my $chr = $1;
        return unless $chr;
        my $bam_file = File::Spec->catfile( $evibam_dir, $chr );

        print "Run evidence2sam\n";
        my $cmd
            = "cgatools evidence2sam"
            . " --beta"
            . " --evidence-dnbs=$file"
            . " --reference=$ref_file"
            . " | samtools view -uS -"
            . " | samtools sort - $bam_file"
            . " && samtools index $bam_file.bam";
        exec_cmd($cmd);
        print "bam file created.\n\n";

        return;
    };

    my @jobs = sort @files;
    my $run  = AlignDB::Run->new(
        parallel => $parallel,
        jobs     => \@jobs,
        code     => $worker,
    );
    $run->run;

    return;
};

my $step_varcall = sub {

    my @files
        = File::Find::Rule->file->name('*.bam')->in( $data_dir->{evibam} );
    printf "\n----%4s bam files ----\n", scalar @files;
    return unless @files;

    my $worker = sub {
        my $job = shift;
        my $opt = shift;

        my $file     = $job;
        my $proc_dir = $data_dir->{proc};
        my $raw_vcf_dir  = $data_dir->{rawvcf};
        my $ref_file = $ref_file->{seq};
        $file =~ /(chr\w+)\./;
        my $chr = $1;
        return unless $chr;
        my $raw_vcf_file = File::Spec->catfile( $raw_vcf_dir, "$chr.raw.vcf" );

        print "Run GATK var call\n";
        my $cmd
            = "java -Xmx${memory}g -jar "
            . $bin_dir->{gatk}
            . "/GenomeAnalysisTK.jar"
            . " -nt $parallel"
            . " -T UnifiedGenotyper"
            . " -R $ref_file"
            . " -glm BOTH"
            . " -I $file"
            . " -o $raw_vcf_file";
        exec_cmd($cmd);
        print "raw vcf file created.\n\n";

        return;
    };

    my @jobs = sort @files;
    my $run  = AlignDB::Run->new(
        parallel => 1,
        jobs     => \@jobs,
        code     => $worker,
    );
    $run->run;

    return;
};

my $step_varfilter = sub {

    my @files
        = File::Find::Rule->file->name('*.raw.vcf')->in( $data_dir->{rawvcf} );
    printf "\n----%4s vcf files ----\n", scalar @files;
    return unless @files;

    my $worker = sub {
        my $job = shift;
        my $opt = shift;

        my $file     = $job;
        my $proc_dir = $data_dir->{proc};
        my $vcf_dir  = $data_dir->{vcf};
        my $ref_file = $ref_file->{seq};
        $file =~ /(chr\w+)\./;
        my $chr = $1;
        return unless $chr;
        my $vcf_file     = File::Spec->catfile( $vcf_dir, "$chr.vcf" );

        print "Hard filter\n";
        my $cmd
            = "java -Xmx${memory}g -jar "
            . $bin_dir->{gatk}
            . "/GenomeAnalysisTK.jar"
            . " -T VariantFiltration"
            . " -R $ref_file"
            . " --variant $file"
            . " -o $vcf_file"
            . " --filterExpression 'QUAL<30.0' "
            . " --filterName 'LowQual' "
            . " --filterExpression 'SB>=-1.0' "
            . " --filterName 'StrandBias' "
            . " --filterExpression 'QD<1.0' "
            . " --filterName 'QualByDepth' "
            . " --filterExpression '(MQ0 >= 4 && ((MQ0 / (1.0 * DP)) > 0.1))' "
            . " --filterName 'HARD_TO_VALIDATE' "
            . " --filterExpression 'HRun>=15' "
            . " --filterName 'HomopolymerRun' ";
        exec_cmd($cmd);
        print "Done.\n";

        return;
    };

    my @jobs = sort @files;
    my $run  = AlignDB::Run->new(
        parallel => 8,
        jobs     => \@jobs,
        code     => $worker,
    );
    $run->run;

    return;
};

my $dispatch = {
    1 => $step_extract,
    2 => $step_evidence2sam,
    3 => $step_varcall,
    4 => $step_varfilter,
};

for my $step (@tasks) {
    my $sub = $dispatch->{$step};
    next unless $sub;
    $sub->();
}

print "\n";
print "Runtime ", duration( time - $start_time ), ".\n";
print "=" x 30, "\n";

exit;

#----------------------------------------------------------#
# Subroutines
#----------------------------------------------------------#
sub exec_cmd {
    my $cmd = shift;

    print "\n", "-" x 12, "CMD", "-" x 15, "\n";
    print $cmd , "\n";
    print "-" x 30, "\n";

    system $cmd;
}

__END__

=head1 NAME

    amp.pl - axt-maf-phast pipeline

=head1 SYNOPSIS

    amp.pl -dt <one target dir or file> -dq <one query dir or file> [options]
      Options:
        -?, --help              brief help message
        --man                   full documentation

      Run in parallel mode
        -p, --paralle           number of child processes

      Fasta dirs  
        -dt, --dir_target       dir of target fasta files
        -dq, --dir_query        dir of query fasta files

      Output .lav and .axt
        -dl, --dir_lav          where .lav and .axt files storess

=head1 OPTIONS

=over 4

=item B<-help>

Print a brief help message and exits.

=item B<-man>

Prints the manual page and exits.

=back

=head1 DESCRIPTION


=cut
