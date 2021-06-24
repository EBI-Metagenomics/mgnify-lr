cwlVersion: v1.2
class: Workflow
label: Hybrid read assembly workflow
doc: |
      Implementation of long-reads + short-reads assembly pipeline

requirements:
  SubworkflowFeatureRequirement: {}
  ResourceRequirement:
    coresMin: 8
    ramMin: 8000

inputs:
  long_reads:
    type: File
    format: edam:format_1930
    label: long reads to assemble
  long_read_tech:
    type: string?
    label: long reads technology, supported techs are nanopore and pacbio
    default: nanopore
  forward_short_reads:
    type: File
    format: edam:format_1930
    label: illumina paired reads to assemble (forward)
  reverse_short_reads:
    type: File
    format: edam:format_1930
    label: illumina paired reads to assemble (reverse)
  align_preset:
    type: string?
    label: minimap2 align preset for filtering, if none, no host filtering is applied
    default: none
  host_genome:
    type: File?
    format: edam:format_1929
    label: Host reference genome, used for decontaminate
  min_contig_size:
    type: int?
    label: minimal size for contigs, shorter are removed
    default: 500
  align_polish: 
    type: string?
    label: minimap2 align mode for coverage
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
  final_assembly:
    type: string?
    label: final assembly file (fasta)
    default: assembly_final.fasta

outputs:
  final_assembly_fasta:
    type: File
    format: edam:format_1929
    outputSource: step_7_filterContigs/outFasta
  assembly_graph:
    type: File
    outputSource: step_1_assembly/assembly_graph
  assembly_gfa:
    type: File
    outputSource: step_1_assembly/assembly_gfa
  assembly_stats:
    type: File
    outputSource: step_8_assembly_stats/outAssemblyStats
  spades_err:
    type: File
    outputSource: step_1_assembly/spades_err
  spades_log:
    type: File
    outputSource: step_1_assembly/spades_log

steps:
  step_1_assembly:
    label: hybrid assembly with metaSPAdes
    run: ../tools/spades/spades_runner.cwl
    in:
      readType: long_read_tech
      readFile: long_reads
      reads1: forward_short_reads
      reads2: reverse_short_reads
    out:
      - contigs_fasta
      - assembly_graph
      - assembly_gfa
      - spades_err
      - spades_log

  step_2_merge_short_reads:
    label: merge paired reads for polishing
    run: ../tools/merge_reads/merge_reads.cwl
    in:
      reads1: forward_short_reads
      reads2: reverse_short_reads
    out: [ merged_reads ]


  step_3_polishing_minimap2:
    label: polishing step 1, map reads back to assembly with minimap2
    run: ../tools/minimap2/minimap2_to_polish_pe.cwl
    in:
      inAssembly: step_1_assembly/contigs_fasta
      inReads: step_2_merge_short_reads/merged_reads
      outPAFname: polish_paf
    out: [ outPAF ]

  step_4_polishing_racon:
    label: polishing step 2, using racon to improve assembly
    run: ../tools/racon/racon.cwl
    in:
      inReads: step_2_merge_short_reads/merged_reads
      mapping: step_3_polishing_minimap2/outPAF
      assembly: step_1_assembly/contigs_fasta
      outName: polish_assembly_racon
    out: [ outAssembly ]

  step_5_polishing_medaka:
    label: polishing step 3, using medaka to create a consensus
    run: ../tools/medaka/medaka_runner.cwl
    in:
      inReads: long_reads
      assembly: step_4_polishing_racon/outAssembly
      medakaModel: medaka_model
      tech: long_read_tech
    out: [ outConsensus ]
  
  step_6_cleaning_host:
    label: post-assembly cleaning, mapping with minimap2
    run: ../tools/minimap2_filter/minimap2_filterHostFa.cwl
    in:
      alignMode: align_preset
      outReadsName: host_unmapped_contigs
      refSeq: host_genome
      inSeq: step_5_polishing_medaka/outConsensus
    out: [ outReads ]

  step_7_filterContigs:
    label: remove short contigs
    run: ../tools/filterContigs/filterContigs.cwl
    in:
      minSize: min_contig_size
      inFasta: step_6_cleaning_host/outReads
      outName: final_assembly
    out: [ outFasta ]
  
  step_8_assembly_stats:
    label: generation of assembly stats JSON
    run: ../tools/assembly_stats/assemblyStatsHybrid.cwl
    in:
      alignMode: align_polish
      contigs: step_7_filterContigs/outFasta
      reads: long_reads
      p1_reads: forward_short_reads
      p2_reads: reverse_short_reads
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