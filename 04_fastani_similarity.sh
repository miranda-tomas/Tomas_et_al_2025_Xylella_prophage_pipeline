#!/bin/bash
# ========================================================================
# Script: 04_fastani_similarity.sh
# Purpose: Compute pairwise Average Nucleotide Identity (ANI) between 
#          prophage genomes using FastANI
# Author:  Miranda Tomás
# Reference: Jain et al. 2018. FastANI: Fast alignment-free computation 
#            of whole-genome Average Nucleotide Identity. 
#            Bioinformatics 34: i187–i194.
# ========================================================================
#
# Usage:
#   bash 04_fastani_similarity.sh "<input_folder>" <output_directory>
#
# ========================================================================

# Check argument count
if [ "$#" -ne 2 ]; then
    echo "Error: Incorrect number of arguments."
    echo "Usage: $0 '<input_folder>' <output_directory>"
    exit 1
fi

# Input and output parameters
INPUT_FOLDER=$1
OUTDIR=$2

# Create output directory if it doesn’t exist
mkdir -p "${OUTDIR}"

# Output file
OUTFILE="${OUTDIR}/fastani_results.txt"

# Collect all fasta files in the input folder
FILES=(${INPUT_FOLDER}/*.fasta)

# Run FastANI pairwise across all files
echo ">>> Starting FastANI pairwise comparisons..."
for QUERY in "${FILES[@]}"; do
    for REF in "${FILES[@]}"; do
        if [ "$QUERY" != "$REF" ]; then
            qname=$(basename "${QUERY}")
            rname=$(basename "${REF}")
            fastani --query "${QUERY}" --ref "${REF}" --output "${OUTDIR}/${qname}_vs_${rname}.txt" --minFraction 0.85
        fi
    done
done

# Merge all individual results into a single file
cat "${OUTDIR}"/*_vs_*.txt > "${OUTFILE}"

echo "=== FastANI pairwise comparison completed ==="
echo "Results saved to: ${OUTFILE}"
