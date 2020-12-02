cwlVersion: v1.1
class: Workflow
label: Long read assembly workflow
doc: |
      Implementation of nanopore reads assembly pipeline

requirements:
  ResourceRequirement:
    coresMin: 8
    ramMin: 2000 # 2GB for testing, it needs more in production

inputs:
  raw_reads:
    type: File
    format: edam:format_1930  # FASTQ
    label: long reads to assemble
  min_read_size:
    type: int?
    label: raw reads filter by size
    default: 200
  min_contig_size:
    type: int?
    label: contigs filter by size
    default: 500
  raw_reads_report:
    type: string?
    label: initial sequences report
    default: raw_reads_stats.txt
  reads_filter_bysize_name:
    type: string?
    label: prefix file for reads with length lt min_read_size
    default: reads_filtered
  host_index:
    type: File
    label: index name for genome host, used for decontaminate
    default: ../db/genome.mmi
  align_preset:
    type: string?
    label: minimap2 align mode
    default: map-ont
  host_unmaped_reads:
    type: string?
    label: unmapped reads to the host genome
    default: host_unmaped.fastq.gz
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
    default: r941_min_fast_g330
  host_unmaped_contigs:
    type: string?
    label: clean contigs unmap to host genome (fasta)
    default: assembly_unmapHost.fasta
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
    default: predict_proteins_diamond.tsv
  ideel_out:
    type: string?
    label: protein completeness evaluation
    default: ideel_report.pdf

outputs:
  raw_reads_stats:
    type: File
    outputSource: step_1_pre_assembly_stats/outReport
  filtered_reads_qcHtml:
    type: File
    outputSource: step_2_filterShortReads/qchtml
  filtered_reads_qcJson:
    type: File
    outputSource: step_2_filterShortReads/qcjson
  final_assembly:
    type: File
    format: edam:format_1929
    outputSource: step_6b_cleaning2_filterContigs/outFasta
  final_assembly_stats:
    type: File
    outputSource: step_6c_cleaning_assemblyStats/outReport 
  predict_proteins:
    type: File
    outputSource: step_7a_annotation_prodigal/outProt
  diamond_align:
    type: File
    outputSource: step_7d_annotation_diamond/alignment
  ideel_pdf:
    type: File
    outputSource: step_7e_annotation_ideel/outFig

steps:
  step_1_pre_assembly_stats:
    label: pre-assembly stats
    run: ../tools/assembly_stats/assemblyStatsFastq.cwl
    in:
      inFile: raw_reads
      outReport: raw_reads_report
    out: [ outReport ]

  step_2_filterShortReads:
    label: filtering short reads
    run: ../tools/fastp/fastp_filter.cwl
    in:
      reads: raw_reads
      minLength: min_read_size
      name: reads_filter_bysize_name
    out:
      - outReads
      - qcjson
      - qchtml
  
  step_3_cleaning_alignHost:
    label: align reads to the genome fasta index
    run: ../tools/minimap2_filter/minimap2_filterHostFq.cwl
    in:
      alignMode: align_preset
      outReadsName: host_unmaped_reads
      inSeq: step_2_filterShortReads/outReads
      dbIndex: host_index
    out: [ outReads ]

  step_4_assembly:
    label: assembly long-reads with flye
    run: ../tools/flye/flye.cwl
    in:
      nano: step_3_cleaning_alignHost/outReads
    out: [ contigs_fasta ]

  step_5a_polishing_minimap2:
    label: polishing step 1, map reads back to assembly with minimap2
    run: ../tools/minimap2/minimap2_to_polish.cwl
    in:
      inAssembly: step_4_assembly/contigs_fasta
      inReads: step_3_cleaning_alignHost/outReads
      outPAFname: polish_paf
    out: [ outPAF ]

  step_5b_polishing_racon:
    label: polishing step 2, using racon to improve assembly
    run: ../tools/racon/racon.cwl
    in:
      inReads: step_3_cleaning_alignHost/outReads
      mapping: step_5a_polishing_minimap2/outPAF
      assembly: step_4_assembly/contigs_fasta
      outName: polish_assembly_racon
    out: [ outAssembly ]

  step_5c_polishing_medaka:
    label: polishing step 3, using medaka to create a consensus
    run: ../tools/medaka/medaka.cwl
    in:
      inReads: step_3_cleaning_alignHost/outReads
      assembly: step_5b_polishing_racon/outAssembly
      medakaModel: medaka_model
    out: [ outConsensus ]
  
  step_6a_cleaning2_alignHost:
    label: post-assembly cleaning, mapping with minimap2
    run: ../tools/minimap2_filter/minimap2_filterHostFa.cwl
    in:
      alignMode: align_preset
      outReadsName: host_unmaped_contigs
      dbIndex: host_index
      inSeq: step_5c_polishing_medaka/outConsensus
    out: [ outReads ]
  
  step_6b_cleaning2_filterContigs:
    label: remove short contigs
    run: ../tools/filterContigs/filterContigs.cwl
    in:
      minSize: min_contig_size
      inFasta: step_6a_cleaning2_alignHost/outReads
      outFasta: final_assembly
    out: [ outFasta ]

  step_6c_cleaning_assemblyStats:
    label: final assembly stats report
    run: ../tools/assembly_stats/assemblyStatsFasta.cwl
    in:
      inFile: step_6b_cleaning2_filterContigs/outFasta
      outReport: final_assembly_stats
    out: [ outReport ]

  step_7a_annotation_prodigal:
    label: predict proteins in assembly with Prodigal
    run: ../tools/prodigal/prodigal.cwl
    in:
      inNucl: step_6b_cleaning2_filterContigs/outFasta
      outProtName: predict_proteins
      outGbkName: predict_proteins_gbk
    out: [ outProt ]

  step_7d_annotation_diamond:
    label: search Uniprot database with diamond
    run: ../tools/diamond/diamond.cwl
    in:
      outName: diamond_out
      proteins: step_7a_annotation_prodigal/outProt
      database: uniprot_index
    out: [ alignment ]

  step_7e_annotation_ideel:
    label: ideel report for protein completeness
    run: ../tools/ideel/ideelPy.cwl
    in:
      inputTable: step_7d_annotation_diamond/alignment
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
