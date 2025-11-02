# 06_similarity_heatmap.R

library(ggplot2)
library(readr)
library(pheatmap)
library(grid)

# Establecer directorio de trabajo (ajustar según corresponda)
setwd("~/Escritorio/SynologyDrive/Profagos Xylella/Figuras_nuevas")

# Importar matriz ANI desde archivo TSV
matriz <- read.csv("matriz_viridic.tsv", sep = "\t", row.names = 1, check.names = FALSE)

# Convertir valores de matriz de character a numérico, cambiando coma por punto decimal
matriz_numerica <- apply(matriz, 2, function(x) gsub(",", ".", x))
matriz_numerica <- apply(matriz_numerica, 2, as.numeric)

# Reemplazar NA por 0
matriz_numerica[is.na(matriz_numerica)] <- 0

# Asignar nombres de fila igual a los nombres de columna (simetría)
rownames(matriz_numerica) <- colnames(matriz_numerica)

# Definir paleta de colores personalizada para el heatmap
custom_colors <- colorRampPalette(c("white", "grey", "black"))(100)

# Generar heatmap sin clustering con pheatmap
p <- pheatmap(matriz_numerica,
              cluster_rows = FALSE,
              cluster_cols = FALSE,
              display_numbers = FALSE,
              fontsize = 8,
              color = custom_colors,
              angle_col = 90)

# Guardar el heatmap como archivo SVG
svg("matriz_similitud.svg", width = 8, height = 7, bg = "transparent")
grid.newpage()
grid.draw(p$gtable)
dev.off()

