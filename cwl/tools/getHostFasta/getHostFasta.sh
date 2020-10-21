#!/bin/bash
# getHostFasta.sh species/url out.fasta
#
# Simple script to retrieve genome sequences
# The input parameter is the species name (homo_sapiens, mus_musculus, etc)
# the script will retrieve the file from Ensembl FTP server.
# Alternatively, the input can be a HTTP/HTTPS/FTP link to the file.
# Compressed files (Gzip) are decompressed.
#
# (C) 2020 EMBL - European Bioinformatics Institute 

error_exit () {
    echo "$1"
    exit 1
}

SPECIES=$1
FASTA=$2

case "$SPECIES" in
    http*)
        URL=$SPECIES
    ;;
    ftp*)
        URL=$SPECIES
    ;;
    *)
        URL=$(getFastaFromEnsemblFTP.py $SPECIES)
    ;;
esac

wget -q "$URL" || error_exit "Cannot retrieve $URL, please chek the link/species"
