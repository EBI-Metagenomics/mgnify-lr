cwlVersion: v1.2
class: CommandLineTool
label: Skip polishing with Medaka for Pacbio.
doc: |
      Skip polishing with Medaka for Pacbio, input Fasta is renamed as consensus.fasta

requirements:
  ResourceRequirement:
    coresMin: 1
    ramMin: 1000
hints:
  DockerRequirement:
    dockerPull: jcaballero/mgnify-lr.filtercontigs:0.0.3

baseCommand: [ "cp" ]

inputs:
  assembly:
    type: File
    format: edam:format_1929
    label: assembly to pass
    inputBinding:
      position: 1
      
  outName:
    type: string?
    default: "consensus.fasta"
    label: fasta outfile
    inputBinding:
      position: 2

outputs:
  outConsensus:
    type: File
    format: edam:format_1929
    outputBinding:
      glob: $(inputs.outName)
  
stdout: medaka.log
stderr: medaka.err

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schemaorg-current-https.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
s:dateCreated: 2020-10-08
