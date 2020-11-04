cwlVersion: v1.1
class: CommandLineTool
label: Minimap2 align
doc: |
      Implementation of sequence mapping with Minimap2.

requirements:
  ResourceRequirement:
    coresMin: 1
    ramMin: 2000 # 2 GB for testing, it needs more in production
hints:
  DockerRequirement:
    dockerPull: jcaballero/mgnify-lr.minimap2:2.17

baseCommand: [ "minimap2" ]

arguments:
 - -a
 - -t
 - $(runtime.cores)

inputs:
  outSAM:
    type: string
    label: output SAM file
    inputBinding:
      position: 1
      prefix: -o
  dbIndex:
    type: File
    label: genome index
    inputBinding:
      position: 2
  inSeq1:
    type: File
    label: sequences to map (single or first pair)
    inputBinding:
      position: 3
  inSeq2:
    type: File?
    label: sequences to map (second pair)
    inputBinding:
      position: 4

outputs:
  outSAM:
    type: File
    format: edam:format_2573
    outputBinding:
      glob: $(inputs.outSAM)

stdout: minimap2_align.log
stderr: minimap2_align.err

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schemaorg-current-https.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
s:dateCreated: 2020-10-08
