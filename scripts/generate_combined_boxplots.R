suppressPackageStartupMessages({
  library(dplyr)
  library(ggplot2)
  library(readr)
})

source("scripts/read_csv.R")

dir.create("graphs/combined_boxplots", showWarnings = FALSE)

print("Reading CSVs...")
dados <- read_csv_results()

dados$L_Value <- as.numeric(dados$L_Value)
dados$t_exec <- as.numeric(dados$t_exec)

combinacoes_grafico <- unique(dados[, c("language", "dimension")])
combinacoes_grafico <- combinacoes_grafico %>% arrange(language, dimension)

print(paste("Generating", nrow(combinacoes_grafico), "graphs..."))

for (i in 1:nrow(combinacoes_grafico)) {
  
  lang  <- combinacoes_grafico$language[i]
  dim   <- combinacoes_grafico$dimension[i]
  
  dados_subset <- dados %>%
    filter(language == lang, dimension == dim)
  
  cor_fill <- if(lang == "python") "#377eb8" else "#984ea3" 
  
  p <- ggplot(dados_subset, aes(x = factor(L_Value), y = t_exec)) + 
  
    geom_boxplot(fill = cor_fill, alpha = 0.7) + 
    geom_jitter(width = 0.1, alpha = 0.5, size = 1.5) + 
    
    # Labels and Title
    labs(
      title = paste("Performance:", toupper(lang), "in", toupper(dim)),
      subtitle = "Distribution of Execution Time by Problem Size (L)",
      x = "Problem Size (L)", 
      y = "Time (s)",
    ) +
    
    # Theme adjustments
    theme_bw() +
    theme(
      plot.title = element_text(face = "bold", size = 16, hjust = 0), # Left-aligned like example
      plot.subtitle = element_text(hjust = 0), # Left-aligned like example
      axis.text.x = element_text(size = 12),
      panel.grid.major.x = element_blank()
    )
  
  nome_arquivo <- sprintf("graphs/combined_boxplots/boxplot_%s_%s.png", lang, dim)
  ggsave(nome_arquivo, plot = p, width = 8, height = 6) 
  print(paste("Saved:", nome_arquivo))

}

print("-------------------------------------------------------")
print("Completed! Check 'scripts/combined_boxplots'.")