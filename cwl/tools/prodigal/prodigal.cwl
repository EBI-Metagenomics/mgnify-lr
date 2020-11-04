cwlVersion: v1.1
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
  inNucl:
    type: File
    format: edam:format_1929  # FASTA
    label: nucleotide sequence fasta
    inputBinding:
      position: 1
      prefix: -i
  outProtName:
    type: string
    label: prodigal predicted proteins in Fasta
    inputBinding:
      position: 2
      prefix: -a
  outGbkName:
    type: string
    label: prodigal predicted proteins output in GBK
    inputBinding:
      position: 3
      prefix: -o
  
arguments:
 - -p
 - meta
 - -q
 
outputs:
  outProt:
    type: File
    format: edam:format_1929 # FASTA
    outputBinding:
      glob: $(inputs.outProtName)
  outGBK:
    type: File
    format: edam:format_1936 # GBK 
    outputBinding:
      glob: $(inputs.outGbkName)

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