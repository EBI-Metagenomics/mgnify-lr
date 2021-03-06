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
  pilon_align:
    type: string?
    label: illumina reads alignment for polishing
    default: pilon_align.bam
  polish_assembly_pilon:
    type: string?
    label: polish assembly after illumina map
    default: assembly_polish_pilon
  min_contig_size:
    type: int?
    label: minimal size for contigs, shorter are removed
    default: 500
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

outputs:
  final_assembly_fasta:
    type: File
    format: edam:format_1929
    outputSource: step_7_filterContigs/outFasta
  assembly_stats:
    type: File
    outputSource: step_8_assembly_stats/outAssemblyStats

steps:
  step_1_assembly:
    label: long-reads assembly with Flye
    run: ../tools/flye/flye_runner.cwl
    in:
      readType: long_read_tech
      readFile: long_reads
    out: [ contigs_fasta ]

  step_2_polishing_align_rnd1:
    label: aligning illumina reads to assembly
    run: ../tools/bwa/bwa-mem2.cwl
    in:
      reads1: forward_short_reads
      reads2: reverse_short_reads
      reference: step_1_assembly/contigs_fasta
      bamName: pilon_align
    out: [ bam ]

  step_3_polishing_pilon_rnd1:
    label: polishing assembly with pilon (round 1)
    run: ../tools/pilon/pilon.cwl
    in:
      sequences: step_1_assembly/contigs_fasta
      alignment: step_2_polishing_align_rnd1/bam
      outfile: polish_assembly_pilon
    out: [ outfile ]

  step_4_polishing_align_rnd2:
    label: aligning illumina reads to assembly
    run: ../tools/bwa/bwa-mem2.cwl
    in:
      reads1: forward_short_reads
      reads2: reverse_short_reads
      reference: step_3_polishing_pilon_rnd1/outfile
      bamName: pilon_align
    out: [ bam ]

  step_5_polishing_pilon_rnd2:
    label: polishing assembly with pilon (round 2)
    run: ../tools/pilon/pilon.cwl
    in:
      sequences: step_3_polishing_pilon_rnd1/outfile
      alignment: step_4_polishing_align_rnd2/bam
      outfile: polish_assembly_pilon
    out: [ outfile ]
  
  step_6_cleaning_host:
    label: post-assembly cleaning, mapping with minimap2
    run: ../tools/minimap2_filter/minimap2_filterHostFa.cwl
    in:
      alignMode: align_preset
      outReadsName: host_unmapped_contigs
      refSeq: host_genome
      inSeq: step_5_polishing_pilon_rnd2/outfile
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