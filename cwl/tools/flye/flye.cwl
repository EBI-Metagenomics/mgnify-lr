cwlVersion: v1.1
class: CommandLineTool
label: Assembly of Nanopore reads with Flye assembler.
doc: |
      Implementation of nanopore long reads assembly using Flye assembler.

requirements:
  ResourceRequirement:
    coresMin: 1
    ramMin: 1000 # 1 GB for testing, it needs more in production
hints:
  DockerRequirement:
    dockerPull: jcaballero/mgnify-lr.flye:2.8.1

baseCommand: [ flye ]

arguments:
 - -t
 - $(runtime.cores)
 - --plasmids
 - --meta
 - -o
 - flye_output

inputs:
  nano:
    type: File
    format: edam:format_1930  # FASTQ
    label: nanopore reads
    inputBinding:
      position: 1
      prefix: --nano-raw

outputs:
  contigs_fasta:
    type: File
    format: edam:format_1929
    outputBinding:
      glob: "flye_output/assembly.fasta"

stdout: flye.log
stderr: flye.err

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schemaorg-current-https.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
s:dateCreated: 2020-10-08