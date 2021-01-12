cwlVersion: v1.1
class: CommandLineTool
label: filterContigs from a Fasta.
doc: |
      Implementation of filtering sequence by mininal size in a Fasta file.

requirements:
  ResourceRequirement:
    coresMin: 1
    ramMin: 2000 # 1 GB for testing, it needs more in production
hints:
  DockerRequirement:
    dockerPull: jcaballero/mgnify-lr.filtercontigs:0.0.1

baseCommand: [ "filterContigs.pl" ]

inputs:
  inFasta:
    type: File
    format: edam:format_1929 
    label: fasta file to filter
    inputBinding:
      position: 1
      prefix: -i
  minSize:
    type: int
    label: mininal size
    inputBinding:
      position: 2
      prefix: -s
  outName:
    type: string
    label: output fasta file name
    inputBinding:
      position: 2
      prefix: -o
 
outputs:
  outFasta:
    type: File
    format: edam:format_1929
    outputBinding:
      glob: $(inputs.outName)
  
stdout: filterContigs.log
stderr: filterContigs.err

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schemaorg-current-https.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
s:dateCreated: 2020-10-08
