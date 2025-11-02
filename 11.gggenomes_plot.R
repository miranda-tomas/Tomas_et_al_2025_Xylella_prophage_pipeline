#!/usr/bin/env Rscript
# *****************************************************************************
# 11_gggenomes_plot.R
#
# This script generates a genomic synteny plot for prophage genomes using
# gggenomes. It visualizes gene organization, functional modules, and
# nucleotide similarity between genomes.
#
# Inputs required:
#   <name>.fasta   - FASTA file with prophage genome sequences
#   <name>.gff     - GFF annotation file for the same genomes
#   <name>.o6      - Pairwise similarity file (output from VIRIDIC or similar)
#
# Usage:
#   Rscript 11_gggenomes_plot.R <name>
#
# Author: Miranda Tomas
# *****************************************************************************

# Load required packages
library(gggenomes)
library(ggplot2)
library(grid)

# Define the family or group name (used as file prefix)
args <- commandArgs(trailingOnly = TRUE)

if(length(args) == 0) {
  stop("Error: Debes proporcionar el argumento 'name'.\nUso: Rscript 11_gggenomes_plot.R <name>")
}

name <- args[1]

# Load input files
seqs <- read_seqs(paste0(name, ".fasta"))
genes <- read_feats(paste0(name, ".gff"))
links <- read_links(paste0(name, ".o6"))

# Rename similarity column and categorize similarity ranges
colnames(links)[4] <- "Similarity"
links$Similarity <- cut(
  links$Similarity,
  breaks = c(-Inf, 85.0, 90.0, 95.0, Inf),
  labels = c("<85%", "85–90%", "90–95%", ">95%")
)

# Assign functional module categories
genes$Functional_Modules <- genes$phase

# Define color palette for functional modules
palette <- c(
  "lightsalmon2", "#F08CBA", "chocolate4", "bisque3",
  "#88C0D0", "#9A7BB5", "#EBCB8B", "grey",
  "#3B578D", "#A3BE8C", "#D34A59"
)

# Generate figure
fig <- gggenomes(seqs = seqs, links = links, genes = genes) +
  geom_link(aes(alpha = Similarity), color = "lightgrey", fill = "lightgrey") +
  geom_seq() +
  geom_gene(aes(fill = Functional_Modules)) +
  geom_bin_label(size = 4, nudge_left = 0.01, expand_left = 0.12) +
  scale_fill_manual(
    values = palette,
    breaks = c(
      "Integration and excision",
      "Head and packaging",
      "Lysis",
      "Other",
      "DNA, RNA and nucleotide metabolism",
      "Tail",
      "tRNA and auxiliary RNA genes",
      "Unknown function",
      "Transcription regulation",
      "Connector",
      "Moron, auxiliary metabolic gene and host takeover"
    ),
    name = "Functional modules"
  ) +
  scale_alpha_manual(
    values = c(0.2, 0.4, 0.6, 1),
    breaks = c("<85%", "85–90%", "90–95%", ">95%"),
    name = "Similarity"
  ) +
  theme(
    legend.key.size = unit(7, "mm"),
    legend.text = element_text(size = 10),
    legend.title = element_text(size = 12, face = "bold"),
    legend.position = "top",
    legend.spacing.x = unit(0.21, "cm"),
    legend.box.just = "right",
    legend.box.margin = margin(-10, 0, -20, -5)
  ) +
  guides(
    fill = guide_legend(order = 1, nrow = 3, byrow = TRUE),
    alpha = guide_legend(order = 2)
  )

# Export figure to SVG
ggsave(
  filename = paste0(name, "_gggenomes.svg"),
  plot = fig,
  width = 15,
  height = 5,
  bg = "transparent"
)
