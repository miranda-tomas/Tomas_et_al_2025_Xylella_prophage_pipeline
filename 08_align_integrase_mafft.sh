#!/bin/bash
# 08_align_integrase_mafft.sh
# Miranda Tomas

# This script aligns integrase coding sequences using MAFFT 
# and builds a maximum-likelihood phylogenetic tree with IQ-TREE2.
# The resulting tree file can be visualized in FigTree.
#
# Usage: 08_align_integrase_mafft.sh <input_fasta> <output_directory>

# Number of required arguments
n=2

# Check number of arguments
if [ "$#" -ne "$n" ]; then
    echo "Error: Incorrect number of arguments."
    echo "Usage: $0 <input_fasta> <output_directory>"
    exit 1
else
    input_fasta=$1
    outdir=$2
    mkdir -p "$outdir"
fi

# Align integrase CDS using MAFFT
echo "Aligning integrase sequences with MAFFT..."
mafft --auto "$input_fasta" > "$outdir/integrase_aligned.fasta"

# Model selection and tree building with IQ-TREE2
echo "Running IQ-TREE2 model selection..."
iqtree2 -s "$outdir/integrase_aligned.fasta" -m MFP -nt AUTO

echo "Building maximum-likelihood tree with ultrafast bootstrap..."
iqtree2 -s "$outdir/integrase_aligned.fasta" -m TPM3+F+R3 -bb 1000 -nt AUTO

# Tree visualization note
echo "Tree construction complete."
echo "You can visualize the resulting tree with FigTree using the file:"
echo "$outdir/integrase_aligned.fasta.treefile"
