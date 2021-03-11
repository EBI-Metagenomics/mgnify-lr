cwlVersion: v1.2
class: Workflow
label: Long-read assembly workflow
doc: |
      Implementation of long-reads assembly pipeline

requirements:
  SubworkflowFeatureRequirement: {}
  ResourceRequirement:
    coresMin: 8
    ramMin: 8000

inputs:
  long_reads:
    type: File
    format: edam:format_1930
    label: long-reads to assemble
  long_read_tech:
    type: string?
    label: long reads technology, supported techs are nanopore and pacbio
    default: nanopore
  host_genome:
    type: File?
    format: edam:format_1929
    label: host genome, used for decontaminate
  align_preset:
    type: string?
    label: minimap2 align mode
    default: none
  align_polish:
    type: string?
    label: minimap2 align mode for polish
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
  host_unmapped_contigs:
    type: string?
    label: clean contigs unmap to host genome (fasta)
    default: assembly_unmap_host.fasta
  min_contig_size:
    type: int?
    label: filter assembly contigs by this size
    default: 500
  final_assembly:
    type: string?
    label: final assembly file name (fasta)
    default: contigs.fasta
  
outputs:
  final_assembly_fasta:
    type: File
    format: edam:format_1929
    outputSource: step_6_filterContigs/outFasta
  assembly_stats:
    type: File
    outputSource: step_7_assembly_stats/outAssemblyStats

steps:
  step_1_assembly:
    label: assembly long-reads with flye
    run: ../tools/flye/flye_runner.cwl
    in:
      readType: long_read_tech
      readFile: long_reads
    out: [ contigs_fasta ]

  step_2_polishing_minimap2:
    label: polishing step 1, map reads back to assembly with minimap2
    run: ../tools/minimap2/minimap2_to_polish.cwl
    in:
      alignMode: align_polish
      inAssembly: step_1_assembly/contigs_fasta
      inReads: long_reads
      outPAFname: polish_paf
    out: [ outPAF ]

  step_3_polishing_racon:
    label: polishing step 2, using racon to improve assembly
    run: ../tools/racon/racon.cwl
    in:
      inReads: long_reads
      mapping: step_2_polishing_minimap2/outPAF
      assembly: step_1_assembly/contigs_fasta
      outName: polish_assembly_racon
    out: [ outAssembly ]

  step_4_polishing_medaka:
    label: polishing step 3, using medaka to create a consensus
    run: ../tools/medaka/medaka_runner.cwl
    in:
      inReads: long_reads
      assembly: step_3_polishing_racon/outAssembly
      medakaModel: medaka_model
      tech: long_read_tech
    out: [ outConsensus ]
  
  step_5_cleaning_host:
    label: post-assembly cleaning, mapping with minimap2
    run: ../tools/minimap2_filter/minimap2_filterHostFa.cwl
    in:
      alignMode: align_preset
      outReadsName: host_unmapped_contigs
      refSeq: host_genome
      inSeq: step_4_polishing_medaka/outConsensus
    out: [ outReads ]

  step_6_filterContigs:
    label: remove short contigs
    run: ../tools/filterContigs/filterContigs.cwl
    in:
      minSize: min_contig_size
      inFasta: step_5_cleaning_host/outReads
      outName: final_assembly
    out: [ outFasta ]
  
  step_7_assembly_stats:
    label: generation of assembly stats JSON
    run: ../tools/assembly_stats/assemblyStats.cwl
    in:
      alignMode: align_polish
      contigs: step_6_filterContigs/outFasta
      reads: long_reads
    out: [ outAssemblyStats ]
  
$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schemaorg-current-https.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
s:dateCreated: 2021-01-14
