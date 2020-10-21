#!/usr/bin/env python3

# Batch of tests for mgnigy-lr-cwl
# 
# (C) 2020 EMBL - European Bioinformatics Insitute

import os.path
import unittest
import subprocess

class TestGetHostFasta(unittest.TestCase):

    def test_getCionaGenome(self):
        """Check if we can retrieve the genome for ciona_intestinalis from Ensembl FTP"""
        cwl = "../tools/getHostFasta/getHostFasta.cwl"
        yml = "./tools/getHostFasta/ciona.yml"
        out = "Ciona_intestinalis.KH.dna.toplevel.fa.gz"
        subprocess.check_call(["toil-cwl-runner", cwl, yml])
        self.assertTrue(os.path.getsize(out) > 10000)
    

if __name__ == "__main__":
    unittest.main()