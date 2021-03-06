cwlVersion: v1.2
class: Workflow
label: Long read assembly with polish workflow
doc: |
      Implementation of long-reads assembly with short-reads polish pipeline

requirements:
  SubworkflowFeatureRequirement: {}
  ResourceRequirement:
    coresMin: 8
    ramMin: 8000

inputs:
  # inputs for preprocessing
  long_reads:
    type: File
    format: edam:format_1930
    label: long reads to assemble
  forward_short_reads:
    type: File
    format: edam:format_1930
    label: illumina paired reads to assemble (forward)
  reverse_short_reads:
    type: File
    format: edam:format_1930
    label: illumina paired reads to assemble (reverse)
  min_read_size:
    type: int?
    label: Raw reads filter by size (long reads)
    default: 200
  min_read_size_short:
    type: int?
    label: Raw reads filter by size (illumina)
    default: 50
  raw_reads_report:
    type: string?
    label: initial sequences report
    default: raw_reads_stats.txt
  align_preset:
    type: string?
    label: minimap2 align preset, if set to 'none', no host filtering is applied
    default: none
  reads_filter_bysize:
    type: string?
    label: prefix for reads with length larger than min_read_size
    default: nano_reads_filtered
  reads_filter_bysize_short:
    type: string?
    label: prefix for reads with length larger than min_read_size
    default: ill_reads_filtered
  host_genome:
    type: File?
    format: edam:format_1929
    label: Reference genome for host, used for decontaminate
  host_unmapped_reads:
    type: string?
    label: unmapped reads to the host genome
    default: host_unmapped.fastq.gz
  host_unmapped_reads_1:
    type: string?
    label: unmapped reads to the host genome
    default: host_unmapped_1.fastq.gz
  host_unmapped_reads_2:
    type: string?
    label: unmapped reads to the host genome
    default: host_unmapped_2.fastq.gz

  # inputs for assembly  
  long_read_tech:
    type: string?
    label: long reads technology, supported techs are nanopore and pacbio
    default: nanopore
  min_contig_size:
    type: int?
    label: contigs filter by size
    default: 500
  pilon_align:
    type: string?
    label: illumina reads alignment for polishing
    default: pilon_align.bam
  polish_assembly_pilon:
    type: string?
    label: polish assembly after illumina map
    default: assembly_polish_pilon
  align_polish:
    type: string?
    label: minimap2 align mode for coverage
    default: map-ont
  host_unmapped_contigs:
    type: string?
    label: clean contigs unmap to host genome (fasta)
    default: assembly_unmap_host.fasta
  final_assembly:
    type: string?
    label: final assembly file (fasta)
    default: assembly_final.fasta

  # inputs for post-processing
  predict_proteins:
    type: string?
    label: predicted proteins from assembly (fasta)
    default: predicted_proteins.fasta
  uniprot_index:
    type: File
    label: uniprot index file
  diamond_out:
    type: string?
    label: proteins align to Uniprot
    default: predict_proteins_align.tsv
  ideel_out:
    type: string?
    label: protein completeness evaluation
    default: ideel_report.pdf

outputs:
  # outputs for preprocessing
  raw_reads_stats:
    type: File
    outputSource: step_1a_preprocessing_long/raw_reads_stats
  filtered_reads_long_qc_html:
    type: File
    outputSource: step_1a_preprocessing_long/reads_qc_html
  filtered_reads_long_qc_json:
    type: File
    outputSource: step_1a_preprocessing_long/reads_qc_json
  filtered_reads_short_qc_html:
    type: File
    outputSource: step_1b_preprocessing_short/reads_qc_html 
  filtered_reads_short_qc_json:
    type: File
    outputSource: step_1b_preprocessing_short/reads_qc_json
  # outputs from assembly
  final_assembly_fasta:
    type: File
    format: edam:format_1929
    outputSource: step_2_assembly/final_assembly_fasta
  final_assembly_stats:
    type: File
    outputSource: step_2_assembly/assembly_stats
  # outputs from post-processing 
  predict_proteins_fasta:
    type: File
    format: edam:format_1929
    outputSource: step_3_postprocessing/predict_proteins_fasta
  diamond_align_table:
    type: File
    outputSource: step_3_postprocessing/diamond_align_table
  ideel_pdf:
    type: File
    outputSource: step_3_postprocessing/ideel_pdf

steps:
  step_1a_preprocessing_long:
    label: preprocessing of raw long-reads data
    run: mgnify_lr_preprocessing_long.cwl
    in:
      long_reads: long_reads
      min_read_size: min_read_size
      raw_reads_report: raw_reads_report
      align_preset: align_preset
      reads_filter_bysize: reads_filter_bysize
      host_genome: host_genome
      host_unmapped_reads: host_unmapped_reads
    out: 
      - raw_reads_stats
      - reads_qc_html
      - reads_qc_json
      - reads_output

  step_1b_preprocessing_short:
    label: preprocessing of raw short-reads data
    run: mgnify_lr_preprocessing_short.cwl
    in:
      reads1: forward_short_reads
      reads2: reverse_short_reads
      min_read_size: min_read_size_short
      align_preset: align_preset
      reads_filter_bysize: reads_filter_bysize_short
      host_genome: host_genome
      host_unmapped_reads_1: host_unmapped_reads_1
      host_unmapped_reads_2: host_unmapped_reads_2
    out: 
      - reads_qc_html
      - reads_qc_json
      - reads_out_1
      - reads_out_2

  step_2_assembly:
    label: long-read assembly with Flye and polish with Pilon
    run: mgnify_lr_assembly_polish.cwl
    in:
      long_reads: step_1a_preprocessing_long/reads_output
      long_read_tech: long_read_tech
      forward_short_reads: step_1b_preprocessing_short/reads_out_1
      reverse_short_reads: step_1b_preprocessing_short/reads_out_2
      pilon_align: pilon_align
      polish_assembly_pilon: polish_assembly_pilon
      align_preset: align_preset
      host_genome: host_genome
      host_unmapped_contigs: host_unmapped_contigs
      align_polish: align_polish
      min_contig_size: min_contig_size
      final_assembly: final_assembly
    out:
      - final_assembly_fasta
      - assembly_stats

  step_3_postprocessing:
    label: postprocessing analysis for assembly
    run: mgnify_lr_postprocessing.cwl
    in:
      assembly_input: step_2_assembly/final_assembly_fasta
      predict_proteins: predict_proteins
      uniprot_index: uniprot_index
      diamond_out: diamond_out
      ideel_out: ideel_out
    out:
      - predict_proteins_fasta
      - diamond_align_table
      - ideel_pdf
      

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schemaorg-current-https.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
s:dateCreated: "2020-10-08"
