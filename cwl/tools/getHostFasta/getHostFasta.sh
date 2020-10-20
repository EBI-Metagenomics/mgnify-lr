#!/bin/bash
# getHostFasta.sh species/url > out.fasta
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

case "$SPECIES" in
    http*)
        URL=$SPECIES
    ;;
    ftp*)
        URL=$SPECIES
    ;;
    *)
        URL="ftp://ftp.ensembl.org/pub/current_fasta/${SPECIES}/dna_index/*.dna.toplevel.fa.gz"
    ;;
esac

wget -q "$URL" || error_exit "Cannot retrieve $URL, please chek the link/species"

for FGZ in ./*.gz
do
    if [ -f "$FGZ" ]
    then
        gunzip -c "$FGZ" || error_exit "Error decompressing GZ $FGZ"
    fi
done

for FIL in ./*
do
    if [ -f "$FIL" ]
    then
        cat "$FIL"
    fi
done
