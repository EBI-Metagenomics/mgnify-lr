#!/usr/bin/perl

# gen_stats_json.pl --reads [reads Fastq] --contigs [contigs Fasta] --out [out JSON] [PARAM]
# script to generate an assembly stats JSON for ENA upload
# (C) 2021 EMBL-EBI

use strict;
use warnings;
use Getopt::Long;

my $reads       = undef;
my $contigs     = undef;
my $out         = "assembly_stats.json";
my $mem_alloc   = 100;
my $peak_mem    = 0.0;
my $exec_time   = 0.0;
my $assembler   = "Flye";
my $version     = "2.8.1";
my $our_version = "0.6";
my $threads     = 1;
my $mode        = "map-ont";
my $reads1      = undef;
my $reads2      = undef;

GetOptions ("reads=s"     => \$reads,
            "contigs=s"   => \$contigs,
            "out=s"       => \$out,
            "assembler=s" => \$assembler,
            "version=s"   => \$version,
            "mem_alloc=i" => \$mem_alloc,
            "peak_mem=f"  => \$peak_mem,
            "exec_time=f" => \$exec_time,
            "ncores=i"    => \$threads,
            "type_aln=s"  => \$mode,
            "1pair=s"     => \$reads1,
            "2pair=s"     => \$reads2
        )
or print_help();
print_help() unless (defined $reads and defined $contigs);
open (my $oh, ">", $out) or die ("cannot write output to $out\n");

my $input_bp = 0;
my $coverage = 0.0;
if (defined $reads1 and defined $reads2) {
    warn "hybrid assembly detected\n";
    $input_bp  = calc_input_bp($reads);
    $input_bp += calc_input_bp($reads1);
    $input_bp += calc_input_bp($reads2);
    $coverage  = calc_coverage_hyb($contigs, $reads, $reads1, $reads2);
}
else {
    $input_bp = calc_input_bp($reads);
    $coverage = calc_coverage($contigs, $reads);
}
my %stats    = calc_assembly_stats($contigs);

print $oh <<JSON
{
  "assembler_name": "$assembler",
  "assembler_version": "$version",
  "mem_alloc": $mem_alloc,
  "peak_mem": $peak_mem,
  "exec_time": $exec_time,
  "input_read_count": $input_bp,
  "limited_1000": [$stats{'seq_num_1k'}, $stats{'seq_bp_1k'}],
  "limited_10000": [$stats{'seq_num_10k'}, $stats{'seq_bp_10k'}],
  "limited_50000": [$stats{'seq_num_50k'}, $stats{'seq_bp_50k'}],
  "num_contigs": $stats{'seq_num'},
  "assembly_length": $stats{'seq_bp'},
  "largest_contig": $stats{'longest'},
  "n50": $stats{'n50'},
  "l50": $stats{'l50'},
  "coverage": $coverage,
  "version": $our_version
}
JSON
;
close $oh;

sub print_help {
    print <<HELP;
Usage: perl gen_stats_json.pl [PARAMS]
    
PARAMS
    --contigs   -c    [str]    Path to the contigs Fasta
    --reads     -r    [str]    Path to the reads Fastq
    --out       -o    [str]    Output JSON file, default: "$out"
    --assembler -a    [str]    Assembler name, default: "$assembler"
    --version   -v    [str]    Assembler version, default: "$version"
    --mem_alloc -m    [int]    Reported mem allocation (Gb), default: "$mem_alloc"
    --peak_mem  -p    [float]  Reported mem peak (Gb),default: "$peak_mem"
    --exec_time -e    [float]  Reported run time (secs), default: "$exec_time"
    --ncores    -n    [int]    Threads to use in mapping, default: "$threads"
    --type_aln  -t    [str]    Align mode for Minimap2, default: "$mode"
    --1pair     -1    [str]    Path to the first pair reads Fastq in Hybrid Assembly 
    --2pair     -2    [str]    Path to the second pair reads Fastq in Hybrid Assembly

HELP

    die("\n");
}

sub calc_input_bp {
    my $fastq = shift @_;
    warn "counting bases in $fastq\n";
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
            s/N//i;
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
    warn "computing assembly stats for $fasta\n";
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
        if ($len >= 10000) {
            $s{'seq_num_10k'}++;
            $s{'seq_bp_10k'} += $len;
        }
        if ($len >= 50000) {
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

sub calc_coverage {
    my $contigs = shift @_;
    my $reads   = shift @_;
    warn "computing coverage for contigs $contigs using reads $reads\n";
    my @path = split(/\//, $contigs);
    my $name = $path[-1];
    $name =~ s/.gz$//;
    $name =~ s/.fasta$//;
    $name =~ s/.fa$//;
    my $sam  = "$name.sam";
    my $bam  = "$name.bam";
    system("minimap2 -a -t $threads -x $mode $contigs $reads > $sam");
    system("samtools sort -o $bam $sam");
    system("samtools coverage $bam > $contigs.cov");
    my $sum = 0;
    my $num = 0;
    open (my $ch, "<", "$contigs.cov") or die "error reading $contigs.cov\n";
    while (<$ch>) {
        next if (/^#/);
        chomp;
        $num++;
        my @ln = split(/\s+/, $_);
        $sum += $ln[5];
    }
    close $ch;
    my $mean = $sum / $num;
    $mean /= 100;
    return $mean;
}

sub calc_coverage_hyb {
    my $contigs = shift @_;
    my $reads   = shift @_;
    my $reads1  = shift @_;
    my $reads2  = shift @_;
    warn "computing coverage for contigs $contigs using reads $reads/$reads1/$reads2\n";
    my @path = split(/\//, $contigs);
    my $name = $path[-1];
    $name =~ s/.gz$//;
    $name =~ s/.fasta$//;
    $name =~ s/.fa$//;
    my $sam    = "$name.sam";
    my $bam    = "$name.bam";
    my $sam2   = $name. "_pe.sam";
    my $bam2   = $name. "_pe.bam";
    my $merge  = "$name" . "_merged.bam"
    my $sort = "$name" . "_sorted.bam"
    system("minimap2 -a -t $threads -x $mode $contigs $reads > $sam");
    system("samtools sort -o $bam $sam");
    system("minimap2 -a -t $threads -x sr $contigs $reads1 $reads2 > $sam2");
    system("samtools sort -o $bam2 $sam2");
    system("samtools merge -o $merge $bam $bam2")
    system("samtools sort -o $sort $merge")
    system("samtools coverage $sort > $contigs.cov");
    my $sum = 0;
    my $num = 0;
    open (my $ch, "<", "$contigs.cov") or die "error reading $contigs.cov\n";
    while (<$ch>) {
        next if (/^#/);
        chomp;
        $num++;
        my @ln = split(/\s+/, $_);
        $sum += $ln[5];
    }
    close $ch;
    my $mean = $sum / $num;
    $mean /= 100;
    return $mean;
}