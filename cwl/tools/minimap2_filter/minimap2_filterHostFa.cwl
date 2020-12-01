cwlVersion: v1.1
class: CommandLineTool
label: Minimap2 align and filter host
doc: |
      Implementation of sequence mapping with Minimap2, host hits are ignored, unmapped reads are passed as output

requirements:
  ResourceRequirement:
    coresMin: 8
    ramMin: 2000 # 2GB for testing, it needs more in production
hints:
  DockerRequirement:
    dockerPull: jcaballero/mgnify-lr.minimap2_filter:2.17.2

baseCommand: [ "minimap2_filter.sh" ]

arguments:
 - $(runtime.cores)
 - fasta

inputs:
  alignMode:
    type: string
    label: minimap2 align mode
    inputBinding:
      position: 0
  dbIndex:
    type: File
    label: genome index
    inputBinding:
      position: 1
  inSeq:
    type: File
    format: edam:format_1929
    label: sequences to map
    inputBinding:
      position: 2
  outReadsName:
    type: string
    label: unmapped reads file name 
    inputBinding:
      position: 3

outputs:
  outReads:
    type: File
    format: edam:format_1929
    outputBinding:
      glob: $(inputs.outReadsName)

stdout: minimap2_filterFa.log
stderr: minimap2_filterFa.err

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schemaorg-current-https.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
s:dateCreated: 2020-10-08
