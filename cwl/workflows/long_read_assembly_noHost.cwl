cwlVersion: v1.2
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
  reads_filter_bysize:
    type: string?
    label: Reads with length > min_read_size
    default: reads_filt.fastq.gz
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
  uniprot_url:
    type: string?
    label: Uniprot database URL
    default: "ftp://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/complete/uniprot_sprot.fasta.gz"
  uniprot_index:
    type: string?
    label: uniprot index file
    default: uniprot.dmnd
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
    outputSource: step_2_filterShortReads/outFastq 
  contigsFasta:
    type: File
    outputSource: step_4_assembly/contigs_fasta
  polishPAF:
    type: File
    outputSource: step_5a_polishing_minimap2/outPAF
  polishRacon:
    type: File
    outputSource: step_5b_polishing_racon/outAssembly
  polishMedaka:
    type: File
    outputSource: step_5c_polishing_medaka/outConsensus
  predictProteins:
    type: File
    outputSource: step_7a_annotation_prodigal/outProt
  predictProteinsGBK:
    type: File
    outputSource: step_7a_annotation_prodigal/outGBK
  uniprotDB:
    type: File
    outputSource: step_7b_annotation_getUniprotDB/outGenome
  uniprotIndex:
    type: File
    outputSource: step_7c_annotation_IndexUniprotDB/diamondIndex
  diamondAlign:
    type: File
    outputSource: step_7d_annotation_diamond/alignment
  ideelPDF:
    type: File
    outputSource: step_7e_annotation_ideel/outFig

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
    run: ../tools/removeSmallReads/removeSmallReads.cwl
    in:
      inFastq: raw_reads
      length: min_read_size
      outFastqName: reads_filter_bysize
    out: [ outFastq ]
   
  step_4_assembly:
    label: assembly long-reads with flye
    run: ../tools/flye/flye.cwl
    in:
      nano: step_2_filterShortReads/outFastq
    out: [ contigs_fasta ]

  step_5a_polishing_minimap2:
    label: polishing step 1, map reads back to assembly with minimap2
    run: ../tools/minimap2/minimap2_to_polish.cwl
    in:
      inAssembly: step_4_assembly/contigs_fasta
      inReads: step_2_filterShortReads/outFastq
      outPAFname: polish_paf
    out: [ outPAF ]

  step_5b_polishing_racon:
    label: polishing step 2, using racon to improve assembly
    run: ../tools/racon/racon.cwl
    in:
      inReads: step_2_filterShortReads/outFastq
      mapping: step_5a_polishing_minimap2/outPAF
      assembly: step_4_assembly/contigs_fasta
      outName: polish_assembly_racon
    out: [ outAssembly ]

  step_5c_polishing_medaka:
    label: polishing step 3, using medaka to create a consensus
    run: ../tools/medaka/medaka.cwl
    in:
      inReads: step_2_filterShortReads/outFastq
      assembly: step_5b_polishing_racon/outAssembly
      medakaModel: medaka_model
    out: [ outConsensus ]
    
  step_7a_annotation_prodigal:
    label: predict proteins in assembly with Prodigal
    run: ../tools/prodigal/prodigal.cwl
    in:
      inNucl: step_5c_polishing_medaka/outConsensus
      outProtName: predict_proteins
      outGbkName: predict_proteins_gbk
    out:
      - outProt
      - outGBK

  step_7b_annotation_getUniprotDB:
    label: retrieve Uniprot database
    run: ../tools/getHostFasta/getHostFasta.cwl
    in:
      species: uniprot_url
      outGbkName: predict_proteins_gbk
    out: [ outGenome ]

  step_7c_annotation_IndexUniprotDB:
    label: index Uniprot database for diamond
    run: ../tools/diamond_makedb/diamond_makedb.cwl
    in:
      proteins: step_7b_annotation_getUniprotDB/outGenome
      database: uniprot_index
    out: [ diamondIndex ]

  step_7d_annotation_diamond:
    label: search Uniprot database with diamond
    run: ../tools/diamond/diamond.cwl
    in:
      outName: diamond_out
      proteins: step_7a_annotation_prodigal/outProt
      database: step_7c_annotation_IndexUniprotDB/diamondIndex
    out: [ alignment ]

  step_7e_annotation_ideel:
    label: ideel report for protein completeness
    run: ../tools/ideel/ideel.cwl
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