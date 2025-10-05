library(readr)
library(dplyr)
library(ggplot2)

dados_1d <- read_csv("python_1d_results.csv")
dados_2d <- read_csv("python_2d_results.csv")
dados_combinados <- bind_rows(dados_1d, dados_2d)

ordem_correta <- dados_combinados %>%
  select(Size, L_Value) %>%
  distinct() %>%
  arrange(L_Value)

niveis_ordenados <- paste0(ordem_correta$Size, " (L = ", ordem_correta$L_Value, ")")

dados_para_plot <- dados_combinados %>%
  mutate(Size_Label = paste0(Size, " (L = ", L_Value, ")"))

dados_para_plot$Size_Label <- factor(
  dados_para_plot$Size_Label,
  levels = niveis_ordenados
)

ggplot(dados_para_plot, aes(x = as.factor(dimension), y = t_exec, fill = as.factor(dimension))) +
  geom_boxplot(alpha = 0.7) +
  geom_jitter(width = 0.1, alpha = 0.5) +
  
  facet_wrap(~ Size_Label + dimension, scales = "free") +
  
  labs(
    title = "Tempo de execução por dimensão",
    x = "Dimensão",
    y = "Tempo de Execução (segundos)"
  ) +
  theme_bw() +
  guides(fill = "none")
