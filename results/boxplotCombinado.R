library(readr)
library(dplyr)
library(ggplot2)

dados_julia_1d <- read_csv("julia_1d_results.csv") %>% mutate(language = "Julia")
dados_julia_2d <- read_csv("julia_2d_results.csv") %>% mutate(language = "Julia")
dados_python_1d <- read_csv("python_1d_results.csv") %>% mutate(language = "Python")
dados_python_2d <- read_csv("python_2d_results.csv") %>% mutate(language = "Python")

dados_combinados <- bind_rows(
  dados_julia_1d, dados_julia_2d,
  dados_python_1d, dados_python_2d
)

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

ggplot(dados_para_plot, aes(x = language, y = t_exec, fill = language)) +
  geom_boxplot(alpha = 0.8) +
  
  geom_jitter(width = 0.1, alpha = 0.4) +
  
  facet_wrap(~ Size_Label + dimension, scales = "free") +
  
  scale_fill_manual(values = c("Julia" = "#9558B2", "Python" = "#3C78D8")) +
  
  labs(
    title = "Comparativo de Desempenho: Julia vs. Python",
    x = "", 
    y = "Tempo de Execução (segundos, escala log)" 
  ) +
  theme_bw() +
  guides(fill = "none")
