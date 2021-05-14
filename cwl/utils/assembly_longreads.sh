#!/bin/bash

# assembly_longreads.sh
# Script to launch MGnify-LR assemblies
# (C) 2021 EMBL - EBI

TARGETDIR=/hps/nobackup2/production/metagenomics/results/assemblies
LAUNCHER=/nfs/production/metagenomics/production/mgnify-lr/cwl/run/runMGnify-lr_LSF.sh
PROJECT=null
GENOME=null
RUNS=null
TECH=null
MEDAKAMODEL=r941_min_high_g360
MINILL=50
MINLR=200
MINCONTIG=500

print_help () {
    echo "assembly_longreads.sh [PARAM]"
    echo
    echo "Parameter |  Definition"
    echo "----------|------------"
    echo "   -p     |  ProjectID (SRPxxx|ERPxxx|DRPxxx)"
    echo "   -r     |  List or runs IDs (SRRxxx|ERRxxx|DRRxxx) to be assembled, if ommited, it assemble all runs in the project /raw directory"
    echo "   -t     |  Long-read technology: nanopore or pacbio"
    echo "   -g     |  Path to genome fasta file"
    echo "   -m     |  Medaka polish model, default $MEDAKAMODEL"
    echo "   -i     |  Minimal size for Illumina filtering, default $MINILL"
    echo "   -j     |  Minimal size for long-read filtering, default $MINLR"
    echo "   -k     |  Minimal size for contig filtering, default $MINCONTIG"
    echo "   -d     |  Assembly project directory, default $TARGETDIR"
}

# simple error printing and script exit
error_exit () {
    echo "Error: $1"
    print_help
    exit 1
}

launch_job () {
    FQ=$1
    NAME=$(basename $FQ .fastq.gz)
    echo "Launching assembly job $NAME"
    CMD="bsub -q production-rh74 -e $RAWDIR/../$NAME.err -o $RAWDIR/../$NAME.log -J $NAME 'bash $LAUNCHER -p $PROJECT -s $FQ -h $TECH -t assembly -g $GENOME -k $MEDAKAMODEL -i $MINILL -j $MINLR -c $MINCONTIG'"
    echo $CMD
    $CMD
}

# Parameter capture
while getopts :p:r:t:m:i:j:k:g:d: option; do
    case "${option}" in
        p) PROJECT=${OPTARG};;
        r) RUNS=${OPTARG};;
        t) TECH=${OPTARG};;
        m) MEDAKAMODEL=${OPTARG};;
        i) MINILL=${OPTARG};;
        j) MINLR=${OPTARG};;
        k) MINCONTIG=${OPTARG};;
        g) GENOME=${OPTARG};;
        d) TARGETDIR=${OPTARG};;
        *) echo "invalid option: $option"; exit;;
    esac
done

# input validation
if [ "$PROJECT" == "null" ]; then error_exit "missing ProjectID (-p)"; fi
if [ "$TECH"    == "null" ]; then error_exit "missing technology (-t)"; fi

PROJ=$(echo "$PROJECT" | perl -lane 'print $1 if (/([ESD]RP\d\d\d\d)/)')
RAWDIR="$TARGETDIR/$PROJ/$PROJECT/raw"
if [ ! -d "$RAWDIR" ]
then
    error_exit "$RAWDIR is missing or cannot be read"
fi

if [ "$RUNS" == "null" ]
then
    for FQ in "$RAWDIR"/*.fastq.gz
    do
        launch_job "$FQ"
    done
else
    for RUN in $( echo "$RUNS" | perl -pe 's/,/\n/g' )
    do
        FQ="$RAWDIR"/$RUN*.fastq.gz
        launch_job "$FQ"
    done
fi