cwlVersion: v1.2
class: Workflow
label: Preprocessing for short-reads (illumina PE)
doc: |
      Implementation of pre-processing and QC for PE Illumina short reads before assembly pipeline in MGnify

requirements:
  ResourceRequirement:
    coresMin: 8
    ramMin: 8000

inputs:
  reads1:
    type: File
    format: edam:format_1930
    label: Fastq file to process (forward)
  reads2:
    type: File
    format: edam:format_1930
    label: Fastq file to process (reverse)
  min_read_size:
    type: int?
    label: Short reads filter by size
    default: 50
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
  host_unmapped_reads_1:
    type: string?
    label: unmapped reads to the host genome
    default: host_unmapped_1.fastq.gz
  host_unmapped_reads_2:
    type: string?
    label: unmapped reads to the host genome
    default: host_unmapped_2.fastq.gz

outputs:
  reads_qc_html:
    type: File
    outputSource: step_1_filter_reads/qchtml 
  reads_qc_json:
    type: File
    outputSource: step_1_filter_reads/qcjson
  reads_out_1:
    type: File
    format: edam:format_1930
    outputSource: step_2_filter_host/outReads1
  reads_out_2:
    type: File
    format: edam:format_1930
    outputSource: step_2_filter_host/outReads2
 
steps:
  step_1_filter_reads:
    label: filtering short reads and perform QC
    run: ../tools/fastp/fastp.cwl
    in:
      reads1: reads1
      reads2: reads2
      minLength: min_read_size
      name: reads_filter_bysize
    out:
      - outreads1
      - outreads2
      - qcjson
      - qchtml

  step_2_filter_host:
    label: align reads to the genome fasta for host filtering
    run: ../tools/bwa/bwa-mem2_filterHostFq.cwl
    in:
      reads1: step_1_filter_reads/outreads1
      reads2: step_1_filter_reads/outreads2
      out1: host_unmapped_reads_1
      out2: host_unmapped_reads_2
      refSeq: host_genome
      alignMode: align_preset
    out:
      - outReads1
      - outReads2 

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schemaorg-current-https.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
s:dateCreated: 2021-01-13