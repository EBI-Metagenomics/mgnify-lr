#!/bin/bash

# getENAdata.sh
# Script to retrieve Fastq files from ENA,
# input is Project accession (PR*)
# Juan Caballero <jcaballero@ebi.ac.uk>
# (C) EMBL-EBI

PROJ=$1

if [ -d $PROJ ]
then
    echo "using $PROJ as output dir"
else
    echo "creating $PROJ as output dir"
    mkdir $PROJ
fi

URL="https://www.ebi.ac.uk/ena/portal/api/filereport?accession=$PROJ&result=read_run&fields=study_accession,sample_accession,experiment_accession,run_accession,tax_id,scientific_name,fastq_ftp&format=tsv&download=true"
echo "retriving project information for $PROJ"
wget -q -O $PROJ/$PROJ.tsv $URL

if [ -d $PROJ ]
then
    echo "using $PROJ as output dir"
else
    echo "creating $PROJ as output dir"
    mkdir $PROJ
fi

if [ -f "$PROJ.tsv" ]
then
    for FTPFQ in $(perl -lane 'print $F[-1] if ($F[-1]=~/^ftp/)' < $PROJ/$PROJ.tsv)
    do
        FQ=$(basename $FTPFQ)
        echo "retriving $FQ"
        wget -q -O $PROJ/$FQ "ftp://$FTPFQ"
    done
fi