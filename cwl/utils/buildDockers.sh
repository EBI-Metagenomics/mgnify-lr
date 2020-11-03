#!/bin/bash

# buildDockers.sh
# Script to build docker containers for mgnify-lr CWL pipeline
# Juan Caballero <jcaballero@ebi.ac.uk>
# (C) 2020 EMBL-EBI

WDIR=$PWD
TOOLS="flye getHostFasta ideel medaka minimap2 nanoplot racon removeSmallReads samtools"

for TOOL in $TOOLS
do
    DOCKERKDIR="$WDIR/../tools/$TOOL"
    if [ -f "$DOCKERDIR/Dockerfile" ]
    then
        echo "Building $TOOL"
        docker build -t $(echo $TOOL | perl -lane 'print lc($F[0])') $DOCKERDIR
    else
        echo "No Dockerfile for $TOOL in $DOCKERDIR, skipped"
    fi
done
echo "All containers ready"
