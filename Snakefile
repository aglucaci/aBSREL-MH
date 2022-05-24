# Snakefile for aBSREL-MH Analysis
# @Author: Alexander G Lucaci
# @Description: aBSREL ModelTest and other musings.

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
# Configuration
# ---------------------------------------------------------------------
# Load the cluster json file, has information on submitting jobs.
with open("cluster.json", "r") as in_c:
    cluster = json.load(in_c)
# endwith

# Load the configuration yaml file.
configfile: 'config.yml'

# ---------------------------------------------------------------------
# Declares
# ---------------------------------------------------------------------
# Get the important directories
FASTA_DIR = config["DataDirectory"]
TREE_DIR = config["DataDirectoryNewick"]

# Glob all of the files
FASTAS = glob.glob(os.path.join(FASTA_DIR, "*" + config["FileEndingFasta"]))
TREES = glob.glob(os.path.join(TREE_DIR, "*" + config["FileEndingNewick"]))

# Get the basenames, need it for output
FASTA_filenames = [os.path.basename(x) for x in FASTAS]
TREE_filenames = [os.path.basename(x) for x in TREES]

# Report to user
print("# Number of fasta files to process:", len(FASTAS))
print("# Number of accompanying tree files to process:", len(TREES))

# Get main output directory
OUTDIR = config["OutputDirectory"]

# Set the subdirectories for output.
OUTDIR_aBSRELMH = os.path.join(OUTDIR, "aBSREL-MH")
OUTDIR_aBSREL   = os.path.join(OUTDIR, "aBSREL")
OUTDIR_aBSRELSMH = os.path.join(OUTDIR, "aBSRELS-MH")
OUTDIR_aBSRELS   = os.path.join(OUTDIR, "aBSRELS")

# Report to user
print("# Files for aBSREL-MH and aBSREL will be saved in:", OUTDIR)

# Create output dirs
Path(OUTDIR).mkdir(parents=True, exist_ok=True)
Path(OUTDIR_aBSRELMH).mkdir(parents=True, exist_ok=True)
Path(OUTDIR_aBSREL).mkdir(parents=True, exist_ok=True)
Path(OUTDIR_aBSRELSMH).mkdir(parents=True, exist_ok=True)
Path(OUTDIR_aBSRELS).mkdir(parents=True, exist_ok=True)

# Settings, these can be passed in or set in a config.json type file
PPN = cluster["__default__"]["ppn"] 
hyphy = "hyphy"

print("# We will use", PPN, "processors")

# ==============================================================================
# Helper functions
# ==============================================================================

def assign_code(wildcards):
    if wildcards.sample == "COXI.nex":
        return "Vertebrate-mtDNA"
    return "Universal"
#end method


# ---------------------------------------------------------------------
# Rule all
# ---------------------------------------------------------------------
rule all:
    input:
        expand(os.path.join(OUTDIR_aBSRELMH, "{fasta}.aBSREL-MH.json"), fasta=FASTA_filenames),
        expand(os.path.join(OUTDIR_aBSREL, "{fasta}.aBSREL.json"), fasta=FASTA_filenames),
        expand(os.path.join(OUTDIR_aBSRELMH, "{fasta}.aBSRELS-MH.json"), fasta=FASTA_filenames),
        expand(os.path.join(OUTDIR_aBSREL, "{fasta}.aBSRELS.json"), fasta=FASTA_filenames)
    #end input
#end rule

# ---------------------------------------------------------------------
# Individual rules
# ---------------------------------------------------------------------

rule aBSRELSMH:
    input:
        fasta = os.path.join(FASTA_DIR, "{sample}"),
        tree  = os.path.join(TREE_DIR, "{sample}-BioNJ_tree_hyphy.nwk") 
    output:
        output = os.path.join(OUTDIR_aBSRELMH, "{sample}.aBSRELS-MH.json")
    shell:
        "mpirun -np {PPN} {hyphy} aBSREL --alignment {input.fasta} --tree {input.tree} --output {output.output} --multiple-hits Double+Triple --srv Yes"
    #end shell
#end rule 

rule aBSRELMH:
    input:
        fasta = os.path.join(FASTA_DIR, "{sample}"),
        tree  = os.path.join(TREE_DIR, "{sample}-BioNJ_tree_hyphy.nwk") 
    output:
        output = os.path.join(OUTDIR_aBSRELMH, "{sample}.aBSREL-MH.json")
    shell:
        "mpirun -np {PPN} {hyphy} aBSREL --alignment {input.fasta} --tree {input.tree} --output {output.output} --multiple-hits Double+Triple"
    #end shell
#end rule

rule aBSREL:
    input:
        fasta = os.path.join(FASTA_DIR, "{sample}"),
        tree  = os.path.join(TREE_DIR, "{sample}-BioNJ_tree_hyphy.nwk") 
    output:
        output = os.path.join(OUTDIR_aBSREL, "{sample}.aBSREL.json")
    shell:
        "mpirun -np {PPN} {hyphy} aBSREL --alignment {input.fasta} --tree {input.tree} --output {output.output}"
    #end shell
#end rule

rule aBSRELS:
    input:
        fasta = os.path.join(FASTA_DIR, "{sample}"),
        tree  = os.path.join(TREE_DIR, "{sample}-BioNJ_tree_hyphy.nwk") 
    output:
        output = os.path.join(OUTDIR_aBSREL, "{sample}.aBSRELS.json")
    shell:
        "mpirun -np {PPN} {hyphy} aBSREL --alignment {input.fasta} --tree {input.tree} --output {output.output} --srv Yes"
    #end shell
#end rule


# ---------------------------------------------------------------------
# End of file
# ---------------------------------------------------------------------
