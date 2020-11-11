cwlVersion: v1.1
class: CommandLineTool
label: Sort read mapping (BAM) with Samtools.
doc: |
      Implementation of sort NGS read mapping with Samtools.

requirements:
  InitialWorkDirRequirement:
    listing: [ $(inputs.inputBam) ]
  ResourceRequirement:
    coresMin: 1
    ramMin: 1000 # 1 GB for testing, it needs more in production
hints:
  DockerRequirement:
    dockerPull: jcaballero/mgnify-lr.samtools:1.11

baseCommand: [ "samtools", "sort" ]

arguments:
 - -@
 - $(runtime.cores)

inputs:
  outputBam:
    type: string
    label: Sorted BAM output
    inputBinding:
      position: 1
      prefix: -o

  inputBam:
    type: File
    format: edam:format_2572 # BAM
    label: BAM input to be sorted
    inputBinding:
      position: 2
 
outputs:
  sortedBam:
    type: File
    outputBinding:
      glob: $(inputs.outputBam)
  
stdout: samtools_sort.log
stderr: samtools_sort.err

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schemaorg-current-https.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
s:dateCreated: 2020-10-08
