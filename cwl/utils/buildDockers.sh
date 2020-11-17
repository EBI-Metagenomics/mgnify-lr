#!/bin/bash

# buildDockers.sh
# Script to build docker containers for mgnify-lr CWL pipeline
# (C) 2020 EMBL-EBI

REPO="jcaballero"
WDIR=$PWD
TOOLFILE="tools.txt"

for LINE in $(cat $TOOLS)
do
    TOOL=$(echo $LINE | perl -pe 's/#.+//')
    TAG="${REPO}/$(echo $LINE | perl -pe 's/.+#//')"
    DOCKERDIR="$WDIR/../tools/$TOOL"
    if [ -f "$DOCKERDIR/Dockerfile" ]
    then
        echo "Building $TOOL"
        docker build -t $TAG $DOCKERDIR
    else
        echo "No Dockerfile for $TOOL in $DOCKERDIR, skipped"
    fi
done
echo "All containers ready"
