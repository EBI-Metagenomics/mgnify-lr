cwlVersion: v1.2
class: CommandLineTool
label: BWA-mem2 index
doc: |
      Implementation of BWA-mem2 index generator.

requirements:
  InitialWorkDirRequirement:
    listing: [ $(inputs.reference) ]
  ResourceRequirement:
    coresMin: 1
    ramMin: 2000
hints:
  DockerRequirement:
    dockerPull: microbiomeinformatics/mgnify-lr.bwa-mem2:2.1.1

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
    type: File[]
    outputBinding:
      glob: $(inputs.reference.basename)*
  
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
