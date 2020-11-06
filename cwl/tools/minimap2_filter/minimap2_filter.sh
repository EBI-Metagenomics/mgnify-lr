#!/bin/bash

# minimap2_filter.sh <THREADS> <FASTQ/FASTA> <INDEX> <READS> <OUTPUT.gz>
# wrapper script for minimap2 + samtools, it will retrieve any unmapped sequence
# Juan Caballero <jcaballero@ebi.ac.uk>
# (C) 2020 EMBL-EBI

THREADS=$1
FORMAT=$2
INDEX=$3
READS=$4
OUTFILE=$5

minimap2 -a -t $THREADS $INDEX $READS | samtools $FORMAT -f 4 | gzip > $OUTFILE