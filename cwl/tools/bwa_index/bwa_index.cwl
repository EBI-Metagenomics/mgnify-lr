cwlVersion: v1.2
class: CommandLineTool
label: Genome indexing with BWA.
doc: |
      Implementation of genome index generation with BWA.

requirements:
  InlineJavascriptRequirement: {} # needed to get GB in RAM
  ResourceRequirement:
    coresMin: 1
    ramMin: 6000 # 6 GB for testing, it needs more in production
hints:
  DockerRequirement:
    dockerPull: bwa:latest

baseCommand: [ bwa ]

arguments:
 - index

inputs:
  algorithm:
    type: string
    label: index algorithm
    inputBinding:
      position: 1
      prefix: -a
  genome:
    type: File
    format: edam:format_1929  # FASTA
    label: genome sequence to index
    inputBinding:
      position: 2

 
outputs:
  index:
    type:
      type: array
      items: File
    outputBinding:
      glob: "$(inputs.genome).*"
  
stdout: bwa_index.log
stderr: bwa_index.err

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schemaorg-current-https.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
s:dateCreated: 2020-10-08
