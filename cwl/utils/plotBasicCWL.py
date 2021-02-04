#!/usr/bin/env python3

# plotBasicCWL.py
# Script to create a plot (directed graph) from a CWL workflow.
# Output is a Graphviz digraph file.
# (C) 2021 EMBL - EBI

import os
import yaml
import argparse
import subprocess

gout = None
# formating, todo: read from a config file
tool_format   = 'shape=box, style=filled, color=lightblue'
wf_format     = 'shape=box, style=filled, color=lightgrey'
other_format  = 'shape=ellipse, color=grey'

def loadCWL(cwl_file):
    print("loading {}".format(cwl_file))
    with open(cwl_file, "r") as yfile:
        cwl = yaml.load(yfile, Loader=yaml.FullLoader)
    return cwl

def getWf(cwl_file, parent):
    global gout
    global step_list
    cwl = loadCWL(cwl_file)
    if "steps" in cwl:
        for step in cwl["steps"]:
            step_cwl       = cwl["steps"][step]["run"]
            step_path      = step_cwl.split("/")
            step_cwl_name  = step_path[-1].replace(".cwl", "")
            step_cwl_id    = step_cwl_name.replace("-", "_")
            def_format     = checkSubWf(step_cwl, cwl_file)
            gout.write("    {} [{}, label=<{}>];\n".format(step_cwl_id, def_format, step_cwl_name))

def checkSubWf(sub_cwl_file, sub_cwl_parent):
    global gout
    global wf_format
    global tool_format
    parent_path = sub_cwl_parent.split("/")
    parent_name = parent_path[-1].replace(".cwl", "").replace("-", "_")
    parent_path[-1] = sub_cwl_file
    fix_cwl_file = "/".join(parent_path)
    cwl_path = fix_cwl_file.split("/")
    cwl_name = cwl_path[-1].replace(".cwl", "").replace("-", "_")
    sub_cwl = loadCWL(fix_cwl_file)
    if "class" in sub_cwl:
        if sub_cwl["class"] == "Workflow":
            gout.write("    {} -> {};\n".format(parent_name, cwl_name))
            getWf(sub_cwl_file, sub_cwl_parent)
            return wf_format
        else:
            gout.write("    {} -> {};\n".format(parent_name, cwl_name))
            return tool_format

def createPlot(graph, gformat, out):
    cmd = [ "dot", "-T{}".format(gformat), "-o{}".format(out), graph ]
    print(cmd)
    subprocess.run(cmd)

if __name__ == '__main__':

    parser = argparse.ArgumentParser(description='Generate a plot for the components in a CWL workflow')
    parser.add_argument('-c', '--cwl', type=str, help='CWL input file', required=True)
    parser.add_argument('-o', '--out', type=str, help='Output figure, file extension defines format [png, jpg, svg]', default='cwl_workflow.jpg')
    parser.add_argument('-g', '--graph', type=str, help='Output graph file (Graphviz)', default='cwl_workflow.gv')
    par = parser.parse_args()

    cwl     = par.cwl
    graph   = par.graph
    out     = par.out
    gformat = None

    if out.endswith("jpg"):
        gformat = "jpg"
    elif out.endswith("png"):
        gformat = "png"
    elif out.endswith("svg"):
        gformat = "svg"
    else:
        ext = out.split(".")
        gformat = ext[-1]

    gout = open(graph, "w")
    if not cwl.startswith("/"):
        cdir = os.getcwd()
        cwl  = "{}/{}".format(cdir, cwl)
    cwl_path = cwl.split("/")
    cwl_name = cwl_path[-1].replace(".cwl", "")
    gout.write("digraph CWL_Workflow {\n")
    gout.write("  subgraph workflow {\n")
    gout.write("    {} [{}];\n".format(cwl_name, wf_format))
    getWf(cwl, cwl_name)
    gout.write("  }\n")
    gout.write("\n")
    
    # workflow information and legend
    cwl_data = loadCWL(cwl)
    wf_legend = "<B>{}</B>".format(cwl_data["label"])
    if "cwlVersion" in cwl_data:
        wf_legend = wf_legend + "<BR/>CWL version: {}".format(cwl_data["cwlVersion"])
    if "doc" in cwl_data:
        wf_legend = wf_legend + "<BR/><I>{}</I>".format(cwl_data["doc"])

    gout.write("  subgraph legend {\n")
    gout.write("    graph [bgcolor=lightgrey, center=1];\n")
    gout.write("    rank = sink;\n")
    gout.write("    Workflow [{}]\n".format(wf_format))
    gout.write("    Tool [{}]\n".format(tool_format))
    gout.write("    legend_text [shape=box, label=<{}>];\n".format(wf_legend))
    gout.write("  }\n")
    gout.write("}\n")

    gout.close()

    createPlot(graph, gformat, out)