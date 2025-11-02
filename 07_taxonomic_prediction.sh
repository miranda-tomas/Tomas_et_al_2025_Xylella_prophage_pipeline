#!/bin/bash
# 07_taxonomic_prediction.sh
# Miranda Tomas

# This script performs taxonomic prediction of prophage sequences using PhageCNN 
# and groups them into genera and species based on VIRIDIC results.
# Usage: 07_taxonomic_prediction.sh <input_fasta_list.txt> <viridic_matrix.tsv> <output_directory>

# Expected inputs:
#   1. Text file with the list of FASTA files containing prophage sequences
#   2. VIRIDIC similarity matrix (TSV format)
#   3. Output directory for all results

# Number of required arguments
n=3

# Check number of arguments
if [ "$#" -ne "$n" ]; then
    echo "Error: Incorrect number of arguments."
    echo "Usage: $0 <input_fasta_list.txt> <viridic_matrix.tsv> <output_directory>"
    exit 1
else
    fasta_list=$1
    viridic_matrix=$2
    outdir=$3
    mkdir -p "$outdir"
fi

# 1. Predict taxonomic family using PhageCNN
echo "Running PhageCNN taxonomic classification..."
while read fasta; do
    name=$(basename "$fasta" .fasta)
    echo "Processing $name ..."
    
    phagecnn predict \
        --input "$fasta" \
        --output "$outdir/${name}_phagecnn_prediction.tsv"
done < "$fasta_list"

# 2. Group prophages into genera and species based on VIRIDIC results
echo "Grouping prophages by genus and species..."
python3 - <<'EOF'
import pandas as pd
import os, sys

viridic_file = sys.argv[1]
outdir = sys.argv[2]

# Load VIRIDIC similarity matrix
df = pd.read_csv(viridic_file, sep="\t", index_col=0)

# Group sequences by genus/species thresholds
# ICTV thresholds: ≥70% ANI for genus, ≥95% ANI for species
species_clusters, genus_clusters = [], []
used_species, used_genus = set(), set()

for i in df.index:
    if i in used_species: 
        continue
    cluster = df.columns[(df.loc[i] >= 0.95)].tolist()
    species_clusters.append(cluster)
    used_species.update(cluster)

for i in df.index:
    if i in used_genus: 
        continue
    cluster = df.columns[(df.loc[i] >= 0.70)].tolist()
    genus_clusters.append(cluster)
    used_genus.update(cluster)

# Export results
pd.DataFrame(species_clusters).to_csv(os.path.join(outdir, "species_clusters.tsv"), sep="\t", index=False)
pd.DataFrame(genus_clusters).to_csv(os.path.join(outdir, "genus_clusters.tsv"), sep="\t", index=False)
EOF "$viridic_matrix" "$outdir"

echo "Taxonomic prediction and grouping completed successfully."

