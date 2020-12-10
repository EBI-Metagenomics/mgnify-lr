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

steps:
  nanopore:
    label: assembly nanopore reads
    run: flye.cwl
    when: $(inputs.tech == "nanopore")
    in:
        tech: readType 
        nano: readFile
    out: [ contigs_fasta ]
  pacbio:
    label: assembly pacbio reads
    run: flye.cwl
    when: $(inputs.tech == "pacbio")
    in:
        tech: readType
        pacbio: readFile
    out: [ contigs_fasta ]

outputs:
    contigs_fasta:
        type: File
        format: edam:format_1929
        outputSource:
            - nanopore/contigs_fasta
            - pacbio/contigs_fasta
        pickValue: first_non_null


$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schemaorg-current-https.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
s:dateCreated: 2020-12-09