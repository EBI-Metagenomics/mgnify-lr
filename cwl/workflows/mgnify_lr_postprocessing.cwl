cwlVersion: v1.2
class: Workflow
label: Postprocessing for long-read assembly
doc: |
      Implementation of post-processing analysis and QC for long-reads assembly pipeline in MGnify

requirements:
  ResourceRequirement:
    coresMin: 8
    ramMin: 8000

inputs:
  assembly_input:
    type: File
    format: edam:format_1929
    label: Fasta assembly to process
  min_contig_size:
    type: int?
    label: contigs filtered by size
    default: 500
  format_assembly:
    type: string?
    label: formatted assembly file (fasta)
    default: assembly_format.fasta
  final_assembly:
    type: string?
    label: final assembly file (fasta)
    default: assembly_final.fasta
  final_assembly_stats:
    type: string?
    label: final assembly stats
    default: assembly_final_stats.txt
  predict_proteins:
    type: string?
    label: predicted proteins from assembly (fasta)
    default: predicted_proteins.fasta
  uniprot_index:
    type: File
    label: uniprot index file
  diamond_out:
    type: string?
    label: proteins align to Uniprot
    default: predict_proteins_diamond.tsv
  ideel_out:
    type: string?
    label: protein completeness evaluation
    default: ideel_report.pdf

outputs:
  final_assembly_fasta:
    type: File
    format: edam:format_1929
    outputSource: step_2_filterContigs/outFasta
  final_assembly_report:
    type: File
    outputSource: step_3_assemblyStats/outReport
  predict_proteins_fasta:
    type: File
    format: edam:format_1929
    outputSource: step_4_prodigal/outProt
  diamond_align_table:
    type: File
    outputSource: step_5_diamond/alignment
  ideel_pdf:
    type: File
    outputSource: step_6_ideel/outFig

steps:

  step_1_formatFasta:
    label: formating fasta input
    run: ../tools/format_fasta/formatFasta.cwl
    in:
      inFile: assembly_input
      outFile: format_assembly
    out: [ outFasta ]

  step_2_filterContigs:
    label: remove short contigs
    run: ../tools/filterContigs/filterContigs.cwl
    in:
      minSize: min_contig_size
      inFasta: step_1_formatFasta/outFasta
      outName: final_assembly
    out: [ outFasta ]

  step_3_assemblyStats:
    label: final assembly stats report
    run: ../tools/assembly_stats/assemblyStatsFasta.cwl
    in:
      inFile: step_2_filterContigs/outFasta
      outReport: final_assembly_stats
    out: [ outReport ]

  step_4_prodigal:
    label: predict proteins in assembly with Prodigal
    run: ../tools/prodigal/prodigal.cwl
    in:
      inNucl: step_2_filterContigs/outFasta
      outProtName: predict_proteins
    out: [ outProt ]

  step_5_diamond:
    label: search Uniprot database with diamond
    run: ../tools/diamond/diamond.cwl
    in:
      outName: diamond_out
      proteins: step_4_prodigal/outProt
      database: uniprot_index
    out: [ alignment ]

  step_6_ideel:
    label: ideel report for protein completeness
    run: ../tools/ideel/ideelPy.cwl
    in:
      inputTable: step_5_diamond/alignment
      outFigName: ideel_out
    out: [ outFig ]

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schemaorg-current-https.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
s:dateCreated: 2020-10-08