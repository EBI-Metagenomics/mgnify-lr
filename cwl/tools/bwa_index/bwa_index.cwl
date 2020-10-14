cwlVersion: v1.2
class: CommandLineTool
label: Genome indexing with BWA.
doc: |
      Implementation of genome index generation with BWA.

requirements:
  InitialWorkDirRequirement:
    listing: [ $(inputs.sequences) ]
  ResourceRequirement:
    coresMin: 1
    ramMin: 6000 # 6 GB for testing, it needs more in production
hints:
  DockerRequirement:
    dockerPull: bwa:latest

baseCommand: [ "bwa", "index" ]

inputs:
  algorithm:
    type: string?
    label: index algorithm
    inputBinding:
      position: 1
      prefix: -a

  sequences:
    type: File
    format: edam:format_1929  # FASTA
    label: genome sequence to index
    inputBinding:
      valueFrom: $(self.basename)
      position: 2

 
outputs:
  output:
    type: File
    secondaryFiles:
      - .amb
      - .ann
      - .bwt
      - .pac
      - .sa
    outputBinding:
      glob: $(inputs.sequences.basename)
  
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
