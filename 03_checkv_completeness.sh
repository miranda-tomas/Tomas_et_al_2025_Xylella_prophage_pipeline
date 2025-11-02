#!/bin/bash
# ========================================================================
# Script: 03_checkv_completeness.sh
# Purpose: Assess viral genome quality and completeness using CheckV
# Author:  Miranda Tomás
# Reference: Nayfach et al. 2020. CheckV: assessing the quality of 
# metagenome-assembled viral genomes. Nature Biotechnology, 39:578–585.
# ========================================================================
#
# Usage:
#   bash 03_checkv_completeness.sh "<input_files>" <output_directory>
#
# ========================================================================

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

# Run CheckV for each input file
for FILE in ${INPUT_FILES}; do
    [ -e "$FILE" ] || continue  # Skip if file not found

    NAME=$(basename "${FILE}" .fasta)
    NAME=$(basename "${NAME}" .fa)
    NAME=$(basename "${NAME}" .fna)

    OUTDIR2="${OUTDIR}/${NAME}"
    mkdir -p "${OUTDIR2}"

    echo ">>> Running CheckV for ${NAME}..."

    checkv contamination "${FILE}" "${OUTDIR2}" -t 16
    checkv completeness "${FILE}" "${OUTDIR2}" -t 16
    checkv complete_genomes "${FILE}" "${OUTDIR2}"
    checkv quality_summary "${FILE}" "${OUTDIR2}"

    if [ $? -eq 0 ]; then
        echo "CheckV completed for ${NAME}"
    else
        echo "Error processing ${NAME}"
    fi

    echo
done

echo "=== CheckV analysis completed ==="
