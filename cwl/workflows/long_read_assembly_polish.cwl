cwlVersion: v1.2.0-dev5
class: Workflow
label: Long read assembly workflow with Illumina polishing
doc: |
      Implementation of nanopore reads assembly pipeline with final polishing using Illumina reads (paired)

requirements:
  SubworkflowFeatureRequirement: {}
  ResourceRequirement:
    coresMin: 8
    ramMin: 8000

inputs:
  raw_reads:
    type: File
    format: edam:format_1930  # FASTQ
    label: long reads to assemble
  lr_tech:
    type: string?
    label: long reads technology, supported techs are nanopore and pacbio
    default: nanopore
  p1_reads:
    type: File
    format: edam:format_1930
    label: illumina reads for polishing (first pair)
  p2_reads:
    type: File
    format: edam:format_1930
    label:  illumina reads for polishing (second pair)
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
  host_genome:
    type: File
    format: edam:format_1929
    label: genome host, used for decontaminate
    default: ../db/genome.fa.gz
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
  pilon_align:
    type: string
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
  final_assembly_fasta:
    type: File
    format: edam:format_1929
    outputSource: step_7e_cleaning_filterContigs/outFasta
  final_assembly_report:
    type: File
    outputSource: step_7f_cleaning_assemblyStats/outReport 
  predict_proteins_fasta:
    type: File
    format: edam:format_1929
    outputSource: step_8a_annotation_prodigal/outProt
  diamond_align_table:
    type: File
    outputSource: step_8b_annotation_diamond/alignment
  ideel_pdf:
    type: File
    outputSource: step_8c_annotation_ideel/outFig

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
      refSeq: host_genome
    out: [ outReads ]

  step_4_assembly:
    label: assembly long-reads with flye
    run: ../tools/flye/flye_runner.cwl
    in:
      readType: lr_tech
      readFile: step_3_cleaning_alignHost/outReads
    out: [ contigs_fasta ]

  step_5a_polishing_minimap2:
    label: polishing step 1, map reads back to assembly with minimap2
    run: ../tools/minimap2/minimap2_to_polish.cwl
    in:
      alignMode: align_preset
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
      refSeq: host_genome
      inSeq: step_5c_polishing_medaka/outConsensus
    out: [ outReads ]

  step_7a_polishing_illumina_align_rnd1:
    label: polishing step 1, aligning illumina reads to assembly
    run: ../tools/bwa/bwa-mem2.cwl
    in:
      reads1: p1_reads
      reads2: p2_reads
      reference: step_6a_cleaning2_alignHost/outReads
      bamName: pilon_align
    out: [ bam ]

  step_7b_polishing_pilon_rnd1:
    label: polishing step 2, polishing assembly with pilon
    run: ../tools/pilon/pilon.cwl
    in:
      sequences: step_6a_cleaning2_alignHost/outReads
      alignment: step_7a_polishing_illumina_align_rnd1/bam
      outfile: polish_assembly_pilon
    out: [ outfile ]

  step_7c_polishing_illumina_align_rnd2:
    label: polishing step 3, aligning illumina reads to assembly
    run: ../tools/bwa/bwa-mem2.cwl
    in:
      reads1: p1_reads
      reads2: p2_reads
      reference: step_7b_polishing_pilon_rnd1/outfile
      bamName: pilon_align
    out: [ bam ]

  step_7d_polishing_pilon_rnd2:
    label: polishing step 4, polishing assembly with pilon
    run: ../tools/pilon/pilon.cwl
    in:
      sequences: step_7b_polishing_pilon_rnd1/outfile
      alignment: step_7c_polishing_illumina_align_rnd2/bam
      outfile: polish_assembly_pilon
    out: [ outfile ]
  
  step_7e_cleaning_filterContigs:
    label: remove short contigs
    run: ../tools/filterContigs/filterContigs.cwl
    in:
      minSize: min_contig_size
      inFasta: step_7d_polishing_pilon_rnd2/outfile
      outFasta: final_assembly
    out: [ outFasta ]

  step_7f_cleaning_assemblyStats:
    label: final assembly stats report
    run: ../tools/assembly_stats/assemblyStatsFasta.cwl
    in:
      inFile: step_7e_cleaning_filterContigs/outFasta
      outReport: final_assembly_stats
    out: [ outReport ]

  step_8a_annotation_prodigal:
    label: predict proteins in assembly with Prodigal
    run: ../tools/prodigal/prodigal.cwl
    in:
      inNucl: step_7e_cleaning_filterContigs/outFasta
      outProtName: predict_proteins
      outGbkName: predict_proteins_gbk
    out: [ outProt ]

  step_8b_annotation_diamond:
    label: search Uniprot database with diamond
    run: ../tools/diamond/diamond.cwl
    in:
      outName: diamond_out
      proteins: step_8a_annotation_prodigal/outProt
      database: uniprot_index
    out: [ alignment ]

  step_8c_annotation_ideel:
    label: ideel report for protein completeness
    run: ../tools/ideel/ideelPy.cwl
    in:
      inputTable: step_8b_annotation_diamond/alignment
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