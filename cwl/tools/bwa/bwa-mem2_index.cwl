cwlVersion: v1.1
class: CommandLineTool
label: BWA-mem2 index
doc: |
      Implementation of BWA-mem2 index generator.

requirements:
  InitialWorkDirRequirement:
    listing: [ $(inputs.reference) ]
  ResourceRequirement:
    coresMin: 1
    ramMin: 1000 # 1 GB for testing, it needs more in production
hints:
  DockerRequirement:
    dockerPull: bwa-mem2:latest

baseCommand: [ "bwa-mem2" ]

arguments:
 - index

inputs:
  reference:
    type: File
    format: edam:format_1929
    label: Genome file (fasta)
    inputBinding:
      position: 1
 
outputs:
  index:
    type: File
    secondaryFiles:
      - .0123
      - .amb
      - .ann
      - .bwt.2bit.64
      - .pac
    outputBinding:
      glob: $(inputs.reference.basename)
  
stdout: bwa-mem2_index.log
stderr: bwa-mem2_index.err

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schemaorg-current-https.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
s:dateCreated: 2020-11-13
