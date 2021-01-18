#!/bin/perl

use strict;
use warnings;

my $sum = 0;
my $num = 0;
while (<>) {
    next if (/^#/);
    chomp;
    $num++;
    my @ln = split(/\s+/, $_);
    $sum += $ln[5];
}

my $mean = $sum / $num;
$mean /= 100;
print "$mean\n";