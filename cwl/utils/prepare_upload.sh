#!/bin/bash

# prepare_upload.sh
# Script to prepare a MGnify-LR assembly to upload to ENA
# (C) 2021 EMBL - EBI

TARGETDIR=/hps/nobackup2/production/metagenomics/results/assemblies
PROJECT=null
CONTIGS=null
READSDIR=null
STATS=null
LOGS=null

print_help () {
    echo "prepare_upload.sh [PARAM]"
    echo
    echo "Parameter |  Definition"
    echo "   -p     |  ProjectID (SRPxxx|ERPxxx|DRPxxx)"
    echo "   -c     |  Path to the directory with contigs Fasta (file name must have run id [S/E/D]RRxxx)"
    echo "   -r     |  Path to the directory with raw reads Fastq (*fastq.gz)"
    echo "   -l     |  Path to the log file (Toil log)"
    echo "   -s     |  Path to the assembly_stats.json file"
}

# simple error printing and script exit
error_exit () {
    echo "Error: $1"
    print_help
    exit 1
}

# Parameter capture
while getopts :p:c:s:r:l: option; do
    case "${option}" in
        p) PROJECT=${OPTARG};;
        c) CONTIGS=${OPTARG};;
        s) STATS=${OPTARG};;
        r) READSDIR=${OPTARG};;
        l) LOGS=${OPTARG};;
        *) echo "invalid option: $option"; exit;;
    esac
done

# input validation
if [ "$PROJECT"  == "null" ]; then error_exit "missing ProjectID (-p)"; fi
if [ "$CONTIGS"  == "null" ]; then error_exit "missing Contigs (-c)"; fi
if [ "$READSDIR" == "null" ]; then error_exit "missing Reads dir (-r)" ; fi
if [ "$LOGS"     == "null" ]; then error_exit "missing Logs (-l)"; fi

echo "main directory preparation"
PROJ=$(echo "$PROJECT" | perl -lane 'print $1 if (/([ESD]RP\d\d\d\d)/)')
if [ -d "$TARGETDIR/$PROJ/$PROJECT" ]
then
    echo "$TARGETDIR/$PROJ/$PROJECT exist"
else
    echo "creating $TARGETDIR/$PROJ/$PROJECT"
    mkdir -p "$TARGETDIR/$PROJ/$PROJECT" || error_exit "cannot create $TARGETDIR/$PROJ/$PROJECT"
fi
WORKDIR="$TARGETDIR/$PROJ/$PROJECT"

echo "preparing assembly relocation"
RUNID=$(echo "$CONTIGS" | perl -lane 'print $1 if (/([EDS]RR\d+)/)')
RUNPREFIX=$(echo "$RUNID" | perl -lane 'print $1 if (/([EDS]RR\d\d\d\d)/)')
RUNDIR="$WORKDIR/$RUNPREFIX/$RUN/metaspades/001"

if [ -d "$RUNDIR" ]
then
    echo "$RUNDIR exist"
else
    mkdir -p "$RUNDIR" || error_exit "cannot create $RUNDIR"
fi

# coverage dir (empty)
if [ -d "$RUNDIR/coverage" ]
then
    echo "$RUNDIR/coverage exist"
else
    mkdir -p "$RUNDIR/coverage" || error_exit "cannot create $RUNDIR/coverage"
fi

# assembly relocation
if [ -e "$CONTIGS" ]
then
    cp "$CONTIGS" "$RUNDIR/contigs.fasta" || error_exit "cannot copy $CONTIGS to $RUNDIR"
else
    error_exit "$CONTIGS is not readable"
fi

# params relocation
if [ -e "$LOGS" ]
then
    cp "$LOGS" "$RUNDIR/params.txt" || error_exit "cannot copy $LOGS to $RUNDIR"
else
    error_exit "$LOGS is not readable"
fi
## TODO: parse logs and get run time and peak memory

# stats relocation
if [ -e "$STATS" ]
then
    cp "$STATS" "$RUNDIR/assembly_stats.json" || error_exit "cannot copy $STATS to $RUNDIR"
else
    error_exit "$STATS is not readable"
fi
## TODO: edit JSON with run time and peak memory

echo "raw fastq relocation"
if [ -d "$WORKDIR/raw" ]
then
    echo "$WORKDIR/raw exists"
else
    mkdir -p "$WORKDIR/raw" || error_exit "cannot create $WORKDIR/raw"
fi
for FQ in "$READSDIR"/$RUNID*fastq.gz
do
    if [ -e "$FQ" ]
    then
        FQTARGET="$WORKDIR/raw/$(basename "$FQ")"
        if [ -e "$FQTARGET" ]
        then
            echo "  $FQTARGET exists, skip"
        else
            echo "  relocating $FQ"
            cp "$FQ" "$WORKDIR/raw/" || error_exit "cannot copy $FQ to $WORKDIR/raw" 
        fi
    else
        error_exit "$FQ is not readable"
    fi
done
## TODO: support hybrid mode
