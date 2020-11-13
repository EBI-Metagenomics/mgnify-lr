#!/bin/bash

# bwa-mem2.sh
# Script to run bwa-mem2
# (C) 2020 EMBL - EBI

THR=$1
REF=$2
FQ1=$3
FQ2=$4
BAM=$5

echo "creating index for $REF"
bwa-mem2 index $REF

echo "aligning $FQ1 | $FQ2 to $REF"
bwa-mem2 mem -t $THR $REF $FQ1 $FQ2 | samtools sort -o $BAM -

echo "indexing $BAM"
samtools index $BAM

echo "all done"