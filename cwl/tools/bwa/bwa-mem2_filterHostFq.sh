#!/bin/bash

# bwa-mem2.sh
# Script to run bwa-mem2 filtering reads mapped to a host genome
# Output are unmapped reads in Fastq format (paired)
# (C) 2020 EMBL - EBI

THR=$1
REF=$2
IN1=$3
IN2=$4
OUT1=$5
OUT2=$6
echo "creating index for $REF"
bwa-mem2 index $REF

echo "aligning $FQ1 | $FQ2 to $REF"
bwa-mem2 mem -t $THR $REF $FQ1 $FQ2 | samtools fastq -f 4 -1 $OUT1 -2 $OUT2  

echo "all done"