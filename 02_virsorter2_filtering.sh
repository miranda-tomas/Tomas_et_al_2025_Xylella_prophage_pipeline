#!/bin/bash
# ===============================================================
# Script: 02_virsorter2_classification.sh
# Purpose: Classify viral contigs (prophages) using VirSorter2
# Author:  Miranda Tomás
# Date:    [Mes Año]
# Reference: Guo et al. 2021, Microbiome 9(1): VirSorter2: a multi-classifier,
#             expert-guided approach to detect diverse DNA and RNA viruses
# ===============================================================
#
# Usage:
#   bash 02_virsorter2_classification.sh "<input_files>" <output_directory>
#
# ===============================================================

# Check argument count
if [ "$#" -ne 2 ]; then
    echo "Error: Incorrect number of arguments."
    echo "Usage: $0 '<input_files>' <output_directory>"
    exit 1
fi

# Input and output parameters
INPUT_FILES=$1
OUTDIR=$2

# Create output directory if it doesn’t exist
mkdir -p "${OUTDIR}"

# Iterate over input files
for FILE in ${INPUT_FILES}; do
    [ -e "$FILE" ] || continue  # skip if no files match

    NAME=$(basename "${FILE}" .fasta)
    NAME=$(basename "${NAME}" .fa)
    NAME=$(basename "${NAME}" .fna)

    echo ">>> Processing ${NAME} with VirSorter2..."

    virsorter run \
        -i "${FILE}" \
        -w "${OUTDIR}/${NAME}.out" \
        --include-groups "dsDNAphage" \
        --min-score 0.9 \
        -j 4 \
        all

    if [ $? -eq 0 ]; then
        echo "Completed: ${NAME}"
    else
        echo "Error processing ${NAME}"
    fi

    echo
done

echo "=== VirSorter2 classification completed ==="
