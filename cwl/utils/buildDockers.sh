#!/bin/bash

# buildDockers.sh
# Script to build docker containers for mgnify-lr CWL pipeline
# Juan Caballero <jcaballero@ebi.ac.uk>
# (C) 2020 EMBL-EBI

WDIR=$PWD
TOOLS="bbduk bwa flye getHostFasta ideel medaka minimap2 nanoplot pilon racon removeSmallReads samtools spades"

for TOOL in $TOOLS
do
    DKFILE="$WDIR/../tools/$TOOL/Dockerfile"
    if [ -f "$DKFILE" ]
    then
        echo "Building $TOOL"
        docker build -t $TOOL $DKFILE
    else
        echo "No Dockerfile for $TOOL in $DKFILE, skipped"
    fi
done
echo "All containers ready"