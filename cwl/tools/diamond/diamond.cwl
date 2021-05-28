cwlVersion: v1.2
class: CommandLineTool
label: Aligment of proteins with Diamond.
doc: |
      Implementation of Diamond aligner for protein searches.

requirements:
  ResourceRequirement:
    coresMin: 32
    ramMin: 2000
hints:
  DockerRequirement:
    dockerPull: microbiomeinformatics/mgnify-lr.diamond:2.0.7

baseCommand: [ diamond ]

arguments:
 - blastp
 - --threads
 - $(runtime.cores)
 - --max-target-seqs
 - "1"
 - --outfmt
 - "6"
 - qlen
 - slen

inputs:
  proteins:
    type: File
    format: edam:format_1929  # FASTA
    label: proteins in fasta
    inputBinding:
      position: 1
      prefix: --query
  database:
    type: File
    label: diamond database
    inputBinding:
      position: 2
      prefix: --db
  outName:
    type: string
    label: prefix output
    inputBinding:
      position: 3
      prefix: --out
 
outputs:
  alignment:
    type: File
    outputBinding:
      glob: $(inputs.outName)

stdout: diamond.log
stderr: diamond.err

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schemaorg-current-https.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
s:dateCreated: 2020-10-09