cwlVersion: v1.1
class: CommandLineTool
label: Sort read mapping with BWA mem.
doc: |
      Implementation of sort NGS read mapping with BWA.

requirements:
  ResourceRequirement:
    coresMin: 32
    ramMin: 2000 # 1 GB for testing, it needs more in production
hints:
  DockerRequirement:
    dockerPull: bwa:latest

baseCommand: [ "bwa", "mem" ]

arguments:
 - -t
 - $(runtime.cores) 

inputs:
  reference:
    type: File
    label: Genome index files
    secondaryFiles:
      - .amb
      - .ann
      - .bwt
      - .pac
      - .sa
    inputBinding:
      position: 1

  reads1:
    type: File
    format: edam:format_1930  # FASTQ
    label: short reads in fastq format
    inputBinding:
      position: 2

  reads2:
    type: File?
    format: edam:format_1930  # FASTQ
    label: short reads in fastq format
    inputBinding:
      position: 3
      
  outfile:
    type: string
    label: final name for the aligment file

 
outputs:
  bamfile:
    type: stdout
  
stdout: $(inputs.outfile)
stderr: bwa.err

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schemaorg-current-https.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
s:dateCreated: 2020-10-08
