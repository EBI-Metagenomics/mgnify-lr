# MGnify-LR Workflow

![](https://img.shields.io/badge/uses-cwl-orange.svg)
![](https://img.shields.io/badge/uses-docker-blue.svg)
![](https://img.shields.io/badge/uses-conda-yellow.svg)

# Description

This repository contains CWL workflows to assembly metagenomic data from long-reads technologies (Nanopore, PacBio).

Maintainers: MGnify Developers @ EMBL - EBI

# Workflows

## Long-read assembly with Flye
![chart](cwl/graph/long_read_assembly_noHost.jpg)

## Long-read assembly with Flye with host decontamination
![chart](cwl/graph/long_read_assembly.jpg)

## Long-read assembly with Flye and polishing
![chart](cwl/graph/long_read_assembly_noHost_polish.jpg)

## Long-read assembly with Flye, with polishing and host decontamination
![chart](cwl/graph/long_read_assembly_polish.jpg)

## Hybrid assembly (long-read + illumina PE) with metaSPAdes
![chart](cwl/graph/hybrid_read_assembly_noHost.jpg)

## Hybrid assembly (long-read + illumina PE) with metaSPAdes and host decontamination
![chart](cwl/graph/hybrid_read_assembly.jpg)


(C) EMBL - European Bioinformatics Institute