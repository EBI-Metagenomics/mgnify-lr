#!/usr/bin/env python3

# plotCWL.py WORKFLOW.cwl > GRAPH.gv
# Script to create a plot (directed graph) from a CWL workflow.
# Output is a Graphviz digraph file (printed in STDOUT).
# (C) 2020 EMBL - EBI

import sys
import yaml

if len(sys.argv) < 2:
    print("usage: plotCWL.py WORKFLOW.cwl > GRAPH.gv")
    exit(1)

cwl_file = sys.argv[1]

with open(cwl_file, "r") as yfile:
    cwl = yaml.load(yfile, Loader=yaml.FullLoader)

outputs = []

input_format = 'shape=ellipse, style=filled, color=lightblue'
output_format = 'shape=ellipse, style=filled, color=red'
step_format = 'shape=box, style=filled, color=grey'
other_format = 'shape=ellipse, color=grey'

print("digraph G {")
print("  subgraph main {")
if "inputs" in cwl:
    for wf_in in cwl["inputs"]:
        label = "<B>{}</B>".format(wf_in)
        if "type" in cwl["inputs"][wf_in]:
            label = label + "<BR/>Type: {}".format(cwl["inputs"][wf_in]["type"])
        if "format" in cwl["inputs"][wf_in]:
            label = label + "<BR/>Format: {}".format(cwl["inputs"][wf_in]["format"])
        if "default" in cwl["inputs"][wf_in]:
            label = label + "<BR/>Default: {}".format(cwl["inputs"][wf_in]["default"])
        if "label" in cwl["inputs"][wf_in]:
            label = label + "<BR/><I>{}</I>".format(cwl["inputs"][wf_in]["label"])                           
        print("  {} [{}, label=<{}>];".format(wf_in, input_format, label))

if "outputs" in cwl:
    for wf_out in cwl["outputs"]:
        out = cwl["outputs"][wf_out]["outputSource"].replace("/", "__")
        label = "<B>{}</B><BR/>{}".format(wf_out, cwl["outputs"][wf_out]["outputSource"])
        print("  {} [{}, label=<{}>];".format(out, output_format, label))
        outputs.append(out)

if "steps" in cwl:
    for step in cwl["steps"]:
        label = "<B>{}</B>".format(step)
        if "run" in cwl["steps"][step]:
            label = label + "<BR/>Run: {}".format(cwl["steps"][step]["run"])
        if "label" in cwl["steps"][step]:
            label = label + "<BR/><I>{}</I>".format(cwl["steps"][step]["label"])       
        print("  {} [{}, label=<{}>];".format(step, step_format, label))
        if "in" in cwl["steps"][step]:
            for step_in in cwl["steps"][step]["in"]:
                print("  {} -> {};".format(cwl["steps"][step]["in"][step_in].replace("/", "__"), step))
        if "out" in cwl["steps"][step]:
            for step_out in cwl["steps"][step]["out"]:
                full_step_out = "{}__{}".format(step, step_out) 
                if full_step_out in outputs:
                    print("  {} -> {};".format(step, full_step_out))
                else:
                    label = "<B>{}/{}</B>".format(step, step_out) 
                    print("  {} [{}, label=<{}>];".format(full_step_out, other_format, label))
                    print("  {} -> {};".format(step, full_step_out))
print("  }")

# workflow information and legend
wf_legend = "<B>{}</B>".format(cwl["label"])
if "cwlVersion" in cwl:
    wf_legend = wf_legend + "<BR/>CWL version: {}".format(cwl["cwlVersion"])
if "doc" in cwl:
    wf_legend = wf_legend + "<BR/><I>{}</I>".format(cwl["doc"])

print("  subgraph legend {")
print("    graph [bgcolor=lightgrey, center=1];")
print("    rank = sink;")
print("    INPUT [{}]".format(input_format))
print("    OUTPUT [{}]".format(output_format))
print("    STEP [{}]".format(step_format))
print("    legend_text [shape=box, label=<{}>];".format(wf_legend))
print("  }")

print("}")