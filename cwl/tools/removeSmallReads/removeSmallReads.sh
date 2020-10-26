#!/bin/bash

# removeSmallReads.sh
# Quick tool to remove small reads in a Fastq input.

LENGTH=$1
READS=$2
OUT=$3

case "$READS" in
    *.gz) 
        zcat $READS | paste - - - - | awk -F"\t" "length(\$2) >= $LENGTH" | sed 's/\t/\n/g' | gzip > "$OUT"
    ;;
    *)
        cat $READS | paste - - - - | awk -F"\t" "length(\$2) >= $LENGTH" | sed 's/\t/\n/g' | gzip > "$OUT"
    ;;
esac
