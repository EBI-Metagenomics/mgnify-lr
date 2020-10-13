cwlVersion: v1.2
class: CommandLineTool

label: Plotting tool for long read sequencing data and alignments.
doc: |
      Implementation to plot Fastq files, PNG and PDF plots are generated.

requirements:
  ResourceRequirement:
    coresMin: 1
    ramMin: 1024  # just a default, could be lowered
hints:
  DockerRequirement:
    dockerPull: quay.io/biocontainers/nanoplot:1.32.1--py_0

baseCommand: [ NanoPlot ]

inputs:
  name:
    type: string
    label: prefix for files
    inputBinding:
      position: 1
      prefix: --title

  reads:
    type: File
    format: edam:format_1930  # FASTQ
    label: nanopore reads
    inputBinding:
      position: 2
      prefix: --fastq
  
  pformat:
    type: string
    label: plot format (png, pdf)
    inputBinding:
      position: 3
      prefix: -f

  pcolor:
    type: string
    label: plot color
    inputBinding:
      position: 4
      prefix: --color

  ptype:
    type: string
    label: plot type
    inputBinding:
      position: 5
      prefix: --plots

arguments:
 - --N50
 - --loglength
 - -t
 - $(runtime.cores)
 - -p
 - $(inputs.name)_

outputs:
  html:
    type: 
      type: array
      items: File
    outputBinding:
      glob: "*.html"
  stats:
    type: File
    outputBinding:
      glob: "*NanoStats.txt"
  pngs:
    type:
      type: array
      items: File
    outputBinding:
      glob: "*.png"
  pdfs:
    type:
      type: array
      items: File
    outputBinding:
      glob: "*.pdf"

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
