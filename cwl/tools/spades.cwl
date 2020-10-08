cwlVersion: v1.2
class: CommandLineTool
label: Hybrid assembly of Nanopore and Illumina reads with SPAdes.
doc: |
      Implementation of hybrid mode assembly using SPAdes assembler.

requirements:
  ResourceRequirement:
    coresMin: 4
    ramMin: 8193 # 8 GB for testing, it needs more in production
hints:
  DockerRequirement:
    dockerPull: quay.io/biocontainers/spades:3.14.1--h2d02072_0

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
 - -M
 - $(runtime.ram)
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
 - https://schema.org/version/latest/schema.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"