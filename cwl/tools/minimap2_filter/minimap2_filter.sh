#!/bin/bash

# minimap2_filter.sh <THREADS> <FASTQ/FASTA> <INDEX> <READS> <OUTPUT.gz>
# wrapper script for minimap2 + samtools, it will retrieve any unmapped sequence
# Juan Caballero <jcaballero@ebi.ac.uk>
# (C) 2020 EMBL-EBI

THREADS=$1
FORMAT=$2
ALNMODE=$3
INDEX=$4
READS=$5
OUTFILE=$6

if [ "$FORMAT" == "fastq" ]
then
    minimap2 -a -x $ALNMODE -t $THREADS $INDEX $READS | samtools $FORMAT -f 4 | gzip > $OUTFILE
else
    minimap2 -a -x $ALNMODE -t $THREADS $INDEX $READS | samtools $FORMAT -f 4 > $OUTFILE
fi
