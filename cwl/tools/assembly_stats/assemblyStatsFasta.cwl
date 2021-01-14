cwlVersion: v1.2
class: CommandLineTool
label: assemblyStats from a Fasta.
doc: |
      Implementation of computing assembly statistics (N50) for a Fasta file.

requirements:
  ResourceRequirement:
    coresMin: 1
    ramMin: 2000
hints:
  DockerRequirement:
    dockerPull: jcaballero/mgnify-lr.assemblystats:0.0.1

baseCommand: [ "calc_stats.pl" ]

arguments:
  - -f
  - fasta

inputs:
  inFile:
    type: File
    format: edam:format_1929  # FASTQ
    label: fasta file to analyze
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
  
stdout: assemblyStatsFasta.log
stderr: assemblyStatsFasta.err

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schemaorg-current-https.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
s:dateCreated: 2020-10-08
