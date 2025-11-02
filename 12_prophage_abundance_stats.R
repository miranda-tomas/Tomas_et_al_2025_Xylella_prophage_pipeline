#!/usr/bin/env Rscript
# *****************************************************************************
# 12_prophage_load_boxplot.R
#
# This script reads a CSV file with prophage counts per strain and subspecies,
# generates a boxplot visualization, and performs statistical tests
# (Kruskal-Wallis and Dunn's post hoc) to compare groups.
#
# Usage:
#   Rscript 12_prophage_load_boxplot.R <csv_file>
#
# Author: Miranda Tomas
# *****************************************************************************

# Cargar librerías necesarias
library(dplyr)
library(ggplot2)
library(FSA)

# Leer argumentos de línea de comando
args <- commandArgs(trailingOnly = TRUE)

if(length(args) == 0) {
  stop("Error. Usage: Rscript 12_prophage_load_boxplot.R <csv_file>")
}

csv_file <- args[1]

# Leer los datos desde CSV
df <- read.csv(csv_file)

# Asegurar que la subespecie es un factor
df$subspecies <- as.factor(df$subspecies)

# Visualización: boxplot
p <- ggplot(df, aes(x = subspecies, y = prophage, fill = subspecies)) +
  geom_boxplot(outlier.shape = NA, alpha = 0.7) +
  geom_jitter(width = 0.2, size = 2, alpha = 0.5) +
  theme_minimal() +
  labs(title = "Prophage Load per Genome by Subspecies",
       x = "Subspecies",
       y = "Number of Intact Prophages") +
  theme(legend.position = "none")

print(p)

# Kruskal-Wallis test (no paramétrico)
kruskal_result <- kruskal.test(prophage ~ subspecies, data = df)
print(kruskal_result)

# Si es significativo, aplicar post hoc (Dunn's test)
if (kruskal_result$p.value < 0.05) {
  cat("Post hoc test (Dunn's test):\n")
  posthoc <- dunnTest(prophage ~ subspecies, data = df, method = "bonferroni")
  print(posthoc)
}

