cwlVersion: v1.1
class: CommandLineTool
label: Index Fasta with Samtools.
doc: |
      Implementation of indexing a Fasta file with Samtools.

requirements:
  InitialWorkDirRequirement:
    listing: [ $(inputs.inputFasta) ]
  ResourceRequirement:
    coresMin: 1
    ramMin: 2000
hints:
  DockerRequirement:
    dockerPull: jcaballero/mgnify-lr.samtools:1.11

baseCommand: [ "samtools", "faidx" ]

inputs:
  inputFasta:
    type: File
    label: Fasta input to be sorted
    inputBinding:
      position: 1
 
outputs:
  indexFai:
    type: File
    outputBinding:
      glob: "$(inputs.inputFasta.basename).fai"
  
stdout: samtools_faidx.log
stderr: samtools_faidx.err

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schemaorg-current-https.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
s:dateCreated: 2020-10-08
