#!/bin/bash

# bwa-mem2_filterHostFq.sh
# Script to run bwa-mem2 filtering reads mapped to a host genome
# Output are unmapped reads in Fastq format (paired)
# (C) 2020 EMBL - EBI

# Defaults
export THREADS=1
export ALNMODE="none"
export GENOME=null
export READS1=null
export READS2=null
export OUT1=null
export OUT2=null

while getopts :t:a:g:p:q:x:y: option; do
    case "${option}" in
        t) THREADS=${OPTARG};;
        a) ALNMODE=${OPTARG};;
        g) GENOME=${OPTARG};;
        p) READS1=${OPTARG};;
        q) READS2=${OPTARG};;
        x) OUT1=${OPTARG};;
        y) OUT2=${OPTARG};;
        *) echo "unknow option"; exit;;
    esac
done

if [ "$ALNMODE" == "none" ]
then
    echo "no aligning requested, just passing files"
    cp $READS1 $OUT1
    cp $READS2 $OUT2
else
    echo "creating index for $REF"
    bwa-mem2 index $GENOME

    echo "aligning $(basename $READS1) | $(basename $READS2) to $(basename $GENOME)"
    bwa-mem2 mem -t $THREADS $GENOME $READS1 $READS2 | samtools fastq -f 4 -1 $OUT1 -2 $OUT2  
fi

echo "all done"