cwlVersion: v1.2
class: CommandLineTool
label: Assembly polishing with Pilon.
doc: |
      Implementation of sequence assembly polishing with pilon.

requirements:
  ResourceRequirement:
    coresMin: 32
    ramMin: 160000 # 150Gb in of a case large assembly
hints:
  DockerRequirement:
    dockerPull: microbiomeinformatics/mgnify-lr.pilon:1.23

baseCommand: [ "java", "-Xmx150G", "-jar", "/opt/pilon.jar" ]

arguments:
 - --threads
 - $(runtime.cores) 

inputs:
  sequences:
    type: File
    label: Genome sequence fasta
    format: edam:format_1929 # fasta
    inputBinding:
      position: 1
      prefix: --genome

  alignment:
    type: File
    format: edam:format_2572  # bam
    secondaryFiles:
      - .bai
    label: short reads aligned in BAM format
    inputBinding:
      position: 2
      prefix: --frags

  outfile:
    type: string
    label: final name for the polished sequence
    inputBinding:
      position: 3
      prefix: --output

 
outputs:
  outfile:
    type: File
    format: edam:format_1929
    outputBinding:
      glob: $(inputs.outfile).fasta
  
stdout: pilon.log
stderr: pilon.err

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schemaorg-current-https.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
s:dateCreated: 2020-10-08
