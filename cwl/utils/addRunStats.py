#!/usr/bin/env python3

# addRunStats.py
# Script to add Toil run stats to an assembly_stats.json
# (C) 2021 EMBL - EBI

import json
import argparse

if __name__ == '__main__':

    parser = argparse.ArgumentParser(description='Script to add Toil run stats to an assembly_stats.json')
    parser.add_argument('-t', '--toil', type=str, help='Toil stats JSON file', required=True)
    parser.add_argument('-a', '--assembly', type=str, help='assembly_stats.json', required=True)
    par = parser.parse_args()

    toil_file = par.toil
    asm_file  = par.assembly

    run_time = 0.00
    peak_mem = 0.00
    def_mem  = 0.00
    
    with open(toil_file, "r") as tf:
        toil_stats = json.load(tf)
        if "total_run_time" in toil_stats:
            run_time = round(float(toil_stats["total_run_time"]), 2)
        if "default_memory" in toil_stats:
            def_mem = round(float(toil_stats["default_memory"]) / 1e9, 2) #value is b, need gb
        if "worker" in toil_stats:
            if "max_memory" in toil_stats["worker"]:
                peak_mem = round(float(toil_stats["worker"]["max_memory"]) / 1e6, 2)  #value is kb, need gb

    with open(asm_file, "r") as af:
        asm_stats = json.load(af)

    if "mem_alloc" in asm_stats and def_mem > 0.1:
        asm_stats["mem_alloc"] = def_mem

    if "peak_mem" in asm_stats and peak_mem > 0.1:
        asm_stats["peak_mem"] = peak_mem
    
    if "exec_time" in asm_stats and run_time > 0.1:
        asm_stats["exec_time"] = run_time

    with open(asm_file, 'w') as outfile:
        json.dump(asm_stats, outfile)

