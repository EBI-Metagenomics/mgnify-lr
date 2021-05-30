#!/usr/bin/perl

use strict;
use warnings;

$ARGV[1] or die "use: perl merge_reads.pl FASTQ_1 FASTQ_2\n";

my $fq1 = shift @ARGV;
my $fq2 = shift @ARGV;
my $out = "merged_reads.fastq.gz";
my $ln = 0;
my $rn = 0;

open (my  $oh, '|-',    "gzip > $out") or die "cannot write $out\n";
open (my $fh1, '-|', "gunzip -c $fq1") or die "cannot read $fq1\n";
while (<$fh1>) {
    $ln++;
    if ($ln == 1) {
        $rn++;
        print $oh ">read_$rn\n";
    }
    else {
        print $oh "$_";
    }
    $ln = 0 if ($ln == 4);
}
close $fh1;

$ln = 0;
open (my $fh2, '-|', "gunzip -c $fq2") or die "cannot read $fq2\n";
while (<$fh2>) {
    $ln++;
    if ($ln == 1) {
        $rn++;
        print $oh ">read_$rn\n";
    }
    else {
        print $oh "$_";
    }
    $ln = 0 if ($ln == 4);
}
close $fh2;
close $oh;