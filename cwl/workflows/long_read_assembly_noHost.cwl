cwlVersion: v1.1
class: Workflow
label: Long read assembly workflow
doc: |
      Implementation of nanopore reads assembly pipeline

requirements:
  ResourceRequirement:
    coresMin: 1
    ramMin: 8000 # 6 GB for testing, it needs more in production

inputs:
  raw_reads:
    type: File
    format: edam:format_1930  # FASTQ
    label: long reads to assemble
  min_read_size:
    type: int?
    label: Raw reads filter by size
    default: 200
  reads_filter_bysize_name:
    type: string?
    label: prefix for reads with length > min_read_size
    default: reads_filtered
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
  nanoplot_html:
    type: File[]
    outputSource: step_1_nanoplot/html
  nanoplot_pngs:
    type: File[]
    outputSource: step_1_nanoplot/pngs
  nanoplot_stats:
    type: File[]
    outputSource: step_1_nanoplot/stats
  nanoplot_pdfs:
    type: File[]
    outputSource: step_1_nanoplot/pdfs
  filtered_reads:
    type: File
    outputSource: step_2_filterShortReads/outReads 
  filtered_reads_qc_html:
    type: File
    outputSource: step_2_filterShortReads/qchtml 
  filtered_reads_qc_json:
    type: File
    outputSource: step_2_filterShortReads/qcjson 
  contigsFasta:
    type: File
    outputSource: step_3_assembly/contigs_fasta
  polishPAF:
    type: File
    outputSource: step_4a_polishing_minimap2/outPAF
  polishRacon:
    type: File
    outputSource: step_4b_polishing_racon/outAssembly
  polishMedaka:
    type: File
    outputSource: step_4c_polishing_medaka/outConsensus
  predictProteins:
    type: File
    outputSource: step_5a_annotation_prodigal/outProt
  predictProteinsGBK:
    type: File
    outputSource: step_5a_annotation_prodigal/outGBK
  diamondAlign:
    type: File
    outputSource: step_5d_annotation_diamond/alignment
  ideelPDF:
    type: File
    outputSource: step_5e_annotation_ideel/outFig

steps:
  step_1_nanoplot:
    label: initial QC for rawdata
    run: ../tools/nanoplot/nanoplot.cwl
    in:
      reads: raw_reads
    out:
      - html
      - pngs
      - stats
      - pdfs

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
   
  step_3_assembly:
    label: assembly long-reads with flye
    run: ../tools/flye/flye.cwl
    in:
      nano: step_2_filterShortReads/outReads
    out: [ contigs_fasta ]

  step_4a_polishing_minimap2:
    label: polishing step 1, map reads back to assembly with minimap2
    run: ../tools/minimap2/minimap2_to_polish.cwl
    in:
      inAssembly: step_3_assembly/contigs_fasta
      inReads: step_2_filterShortReads/outReads
      outPAFname: polish_paf
    out: [ outPAF ]

  step_4b_polishing_racon:
    label: polishing step 2, using racon to improve assembly
    run: ../tools/racon/racon.cwl
    in:
      inReads: step_2_filterShortReads/outReads
      mapping: step_4a_polishing_minimap2/outPAF
      assembly: step_3_assembly/contigs_fasta
      outName: polish_assembly_racon
    out: [ outAssembly ]

  step_4c_polishing_medaka:
    label: polishing step 3, using medaka to create a consensus
    run: ../tools/medaka/medaka.cwl
    in:
      inReads: step_2_filterShortReads/outReads
      assembly: step_4b_polishing_racon/outAssembly
      medakaModel: medaka_model
    out: [ outConsensus ]
    
  step_5a_annotation_prodigal:
    label: predict proteins in assembly with Prodigal
    run: ../tools/prodigal/prodigal.cwl
    in:
      inNucl: step_4c_polishing_medaka/outConsensus
      outProtName: predict_proteins
      outGbkName: predict_proteins_gbk
    out:
      - outProt
      - outGBK

  step_5d_annotation_diamond:
    label: search Uniprot database with diamond
    run: ../tools/diamond/diamond.cwl
    in:
      outName: diamond_out
      proteins: step_5a_annotation_prodigal/outProt
      database: uniprot_index
    out: [ alignment ]

  step_5e_annotation_ideel:
    label: ideel report for protein completeness
    run: ../tools/ideel/ideelPy.cwl
    in:
      inputTable: step_5d_annotation_diamond/alignment
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