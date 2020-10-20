cwlVersion: v1.2
class: CommandLineTool
label: getHostFasta retrieve a genome fasta from Ensembl/link.
doc: |
      Implementation of retriving a genome in fasta format from Ensemble (species) or from a URL.

requirements:
  ResourceRequirement:
    coresMin: 1
    ramMin: 1000
hints:
  DockerRequirement:
    dockerPull: gethostfasta:latest

baseCommand: [ "getHostFasta.sh" ]

inputs:
  species:
    type: string
    label: species or url to retrieve
    inputBinding:
      position: 1
  outfasta:
    type: string
    label: output file (fasta)
 
outputs:
  out: stdout
  
stdout: $(inputs.outfasta)
stderr: getHostFasta.err

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schemaorg-current-https.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
s:dateCreated: 2020-10-08
