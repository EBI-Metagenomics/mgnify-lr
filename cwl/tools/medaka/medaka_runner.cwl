cwlVersion: v1.2
class: Workflow

requirements:
  InlineJavascriptRequirement: {}
  MultipleInputFeatureRequirement: {}

inputs:
  tech:
    type: string
    label: read type, nanopore or pacbio
  
  inReads:
    type: File
    format: edam:format_1930  # FASTQ
    label: Short reads sequences in Fastq format

  assembly:
    type: File
    format: edam:format_1929  # FASTA
    label: assembly to correct in Fasta format
    
  medakaModel:
    type: string
    label: medaka model to apply

  pacbioOut:
    type: string?
    label: if no polishing is done, default outfile name
    default: "consensus.fasta"

steps:
  nanopore:
    label: medaka polish for nanopore
    run: medaka.cwl
    when: $(inputs.tech == "nanopore")
    in:
      tech: tech
      inReads: inReads 
      assembly: assembly
      medakaModel: medakaModel
    out: [ outConsensus ]

  pacbio:
    label: skip medaka for pacbio
    run: no_medaka.cwl
    when: $(inputs.tech == "pacbio")
    in:
      tech: tech
      assembly: assembly
      outName: pacbioOut
    out: [ outConsensus ]

outputs:
    outConsensus:
        type: File
        format: edam:format_1929
        outputSource:
            - nanopore/outConsensus
            - pacbio/outConsensus
        pickValue: first_non_null


$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schemaorg-current-https.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
s:dateCreated: 2020-02-24