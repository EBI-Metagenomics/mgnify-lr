cwlVersion: v1.2
class: CommandLineTool
label: Index for minimap2.
doc: |
      Implementation of sequence indexing for Minimap2 alignment.

requirements:
  ResourceRequirement:
    coresMin: 8
    ramMin: 2000
hints:
  DockerRequirement:
    dockerPull: microbiomeinformatics/mgnify-lr.minimap2_filter:2.17.4

baseCommand: [ "minimap2" ]

arguments:
 - -t
 - $(runtime.cores)

inputs:
  preset:
    type: string
    label: preset options [ map-pb, map-ont, sr, asm5, ... ]
    inputBinding:
        position: 1
        prefix: -x
  indexName:
    type: string
    label: output index name
    inputBinding:
      position: 1
      prefix: -d
  inFasta:
    type: File
    format: edam:format_1929  # FASTA
    label: sequences to index (fasta)
    inputBinding:
      position: 2

outputs:
  outIndex:
    type: File
    outputBinding:
      glob: $(inputs.indexName)

stdout: minimap2_index.log
stderr: minimap2_index.err

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schemaorg-current-https.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
s:dateCreated: 2020-10-08