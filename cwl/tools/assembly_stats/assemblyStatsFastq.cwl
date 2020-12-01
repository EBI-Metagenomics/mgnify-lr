cwlVersion: v1.1
class: CommandLineTool
label: assemblyStats from a Fastq.
doc: |
      Implementation of computing assembly statistics (N50) for a Fastq file.

requirements:
  ResourceRequirement:
    coresMin: 1
    ramMin: 2000 # 1 GB for testing, it needs more in production
hints:
  DockerRequirement:
    dockerPull: jcaballero/mgnify-lr.assemblystats:0.0.1

baseCommand: [ "calc_stats.pl" ]

arguments:
  - -f
  - fastq

inputs:
  inFile:
    type: File
    format: edam:format_1930  # FASTQ
    label: fastq file to analyze
    inputBinding:
      position: 1
      prefix: -i
  outReport:
    type: string
    label: output report file
    inputBinding:
      position: 2
      prefix: -o
 
outputs:
  outReport:
    type: File
    outputBinding:
      glob: $(inputs.outReport)
  
stdout: assemblyStatsFastq.log
stderr: assemblyStatsFastq.err

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schemaorg-current-https.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
s:dateCreated: 2020-10-08
