#!/bin/bash

# minimap2_filter.sh <THREADS> <FASTQ/FASTA> <INDEX> <READS> <OUTPUT.gz>
# wrapper script for minimap2 + samtools, it will retrieve any unmapped sequence
# Juan Caballero <jcaballero@ebi.ac.uk>
# (C) 2020 EMBL-EBI

# Defaults
export THREADS=1
export FORMAT="fastq"
export ALNMODE="map-ont"
export GENOME=null
export READS=null
export OUTFILE=null

while getopts :t:f:a:g:r:o: option; do
    case "${option}" in
        t) THREADS=${OPTARG};;
        f) FORMAT=${OPTARG};;
        a) ALNMODE=${OPTARG};;
        g) GENOME=${OPTARG};;
        r) READS=${OPTARG};;
        o) OUTFILE=${OPTARG};;
        *) echo "unknow option"; exit;;
    esac
done

case $FORMAT in
    fastq)
        minimap2 -a -x $ALNMODE -t $THREADS $GENOME $READS | samtools $FORMAT -f 4 | gzip > $OUTFILE
    ;;
    fasta)
        minimap2 -a -x $ALNMODE -t $THREADS $GENOME $READS | samtools $FORMAT -f 4 > $OUTFILE
    ;;
    *)
        echo "unknown format $FORMAT"
        exit
    ;;
esac
