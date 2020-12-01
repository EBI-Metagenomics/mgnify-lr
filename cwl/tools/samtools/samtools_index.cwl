cwlVersion: v1.1
class: CommandLineTool
label: Index read mapping (BAM) with Samtools.
doc: |
      Implementation of indexing a NGS read mapping with Samtools.

requirements:
  InitialWorkDirRequirement:
    listing: [ $(inputs.inputBam) ]
  ResourceRequirement:
    coresMin: 8
    ramMin: 2000 # 2 GB for testing
hints:
  DockerRequirement:
    dockerPull: jcaballero/mgnify-lr.samtools:1.11

baseCommand: [ "samtools", "index" ]

arguments:
 - -@
 - $(runtime.cores)

inputs:
  inputBam:
    type: File
    format: edam:format_2572 # BAM
    label: BAM input to be sorted
    inputBinding:
      position: 1
 
outputs:
  indexBam:
    type: File
    outputBinding:
      glob: $(inputs.inputBam.basename).bai
  
stdout: samtools_index.log
stderr: samtools_index.err

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schemaorg-current-https.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
s:dateCreated: 2020-10-08
