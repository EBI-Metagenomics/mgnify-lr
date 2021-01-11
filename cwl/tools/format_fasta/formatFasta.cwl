cwlVersion: v1.1
class: CommandLineTool
label: formatFasta.
doc: |
      Implementation of formating an input file to Fasta format.

requirements:
  ResourceRequirement:
    coresMin: 1
    ramMin: 2000 # 1 GB for testing, it needs more in production
hints:
  DockerRequirement:
    dockerPull: jcaballero/mgnify-lr.formatfasta:0.0.1

baseCommand: [ "formatFasta.pl" ]

arguments:
  - -c
  - "80"
  
inputs:
  inFile:
    type: File
    format: edam:format_1929  # FASTA
    label: input file to format
    inputBinding:
      position: 1
      prefix: -i
  outFile:
    type: string
    label: output name for formated file
    inputBinding:
      position: 2
      prefix: -o
 
outputs:
  outFasta:
    type: File
    format: edam:format_1929  # FASTA
    outputBinding:
      glob: $(inputs.outFile)
  
stdout: formatFasta.log
stderr: formatFasta.err

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schemaorg-current-https.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
s:dateCreated: 2021-01-11
