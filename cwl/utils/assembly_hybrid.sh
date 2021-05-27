#!/bin/bash

# assembly_hybrid.sh
# Script to launch MGnify-LR assemblies in hybrid mode
# (C) 2021 EMBL - EBI

TARGETDIR=/hps/nobackup2/production/metagenomics/results/assemblies
LAUNCHER=/nfs/production/metagenomics/production/mgnify-lr/cwl/run/runMGnify-lr_LSF.sh
PROJECT=null
GENOME=null
RUN_LR=null
RUN_PE=null
TECH=null
MEDAKAMODEL=r941_min_high_g360
MINILL=50
MINLR=200
MINCONTIG=500
RESTART=False

print_help () {
    echo "assembly_longreads.sh [PARAM]"
    echo
    echo "Parameter |  Definition"
    echo "----------|------------"
    echo "   -p     |  ProjectID (SRPxxx|ERPxxx|DRPxxx)"
    echo "   -l     |  Long-reads run ID (SRRxxx|ERRxxx|DRRxxx)"
    echo "   -s     |  Short-reads run ID (SRRxxx|ERRxxx|DRRxxx)"
    echo "   -t     |  Long-read technology: nanopore or pacbio"
    echo "   -g     |  Path to genome fasta file for host filtering"
    echo "   -m     |  Medaka polish model for Nanopore, see https://github.com/nanoporetech/medaka#models, default is $MEDAKAMODEL"
    echo "   -i     |  Minimum size for short-read filtering, default is $MINILL"
    echo "   -j     |  Minimum size for long-read filtering, default is $MINLR"
    echo "   -k     |  Minimum size for contig filtering, default is $MINCONTIG"
    echo "   -d     |  Assembly project base directory, default is $TARGETDIR"
    echo "   -x     |  Restart mode, should be True or False, default is $RESTART"
}

# simple error printing and script exit
error_exit () {
    echo "Error: $1"
    print_help
    exit 1
}

launch_job () {
    FQ=$1
    PE1=$2
    PE2=$3
    NAME=$(basename "$PE1" _1.fastq.gz)
    echo "Launching assembly job $NAME"
    bsub -q production-rh74 -e $RAWDIR/../$NAME.err -o $RAWDIR/../$NAME.log -J $NAME "bash $LAUNCHER -x $RESTART -p $PROJECT -a $NAME -s $FQ -f $PE1 -r $PE2 -h $TECH -t hybrid -g $GENOME -k $MEDAKAMODEL -i $MINILL -j $MINLR -c $MINCONTIG"
}

# Parameter capture
while getopts :p:s:l:t:m:i:j:k:g:d:x: option; do
    case "${option}" in
        p) PROJECT=${OPTARG};;
        l) RUN_LR=${OPTARG};;
        s) RUN_PE=${OPTARG};;
        t) TECH=${OPTARG};;
        m) MEDAKAMODEL=${OPTARG};;
        i) MINILL=${OPTARG};;
        j) MINLR=${OPTARG};;
        k) MINCONTIG=${OPTARG};;
        g) GENOME=${OPTARG};;
        d) TARGETDIR=${OPTARG};;
        x) RESTART=${OPTARG};;
        *) echo "invalid option: $option"; exit;;
    esac
done

# input validation
if [ "$PROJECT" == "null" ]; then error_exit "missing ProjectID (-p)"; fi
if [ "$TECH"    == "null" ]; then error_exit "missing technology (-t)"; fi
if [ "$RUN_LR"  == "null" ]; then error_exit "missing long-reads run_id (-l)"; fi
if [ "$RUN_PE"  == "null" ]; then error_exit "missing short-reads run_id (-s)"; fi

PROJ=$(echo "$PROJECT" | perl -lane 'print $1 if (/([ESD]RP\d\d\d\d)/)')
RAWDIR="$TARGETDIR/$PROJ/$PROJECT/raw"
if [ ! -d "$RAWDIR" ]
then
    error_exit "$RAWDIR is missing or cannot be read"
fi

LR_FASTQ=$( find "$RAWDIR" -name "$RUN_LR*.fastq.gz"   | head -1)
PE1_FASTQ=$(find "$RAWDIR" -name "$RUN_PE*_1.fastq.gz" | head -1)
PE2_FASTQ=$(find "$RAWDIR" -name "$RUN_PE*_2.fastq.gz" | head -1)

echo "found long-reads $LR_FASTQ"
echo "found short-reads 1 $PE1_FASTQ"
echo "found short-reads 2 $PE2_FASTQ"

launch_job "$LR_FASTQ" "$PE1_FASTQ" "$PE2_FASTQ"