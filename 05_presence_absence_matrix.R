# 05_presence_absence_matrix.R

# This script generates a presence/absence heatmap of prophages across 
# Xylella fastidiosa strains.

# Usage: Rscript 05_presence_absence_matrix.R <matrix_file.tsv>

# Load required packages
library(ggplot2)

# Read command-line arguments
args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 1) {
  stop("Uso: Rscript 05_presence_absence_matrix.R <matrix_infeccion_new.tsv>")
}
input_file <- args[1]

# Load presence/absence matrix
matrix <- read.csv(input_file, sep = "\t", header = TRUE, row.names = 1)

# Replace NA with 0
matrix[is.na(matrix)] <- 0

# Convert to matrix and then to long format for ggplot
matrix <- as.matrix(matrix)
df <- as.data.frame(as.table(matrix))

# Rename columns for clarity
colnames(df) <- c("Strain", "Prophage", "Value")

# Reverse strain order for better visualization
df$Strain <- factor(df$Strain, levels = rev(rownames(matrix)))

# Assign subspecies based on strain name patterns
df$Subspecies <- ifelse(grepl("ST 01|ST 02|ST 75", df$Strain, ignore.case = TRUE), "fastidiosa",
                  ifelse(grepl("ST 11|ST 13|ST 14|ST 16|ST 53|ST 69|ST 70|ST 74|ST 78|ST 79|ST 80", df$Strain, ignore.case = TRUE), "pauca",
                  ifelse(grepl("ST 05|ST 72", df$Strain, ignore.case = TRUE), "sandyi",
                  ifelse(grepl("ST 31|ST 62", df$Strain, ignore.case = TRUE), "morus",
                         "multiplex"))))

# Define subspecies order
df$Subspecies <- factor(df$Subspecies, levels = c("fastidiosa", "multiplex", "pauca", "sandyi", "morus"))

# Define custom color palette for subspecies
subspecies_colors <- c(
  "fastidiosa" = "#d17b7f",
  "multiplex" = "#8fa3b2",
  "pauca" = "#86b89d",
  "sandyi" = "#ebae75",
  "morus" = "#a888ad"
)

# Generate heatmap using ggplot2
ggplot(df, aes(x = Prophage, y = Strain)) +
  geom_tile(aes(fill = ifelse(Valor == 1, Subspecies, NA)), color = "white") +
  scale_fill_manual(
    values = subspecies_colors,
    name = "Subspecies",
    limits = names(subspecies_colors),
    na.value = "white",
    guide = guide_legend(title = "Subspecies")
  ) +
  scale_x_discrete(position = "top") +
  theme_light() +
  theme(
    axis.text.x = element_text(angle = 60, vjust = 0.5, hjust = 0, size = 8, family = "sans"),
    axis.text.y = element_text(size = 8, hjust = 0, family = "sans"),
    axis.title.x = element_text(size = 10, family = "sans"),
    axis.title.y = element_text(size = 10, family = "sans"),
    legend.text = element_text(size = 8, family = "sans"),
    legend.title = element_text(size = 10, family = "sans")
  ) +
  labs(x = "PROPHAGE", y = "STRAIN")

# Save plot
ggsave("presence_absence_heatmap.png", plot = p, width = 10, height = 8, dpi = 300)
