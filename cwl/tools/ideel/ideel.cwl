cwlVersion: v1.2
class: CommandLineTool
label: Ideel predicted proteins report
doc: |
      Implementation of completeness of predicted proteins after comparison with Uniprot.

requirements:
  ResourceRequirement:
    coresMin: 1
    ramMin: 1000 # 6 GB for testing, it needs more in production
hints:
  DockerRequirement:
    dockerPull: ideel:latest

baseCommand: [ "Rscript", "/usr/local/bin/ideel.R" ]

inputs:
  inputTable:
    type: File
    label: input table with diamond [qlen slen]
    inputBinding:
      position: 1

  outFigName:
    type: string
    label: output figure (pdf)
    inputBinding:
      position: 2
 
outputs:
  outFig:
    type: File
    outputBinding:
      glob: $(inputs.outFigName)
  
stdout: ideel.log
stderr: ideel.err

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schemaorg-current-https.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
s:dateCreated: 2020-10-08
