cwlVersion: v1.2
class: CommandLineTool
label: BWA-mem2 align to filter host-mapping reads
doc: |
      Implementation of BWA-mem2 aligner to remove reads mapping to host reference genome and kept unmapped reads as Fastq files

requirements:
  InitialWorkDirRequirement:
    listing: [ $(inputs.refSeq) ]
  ResourceRequirement:
    coresMin: 32
    ramMin: 4000
hints:
  DockerRequirement:
    dockerPull: microbiomeinformatics/mgnify-lr.bwa-mem2:2.1.2

baseCommand: [ "bwa-mem2_filterHostFq.sh" ]

arguments:
  - -t
  - $(runtime.cores)

inputs:
  alignMode:
    type: string?
    label: flag to pass when genome filtering is off
    default: none
    inputBinding:
      prefix: -a
      position: 0
  refSeq:
    type: File?
    format: edam:format_1929
    label: Genome Fasta
    inputBinding:
      prefix: -g
      position: 1
  reads1:
    type: File
    format: edam:format_1930
    label: reads first pair
    inputBinding:
      prefix: -p
      position: 2
  reads2:
    type: File
    format: edam:format_1930
    label: reads second pair
    inputBinding:
      prefix: -q
      position: 3
  out1:
    type: string
    label: output fastq first pair file name
    inputBinding:
      prefix: -x
      position: 4
  out2:
    type: string
    label: output fastq second pair file name
    inputBinding:
      prefix: -y
      position: 5

outputs:
  outReads1:
    type: File
    format: edam:format_1930
    outputBinding:
      glob: $(inputs.out1)
  outReads2:
    type: File
    format: edam:format_1930
    outputBinding:
      glob: $(inputs.out2)
  
stdout: bwa-mem2_filterHostFq.log
stderr: bwa-mem2_filterHostFq.err

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schemaorg-current-https.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
s:dateCreated: 2020-11-13
