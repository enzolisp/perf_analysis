library(readr)
library(dplyr)
library(ggplot2)

dados_1d <- read_csv("python_1d_results.csv")
dados_2d <- read_csv("python_2d_results.csv")
dados_combinados <- bind_rows(dados_1d, dados_2d)

dados_combinados$Size <- factor(dados_combinados$Size, levels = c("low", "mid", "high"))


ggplot(dados_combinados, aes(x = as.factor(dimension), y = t_exec, fill = as.factor(dimension))) +
  geom_violin(alpha = 0.7) +
  geom_jitter(width = 0.1, alpha = 0.5) +
  
  facet_wrap(~ Size + dimension, scales = "free") +
  
  labs(
    title = "Distribuição do Tempo de execução",
    x = "",
    y = "Tempo de Execução (segundos)"
  ) +
  theme_bw() +
  guides(fill = "none") +
  theme(axis.text.x = element_blank(), axis.ticks.x = element_blank())
