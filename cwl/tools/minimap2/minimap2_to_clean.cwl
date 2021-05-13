cwlVersion: v1.2
class: CommandLineTool
label: Minimap2 to clean.
doc: |
      Implementation of sequence mapping with Minimap2.

requirements:
  ResourceRequirement:
    coresMin: 8
    ramMin: 2000
hints:
  DockerRequirement:
    dockerPull: microbiomeinformatics/mgnify-lr.minimap2_filter:2.17.4

baseCommand: [ "minimap2" ]

arguments:
 - -a
 - -t
 - $(runtime.cores)

inputs:
  outSAMname:
    type: string
    label: output SAM file
    inputBinding:
      position: 1
      prefix: -o
  inHostIndex:
    type: File
    label: genome index
    inputBinding:
      position: 2
  inSeqs:
    type: File
    format: edam:format_1929
    label: assembled sequences to map 
    inputBinding:
      position: 3

outputs:
  outSAM:
    type: File
    format: edam:format_2573
    outputBinding:
      glob: $(inputs.outSAMname)

stdout: minimap2_to_clean.log
stderr: minimap2_to_clean.err

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schemaorg-current-https.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
s:dateCreated: 2020-10-08