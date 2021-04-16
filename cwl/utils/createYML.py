#!/usr/bin/env python

# Script to generate the YAML file for MGnify-LR pipeline
# (C) 2020 EMBL - EBI

import argparse

parser = argparse.ArgumentParser(description='Generate the YAML file for MGnify-LR pipeline')
parser.add_argument('-m', '--mode', type=str, choices=['assembly', 'hybrid', 'polish'], help='Pipeline mode selection, default: assembly', default='assembly')
parser.add_argument('-o', '--out', type=str, help='Output YAML file', required=True)
parser.add_argument('-r', '--reads', type=str, help='Path to long reads Fastq file', required=True)
parser.add_argument('-t', '--tech', type=str, choices=['nanopore', 'pacbio'], help='Long-reads techonology', required=True)
parser.add_argument('-p', '--prefix', type=str, help='Output files prefix, default: meta_assembly', default='meta_assembly')
parser.add_argument('-g', '--host', type=str, help='Path to host genome file (fasta)', default=None)
parser.add_argument('-1', '--pair1', type=str, help='Path to Illumina first paired-end reads Fastq', default=None)
parser.add_argument('-2', '--pair2', type=str, help='Path to Illumina second paired-end reads Fastq', default=None)
parser.add_argument('-l', '--minLen', type=int, help='Minimal length size for nanopore reads, default: 200', default=200)
parser.add_argument('-i', '--minLenIll', type=int, help='Minimal length size for illumina reads, default: 50', default=50)
parser.add_argument('-c', '--minContig', type=int, help='Minimal length size for assembled contigs, default: 500', default=500)
parser.add_argument('-k', '--medakaModel', type=str, help='Medaka model to use, default: r941_min_high_g360', default='r941_min_high_g360')
parser.add_argument('-u', '--uniprot', type=str, help='Path to Uniprot file (diamond index), default: ../db/uniprot.dmnd', default='../db/uniprot.dmnd')

par = parser.parse_args()

if par.mode == "hybrid" or par.mode == "polish":
    if not par.pair1:
        print("Mode is '{}', missing Illumina pair 1 fastq (-1/--pair1)".format(par.mode))
        exit(1)
    elif not par.pair2:
        print("Mode is '{}', missing Illumina pair 2 fastq (-2/--pair2)".format(par.mode))
        exit(1)

oh = open(par.out, "w")

oh.write("long_reads:\n  class: File\n  format: edam:format_1930\n  path: {}\n".format(par.reads))
oh.write("min_read_size: {}\n".format(par.minLen))
oh.write("raw_reads_report: {}\n".format(par.prefix + "_raw_reads_stats.txt"))    
oh.write("min_contig_size: {}\n".format(par.minContig))
oh.write("long_reads_tech: {}\n".format(par.tech))

if par.tech == "pacbio":
    oh.write("align_polish: map-pb\n")
else:
    oh.write("align_polish: map-ont\n")

if par.mode == "assembly":
    oh.write("reads_filter_bysize: {}\n".format(par.prefix + "_filtered_reads"))
    if par.host: # assembly with Host filtering
        oh.write("host_genome:\n  class: File\n  format: edam:format_1929\n  path: {}\n".format(par.host))
        if par.tech == "pacbio":
            oh.write("align_preset: map-pb\n")
        else:
            oh.write("align_preset: map-ont\n")

    else: # assembly without Host filtering
        oh.write("align_preset: none\n")

    oh.write("host_unmapped_reads: {}\n".format(par.prefix + "_filterHost.fastq.gz"))
    oh.write("polish_paf: {}\n".format(par.prefix + "_polish.paf"))
    oh.write("polish_assembly_racon: {}\n".format(par.prefix + "_racon.fasta"))
    oh.write("host_unmapped_contigs: {}\n".format(par.prefix + "_unmap.fasta"))
    oh.write("medaka_model: {}\n".format(par.medakaModel))

elif par.mode == "hybrid" or par.mode == "polish":
    oh.write("forward_short_reads:\n  class: File\n  format: edam:format_1930\n  path: {}\n".format(par.pair1))
    oh.write("reverse_short_reads:\n  class: File\n  format: edam:format_1930\n  path: {}\n".format(par.pair2))
    oh.write("min_read_size_short: {}\n".format(par.minLenIll))
    oh.write("reads_filter_bysize: {}\n".format(par.prefix + "_filtered_nano"))
    oh.write("reads_filter_bysize_short: {}\n".format(par.prefix + "_filtered_illumina"))
    if par.host: # assembly with Host filtering and Illumina polishing
        oh.write("host_genome:\n  class: File\n  format: edam:format_1929\n  path: {}\n".format(par.host))
        oh.write("host_unmapped: {}\n".format(par.prefix + "_filterHost.fastq.gz"))
        oh.write("host_unmapped_reads_1: {}\n".format(par.prefix + "_filterHost_1.fastq.gz"))
        oh.write("host_unmapped_reads_2: {}\n".format(par.prefix + "_filterHost_2.fastq.gz"))
        oh.write("host_unmapped_contigs: {}\n".format(par.prefix + "_unmapHost.fasta"))
    oh.write("pilon_align: {}\n".format(par.prefix + "_align.bam"))
    oh.write("polish_assembly_pilon: {}\n".format(par.prefix + "_pilon"))

else:
    print("Unknown mode '{}'".format(par.mode))
    exit(1)

oh.write("final_assembly: {}\n".format(par.prefix + "_final.fasta"))
oh.write("predict_proteins: {}\n".format(par.prefix + "_prot.fasta"))
oh.write("uniprot_index:\n  class: File\n  path: {}\n".format(par.uniprot))
oh.write("diamond_out: {}\n".format(par.prefix + "_diamond.tsv"))
oh.write("ideel_out: {}\n".format(par.prefix + "_ideel.pdf"))

oh.close()