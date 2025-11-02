#!/bin/bash
# 09_pharokka_annotation.sh
# Miranda Tomas

# This script runs Pharokka to annotate prophage genomes using a specified Conda environment.
# It requires as arguments: 
# (1) the input FASTA files to annotate and 
# (2) the output directory where the results will be stored.

# Number of required arguments
n=2

# Check the number of arguments
if [ "$#" -ne "$n" ]; then
    echo "Error: Incorrect number of arguments."
    echo "Usage: $0 <input_files.txt> <output_directory>"
    exit 1
else
    # Input files
    input_files=$1

    # Output directory
    outdir=$2
    mkdir -p "$outdir"
fi

# Activate the conda environment containing Pharokka
conda activate pharokka_env

# Loop through all input files and annotate with Pharokka
for file in $input_files; do
    name=$(basename "$file" .fasta)
    echo "Annotating prophage genome: $name"

    pharokka.py -i "$file" -o "$outdir/$name" -d /path/to/pharokka_db -t 8
done

# Deactivate conda environment
conda deactivate

