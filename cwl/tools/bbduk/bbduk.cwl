cwlVersion: v1.1
class: CommandLineTool
label: Decontamination with BBduk.
doc: |
      Implementation of short read decontamination BBduk.

requirements:
  InlineJavascriptRequirement: {} # needed to get GB in RAM
  ResourceRequirement:
    coresMin: 1
    ramMin: 6000 # 6 GB for testing, it needs more in production
hints:
  DockerRequirement:
    dockerPull: bbtools:latest

# bbduk.sh -Xmx\${MEM}g ref=${db} threads=${task.cpus} ordered=t k=31 in=${name}.R1.id.fastq in2=${name}.R2.id.fastq out=${name}.clean.R1.id.fastq out2=${name}.clean.R2.id.fastq outm=${name}.contamination.R1.id.fastq outm2=${name}.contamination.R2.id.fastq
baseCommand: [ "bbduk.sh" ]

arguments:
 - Xmx$(runtime.ram / 1000)g
 - threads=$(runtime.cores) 
 - ordered=t
 - k=31

inputs:
  reference:
    type: File
    label: Genome index files
    format: edam:format_1929  # FASTA
    inputBinding:
      position: 1
      separate: false
      prefix: ref=

  reads1:
    type: File
    format: edam:format_1930  # FASTQ
    label: short reads in fastq format, first or single pair
    inputBinding:
      position: 2
      separate: false
      prefix: in=

  reads2:
    type: File?
    format: edam:format_1930  # FASTQ
    label: short reads in fastq format, second pair (optional)
    inputBinding:
      position: 3
      separate: false
      prefix: in2=
      
  outfilt:
    type: string
    label: outfile name for the filtered reads, first or single pair
    inputBinding:
      position: 4
      separate: false
      prefix: out=

  outfilt2:
    type: string?
    label: outfile name for the filtered reads, second pair (optional)
    inputBinding:
      position: 5
      separate: false
      prefix: out2=
  outcont:
    type: string
    label: outfile name for the contaminant reads, first or single pair
    inputBinding:
      position: 6
      separate: false
      prefix: outm=
  outcont2:
    type: string?
    label: outfile name for the contaminant reads, second pair (optional)
    inputBinding:
      position: 7
      separate: false
      prefix: outm2=

outputs:
  outfilt:
    type: File
    outputBinding:
      glob: $(inputs.outfilt.basename)

  outfilt2:
    type: File
    outputBinding:
      glob: $(inputs.outfilt2.basename)

  outcont:
    type: File
    outputBinding:
      glob: $(inputs.outcont.basename)

  outcont2:
    type: File
    outputBinding:
      glob: $(inputs.outcont2.basename)

stdout: bbduk.log
stderr: bbduk.err

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schemaorg-current-https.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
s:dateCreated: 2020-10-08
