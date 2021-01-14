cwlVersion: v1.2
class: CommandLineTool

label: Plotting tool for long read sequencing data and alignments.
doc: |
      Implementation to plot Fastq files, PNG and PDF plots are generated.

requirements:
  ResourceRequirement:
    coresMin: 8
    ramMin: 2000
hints:
  DockerRequirement:
    dockerPull: jcaballero/mgnify-lr.nanoplot:1.33.1

baseCommand: [ NanoPlot ]

arguments:
 - --N50
 - --loglength
 - -t
 - $(runtime.cores)
 - -p
 - $(inputs.name)_

inputs:
  reads:
    type: File
    format: edam:format_1930  # FASTQ
    label: nanopore reads
    inputBinding:
      position: 1
      prefix: --fastq

  name:
    type: string?
    label: prefix for files
    inputBinding:
      position: 2
      prefix: --title
    default: nanoplot
  
  pformat:
    type: string?
    label: plot format (png, pdf)
    inputBinding:
      position: 3
      prefix: -f
    default: png

  pcolor:
    type: string?
    label: plot color
    inputBinding:
      position: 4
      prefix: --color
    default: darkslategrey

  ptype:
    type: string?
    label: plot type
    inputBinding:
      position: 5
      prefix: --plots
    default: hex

outputs:
  html:
    type: File[]
    outputBinding:
      glob: $(inputs.name)*.html
  stats:
    type: File[]
    outputBinding:
      glob: "$(inputs.name)*NanoStats.txt"
  pngs:
    type: File[]
    outputBinding:
      glob: "$(inputs.name)*.png"
  pdfs:
    type: File[]
    outputBinding:
      glob: "$(inputs.name)*.pdf"

stdout: nanoplot.log
stderr: nanoplot.err

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schema.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
s:version: 0.0.1
s:dateCreated: 2020-10-07
