cwlVersion: v1.2
class: CommandLineTool
label: Hybrid assembly of Nanopore and Illumina reads with SPAdes.
doc: |
      Implementation of hybrid mode assembly using SPAdes assembler.

requirements:
  ResourceRequirement:
    coresMin: 8
    ramMin: 400000
hints:
  DockerRequirement:
    dockerPull: jcaballero/mgnify-lr.spades:3.15.2

baseCommand: [ spades.py ]

arguments:
 - -t
 - $(runtime.cores)
 - --meta
 - -o
 - spades_out

inputs:
  reads1:
    type: File
    format: edam:format_1930  # FASTQ
    label: illumina first pair reads
    inputBinding:
      position: 1
      prefix: "-1"
  reads2:
    type: File
    format: edam:format_1930  # FASTQ
    label: illumina second pair reads
    inputBinding:
      position: 2
      prefix: "-2"
  nano:
    type: File?
    format: edam:format_1930  # FASTQ
    label: nanopore reads
    inputBinding:
      position: 3
      prefix: --nanopore
  pacbio:
    type: File?
    format: edam:format_1930  # FASTQ
    label: pacbio reads
    inputBinding:
      position: 4
      prefix: --pacbio
 
outputs:
  contigs_fasta:
    type: File
    format: edam:format_1929
    outputBinding:
      glob: "spades_out/scaffolds.fasta"
  assembly_graph:
    type: File
    outputBinding:
      glob: "spades_out/assembly_graph.fastg"
  
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
