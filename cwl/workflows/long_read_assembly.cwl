cwlVersion: v1.2
class: Workflow
label: Long read assembly workflow
doc: |
      Implementation of nanopore reads assembly pipeline

requirements:
  SubworkflowFeatureRequirement: {}
  ResourceRequirement:
    coresMin: 8
    ramMin: 8000

inputs:
  # inputs for preprocessing
  raw_reads:
    type: File
    format: edam:format_1930
    label: Fastq file to process
  min_read_size:
    type: int?
    label: Raw reads filter by size
    default: 200
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
    label: prefix for reads with length lt min_read_size
    default: reads_filtered
  host_genome:
    type: File?
    format: edam:format_1929
    label: index name for genome host, used for decontaminate
  host_unmaped_reads:
    type: string?
    label: unmapped reads to the host genome
    default: reads_filtered.fastq.gz

  # inputs for assembly
  lr_tech:
    type: string?
    label: long reads technology, supported techs are nanopore and pacbio
    default: nanopore
  align_polish:
    type: string?
    label: minimap2 align mode for polish, can be map-ont (nanopore) or map-pb (pacbio)
    default: map-ont
  polish_paf:
    type: string?
    label: polish align PAF file
    default: assembly_polish.paf
  polish_assembly_racon:
    type: string?
    label: polish assembly with racon
    default: assembly_polish_racon.fasta  
  medaka_model:
    type: string?
    label: medaka model to improve assembly
    default: r941_min_high_g360
  host_unmaped_contigs:
    type: string?
    label: clean contigs unmap to host genome (fasta)
    default: assembly_filtered.fasta
  min_contig_size:
    type: int?
    label: filter assembly contigs by this size
    default: 500
  final_assembly:
    type: string?
    label: final assembly file name (fasta)
    default: contigs.fasta
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
    default: predicted_proteins_diamond.tsv
  ideel_out:
    type: string?
    label: protein completeness evaluation
    default: predicted_proteins_ideel.pdf

outputs:
  # outputs from preprocessing
  raw_reads_stats:
    type: File
    outputSource: step_1_preprocessing/raw_reads_stats
  filtered_reads_qcHtml:
    type: File
    outputSource: step_1_preprocessing/reads_qc_html
  filtered_reads_qcJson:
    type: File
    outputSource: step_1_preprocessing/reads_qc_json
  # outputs from assembly
  final_assembly_fasta:
    type: File
    format: edam:format_1929
    outputSource: step_2_assembly/final_assembly_fasta
  final_assembly_report:
    type: File
    outputSource: step_2_assembly/assembly_stats
  # outputs from postprocessing 
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
  step_1_preprocessing:
    label: preprocessing of raw data
    run: mgnify_lr_preprocessing_long.cwl
    in:
      raw_reads: raw_reads
      min_read_size: min_read_size
      raw_reads_report: raw_reads_report
      align_preset: align_preset
      reads_filter_bysize: reads_filter_bysize
      host_genome: host_genome
      host_unmaped_reads: host_unmaped_reads
    out: 
      - raw_reads_stats
      - reads_qc_html
      - reads_qc_json
      - reads_output
  
  step_2_assembly:
    label: assembly of reads
    run: mgnify_lr_assembly.cwl
    in:
      long_reads: step_1_preprocessing/reads_output
      lr_tech: lr_tech
      host_genome: host_genome
      align_preset: align_preset
      align_polish: align_polish
      polish_paf: polish_paf
      polish_assembly_racon: polish_assembly_racon
      medaka_model: medaka_model
      host_unmaped_contigs: host_unmaped_contigs
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
s:dateCreated: 2020-10-08
