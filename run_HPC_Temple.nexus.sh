#!/bin/bash

clear 

set -euo pipefail

printf "Running snakemake...\n"

#snakemake --forceall --dag | dot -Tpdf > dag.pdf

mkdir -p logs

snakemake \
      -s Snakefile.nexus \
      --cluster-config cluster.json \
      --cluster "qsub -V -N aBSREL_ModelTest -l nodes={cluster.nodes}:ppn={cluster.ppn} -l walltime=120:00:00 -q {cluster.name} -e logs -o logs" \
      --jobs 8 all \
      --rerun-incomplete \
      --keep-going \
      --reason \
      --latency-wait 60 \
      --use-conda \
      --conda-frontend conda
# End of file 
