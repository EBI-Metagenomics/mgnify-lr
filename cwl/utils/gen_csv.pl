#!/usr/bin/perl

# gen_csv.pl --reads [reads fastq] --contigs [contigs fasta] --out [report file]
# script to generate a CSV table for ENA upload
# (C) 2021 EMBL-EBI

use strict;
use warnings;
use Getopt::Long;

my $reads     = undef;
my $contigs   = undef;
my $out       = undef;
my $proj      = undef;
my $run       = undef;
my $coverage  = undef;
my $assembler = "Flye";
my $version   = "2.8.1";
my $lineage   = "";
my $biome     = "";
my $upload    = "yes";
my $nohead    = undef;

GetOptions ("reads=s"     => \$reads,
            "fasta=s"     => \$contigs,
            "out=s"       => \$out,
            "proj=s"      => \$proj,
            "idrun=s"     => \$run,
            "assembler=s" => \$assembler,
            "version=s"   => \$version,
            "lineage=s"   => \$lineage,
            "biome=s"     => \$biome,
            "upload=s"    => \$upload,
            "coverage=s"  => \$coverage,
            "nohead"      => \$nohead
        )
or print_help();
print_help() if ( !($reads) or !($contigs) or !($out) or !($proj) or !($run) or !($coverage));
   
my $header = "Project ID,Run ID,Assembler name,Assembler version,Input base pairs,Assembled base pairs (raw),Coverage,Num contigs,Largest contig,N50,L50,Num contigs (min length 1000),Sum of BP of contigs (min length 1000),Num contigs (min length 10000),Sum of BP of contigs (min length 10000),Num contigs (min length 50000),Sum of BP of contigs (min length 50000),lineage,biome_id,upload(yes/no),reason";
open (my $oh, ">", $out) or die ("cannot write output to $out\n");

print $oh "$header\n" unless ($nohead);

my $input_bp = calc_input_bp($reads);
my %stats    = calc_assembly_stats($contigs);

print $oh join ",", 
            $proj, 
            $run, 
            $assembler, 
            $version, 
            $input_bp, 
            $stats{'seq_bp'}, 
            $coverage, 
            $stats{'seq_num'}, 
            $stats{'longest'}, 
            $stats{'n50'}, 
            $stats{'l50'}, 
            $stats{'seq_num_1k'}, 
            $stats{'seq_bp_1k'}, 
            $stats{'seq_num_10k'}, 
            $stats{'seq_bp_10k'}, 
            $stats{'seq_num_50k'}, 
            $stats{'seq_bp_50k'},
            $lineage,
            $biome,
            $upload,
            "\n"; 
close $oh;

sub print_help {
    print <<HELP;
Usage: perl gen_csv.pl [PARAMS]
    
PARAMS
    --fasta     -f     Path to the contigs Fasta*
    --reads     -r     Path to the reads Fastq*
    --out       -o     Path to report file*
    --proj      -p     Project ID*
    --idrun     -i     Run ID*
    --coverage  -c     Computed coverage*
    --assembler -a     Assembler name, default: "$assembler"
    --version   -v     Assembler version, default: "$version"
    --lineage   -l     Lineage
    --biome     -b     Biome
    --upload    -u     Upload field (yes/no), default: "$upload"
    --nohead    -n     Don't print header line

 *Required

HELP

    die("\n");
}

sub calc_input_bp {
    my $fastq = shift @_;
    my $fh;
    if ($fastq =~ /gz$/i) {
        open($fh, "-|", "gunzip", "-c", $fastq) or die ("cannot read compressed file $fastq\n");
    }
    else {
        open($fh, "<", $fastq) or die ("cannot read file $fastq\n");
    }
    my $nl = 0;
    my $bp = 0;
    while (<$fh>) {
        $nl++;
        if ($nl == 2) {
            chomp;
            $bp += length($_);
        }
        elsif ($nl == 4) {
            $nl = 0;
        }
    } 
    close $fh;
    return $bp;
}

sub calc_assembly_stats {
    my $fasta = shift @_;
    my $fh;
    my %s;
    if ($fasta =~ /gz$/i) {
        open($fh, "-|", "gunzip", "-c", $fasta) or die ("cannot read compressed file $fasta\n");
    }
    else {
        open($fh, "<", $fasta) or die ("cannot read file $fasta\n");
    }
    $s{'seq_num'}     = 0;
    $s{'seq_bp'}      = 0;
    $s{'longest'}     = 0;
    $s{'n50'}         = 0;
    $s{'l50'}         = 0;
    $s{'seq_num_1k'}  = 0;
    $s{'seq_bp_1k'}   = 0;
    $s{'seq_num_10k'} = 0;
    $s{'seq_bp_10k'}  = 0;
    $s{'seq_num_50k'} = 0;
    $s{'seq_bp_50k'}  = 0;

    my @len;
    $/ = "\n>";    
    while (<$fh>) {
        s/>//g;
        my ($id, @seq) = split (/\n/, $_);
        my $seq = join "", @seq;
        my $len = length $seq;
        $s{'seq_num'}++;
        $s{'seq_bp'} += $len;
        if ($len >= 1000) {
            $s{'seq_num_1k'}++;
            $s{'seq_bp_1k'} += $len;
        }
        elsif ($len >= 10000) {
            $s{'seq_num_10k'}++;
            $s{'seq_bp_10k'} += $len;
        }
        elsif ($len >= 50000) {
            $s{'seq_num_50k'}++;
            $s{'seq_bp_50k'} += $len;
        }
        push @len, $len;
    }

    @len = sort { $b <=> $a } @len;
    $s{'longest'} = $len[0];
    my $limit = $s{'seq_bp'} / 2;
    my $pos = 0;
    for (@len) {
        $pos += $_;
        $s{'l50'}++;
        if($pos >= $limit){
            $s{'n50'} = $_;
            last;
        }
    }
    close $fh;
    return %s;
}