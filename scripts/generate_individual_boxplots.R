suppressPackageStartupMessages({
  library(dplyr)
  library(ggplot2)
  library(readr)
})

source("scripts/read_csv.R")

dir.create("graphs/individual_boxplots", showWarnings = FALSE)

dados <- read_csv_results()

dados$L_Value <- as.numeric(dados$L_Value)
dados$t_exec <- as.numeric(dados$t_exec)

# criar combinacoes e ordenar
combinacoes <- unique(dados[, c("language", "dimension", "Size", "L_Value")])
combinacoes <- combinacoes %>% arrange(language, dimension, L_Value)

for (i in 1:nrow(combinacoes)) {
  
  lang  <- combinacoes$language[i]
  dim   <- combinacoes$dimension[i]
  sz    <- combinacoes$Size[i]
  l_val <- combinacoes$L_Value[i]
  
  
  dados_subset <- dados %>%
    filter(language == lang, dimension == dim, Size == sz)
  
  cor_fill <- if(lang == "python") "#377eb8" else "#984ea3"
  
  # Cria o gráfico (Eixo X vazio, pois é um único boxplot)
  p <- ggplot(dados_subset, aes(x = "", y = t_exec)) +
    geom_boxplot(fill = cor_fill, alpha = 0.7, width = 0.5, outlier.color = "red") +
    geom_jitter(width = 0.05, alpha = 0.6, size = 3) + 
    
    labs(
      title = paste(toupper(lang), toupper(dim), "-", sz, "(L =", l_val, ")"),
      subtitle = "Execution Time (s)",
      x = "", 
      y = "Time (s)"
    ) +
    theme_bw() +
    theme(
      plot.title = element_text(face = "bold", size = 14),
      axis.text.x = element_blank(), 
      axis.ticks.x = element_blank(),
      panel.grid.major.x = element_blank()
    )
  
  nome_arquivo <- sprintf("graphs/individual_boxplots/boxplot_%s_%s_%sd.pdf", lang, sz, dim)
  ggsave(nome_arquivo, plot = p, width = 6, height = 6)
  print(paste("Saved:", nome_arquivo))

}

print("-------------------------------------------------------")
cat("Completed! Check 'graphs/individual_boxplots'.\n\n")
