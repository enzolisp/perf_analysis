suppressPackageStartupMessages({
  library(dplyr)
  library(ggplot2)
  library(readr)
  library(stringr)
})

pick_col <- function(df, opts) {
  for (c in opts) {
    if (c %in% names(df)) return(df[[c]])
  }
  return(rep(NA, nrow(df)))
}

parse_mem_to_MiB <- function(x) {
  x <- as.character(x)
  x[is.na(x) | x == ""] <- NA
  num <- as.numeric(str_extract(x, "[0-9]+\\.?[0-9]*"))
  unit <- tolower(str_extract(x, "[a-zA-Z]+"))
  unit <- ifelse(is.na(unit), "", unit)
  miB <- rep(NA_real_, length(num))
  miB[unit %in% c("mib","mb")] <- num[unit %in% c("mib","mb")]
  miB[unit %in% c("gib","gb")] <- num[unit %in% c("gib","gb")] * 1024
  miB[unit %in% c("kib","kb")] <- num[unit %in% c("kib","kb")] / 1024
  miB[unit %in% c("b")] <- num[unit %in% c("b")] / (1024^2)
  miB[is.na(miB) & !is.na(num)] <- num[is.na(miB) & !is.na(num)]
  return(miB)
}

source("scripts/read_csv.R")

dados <- read_csv_performance()

dir.create("graphs/boxplots_mem", showWarnings = FALSE)

dados <- dados %>%
  mutate(
    Mem_MiB = parse_mem_to_MiB(MemUsed),
    Mem_MB  = Mem_MiB * 1.048576,
    # The fix is here: using `dim`
    #dim = as.numeric(str_remove(tolower(as.character(`dim`)), "d")),
    L_Value = as.numeric(L_Value)
  )

summary_mem <- dados %>%
  group_by(language, ContainerID, dimension, L_Value) %>%
  summarise(mean_mem_MiB = mean(Mem_MiB, na.rm = TRUE),
            n_obs = sum(!is.na(Mem_MiB)),
            .groups = "drop")

summary_geral <- summary_mem %>%
  #filter(!is.na(L_value), !is.na(mean_mem_MiB)) %>%
  group_by(language, dimension, L_Value) %>%
  summarise(
    avg_mem = mean(mean_mem_MiB, na.rm = TRUE),
    sd_mem = sd(mean_mem_MiB, na.rm = TRUE),
    n_runs = n(),
    .groups = "drop"
  )


theme_set(theme_minimal(base_size = 14))

pos <- position_dodge(width = 0.9)

plot_1d_bars <- summary_geral %>%
  filter(dimension == 1) %>%
  ggplot(aes(x = factor(L_Value), y = avg_mem, fill = language)) +
  geom_col(position = pos, alpha = 0.85) +
  geom_errorbar(aes(ymin = avg_mem - sd_mem, ymax = avg_mem + sd_mem),
                position = pos, width = 0.25, color = "gray20") +
  labs(title = "Uso Médio de Memória por Tamanho do Problema (1D)",
       subtitle = "Comparação entre linguagens para cada tamanho discreto",
       x = "Tamanho",
       y = "Memória Média Usada (MiB)",
       fill = "Linguagem") +
  theme(legend.position = "top")


plot_2d_bars <- summary_geral %>%
  filter(dimension == 2) %>%
  ggplot(aes(x = factor(L_Value), y = avg_mem, fill = language)) +
  geom_col(position = pos, alpha = 0.85) +
  geom_errorbar(aes(ymin = avg_mem - sd_mem, ymax = avg_mem + sd_mem),
                position = pos, width = 0.25, color = "gray20") +
  labs(title = "Uso Médio de Memória por Tamanho do Problema (2D)",
       subtitle = "Comparação entre linguagens para cada tamanho discreto",
       x = "Tamanho",
       y = "Memória Média Usada (MiB)",
       fill = "Linguagem") +
  theme(legend.position = "top")
  
plot_3d_bars <- summary_geral %>%
  filter(dimension == 3) %>%
  ggplot(aes(x = factor(L_Value), y = avg_mem, fill = language)) +
  geom_col(position = pos, alpha = 0.85) +
  geom_errorbar(aes(ymin = avg_mem - sd_mem, ymax = avg_mem + sd_mem),
                position = pos, width = 0.25, color = "gray20") +
  labs(title = "Uso Médio de Memória por Tamanho do Problema (3D)",
       subtitle = "Comparação entre linguagens para cada tamanho discreto",
       x = "Tamanho (Aresta do Cubo)",
       y = "Memória Média Usada (MiB)",
       fill = "Linguagem") +
  theme(legend.position = "top")


ggsave("graphs/boxplots_mem/boxplot_mem_1d.pdf", plot_1d_bars, width = 10, height = 7)
print("Saved: graphs/boxplot_mem_1d.pdf")

ggsave("graphs/boxplots_mem/boxplot_mem_2d.pdf", plot_2d_bars, width = 10, height = 7)
print("Saved: graphs/boxplot_mem_2d.pdf")

ggsave("graphs/boxplots_mem/boxplot_mem_3d.pdf", plot_3d_bars, width = 10, height = 7)
print("Saved: graphs/boxplot_mem_3d.pdf")

print("-------------------------------------------------------")
cat("Completed! Check 'graphs/boxplots_mem'.\n\n")