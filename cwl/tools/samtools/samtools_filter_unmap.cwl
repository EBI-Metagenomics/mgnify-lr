cwlVersion: v1.2
class: CommandLineTool
label: Filter read unmaped (SAM) with Samtools.
doc: |
      Implementation of extraction of NGS read unmaped with Samtools.

requirements:
  ResourceRequirement:
    coresMin: 1
    ramMin: 6000 # 6 GB for testing, it needs more in production
hints:
  DockerRequirement:
    dockerPull: samtools:latest

baseCommand: [ "samtools", $(inputs.format) ]

arguments:
 - -@
 - $(runtime.cores)
 - -f
 - "4"

inputs:
  outFormat:
    type: string
    label: output format [fastq, fasta]

  outFile:
    type: string
    label: mapped sequences file
    inputBinding:
      position: 1
      prefix: -0

  inputSam:
    type: File
    format: edam:format_2573 # SAM
    label: SAM input to be filtered
    inputBinding:
      position: 2
 
outputs:
  mapped:
    type: File
    outputBinding:
      glob: $(inputs.outFile)
  
stdout: samtools_filter_unmap.log
stderr: samtools_filter_unmap.err

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schemaorg-current-https.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
s:dateCreated: 2020-10-08
