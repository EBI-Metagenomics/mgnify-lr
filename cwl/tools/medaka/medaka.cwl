cwlVersion: v1.2
class: CommandLineTool
label: Correct assembled contigs with Medaka.
doc: |
      Implementation of polishing assembled contigs with Medaka.

requirements:
  InitialWorkDirRequirement:
    listing: [ $(inputs.assembly) ]
  ResourceRequirement:
    coresMin: 32
    ramMin: 8000
hints:
  DockerRequirement:
    dockerPull: microbiomeinformatics/mgnify-lr.medaka:1.2.3

baseCommand: [ "medaka_consensus" ]

arguments:
 - -t
 - $(runtime.cores) 
 - -o
 - medaka_polish

inputs:
  inReads:
    type: File
    format: edam:format_1930  # FASTQ
    label: Short reads sequences in Fastq format
    inputBinding:
      position: 1
      prefix: -i

  assembly:
    type: File
    format: edam:format_1929  # FASTA
    label: assembly to correct in Fasta format
    inputBinding:
      position: 2
      prefix: -d
      
  medakaModel:
    type: string
    label: medaka model to apply
    inputBinding:
      position: 3
      prefix: -m

outputs:
  outConsensus:
    type: File
    format: edam:format_1929
    outputBinding:
      glob: medaka_polish/consensus.fasta
  
stdout: medaka.log
stderr: medaka.err

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schemaorg-current-https.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
s:dateCreated: 2020-10-08
