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
  predict_proteins_fasta:
    type: File
    format: edam:format_1929
    outputSource: step_1_prodigal/outProt
  diamond_align_table:
    type: File
    outputSource: step_2_diamond/alignment
  ideel_pdf:
    type: File
    outputSource: step_3_ideel/outFig

steps:

  step_1_prodigal:
    label: predict proteins in assembly with Prodigal
    run: ../tools/prodigal/prodigal.cwl
    in:
      inNucl: assembly_input
      outProtName: predict_proteins
    out: [ outProt ]

  step_2_diamond:
    label: search Uniprot database with diamond
    run: ../tools/diamond/diamond.cwl
    in:
      outName: diamond_out
      proteins: step_4_prodigal/outProt
      database: uniprot_index
    out: [ alignment ]

  step_3_ideel:
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