cwlVersion: v1.2
class: CommandLineTool
label: Minimap2 align and filter host
doc: |
      Implementation of sequence mapping with Minimap2, host hits are ignored, unmapped reads are passed as output

requirements:
  ResourceRequirement:
    coresMin: 8
    ramMin: 2000
hints:
  DockerRequirement:
    dockerPull: jcaballero/mgnify-lr.minimap2_filter:2.17.4

baseCommand: [ "minimap2_filter.sh" ]

arguments:
  - -t
  - $(runtime.cores)
  - -f
  - fastq

inputs:
  alignMode:
    type: string
    label: minimap2 align mode
    inputBinding:
      position: 1
      prefix: -a
  refSeq:
    type: File
    format: edam:format_1929
    label: genome fasta
    inputBinding:
      position: 2
      prefix: -g
  inSeq:
    type: File
    format: edam:format_1930
    label: sequences to map
    inputBinding:
      position: 3
      prefix: -r
  outReadsName:
    type: string
    label: unmapped reads file name 
    inputBinding:
      position: 4
      prefix: -o

outputs:
  outReads:
    type: File
    format: edam:format_1930
    outputBinding:
      glob: $(inputs.outReadsName)

stdout: minimap2_filterFq.log
stderr: minimap2_filterFq.err

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schemaorg-current-https.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
s:dateCreated: 2020-10-08
