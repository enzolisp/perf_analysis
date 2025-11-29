suppressPackageStartupMessages({
  library(dplyr)
  library(ggplot2)
  library(readr)
  library(stringr)
})

source("scripts/read_csv.R")

dados <- read_csv_results()

dados$L_fator <- factor(dados$L_Value, levels = sort(unique(dados$L_Value)))

p_comp <- ggplot(dados, aes(x = L_fator, y = t_exec, fill = language)) +
  geom_boxplot() +
  geom_jitter(alpha = 0.5, size = 1.5, position = position_jitterdodge(jitter.width = 0.1, dodge.width = 0.75)) + 
  facet_wrap(~dimension, scales = "free", ncol = 3) +
  scale_fill_manual(values = c("julia" = "#984ea3", "python" = "#377eb8")) +
  labs(
    title = "Python vs Julia: Comparativo Direto",
    x = "Tamanho L",
    y = "Tempo (s)"
  ) +
  theme_bw()

ggsave("graphs/general_comparison.pdf", p_comp, width = 12, height = 6)
print("Saved: graphs/general_comparison.pdf")

print("-------------------------------------------------------")
cat("Completed! Check 'graphs'.\n\n")