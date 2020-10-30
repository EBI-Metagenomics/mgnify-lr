#!/usr/bin/env python3

# Script to plot query/hit length frequencies
# Juan Caballero <jcaballero@ebi.ac.uk>
# (C) 2020 EMBL-EBI

import sys
import matplotlib as mpl
import matplotlib.pyplot as plt

tsv_file = sys.argv[1]
fig_file = sys.argv[2] 
num_bins = 20
pseudo = 0
data = []

with open(tsv_file, "r") as th:
    for line in th:
        ln = line.rstrip().split("\t")
        ratio = int(ln[0]) / int(ln[1])
        if ratio > 1.3:
            continue
        data.append(ratio)
        if ratio < 0.9:
            pseudo += 1

mpl.style.use("seaborn")
fig, ax = plt.subplots()
# the histogram of the data
ax.hist(data, num_bins)
ax.set_xlabel('query length / hit length')
ax.set_ylabel('frequency')
ax.set_title('Encountered genes < 0.9 ref length: {}'.format(pseudo))
ax.set_xlim(0, 1.3)
ax.grid()
# Tweak spacing to prevent clipping of ylabel
fig.tight_layout()
fig.savefig(fig_file)