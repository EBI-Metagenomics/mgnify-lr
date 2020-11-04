cwlVersion: v1.1
class: CommandLineTool
label: decompress
doc: |
      Implementation of decompression for GZip files

requirements:
  InitialWorkDirRequirement:
    listing: [ $(inputs.gzfile) ]
  ResourceRequirement:
    coresMin: 1
    ramMin: 1000
hints:
  DockerRequirement:
    dockerPull: alpine:latest

baseCommand: [ "gunzip", "-c" ]

inputs:
  gzfile:
    type: File
    label: file to be decompressed
    inputBinding:
      position: 1

outputs:
  outfile: stdout

stdout: $(inputs.gzfile.nameroot)
stderr: decompress.err

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schemaorg-current-https.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
s:dateCreated: 2020-10-08