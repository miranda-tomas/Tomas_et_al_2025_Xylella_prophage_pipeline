#!/bin/bash

===============================================================
# Script: 01_phastest_prediction.sh
# Purpose: Submit Xylella fastidiosa genomes to the PHASTEST API
#          to predict prophages and download the annotated results.
# Author:  Miranda Tomás Tomás 
# Reference: Wishart et al. 2023, Nucleic Acids Research
# ===============================================================
#
# Usage:
#   bash 01_phastest_prediction.sh input_folder output_folder
#
# ===============================================================

INPUT_DIR=$1
OUTPUT_DIR=$2

# Create output directory if it doesn't exist
mkdir -p "${OUTPUT_DIR}"

# Loop over all fasta/fna files in the input directory
for genome in "${INPUT_DIR}"/*.fasta "${INPUT_DIR}"/*.fna; do
    [ -e "$genome" ] || continue  # skip if no files found

    BASENAME=$(basename "$genome" .fasta)
    BASENAME=$(basename "$BASENAME" .fna)

    echo ">>> Submitting ${BASENAME} to PHASTEST API..."

    # Submit genome to PHASTEST API (example endpoint, may vary)
    RESPONSE=$(curl -s -F "file=@${genome}" https://phastest.ca/api/upload)

    # Extract job ID
    JOB_ID=$(echo "$RESPONSE" | jq -r '.job_id')

    if [[ "$JOB_ID" == "null" || -z "$JOB_ID" ]]; then
        echo "!!! Failed to submit ${BASENAME}"
        continue
    fi

    echo "    Job ID: $JOB_ID"
    echo "    Waiting for results..."

    # Wait for job completion
    STATUS="running"
    while [[ "$STATUS" == "running" ]]; do
        sleep 60
        STATUS=$(curl -s "https://phastest.ca/api/status/${JOB_ID}" | jq -r '.status')
        echo "    Status: $STATUS"
    done

    if [[ "$STATUS" != "done" ]]; then
        echo "!!! ${BASENAME} failed with status ${STATUS}"
        continue
    fi

    # Download GBK and FASTA outputs
    curl -s -o "${OUTPUT_DIR}/${BASENAME}_phastest.gbk" "https://phastest.ca/api/result/${JOB_ID}/gbk"
    curl -s -o "${OUTPUT_DIR}/${BASENAME}_phastest.fasta" "https://phastest.ca/api/result/${JOB_ID}/fasta"

    echo "Results saved for ${BASENAME}"
    echo
done

echo "=== All submissions completed ==="
