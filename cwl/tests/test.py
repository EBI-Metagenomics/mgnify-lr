#!/usr/bin/env python3

# Batch of tests for mgnigy-lr-cwl
# 
# (C) 2020 EMBL - European Bioinformatics Insitute

import json
import os.path
import unittest
import subprocess
import hashlib

md5_json   = "files_md5.json"
cwl_runner = 'toil-cwl-runner'
files_md5  = None

def md5(fname):
    hash_md5 = hashlib.md5()
    with open(fname, "rb") as f:
        for chunk in iter(lambda: f.read(4096), b""):
            hash_md5.update(chunk)
    return hash_md5.hexdigest()


class TestGetHostFasta(unittest.TestCase):

    def test_getCionaGenome(self):
        print("Checking getHostFasta: retrieve ciona_intestinalis genome from Ensembl FTP")
        cwl = "../tools/getHostFasta/getHostFasta.cwl"
        yml = "./tools/getHostFasta/ciona.yml"
        out = "Ciona_intestinalis.KH.dna.toplevel.fa.gz"
        # file is not an unique url, could change overtime, we only check if exists and isn't empty
        subprocess.check_call([cwl_runner, cwl, yml])
        self.assertTrue(os.path.getsize(out) > 30000)

    def test_getYeastGenome(self):
        print("Checking getHostFasta: retrieve Saccharomyces genome from UCSC Genome Browser")
        cwl = "../tools/getHostFasta/getHostFasta.cwl"
        yml = "./tools/getHostFasta/yeast.yml"
        out = "sacCer3.fa.gz"
        chk = files_md5["getHostFasta"][out]
        subprocess.check_call([cwl_runner, cwl, yml])
        self.assertEqual(md5(out), chk)

class TestDecompress(unittest.TestCase):
    def test_decompress(self):
        print("Checking Decompress")
        cwl = "../tools/decompress/decompress.cwl"
        yml = "./tools/decompress/decompress.yml"
        out = "eco_phix_dcs.fa"
        chk = files_md5["decompress"][out]
        subprocess.check_call([cwl_runner, cwl, yml])
        self.assertEqual(md5(out), chk)

class TestBwaIndex(unittest.TestCase):
    def test_bwa_index(self):
        print("Checking bwa_index")
        cwl = "../tools/bwa_index/bwa_index.cwl"
        yml = "./tools/bwa_index/bwa_index.yml"
        out = "eco_phix_dcs.fa"
        subprocess.check_call([cwl_runner, cwl, yml])
        for file in files_md5["bwa_index"].keys():
            check = files_md5["bwa_index"][file]
            self.assertEqual(md5(file), check)

class TestNanoplot(unittest.TestCase):
    def test_nanoplot(self):
        print("Checking Nanoplot")
        cwl = "../tools/nanoplot/nanoplot.cwl"
        yml = "./tools/nanoplot/nanoplot.yml"
        subprocess.check_call([cwl_runner, cwl, yml])
        for file in files_md5["nanoplot"].keys():
            # HTML files are dynamic, we only check if exists and aren't empty
            if file.endswith("html"):
                self.assertTrue(os.path.getsize(file) > 100)
            else:
                check = files_md5["nanoplot"][file]
                self.assertEqual(md5(file), check)

class TestRemoveSmallReads(unittest.TestCase):
    def test_removeSmallReads(self):
        print("Checking removeSmallReads")
        cwl = "../tools/removeSmallReads/removeSmallReads.cwl"
        yml = "./tools/removeSmallReads/removeSmallReads.yml"
        subprocess.check_call([cwl_runner, cwl, yml])
        for file in files_md5["removeSmallReads"].keys():
            check = files_md5["removeSmallReads"][file]
            self.assertEqual(md5(file), check)

class TestFlye(unittest.TestCase):
    def test_flye(self):
        print("Checking flye")
        cwl = "../tools/flye/flye.cwl"
        yml = "./tools/flye/flye.yml"
        subprocess.check_call([cwl_runner, cwl, yml])
        for file in files_md5["flye"].keys():
            check = files_md5["flye"][file]
            self.assertEqual(md5(file), check)

class TestMinimapPolish(unittest.TestCase):
    def test_flye(self):
        print("Checking flye")
        cwl = "../tools/minimap2/minimap2_to_polish.cwl"
        yml = "./tools/minimap2/minimap2_to_polish.yml"
        subprocess.check_call([cwl_runner, cwl, yml])
        for file in files_md5["minimap2_to_polish"].keys():
            check = files_md5["minimap2_to_polish"][file]
            self.assertEqual(md5(file), check)


class TestCleanUp(unittest.TestCase):
    def test_cleanUp():
        for test in files_md5:
            for file in files_md5[test]:
                os.remove(file)
        


if __name__ == "__main__":
    print("loading test files")
    with open(md5_json, "r") as jh:
        files_md5 = json.load(jh)

    print("running tests")
    unittest.main()
