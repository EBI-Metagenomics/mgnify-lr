cwlVersion: v1.1
class: CommandLineTool
label: Reporting and preprocessing of Fastq files with fastp.
doc: |
      Implementation of paired-end Fastq preprocessing and quality reporting with fastp.

requirements:
  ResourceRequirement:
    coresMin: 1
    ramMin: 1000 # 1 GB for testing, it needs more in production
hints:
  DockerRequirement:
    dockerPull: microbiomeinformatics/fastp:v0.20.1

baseCommand: [ fastp ]

#fastp -w ${task.cpus} --in1 ${sread[0]} --in2 ${sread[1]} --out1 "${name}.fastp.R1.fastq" \
#        --out2 "${name}.fastp.R2.fastq" --json "${name}.qc.json" --html "${name}.qc.html"
arguments:
- -w
- $(runtime.cores)
- --out1
- $(inputs.name).fastp.R1.fastq.gz
- --out2
- $(inputs.name).fastp.R2.fastq.gz
- --json
- $(inputs.name).fastq.qc.json
- --html
- $(inputs.name).fastq.qc.html

inputs:
  name:
    type: string
    label: name prefix for output files (Fastq, JSON and HTML)

  reads1:
    type: File
    format: edam:format_1930  # FASTQ
    label: first pair Fastq file
    inputBinding:
      position: 1
      prefix: --in1

  reads2:
    type: File
    format: edam:format_1930  # FASTQ
    label: second pair Fastq file
    inputBinding:
      position: 2
      prefix: --in2
 
outputs:
  outreads1:
    type: File
    outputBinding:
      glob: "$(inputs.name).fastp.R1.fastq.gz"

  outreads2:
    type: File
    outputBinding:
      glob: "$(inputs.name).fastp.R2.fastq.gz"

  qcjson:
    type: File
    outputBinding:
      glob: "$(inputs.name).fastp.qc.json"

  qchtml:
    type: File
    outputBinding:
      glob: "$(inputs.name).fastp.qc.html"

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