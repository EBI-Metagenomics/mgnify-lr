cwlVersion: v1.1
class: CommandLineTool
label: removeSmallReads from a Fastq.
doc: |
      Implementation of filtering by read size in a Fastq file.

requirements:
  ResourceRequirement:
    coresMin: 1
    ramMin: 2000 # 2 GB for testing, it needs more in production
hints:
  DockerRequirement:
    dockerPull: jcaballero/mgnify-lr.removesmallreads:0.0.1

baseCommand: [ "removeSmallReads.sh" ]

inputs:
  length:
    type: int
    label: size threshold
    inputBinding:
      position: 1
  inFastq:
    type: File
    format: edam:format_1930  # FASTQ
    label: short reads to filter (fastq)
    inputBinding:
      position: 2
  outFastqName:
    type: string
    label: short reads filtered (gzip fastq)
    inputBinding:
      position: 3
 
outputs:
  outFastq:
    type: File
    format: edam:format_1930
    outputBinding:
      glob: $(inputs.outFastqName)
  
stdout: removeSmallReads.log
stderr: removeSmallReads.err

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schemaorg-current-https.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
s:dateCreated: 2020-10-08
