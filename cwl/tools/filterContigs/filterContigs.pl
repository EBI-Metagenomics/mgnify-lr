#!/usr/bin/perl

# filterContigs.pl --size [int] --in [input file] --out [output file]
# script to filter contigs by size in a sequence file (Fasta)
# (C) 2020 EMBL-EBI

use strict;
use warnings;
use Getopt::Long;

my $infile  = undef;
my $minsize = undef;
my $outfile = undef;
my $total   = 0;
my $pass    = 0;
my $ih;
my $oh;

GetOptions ("size=i"   => \$minsize,
            "in=s"     => \$infile,
            "out=s"    => \$outfile)
or die("Usage: filterContigs.pl --size [int] --in [input file] --out [output file]\n");

if ( !($infile) or !($minsize) or !($outfile) ) {
    die("Usage: filterContigs.pl --size [int] --in [input file] --out [output file]\n");
}


# Check if input file is compressed
if ($infile =~ /gz$/i) {
    open($ih, "-|", "gunzip", "-c", $infile) or die ("cannot read compressed file $infile\n");
}
else {
    open($ih, "<", $infile) or die ("cannot read compressed file $infile\n");
}
# check if we want a compressed output
if ($outfile =~ /gz$/i){
    open($oh, "|-", "gzip > $outfile") or die ("cannot write compressed file $outfile\n");
}
else {
    open ($oh, ">", $outfile) or die ("cannot write output to $outfile\n");
}

# Read sequences and filter
$/ = "\n>";
while (<$ih>) {
    s/>//g;
    $total++;
    my ($id, @seq) = split (/\n/, $_);
    my $seq = join "", @seq;
    my $len = length $seq;
    if ($len >= $minsize) {
        print $oh ">$id\n";
        while ($seq) {
            print $oh substr($seq, 0, 80), "\n";
            substr($seq, 0, 80) = '';
        }
        $pass++;
    }
}
close $ih;
close $oh;

# quick report
my @path = split(/\//, $infile);
warn "Input file:  $path[-1]\n";
warn "Min size:    $minsize\n";
warn "Sequences:   $total\n";
warn "Passed seqs: $pass\n";
