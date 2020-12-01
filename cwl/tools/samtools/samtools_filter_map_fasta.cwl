cwlVersion: v1.1
class: CommandLineTool
label: Filter read maped (SAM) with Samtools.
doc: |
      Implementation of extraction of NGS read maped with Samtools.

requirements:
  ResourceRequirement:
    coresMin: 8
    ramMin: 2000 # 2 GB for testing, it needs more in production
hints:
  DockerRequirement:
    dockerPull: jcaballero/mgnify-lr.samtools:1.11

baseCommand: [ "samtools", "fasta" ]

arguments:
 - -@
 - $(runtime.cores)
 - -F
 - "4"

inputs:
  outFastaName:
    type: string
    label: mapped sequences fasta
    inputBinding:
      position: 1
      prefix: "-0"
  inSam:
    type: File
    format: edam:format_2573 # SAM
    label: SAM input to be filtered
    inputBinding:
      position: 2
 
outputs:
  outFasta:
    type: File
    format: edam:format_1929
    outputBinding:
      glob: $(inputs.outFastaName)
  
stdout: samtools_filter_map_fasta.log
stderr: samtools_filter_map_fasta.err

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schemaorg-current-https.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
s:dateCreated: 2020-10-08
