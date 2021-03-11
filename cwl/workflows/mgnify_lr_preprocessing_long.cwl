cwlVersion: v1.2
class: Workflow
label: Preprocessing for long-reads
doc: |
      Implementation of pre-processing and QC for long-reads before assembly pipeline in MGnify

requirements:
  ResourceRequirement:
    coresMin: 8
    ramMin: 8000

inputs:
  long_reads:
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
    label: minimap2 align preset
    default: none
  reads_filter_bysize:
    type: string?
    label: prefix for reads with length lt min_read_size
    default: reads_filtered
  host_genome:
    type: File?
    format: edam:format_1929
    label: index name for genome host, used for decontaminate
  host_unmapped_reads:
    type: string?
    label: unmapped reads to the host genome
    default: host_unmapped.fastq.gz
  
outputs:
  raw_reads_stats:
    type: File
    outputSource: step_1_raw_reads_stats/outReport
  reads_qc_html:
    type: File
    outputSource: step_2_filter_reads/qchtml 
  reads_qc_json:
    type: File
    outputSource: step_2_filter_reads/qcjson
  reads_output:
    type: File
    format: edam:format_1930
    outputSource: step_3_filter_host/outReads
 
steps:
  step_1_raw_reads_stats:
    label: raw reads stats
    run: ../tools/assembly_stats/assemblyStatsFastq.cwl
    in:
      inFile: long_reads
      outReport: raw_reads_report
    out: [ outReport ]

  step_2_filter_reads:
    label: filtering short reads and perform QC
    run: ../tools/fastp/fastp_filter.cwl
    in:
      reads: long_reads
      minLength: min_read_size
      name: reads_filter_bysize
    out:
      - outReads
      - qcjson
      - qchtml

  step_3_filter_host:
    label: filter host reads aligning to the genome fasta
    run: ../tools/minimap2_filter/minimap2_filterHostFq.cwl
    in:
      alignMode: align_preset
      outReadsName: host_unmapped_reads
      inSeq: step_2_filter_reads/outReads
      refSeq: host_genome
    out: [ outReads ]
 

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schemaorg-current-https.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
s:dateCreated: 2021-01-12