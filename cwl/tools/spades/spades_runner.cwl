cwlVersion: v1.2
class: Workflow

requirements:
  InlineJavascriptRequirement: {}
  MultipleInputFeatureRequirement: {}

inputs:
  readType:
    type: string
    label: read type, nanopore or pacbio
  readFile:
    type: File
    format: edam:format_1930
    label: reads fastq file
  reads1:
    type: File
    format: edam:format_1930  # FASTQ
    label: illumina first pair reads
  reads2:
    type: File
    format: edam:format_1930  # FASTQ
    label: illumina second pair reads
  

steps:
  nanopore:
    label: assembly nanopore reads
    run: spades.cwl
    when: $(inputs.tech == "nanopore")
    in:
        tech: readType 
        nano: readFile
        reads1: reads1
        reads2: reads2
    out:
      - contigs_fasta
      - assembly_graph
      - assembly_gfa

  pacbio:
    label: assembly pacbio reads
    run: spades.cwl
    when: $(inputs.tech == "pacbio")
    in:
        tech: readType
        pacbio: readFile
        reads1: reads1
        reads2: reads2
    out:
      - contigs_fasta
      - assembly_graph
      - assembly_gfa

outputs:
    contigs_fasta:
        type: File
        format: edam:format_1929
        outputSource:
            - nanopore/contigs_fasta
            - pacbio/contigs_fasta
        pickValue: first_non_null
    assembly_graph:
        type: File
        outputSource:
            - nanopore/assembly_graph
            - pacbio/assembly_graph
        pickValue: first_non_null
    assembly_gfa:
        type: File
        outputSource:
            - nanopore/assembly_gfa
            - pacbio/assembly_gfa
        pickValue: first_non_null


$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schemaorg-current-https.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
s:dateCreated: 2020-12-10