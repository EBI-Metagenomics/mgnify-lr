cwlVersion: v1.2
class: CommandLineTool
label: Merge paired end reads in a single file
doc: |
      Implementation of Fastq merging for paired-end data, sequences IDs are modified to be uniq

requirements:
  ResourceRequirement:
    coresMin: 1
    ramMin: 2000
hints:
  DockerRequirement:
    dockerPull: microbiomeinformatics/mgnify-lr.merge_reads:0.0.3

baseCommand: [ "merge_reads.pl" ]

inputs:
  reads1:
    type: File
    format: edam:format_1930
    label: First pair file
    inputBinding:
      position: 1
  reads2:
    type: File
    format: edam:format_1930
    label: Second pair file
    inputBinding:
      position: 2

outputs:
  merged_reads:
    type: File
    format: edam:format_1930
    outputBinding:
      glob: "merged_reads.fastq.gz"

stdout: merge_reads.log
stderr: merge_reads.err

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schemaorg-current-https.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
s:dateCreated: 2021-05-20
