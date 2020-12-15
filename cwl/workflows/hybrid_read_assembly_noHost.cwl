cwlVersion: v1.2.0-dev5
class: Workflow
label: Hybrid read assembly workflow
doc: |
      Implementation of nanopore + illumina reads assembly pipeline

requirements:
  SubworkflowFeatureRequirement: {}
  ResourceRequirement:
    coresMin: 8
    ramMin: 8000

inputs:
  raw_reads:
    type: File
    format: edam:format_1930 
    label: long reads to assemble
  lr_tech:
    type: string?
    label: long reads technology, supported techs are nanopore and pacbio
    default: nanopore
  p1_reads:
    type: File
    format: edam:format_1930
    label: illumina paired reads to assemble (first pair)
  p2_reads:
    type: File
    format: edam:format_1930
    label: illumina paired reads to assemble (second pair)
  min_read_size:
    type: int?
    label: Raw reads filter by size (nanopore)
    default: 200
  min_read_size_ill:
    type: int?
    label: Raw reads filter by size (illumina)
    default: 50
  min_contig_size:
    type: int?
    label: contigs filter by size
    default: 500
  raw_reads_report:
    type: string?
    label: initial sequences report
    default: raw_reads_stats.txt
  reads_filter_bysize_nano:
    type: string?
    label: prefix for reads with length lt min_read_size
    default: nano_reads_filtered
  reads_filter_bysize_ill:
    type: string?
    label: prefix for reads with length lt min_read_size
    default: ill_reads_filtered
  pilon_align:
    type: string?
    label: illumina reads alignment for polishing
    default: pilon_align.bam
  polish_assembly_pilon:
    type: string?
    label: polish assembly after illumina map
    default: assembly_polish_pilon
  final_assembly:
    type: string?
    label: final assembly file (fasta)
    default: assembly_final.fasta
  final_assembly_stats:
    type: string?
    label: final assembly stats
    default: assembly_final_stats.txt
  predict_proteins:
    type: string?
    label: predicted proteins from assembly (fasta)
    default: predicted_proteins.fasta
  predict_proteins_gbk:
    type: string?
    label: predicted proteins from assembly (gbk)
    default: predicted_proteins.gbk
  uniprot_index:
    type: File
    label: uniprot index file
    default: ../db/uniprot.dmnd
  diamond_out:
    type: string?
    label: proteins align to Uniprot
    default: predict_proteins_align.tsv
  ideel_out:
    type: string?
    label: protein completeness evaluation
    default: ideel_report.pdf

outputs:
  raw_reads_stats:
    type: File
    outputSource: step_0_pre_assembly_stats/outReport
  filtered_reads_nano_qc_html:
    type: File
    outputSource: step_1a_filterShortReads_nano/qchtml 
  filtered_reads_nano_qc_json:
    type: File
    outputSource: step_1a_filterShortReads_nano/qcjson 
  filtered_reads_ill_qc_html:
    type: File
    outputSource: step_1b_filterShortReads_ill/qchtml 
  filtered_reads_ill_qc_json:
    type: File
    outputSource: step_1b_filterShortReads_ill/qcjson 
  final_assembly_fasta:
    type: File
    format: edam:format_1929
    outputSource: step_4c_cleaning_filterContigs/outFasta
  final_assembly_report:
    type: File
    outputSource: step_4d_cleaning_assemblyStats/outReport 
  predict_proteins_fasta:
    type: File
    format: edam:format_1929
    outputSource: step_5a_annotation_prodigal/outProt
  diamond_align_table:
    type: File
    outputSource: step_5b_annotation_diamond/alignment
  ideel_pdf:
    type: File
    outputSource: step_5c_annotation_ideel/outFig

steps:
  step_0_pre_assembly_stats:
    label: pre-assembly stats
    run: ../tools/assembly_stats/assemblyStatsFastq.cwl
    in:
      inFile: raw_reads
      outReport: raw_reads_report
    out: [ outReport ]

  step_1a_filterShortReads_nano:
    label: filtering short reads (nanopore)
    run: ../tools/fastp/fastp_filter.cwl
    in:
      reads: raw_reads
      minLength: min_read_size
      name: reads_filter_bysize_nano
    out:
      - outReads
      - qcjson
      - qchtml

  step_1b_filterShortReads_ill:
    label: filtering short reads (illumina)
    run: ../tools/fastp/fastp.cwl
    in:
      reads1: p1_reads
      reads2: p2_reads
      minLength: min_read_size_ill
      name: reads_filter_bysize_ill
    out:
      - outreads1
      - outreads2
      - qcjson
      - qchtml
   
  step_2_assembly:
    label: hybrid assembly with SPAdes
    run: ../tools/spades/spades_runner.cwl
    in:
      readType: lr_tech
      readFile: step_1a_filterShortReads_nano/outReads
      reads1: step_1b_filterShortReads_ill/outreads1
      reads2: step_1b_filterShortReads_ill/outreads2
    out: [ contigs_fasta ]

  step_3a_polishing_illumina_align_rnd1:
    label: aligning illumina reads to assembly
    run: ../tools/bwa/bwa-mem2.cwl
    in:
      reads1: step_1b_filterShortReads_ill/outreads1
      reads2: step_1b_filterShortReads_ill/outreads2
      reference: step_2_assembly/contigs_fasta
      bamName: pilon_align
    out: [ bam ]

  step_3b_polishing_pilon_rnd1:
    label: polishing assembly with pilon
    run: ../tools/pilon/pilon.cwl
    in:
      sequences: step_2_assembly/contigs_fasta
      alignment: step_3a_polishing_illumina_align_rnd1/bam
      outfile: polish_assembly_pilon
    out: [ outfile ]

  step_4a_polishing_illumina_align_rnd2:
    label: aligning illumina reads to assembly
    run: ../tools/bwa/bwa-mem2.cwl
    in:
      reads1: step_1b_filterShortReads_ill/outreads1
      reads2: step_1b_filterShortReads_ill/outreads2
      reference: step_3b_polishing_pilon_rnd1/outfile
      bamName: pilon_align
    out: [ bam ]

  step_4b_polishing_pilon_rnd2:
    label: polishing assembly with pilon
    run: ../tools/pilon/pilon.cwl
    in:
      sequences: step_3b_polishing_pilon_rnd1/outfile
      alignment: step_4a_polishing_illumina_align_rnd2/bam
      outfile: polish_assembly_pilon
    out: [ outfile ]

  step_4c_cleaning_filterContigs:
    label: remove short contigs
    run: ../tools/filterContigs/filterContigs.cwl
    in:
      minSize: min_contig_size
      inFasta: step_4b_polishing_pilon_rnd2/outfile
      outFasta: final_assembly
    out: [ outFasta ]

  step_4d_cleaning_assemblyStats:
    label: final assembly stats report
    run: ../tools/assembly_stats/assemblyStatsFasta.cwl
    in:
      inFile: step_4c_cleaning_filterContigs/outFasta
      outReport: final_assembly_stats
    out: [ outReport ]
    
  step_5a_annotation_prodigal:
    label: predict proteins in assembly with Prodigal
    run: ../tools/prodigal/prodigal.cwl
    in:
      inNucl: step_4c_cleaning_filterContigs/outFasta
      outProtName: predict_proteins
      outGbkName: predict_proteins_gbk
    out: [ outProt ]

  step_5b_annotation_diamond:
    label: search Uniprot database with diamond
    run: ../tools/diamond/diamond.cwl
    in:
      outName: diamond_out
      proteins: step_5a_annotation_prodigal/outProt
      database: uniprot_index
    out: [ alignment ]

  step_5c_annotation_ideel:
    label: ideel report for protein completeness
    run: ../tools/ideel/ideelPy.cwl
    in:
      inputTable: step_5b_annotation_diamond/alignment
      outFigName: ideel_out
    out: [ outFig ]

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schemaorg-current-https.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
s:dateCreated: 2020-10-08