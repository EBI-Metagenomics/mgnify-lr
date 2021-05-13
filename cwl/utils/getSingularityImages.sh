#!/bin/bash

# Script to pull Singularity images from DockerHub

REPO=microbiomeinformatics
for IMG in  $(cut -f2 -d"#" tools.txt)
do
    singularity pull --name ${REPO}_${IMG}.sif docker://$REPO/$IMG
done

REPO=microbiomeinformatics
for IMG in fastp:v0.20.1
do
    singularity pull --name ${REPO}_${IMG}.sif docker://$REPO/$IMG
done
