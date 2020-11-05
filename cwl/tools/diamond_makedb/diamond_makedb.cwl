cwlVersion: v1.1
class: CommandLineTool
label: Index of proteins database with Diamond.
doc: |
      Implementation of Diamond index creation for protein searches.

requirements:
  ResourceRequirement:
    coresMin: 1
    ramMin: 1000 # 1 GB for testing, it needs more in production
hints:
  DockerRequirement:
    dockerPull: microbiomeinformatics/pipeline-v5.diamond:v0.9.25

baseCommand: [ diamond ]

arguments:
 - makedb

inputs:
  proteins:
    type: File
    format: edam:format_1929  # FASTA
    label: proteins in fasta
    inputBinding:
      position: 1
      prefix: --in
  database:
    type: string
    label: diamond database
    inputBinding:
      position: 2
      prefix: -d
 
outputs:
  diamondIndex:
    type: File
    label: output index
    outputBinding:
      glob: $(inputs.database)

stdout: diamond_makedb.log
stderr: diamond_makedb.err

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schemaorg-current-https.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
s:dateCreated: 2020-10-09