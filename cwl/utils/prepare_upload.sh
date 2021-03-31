#!/bin/bash

# prepare_upload.sh
# Script to prepare a MGnify-LR assembly to upload to ENA
# (C) 2021 EMBL - EBI

TARGETDIR=/hps/nobackup2/production/metagenomics/results/assemblies
PROJECT=null
CONTIGS=null
READS=null
STATS=null
PARAMS=null
GRAPH=null

print_help () {
    echo "prepare_upload.sh [PARAM]"
    echo
    echo "Parameter |  Definition"
    echo "----------|------------"
    echo "   -p     |  ProjectID (SRPxxx|ERPxxx|DRPxxx)"
    echo "   -c     |  Path to contigs Fasta (file name must have run_id [S/E/D]RRxxxx)"
    echo "   -r     |  Path to raw reads Fastq (*fastq.gz), multiple files can be specified with ','"
    echo "   -y     |  Path to params file (CWL YAML input)"
    echo "   -s     |  Path to assembly_stats.json file"
    echo "   -g     |  Path to assembly graph file"
    echo "   -t     |  Target dir, default: $TARGETDIR"
}

# simple error printing and script exit
error_exit () {
    echo "Error: $1"
    print_help
    exit 1
}

# Parameter capture
while getopts :p:c:s:r:y:g:t: option; do
    case "${option}" in
        p) PROJECT=${OPTARG};;
        c) CONTIGS=${OPTARG};;
        s) STATS=${OPTARG};;
        r) READS=${OPTARG};;
        y) PARAMS=${OPTARG};;
        t) TARGETDIR=${OPTARG};;
        g) GRAPH=${OPTARG};;
        *) echo "invalid option: $option"; exit;;
    esac
done

# input validation
if [ "$PROJECT"  == "null" ]; then error_exit "missing ProjectID (-p)"; fi
if [ "$CONTIGS"  == "null" ]; then error_exit "missing Contigs (-c)"; fi
if [ "$READSDIR" == "null" ]; then error_exit "missing Reads (-r)" ; fi
if [ "$PARAMS"   == "null" ]; then error_exit "missing Params (-y)"; fi
if [ "$STATS"    == "null" ]; then error_exit "missing Assembly stats (-s)"; fi

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
    echo "$RUNDIR/coverage dir exist"
else
    mkdir -p "$RUNDIR/coverage" || error_exit "cannot create $RUNDIR/coverage"
fi

# assembly relocation
if [ -e "$CONTIGS" ]
then
    echo "copying contigs: $CONTIGS"
    cp "$CONTIGS" "$RUNDIR/contigs.fasta" || error_exit "cannot copy $CONTIGS to $RUNDIR"
    echo "copying $RUNID.fasta"
    cp "$RUNDIR/contigs.fasta" "$RUNDIR/$RUNID.fasta"
    echo "compressing $RUNID.fasta"
    gzip "$RUNDIR/$RUNID.fasta"
    echo "generating checksum for $RUNID.fasta.gz"
    md5sum "$RUNDIR/$RUNID.fasta.gz" | cut -f1 -d" " > "$RUNDIR/$RUNID.fasta.gz.md5"
else
    error_exit "$CONTIGS is not readable"
fi

# params relocation
if [ -e "$PARAMS" ]
then
    echo "copying params from $PARAMS"
    cp "$PARAMS" "$RUNDIR/params.txt" || error_exit "cannot copy $PARAMS to $RUNDIR"
else
    error_exit "$PARAMS is not readable"
fi

# stats relocation
if [ -e "$STATS" ]
then
    echo "copying assembly stats from $STATS"
    cp "$STATS" "$RUNDIR/assembly_stats.json" || error_exit "cannot copy $STATS to $RUNDIR"
else
    error_exit "$STATS is not readable"
fi

# graph relocation
if [ -e "$GRAPH" ]
then
    echo "copying grafh file from $GRAPH"
    cp "$GRAPH" "$RUNDIR/" || error_exit "cannot copy $GRAPH to $RUNDIR"
else
    echo "no graph found"
fi


echo "raw fastq relocation"
if [ -d "$WORKDIR/raw" ]
then
    echo "$WORKDIR/raw exists"
else
    mkdir -p "$WORKDIR/raw" || error_exit "cannot create $WORKDIR/raw"
fi

for FQ in $( echo $READS | perl -pe "s/,/\n/g" )
do
    if [ -e "$FQ" ]
    then
        FQFILE=$(basename $FQ)
        FQTARGET="$WORKDIR/raw/$FQFILE"
        if [ -e "$FQTARGET" ]
        then
            echo "  $FQTARGET exists, skip"
        else
            echo "  relocating $FQ"
            cp "$FQ" "$WORKDIR/raw/$FQFILE" || error_exit "cannot copy $FQ to $WORKDIR/raw" 
        fi
    else
        error_exit "$FQ is not readable"
    fi
done