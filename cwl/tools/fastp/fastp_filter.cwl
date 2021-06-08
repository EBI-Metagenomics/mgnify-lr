cwlVersion: v1.2
class: CommandLineTool
label: Reporting and preprocessing of LR Fastq files with fastp.
doc: |
      Implementation of long-reads Fastq preprocessing and quality reporting with fastp.

requirements:
  ResourceRequirement:
    coresMin: 32
    ramMin: 8000
hints:
  DockerRequirement:
    dockerPull: microbiomeinformatics/fastp:v0.20.1

baseCommand: [ fastp ]

arguments:
  - -Q
  - -A
  - -w
  - $(runtime.cores)
  - -o
  - $(inputs.name).fastp.fastq.gz
  - --json
  - $(inputs.name).fastp.qc.json
  - --html
  - $(inputs.name).fastp.qc.html

inputs:
  name:
    type: string
    label: name prefix for output files (Fastq, JSON and HTML)
  reads:
    type: File
    format: edam:format_1930  # FASTQ
    label: first pair Fastq file
    inputBinding:
      position: 1
      prefix: -i
  minLength:
    type: int
    label: filter reads shorted that this value
    inputBinding:
      position: 2
      prefix: -l
 
outputs:
  outReads:
    type: File
    format: edam:format_1930
    outputBinding:
      glob: $(inputs.name).fastp.fastq.gz
  qcjson:
    type: File
    outputBinding:
      glob: $(inputs.name).fastp.qc.json
  qchtml:
    type: File
    outputBinding:
      glob: $(inputs.name).fastp.qc.html

stdout: fastp.log
stderr: fastp.err

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schemaorg-current-https.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
s:dateCreated: 2020-10-12
