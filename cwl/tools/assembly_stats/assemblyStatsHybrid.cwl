cwlVersion: v1.2
class: CommandLineTool
label: AssemblyStats from a Contig hybrid assembly.
doc: |
      Implementation of computing statistics (N50 and others) for a hybrid assembly file.

requirements:
  InitialWorkDirRequirement:
    listing: [ $(inputs.contigs) ]
  ResourceRequirement:
    coresMin: 1
    ramMin: 8000
hints:
  DockerRequirement:
    dockerPull: jcaballero/mgnify-lr.assemblystats:0.0.5

baseCommand: [ "gen_stats_json.pl" ]

arguments:
  - -n
  - $(runtime.cores)
  - -a
  - metaSPAdes
  - -v
  - 3.15.2
  - -m
  - "100"

inputs:
  contigs:
    type: File
    format: edam:format_1929
    label: contigs in Fasta to analyze
    inputBinding:
      position: 1
      prefix: -c
  reads:
    type: File
    format: edam:format_1930
    label: original raw data in Fastq
    inputBinding:
      position: 2
      prefix: -r
  p1_reads:
    type: File
    format: edam:format_1930
    label: original raw short-reads (first pair) in Fastq
    inputBinding:
      position: 3
      prefix: "-1"
  p2_reads:
    type: File
    format: edam:format_1930
    label: original raw short-reads (second pair) in Fastq
    inputBinding:
      position: 4
      prefix: "-2"
  alignMode:
    type: string
    label: align mode for minimap2 mapping
    inputBinding:
      position: 5
      prefix: -t
 
outputs:
  outAssemblyStats:
    type: File
    outputBinding:
      glob: "assembly_stats.json"
  
stdout: assemblyStats.log
stderr: assemblyStats.err

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schemaorg-current-https.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
s:dateCreated: 2020-10-08
