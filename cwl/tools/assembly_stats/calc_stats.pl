#!/usr/bin/perl

# calc_stats.pl --format [fastq|fasta] --in [input file] --out [output file]
# script to compute N50 in a sequence file (Fasta or FastQ)
# (C) 2002 EMBL-EBI

use strict;
use warnings;
use Getopt::Long;

my $infile  = undef;
my $format  = undef;
my $outfile = undef;

GetOptions ("format=s" => \$format,
            "in=s"     => \$infile,
            "out=s"    => \$outfile)
or die("Usage: calc_stats.pl --format [fastq|fasta] --in [input file] --out [output file]\n");

if ( !($infile) or !($format) or !($outfile) ) {
    die("Usage: calc_stats.pl --format [fastq|fasta] --in [input file] --out [output file]\n");
}

my $totalLen = 0;
my $numSeqs  = 0;
my @len      = ();
my $nl       = 0;
my $n50      = 0;
my $l50      = 0;
my $ih;
my $oh;

# Check if file is compressed
if ($infile =~ /gz$/i) {
    open($ih, "-|", "gunzip", "-c", $infile) or die ("cannot read compressed file $infile\n");
}
else {
    open($ih, "<", $infile) or die ("cannot read compressed file $infile\n");
}

# Read sequence length
if ($format =~ /fastq/i) {
    while (<$ih>) {
        $nl++;
        if ($nl == 2) {
            chomp;
            my $len = length $_;
            $totalLen += $len;
            push @len, $len;
            $numSeqs++;
        }
        elsif ($nl == 4) {
            $nl = 0;
        }
    }
}
elsif ($format =~ /fasta/i) {
    $/ = "\n>";
    while (<$ih>) {
        my ($id, @seq) = split (/\n/, $_);
        my $seq = join "", @seq;
        my $len = length $seq;
        $totalLen += $len;
        push @len, $len;
        $numSeqs++;
    }
}
else { die ("unrecognized format $format, use fastq or fasta\n"); }
close $ih;

# Calc N50
@len = sort { $b <=> $a } @len;
my $limit = $totalLen / 2;
my $pos = 0;
for (@len) {
    $pos += $_;
    $l50++;
    if($pos >= $limit){
        $n50 = $_;
        last;
  }
}

# Print output
open ($oh, ">", $outfile) or die ("cannot write output to $outfile\n");
my @path = split(/\//, $infile);
print $oh "Input file: $path[-1]\n";
print $oh "Sequences: " . ($#len + 1) . "\n";
print $oh "Total length: $totalLen\n";
print $oh "Longest sequence: $len[0]\n";
print $oh "N50: $n50\n";
print $oh "L50: $l50\n";
close $oh;