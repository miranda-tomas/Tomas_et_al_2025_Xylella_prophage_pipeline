# 06_similarity_heatmap.R

# This script generates a similarity heatmap (based on ANI values) of prophages
# using a precomputed VIRIDIC matrix.

# Usage: Rscript 06_similarity_heatmap.R <matrix_file.tsv>

# Load required packages
library(ggplot2)
library(readr)
library(pheatmap)
library(grid)

# Read command-line arguments
args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 1) {
  stop("Usage: Rscript 06_similarity_heatmap.R <matrix_file.tsv>")
}
input_file <- args[1]

# Load VIRIDIC ANI matrix
matrix <- read.csv("matrix_viridic.tsv", sep = "\t", row.names = 1, check.names = FALSE)

# Convert from character to numeric (replace commas with dots)
ani_matrix <- apply(matrix, 2, function(x) gsub(",", ".", x))
ani_matrix <- apply(ani_matrix, 2, as.numeric)

# Replace NA with 0
ani_matrix[is.na(ani_matrix)] <- 0

# Assign row names equal to column names (ensure symmetry)
rownames(ani_matrix) <- colnames(ani_matrix)

# Define grayscale color palette
custom_colors <- colorRampPalette(c("white", "grey", "black"))(100)

# Generate non-clustered heatmap
heatmap_plot <- pheatmap(
  ani_matrix,
  cluster_rows = FALSE,
  cluster_cols = FALSE,
  display_numbers = FALSE,
  fontsize = 8,
  color = custom_colors,
  angle_col = 90
)

# Save heatmap as SVG file
svg("similarity_matrix.svg", width = 8, height = 7, bg = "transparent")
grid.newpage()
grid.draw(heatmap_plot$gtable)
dev.off()

