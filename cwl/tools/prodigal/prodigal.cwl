cwlVersion: v1.2
class: CommandLineTool
label: Gene predition with Prodigal.
doc: |
      Implementation of gene prediction with Prodigal.

requirements:
  ResourceRequirement:
    coresMin: 1
    ramMin: 1000 # 1 GB for testing, it needs more in production
hints:
  DockerRequirement:
    dockerPull: microbiomeinformatics/pipeline-v5.prodigal:v2.6.3

baseCommand: [ prodigal ]

inputs:
  nucleotides:
    type: File
    format: edam:format_1929  # FASTA
    label: nucleotide sequence fasta
    inputBinding:
      position: 1
      prefix: -i
  proteins:
    type: string
    label: predicted aminoacids
    inputBinding:
      position: 2
      prefix: -a
  output:
    type: string
    label: prodigal output (gbk)
    inputBinding:
      position: 3
      prefix: -o
  
arguments:
 - -p
 - meta
 - -q
 
outputs:
  protpred:
    type: File
    outputBinding:
      glob: $(inputs.proteins)
  outfile:
    type: File
    outputBinding:
      glob: $(inputs.output)

stdout: prodigal.log
stderr: prodigal.err

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schemaorg-current-https.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
s:dateCreated: 2020-10-09