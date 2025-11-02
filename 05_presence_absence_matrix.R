# 05_presence_absence_matrix.R

library(ggplot2)

# Cargar la matriz desde archivo TSV
matriz <- read.csv("matriz_infeccion_new.tsv", sep = "\t", header = TRUE, row.names = 1)

# Reemplazar NA por 0
matriz[is.na(matriz)] <- 0

# Convertir a matriz
matriz <- as.matrix(matriz)

# Convertir la matriz a dataframe en formato largo
df <- as.data.frame(as.table(matriz))

# Renombrar columnas para claridad
colnames(df) <- c("Cepa", "Profago", "Valor")

# Invertir el orden de las cepas para la visualización
df$Cepa <- factor(df$Cepa, levels = rev(rownames(matriz)))

# Asignar Subspecies basado en patrones de nombre
df$Subspecies <- ifelse(grepl("ST 01|ST 02|ST 75", df$Cepa, ignore.case = TRUE), "fastidiosa",
                  ifelse(grepl("ST 11|ST 13|ST 14|ST 16|ST 53|ST 69|ST 70|ST 74|ST 78|ST 79|ST 80", df$Cepa, ignore.case = TRUE), "pauca",
                  ifelse(grepl("ST 05|ST 72", df$Cepa, ignore.case = TRUE), "sandyi",
                  ifelse(grepl("ST 31|ST 62", df$Cepa, ignore.case = TRUE), "morus",
                         "multiplex"))))

# Definir el factor con niveles específicos para el grupo
df$Subspecies <- factor(df$Subspecies, levels = c("fastidiosa", "multiplex", "pauca", "sandyi", "morus"))

# Definir paleta de colores para cada subespecie
colores_subspecies <- c(
  "fastidiosa" = "#d17b7f",
  "multiplex" = "#8fa3b2",
  "pauca" = "#86b89d",
  "sandyi" = "#ebae75",
  "morus" = "#a888ad"
)

# Crear heatmap con ggplot2
ggplot(df, aes(x = Profago, y = Cepa)) +
  geom_tile(aes(fill = ifelse(Valor == 1, Subspecies, NA)), color = "white") +
  scale_fill_manual(values = colores_subspecies,
                    name = "Subspecies",
                    limits = names(colores_subspecies),
                    na.value = "white",
                    guide = guide_legend(title = "Subspecies")) +
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
