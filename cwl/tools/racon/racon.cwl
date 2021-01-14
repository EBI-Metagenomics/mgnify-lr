cwlVersion: v1.2
class: CommandLineTool
label: Correct raw contigs generated by rapid assembly with Racon.
doc: |
      Implementation of polishing raw contigs generated by rapid assembly with Racon.

requirements:
  ResourceRequirement:
    coresMin: 8
    ramMin: 4000
hints:
  DockerRequirement:
    dockerPull: jcaballero/mgnify-lr.racon:1.4.13

baseCommand: [ "racon" ]

arguments:
 - -t
 - $(runtime.cores) 

inputs:
  inReads:
    type: File
    format: edam:format_1930  # FASTQ
    label: Short reads sequences in Fastq format
    inputBinding:
      position: 1

  mapping:
    type: File
    label: short reads aligments in PAF/MHAP/BAM format
    inputBinding:
      position: 2

  assembly:
    type: File
    format: edam:format_1929  # FASTA
    label: assembly to correct in Fasta format
    inputBinding:
      position: 3
      
  outName:
    type: string
    label: final name for the corrected sequence file
 
outputs:
  outAssembly:
    type: stdout
    format: edam:format_1929
  
stdout: $(inputs.outName)
stderr: racon.err

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schemaorg-current-https.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
s:dateCreated: 2020-10-08
