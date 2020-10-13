cwlVersion: v1.2
class: CommandLineTool
label: Sort read mapping with BWA mem.
doc: |
      Implementation of sort NGS read mapping with BWA.

requirements:
  ResourceRequirement:
    coresMin: 1
    ramMin: 6000 # 6 GB for testing, it needs more in production
hints:
  DockerRequirement:
    dockerPull: bwa:latest

baseCommand: [ "bwa", "mem" ]

arguments:
 - 

inputs:
  index:
    type: File
    label: Genome index files
    inputBinding:
      position: 1
  reads1:
    type: File
    format: edam:format_1930  # FASTQ
    label: first pair FASTQ
    inputBinding:
      position: 2
  reads2:
    type: File
    format: edam:format_1930  # FASTQ
    label: second pair FASTQ
    inputBinding:
      position: 2
  outbam:
    type: string
    label: final name for the aligment in BAM

 
outputs:
  bamfile:
    type: File
    outputBinding:
      glob: $(inputs.outbam)
  
stdout: bwa.log
stderr: bwa.err

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schemaorg-current-https.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
s:dateCreated: 2020-10-08
