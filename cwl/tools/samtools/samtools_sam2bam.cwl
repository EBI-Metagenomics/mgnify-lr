cwlVersion: v1.2
class: CommandLineTool
label: Conversion of text read mapping (SAM) to BAM with Samtools.
doc: |
      Implementation of converting NGS text read mapping (SAM) to compressed binary format (BAM) with Samtools.

requirements:
  ResourceRequirement:
    coresMin: 1
    ramMin: 6000 # 6 GB for testing, it needs more in production
hints:
  DockerRequirement:
    dockerPull: jcaballero/mgnify-lr.samtools:1.11

baseCommand: [ "samtools", "view", "-bS" ]

arguments:
 - -@
 - $(runtime.cores)

inputs:
  outputBam:
    type: string
    label: BAM output
    inputBinding:
      position: 1
      prefix: -o

  inputSam:
    type: File
    format: edam:format_2573 # SAM
    label: SAM input to be converted
    inputBinding:
      position: 2
 
outputs:
  outputBam:
    type: File
    outputBinding:
      glob: $(inputs.outputBam.basename)
  
stdout: samtools_sam2bam.log
stderr: samtools_sam2bam.err

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schemaorg-current-https.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
s:dateCreated: 2020-10-08
