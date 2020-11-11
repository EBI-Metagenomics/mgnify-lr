cwlVersion: v1.1
class: CommandLineTool
label: Hybrid assembly of Nanopore and Illumina reads with SPAdes.
doc: |
      Implementation of hybrid mode assembly using SPAdes assembler.

requirements:
  InlineJavascriptRequirement: {} # needed to get GB in RAM
  ResourceRequirement:
    coresMin: 1
    ramMin: 1000 # 1 GB for testing, it needs more in production
hints:
  DockerRequirement:
    dockerPull: spades:latest

baseCommand: [ spades.py ]

inputs:
  nano:
    type: File
    format: edam:format_1930  # FASTQ
    label: nanopore reads
    inputBinding:
      position: 1
      prefix: --nanopore

  reads1:
    type: File
    format: edam:format_1930  # FASTQ
    label: illumina first pair reads
    inputBinding:
      position: 2
      prefix: "-1"
  
  reads2:
    type: File
    format: edam:format_1930  # FASTQ
    label: illumina second pair reads
    inputBinding:
      position: 3
      prefix: "-2"

arguments:
 - -t
 - $(runtime.cores)
 - -m
 - $(runtime.ram / 1000)
 - --only-assembler
 - --meta
 - -o
 - spades_out
 
outputs:
  contigs_fasta:
    type: File
    outputBinding:
      glob: "spades_out/contigs.fasta"
  
stdout: spades.log
stderr: spades.err

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schemaorg-current-https.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
s:dateCreated: 2020-10-08
