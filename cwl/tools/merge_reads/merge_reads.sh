#!/bin/bash

FQ1=$1
FQ2=$2
OUT="merged_reads.fastq.gz"

if [ ! -f $FQ1 ]; then echo "Fastq 1 $FQ1 is missing, abort"; exit 1; fi
if [ ! -f $FQ2 ]; then echo "Fastq 2 $FQ2 is missing, abort"; exit 1; fi

gunzip -c $FQ1 | perl -pe 's/$1/$&:1/ if (m/^@(\S+)/)' | gzip  > $OUT

gunzip -c $FQ2 | perl -pe 's/$1/$&:2/ if (m/^@(\S+)/)' | gzip >> $OUT
