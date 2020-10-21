#!/usr/bin/env python3

# getFastaFromEnsemblFTP.py <species_name>
#
# Script to query Ensembl FTP server to get the
# current reference genome for species (homo_sapiens,
# mus_musculus, ...)
#
# (C) 2020 EMBL - European Bioinformatics Institute

import sys
from ftplib import FTP

ftphost = 'ftp.ensembl.org'
species =sys.argv[1]

ftp = FTP(ftphost)
ftp.login()

try:
    ftp.cwd("pub/current_fasta/{}/dna_index".format(species))
except:
    print("failed too obtain files in ftp://{}/pub/current_fasta/{}/dna_index/".format(ftphost, species))
    exit(1)
    
content = ftp.nlst()
for file in content:
    if file.endswith("toplevel.fa.gz"):
        print("ftp://{}/pub/current_fasta/{}/dna_index/{}".format(ftphost, species, file))
ftp.quit()