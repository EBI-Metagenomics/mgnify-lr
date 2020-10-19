cwlVersion: v1.2
class: CommandLineTool
label: Minimap2 to polish.
doc: |
      Implementation of sequence mapping with Minimap2.

requirements:
  ResourceRequirement:
    coresMin: 1
    ramMin: 2000 # 2 GB for testing, it needs more in production
hints:
  DockerRequirement:
    dockerPull: minimap2:latest

baseCommand: [ "minimap2" ]

arguments:
 - -x
 - map-ont
 - -t
 - $(runtime.cores)

inputs:
  outPAF:
    type: string
    label: output PAF file
    inputBinding:
      position: 1
      prefix: -o
  inAssembly:
    type: File
    label: assembly to be used as target
    inputBinding:
      position: 2
  inReads:
    type: File
    label: read sequences to map 
    inputBinding:
      position: 3

outputs:
  outPAF:
    type: File
    outputBinding:
      glob: $(inputs.outPAF)

stdout: minimap2_to_polish.log
stderr: minimap2_to_polish.err

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schemaorg-current-https.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
s:dateCreated: 2020-10-08