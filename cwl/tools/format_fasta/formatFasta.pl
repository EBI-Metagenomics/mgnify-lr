#!/usr/bin/perl

# formatFasta.pl --in [input file] --out [output file]
# script to format an input sequence file to Fasta format
# (C) 2002 EMBL-EBI

use strict;
use warnings;
use Getopt::Long;

my $infile  = undef;
my $outfile = undef;
my $cols    = 80;

GetOptions ("col=i" => \$cols,
            "in=s"  => \$infile,
            "out=s" => \$outfile)
or die("Usage: formatFasta.pl --col [col size] --in [input file] --out [output file]\n");

if ( !($infile) or !($outfile) ) {
   die("Usage: formatFasta.pl --col [col size] --in [input file] --out [output file]\n");
}

my $ih;
my $oh;

# Check if input file is compressed
if ($infile =~ /gz$/i) {
    open($ih, "-|", "gunzip", "-c", $infile) or die ("cannot read compressed file $infile\n");
}
else {
    open($ih, "<", $infile) or die ("cannot read compressed file $infile\n");
}
open ($oh, ">", $outfile) or die ("cannot write output to $outfile\n");

while (<$ih>) {
    my $ln = $_;
    if ($ln =~ /^>/) {
        print $oh $ln;
    }
    else {
        while ($ln) {
            print $oh substr($ln, 0, $cols), "\n";
            substr($ln, 0, $cols) = '';
        }
    }
}

close $oh;
close $ih;