cwlVersion: v1.1
class: CommandLineTool
label: BWA-mem2 align
doc: |
      Implementation of BWA-mem2 aligner.

requirements:
  InitialWorkDirRequirement:
    listing: [ $(inputs.reference) ]
  ResourceRequirement:
    coresMin: 8
    ramMin: 1000 # 1 GB for testing, it needs more in production
hints:
  DockerRequirement:
    dockerPull: jcaballero/mgnify-lr.bwa-mem2:2.1

baseCommand: [ "bwa-mem2.sh" ]

arguments:
 - $(runtime.cores)

inputs:
  reference:
    type: File
    format: edam:format_1929
    label: Genome file (fasta)
    inputBinding:
      position: 1
  reads1:
    type: File
    format: edam:format_1930
    label: reads first pair
    inputBinding:
      position: 2
  reads2:
    type: File
    format: edam:format_1930
    label: reads second pair
    inputBinding:
      position: 3
  bamName:
    type: string
    label: output BAM file name
    inputBinding:
      position: 4

outputs:
  bam:
    type: File
    format: edam:format_2572
    secondaryFiles:
      - .bai
    outputBinding:
      glob: $(inputs.bamName)
  
stdout: bwa-mem2.log
stderr: bwa-mem2.err

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schemaorg-current-https.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
s:dateCreated: 2020-11-13
