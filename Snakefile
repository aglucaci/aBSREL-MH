# Snakefile for aBSREL-MH Analysis
# @Author: Alexander G Lucaci
# @Description:
#

# ---------------------------------------------------------------------
# Imports
# ---------------------------------------------------------------------
import os
import sys
import json
import csv
from pathlib import Path
import glob

# ---------------------------------------------------------------------
# Declares
# ---------------------------------------------------------------------
#with open("cluster.json", "r") as in_c:
#  cluster = json.load(in_c)

# ---------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------
configfile: 'config.yml'

#FASTA_DIR = "/home/aglucaci/BUSTEDS-MH/data/Shultz/compgen_alignments"
#TREE_DIR = "/home/aglucaci/BUSTEDS-MH/data/Shultz/compgen_alignments/Trees/BioNJ/ForHyPhy"

FASTA_DIR = config["DataDirectory"]
TREE_DIR = config["DataDirectoryNewick"]

# glob all of the files
FASTAS = glob.glob(os.path.join(FASTA_DIR, "*" + config["FileEndingFasta"]))
TREES = glob.glob(os.path.join(TREE_DIR, "*" + config["FileEndingNewick"]))

FASTA_filenames = [os.path.basename(x) for x in FASTAS]
TREE_filenames = [os.path.basename(x) for x in TREES]

# Report to user
print("# Number of fasta files to process:", len(FASTAS))
print("# Number of accompanying tree files to process:", len(TREES))

#OUTDIR = "/home/aglucaci/BUSTEDS-MH/analysis/Enard"
#OUTDIR = "/home/aglucaci/BUSTEDS-MH/analysis/Shultz"
OUTDIR = config["OutputDirectory"]

OUTDIR_aBSRELMH = os.path.join(OUTDIR, "aBSREL-MH")
OUTDIR_aBSREL   = os.path.join(OUTDIR, "aBSREL")

# Report to user
print("# Files for aBSREL-MH and aBSREL will be saved in:", OUTDIR)

# Create output dir.
Path(OUTDIR).mkdir(parents=True, exist_ok=True)
Path(OUTDIR_aBSRELMH).mkdir(parents=True, exist_ok=True)
Path(OUTDIR_aBSREL).mkdir(parents=True, exist_ok=True)

# Settings, these can be passed in or set in a config.json type file
#PPN = cluster["__default__"]["ppn"] 
PPN = 16 
hyphy = "hyphy"

print("# We will use", PPN, "processors")

# ---------------------------------------------------------------------
# Rule all
# ---------------------------------------------------------------------
rule all:
    input:
        expand(os.path.join(OUTDIR_aBSRELMH, "{fasta}.aBSREL-MH.json"), fasta=FASTA_filenames),
        expand(os.path.join(OUTDIR_aBSREL, "{fasta}.aBSREL.json"), fasta=FASTA_filenames)

# ---------------------------------------------------------------------
# Individual rules
# ---------------------------------------------------------------------

rule aBSRELSMH:
    input:
        fasta = os.path.join(FASTA_DIR, "{sample}"),
        tree  = os.path.join(TREE_DIR, "{sample}-BioNJ_tree_hyphy.nwk") 
    output:
        output = os.path.join(OUTDIR_aBSRELMH, "{sample}.aBSREL-MH.json")
    shell:
        "mpirun -np {PPN} {hyphy} aBSREL --alignment {input.fasta} --tree {input.tree} --output {output.output} --multiple-hits Double+Triple"
        #mpiexec --mca opal_cuda_support 1
    #end shell
#end fule aBSREL-MH

rule aBSREL:
    input:
        fasta = os.path.join(FASTA_DIR, "{sample}"),
        tree  = os.path.join(TREE_DIR, "{sample}-BioNJ_tree_hyphy.nwk") 
    output:
        output = os.path.join(OUTDIR_aBSREL, "{sample}.aBSREL.json")
    shell:
        "mpirun -np {PPN} {hyphy} aBSREL --alignment {input.fasta} --tree {input.tree} --output {output.output}"
    #end shell
#end rule aBSREL

# ---------------------------------------------------------------------
# End of file
# ---------------------------------------------------------------------
