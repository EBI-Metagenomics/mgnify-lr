#!/bin/bash

# Script to pull Singularity images from DockerHub

REPO=jcaballero
for IMG in  mgnify-lr.flye:2.8.1 \
            mgnify-lr.ideel:0.0.2 \
            mgnify-lr.medaka:1.1.3 \
            mgnify-lr.racon:1.4.13 \
            mgnify-lr.pilon:1.23 \
            mgnify-lr.bwa-mem2:2.1.1 \
            mgnify-lr.minimap2_filter:2.17.3 \
            mgnify-lr.spades:3.14.1 \
            mgnify-lr.prodigal:2.6.3 \
            mgnify-lr.filtercontigs:0.0.1 \
            mgnify-lr.assemblystats:0.0.1
do
    singularity pull --name ${REPO}_${IMG}.sif docker://$REPO/$IMG
done

REPO=microbiomeinformatics
for IMG in pipeline-v5.diamond:v0.9.25 fastp:v0.20.1
do
    singularity pull --name ${REPO}_${IMG}.sif docker://$REPO/$IMG
done
