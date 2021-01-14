cwlVersion: v1.2
class: CommandLineTool
label: Gene predition with Prodigal.
doc: |
      Implementation of gene prediction with Prodigal.

requirements:
  ResourceRequirement:
    coresMin: 1
    ramMin: 2000
hints:
  DockerRequirement:
    dockerPull: jcaballero/mgnify-lr.prodigal:2.6.3

baseCommand: [ prodigal ]

arguments:
 - -p
 - meta


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
   
outputs:
  outProt:
    type: File
    format: edam:format_1929 # FASTA
    outputBinding:
      glob: $(inputs.outProtName)

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
