cwlVersion: v1.1
class: CommandLineTool
label: BWA-mem2 align to filter host-mapping reads
doc: |
      Implementation of BWA-mem2 aligner to remove reads mapping to host reference genome and kept unmapped reads as Fastq files

requirements:
  ResourceRequirement:
    coresMin: 8
    ramMin: 1000 # 1 GB for testing, it needs more in production
hints:
  DockerRequirement:
    dockerPull: jcaballero/mgnify-lr.bwa-mem2:2.1.1

baseCommand: [ "bwa-mem2_filterHostFq.sh" ]

arguments:
 - $(runtime.cores)

inputs:
  reference:
    type: File
    secondaryFiles:
      - .0123
      - .amb
      - .ann
      - .bwt.2bit.64
      - .pac
    label: Genome index (bwa-mem2 -x sr)
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
  out1name:
    type: string
    label: output fastq first pair file name
    inputBinding:
      position: 4
  out2name:
    type: string
    label: output fastq second pair file name
    inputBinding:
      position: 5

outputs:
  out1:
    type: File
    format: edam:format_1930
    outputBinding:
      glob: $(inputs.out1name)
  out2:
    type: File
    format: edam:format_1930
    outputBinding:
      glob: $(inputs.out2name)
  
stdout: bwa-mem2_filterHostFq.log
stderr: bwa-mem2_filterHostFq.err

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schemaorg-current-https.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
s:dateCreated: 2020-11-13
