suppressPackageStartupMessages({
  library(dplyr)
  library(ggplot2)
  library(readr)
  library(stringr)
})

source("scripts/read_csv.R")

#dir.create("graphs/general_boxplot", showWarnings = FALSE)

dados <- read_csv_results()

dados$L_fator <- factor(dados$L_Value, levels = sort(unique(dados$L_Value)))

p_geral <- ggplot(dados, aes(x = L_fator, y = t_exec, fill = language)) +
  geom_boxplot(alpha = 0.8) +
  # divide os gráficos Scales="free"
  facet_grid(language ~ dimension, scales = "free") +
  scale_fill_manual(values = c("julia" = "#984ea3", "python" = "#377eb8")) +
  labs(
    title = "Visão Geral de Desempenho (Todos os Experimentos)",
    subtitle = "Comparação de Tempo de Execução (Eixos independentes)",
    x = "Tamanho L",
    y = "Tempo (s)"
  ) +
  theme_bw() +
  theme(legend.position = "bottom")

ggsave("graphs/general_boxplot.png", p_geral, width = 12, height = 8)
print("Saved: graphs/general_boxplot.png")

print("-------------------------------------------------------")
cat("Completed! Check 'graphs'.\n\n")