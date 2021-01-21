#!/usr/bin/env python3

# Batch of tests for mgnigy-lr-cwl pipeline
# (C) 2020 EMBL - European Bioinformatics Insitute

import json
import os.path
import unittest
import subprocess
import hashlib

md5_json    = 'files_md5.json'
cwl_runner  = 'toil-cwl-runner'
files_md5   = None

# Subroutines
def md5(fname):
    hash_md5 = hashlib.md5()
    with open(fname, "rb") as f:
        for chunk in iter(lambda: f.read(4096), b""):
            hash_md5.update(chunk)
    return hash_md5.hexdigest()

# Test Batch
class TestFastp(unittest.TestCase):
    def test_fastp(self):
        print("Checking fastp")
        cwl = "../tools/fastp/fastp_filter.cwl"
        yml = "./tools/fastp/fastp_filter.yml"
        subprocess.check_call([cwl_runner, cwl, yml])
        for file in files_md5["fastp"].keys():
            # HTML/JSON files are dynamic, we only check if exists and aren't empty
            if file.endswith("fastq.gz"):
                check = files_md5["fastp"][file]
                self.assertEqual(md5(file), check)
            else:
                self.assertTrue(os.path.getsize(file) > 100)

class TestMinimap2filterHostFq(unittest.TestCase):
    def test_minimap2_filterHostFq(self):
        print("Checking minimap2_filterHostFq")
        cwl = "../tools/minimap2_filter/minimap2_filterHostFq.cwl"
        yml = "./tools/minimap2/minimap2_filterHostFq.yml"
        subprocess.check_call([cwl_runner, cwl, yml])
        for file in files_md5["minimap2_filterHostFq"].keys():
            check = files_md5["minimap2_filterHostFq"][file]
            self.assertEqual(md5(file), check)

class TestFlye(unittest.TestCase):
    def test_flye_nano(self):
        print("Checking flye with nanopore")
        cwl = "../tools/flye/flye.cwl"
        yml = "./tools/flye/flye_nano.yml"
        subprocess.check_call([cwl_runner, cwl, yml])
        for file in files_md5["flye_nano"].keys():
            self.assertTrue(os.path.getsize(file) > 100)
    def test_flye_pacbio(self):
        print("Checking flye with pacbio")
        cwl = "../tools/flye/flye.cwl"
        yml = "./tools/flye/flye_pacbio.yml"
        subprocess.check_call([cwl_runner, cwl, yml])
        for file in files_md5["flye_pacbio"].keys():
            self.assertTrue(os.path.getsize(file) > 100)

class TestMinimap2ToPolish(unittest.TestCase):
    def test_minimap2_to_polish(self):
        print("Checking minimap2_to_polish")
        cwl = "../tools/minimap2/minimap2_to_polish.cwl"
        yml = "./tools/minimap2/minimap2_to_polish.yml"
        subprocess.check_call([cwl_runner, cwl, yml])
        for file in files_md5["minimap2_to_polish"].keys():
            check = files_md5["minimap2_to_polish"][file]
            self.assertEqual(md5(file), check)

class TestRacon(unittest.TestCase):
    def test_racon(self):
        print("Checking racon")
        cwl = "../tools/racon/racon.cwl"
        yml = "./tools/racon/racon.yml"
        subprocess.check_call([cwl_runner, cwl, yml])
        for file in files_md5["racon"].keys():
            check = files_md5["racon"][file]
            self.assertEqual(md5(file), check)

class TestMedaka(unittest.TestCase):
    def test_medaka(self):
        print("Checking medaka")
        cwl = "../tools/medaka/medaka.cwl"
        yml = "./tools/medaka/medaka.yml"
        subprocess.check_call([cwl_runner, cwl, yml])
        for file in files_md5["medaka"].keys():
            check = files_md5["medaka"][file]
            self.assertEqual(md5(file), check)

class TestMinimap2filterHostFa(unittest.TestCase):
    def test_minimap2_filterHostFa(self):
        print("Checking minimap2_filterHostFa")
        cwl = "../tools/minimap2_filter/minimap2_filterHostFa.cwl"
        yml = "./tools/minimap2/minimap2_filterHostFa.yml"
        subprocess.check_call([cwl_runner, cwl, yml])
        for file in files_md5["minimap2_filterHostFa"].keys():
            check = files_md5["minimap2_filterHostFa"][file]
            self.assertEqual(md5(file), check)

class TestProdigal(unittest.TestCase):
    def test_prodigal(self):
        print("Checking prodigal")
        cwl = "../tools/prodigal/prodigal.cwl"
        yml = "./tools/prodigal/prodigal.yml"
        subprocess.check_call([cwl_runner, cwl, yml])
        for file in files_md5["prodigal"].keys():
            check = files_md5["prodigal"][file]
            self.assertEqual(md5(file), check)

class TestDiamond(unittest.TestCase):
    def test_diamond(self):
        print("Checking diamond")
        cwl = "../tools/diamond/diamond.cwl"
        yml = "./tools/diamond/diamond.yml"
        subprocess.check_call([cwl_runner, cwl, yml])
        for file in files_md5["diamond"].keys():
            check = files_md5["diamond"][file]
            self.assertEqual(md5(file), check)

class TestIdeel(unittest.TestCase):
    def test_ideel(self):
        print("Checking ideel")
        cwl = "../tools/ideel/ideelPy.cwl"
        yml = "./tools/ideel/ideel.yml"
        subprocess.check_call([cwl_runner, cwl, yml])
        # PDF is dynamic, size checking only
        for file in files_md5["ideel"].keys():
            self.assertTrue(os.path.getsize(file) > 100)

class TestBWAmem2(unittest.TestCase):
    def test_bwamem2(self):
        print("Checking BWA-mem2")
        cwl = "../tools/bwa/bwa-mem2.cwl"
        yml = "./tools/bwa/bwa-mem2.yml"
        subprocess.check_call([cwl_runner, cwl, yml])
        for file in files_md5["bwa-mem2"].keys():
            self.assertTrue(os.path.getsize(file) > 100)

class TestPilon(unittest.TestCase):
    def test_pilon(self):
        print("Checking pilon")
        cwl = "../tools/pilon/pilon.cwl"
        yml = "./tools/pilon/pilon.yml"
        subprocess.check_call([cwl_runner, cwl, yml])
        for file in files_md5["pilon"].keys():
            check = files_md5["pilon"][file]
            self.assertEqual(md5(file), check)

class TestPilon(unittest.TestCase):
    def test_pilon(self):
        print("Checking pilon")
        cwl = "../tools/pilon/pilon.cwl"
        yml = "./tools/pilon/pilon.yml"
        subprocess.check_call([cwl_runner, cwl, yml])
        for file in files_md5["pilon"].keys():
            check = files_md5["pilon"][file]
            self.assertEqual(md5(file), check)

class TestFilterContigs(unittest.TestCase):
    def test_filterContigs(self):
        print("Checking filterContigs")
        cwl = "../tools/filterContigs/filterContigs.cwl"
        yml = "./tools/filterContigs/filterContigs.yml"
        subprocess.check_call([cwl_runner, cwl, yml])
        for file in files_md5["filterContigs"].keys():
            check = files_md5["filterContigs"][file]
            self.assertEqual(md5(file), check)

class TestAssemblyStats(unittest.TestCase):
    def test_assemblyStats_fastq(self):
        print("Checking assemblyStats (fastq)")
        cwl = "../tools/assembly_stats/assemblyStatsFastq.cwl"
        yml = "./tools/assembly_stats/assemblyStatsFastq.yml"
        subprocess.check_call([cwl_runner, cwl, yml])
        for file in files_md5["assemblyStatsFastq"].keys():
            check = files_md5["assemblyStatsFastq"][file]
            self.assertEqual(md5(file), check)
    def test_assemblyStats_fasta(self):
        print("Checking assemblyStats (fasta)")
        cwl = "../tools/assembly_stats/assemblyStatsFasta.cwl"
        yml = "./tools/assembly_stats/assemblyStatsFasta.yml"
        subprocess.check_call([cwl_runner, cwl, yml])
        for file in files_md5["assemblyStatsFasta"].keys():
            check = files_md5["assemblyStatsFasta"][file]
            self.assertEqual(md5(file), check)
    def test_assemblyStats_cov(self):
        print("Checking assemblyStats (coverage)")
        cwl = "../tools/assembly_stats/assemblyStats.cwl"
        yml = "./tools/assembly_stats/assemblyStats.yml"
        subprocess.check_call([cwl_runner, cwl, yml])
        for file in files_md5["assemblyStats"].keys():
            check = files_md5["assemblyStats"][file]
            self.assertEqual(md5(file), check)

if __name__ == "__main__":
    print("loading test files")
    with open(md5_json, "r") as jh:
        files_md5 = json.load(jh)

    print("running tests")
    unittest.main()
