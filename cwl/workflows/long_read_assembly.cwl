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
  host_species:
    type: string?
    label: if defined, retrieve the genome to decontaminate the sample
  host_index:
    type: string?
    label: index name if genome host is used for decontaminate
    default: genome.mmi
  host_align:
    type: string?
    label: SAM output from reads alignment to host
    default: genome_align.sam
  align_preset:
    type: string?
    label: minimap2 align mode
    default: map-ont
  host_maped:
    type: string?
    label: mapped reads to the host genome
    default: host_maped.fastq
  host_unmaped:
    type: string?
    label: unmapped reads to the host genome
    default: host_unmaped.fastq
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
  assembly_clean_sam:
    type: string?
    label: clean assembly map to host genome (SAM)
    default: assembly_clean.sam
  host_maped_contigs:
    type: string?
    label: clean contigs map to host genome (fasta)
    default: assembly_mapHost.fasta
  host_unmaped_contigs:
    type: string?
    label: clean contigs unmap to host genome (fasta)
    default: assembly_unmapHost.fasta
  
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
  hostGenome:
    type: File
    outputSource: step_3a_cleaning_getHostFasta/outGenome
  hostGenomeIndex:
    type: File
    outputSource: step_3b_cleaning_indexFasta/outIndex
  hostAlignSAM:
    type: File
    outputSource: step_3c_cleaning_alignHost/outSAM 
  hostUnmapedReads:
    type: File
    outputSource: step_3d_cleaning_extractUnmaped/outFastq 
  hostMapedReads:
    type: File
    outputSource: step_3e_cleaning_extractMaped/outFastq 
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
  cleanAssemblySAM:
    type: File
    outputSource: step_6a_cleaning2_minimap2/outSAM
  cleanAssemblyUnmap:
    type: File
    outputSource: step_6b_cleaning2_extractUnmaped/outFasta
  cleanAssemblyMap:
    type: File
    outputSource: step_6c_cleaning2_extractMaped/outFasta

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
  
  step_3a_cleaning_getHostFasta:
    label: retrieve genome fasta from host (if defined)
    run: ../tools/getHostFasta/getHostFasta.cwl
    #when: host_species
    in:
      species: host_species
    out: [ outGenome ]

  step_3b_cleaning_indexFasta:
    label: generate the genome fasta index for minimap2
    run: ../tools/minimap2/minimap2_index.cwl
    in:
      preset: align_preset
      inFasta: step_3a_cleaning_getHostFasta/outGenome
      indexName: host_index
    out: [ outIndex ]

  step_3c_cleaning_alignHost:
    label: align reads to the genome fasta index
    run: ../tools/minimap2/minimap2_align.cwl
    in:
      outSAM: host_align
      inSeq1: step_2_filterShortReads/outFastq
      dbIndex: step_3b_cleaning_indexFasta/outIndex
    out: [ outSAM ]

  step_3d_cleaning_extractUnmaped:
    label: extract unmaped reads to the host genome
    run: ../tools/samtools/samtools_filter_unmap.cwl
    in:
      outFastqName: host_unmaped
      inSam: step_3c_cleaning_alignHost/outSAM
    out: [ outFastq ]

  step_3e_cleaning_extractMaped:
    label: extract maped reads to the host genome
    run: ../tools/samtools/samtools_filter_map.cwl
    in:
      outFastqName: host_maped
      inSam: step_3c_cleaning_alignHost/outSAM
    out: [ outFastq ]

  step_4_assembly:
    label: assembly long-reads with flye
    run: ../tools/flye/flye.cwl
    in:
      nano: step_3d_cleaning_extractUnmaped/outFastq
    out: [ contigs_fasta ]

  step_5a_polishing_minimap2:
    label: polishing step 1, map reads back to assembly with minimap2
    run: ../tools/minimap2/minimap2_to_polish.cwl
    in:
      inAssembly: step_4_assembly/contigs_fasta
      inReads: step_3d_cleaning_extractUnmaped/outFastq
      outPAFname: polish_paf
    out: [ outPAF ]

  step_5b_polishing_racon:
    label: polishing step 2, using racon to improve assembly
    run: ../tools/racon/racon.cwl
    in:
      inReads: step_3d_cleaning_extractUnmaped/outFastq
      mapping: step_5a_polishing_minimap2/outPAF
      assembly: step_4_assembly/contigs_fasta
      outName: polish_assembly_racon
    out: [ outAssembly ]

  step_5c_polishing_medaka:
    label: polishing step 3, using medaka to create a consensus
    run: ../tools/medaka/medaka.cwl
    in:
      inReads: step_3d_cleaning_extractUnmaped/outFastq
      assembly: step_5b_polishing_racon/outAssembly
      medakaModel: medaka_model
    out: [ outConsensus ]
  
  step_6a_cleaning2_minimap2:
    label: post-assembly cleaning, mapping with minimap2
    run: ../tools/minimap2/minimap2_to_clean.cwl
    in:
      outSAMname: assembly_clean_sam
      inHostIndex: step_3b_cleaning_indexFasta/outIndex
      inSeqs: step_5c_polishing_medaka/outConsensus
    out: [ outSAM ]

  step_6b_cleaning2_extractUnmaped:
    label: extract unmaped contigs to the host genome
    run: ../tools/samtools/samtools_filter_unmap_fasta.cwl
    in:
      outFastaName: host_unmaped_contigs
      inSam: step_6a_cleaning2_minimap2/outSAM
    out: [ outFasta ]

  step_6c_cleaning2_extractMaped:
    label: extract maped contigs to the host genome
    run: ../tools/samtools/samtools_filter_map_fasta.cwl
    in:
      outFastaName: host_maped_contigs
      inSam: step_6a_cleaning2_minimap2/outSAM
    out: [ outFasta ]

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schemaorg-current-https.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
s:dateCreated: 2020-10-08