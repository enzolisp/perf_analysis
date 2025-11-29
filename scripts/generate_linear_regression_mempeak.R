suppressPackageStartupMessages({
  library(dplyr)
  library(ggplot2)
  library(readr)
  library(stringr)
})

source("scripts/read_csv.R")

dir.create("graphs/linear_regression_mempeak", showWarnings = FALSE)

dados <- read_csv_results() 

dados <- dados %>%
    mutate(
      L_Value = as.numeric(L_Value),
      Memoria_MiB = as.numeric(peak_mem) / (1024 * 1024)
    )

combinacoes_grafico <- unique(dados[, c("language", "dimension")])
combinacoes_grafico <- combinacoes_grafico %>% arrange(language, dimension)

for (i in 1:nrow(combinacoes_grafico)) {
    
    lang  <- combinacoes_grafico$language[i]
    dim   <- combinacoes_grafico$dimension[i]
    
    dados_subset <- dados %>%
        filter(language == lang, dimension == dim)

    unique_L_values <- sort(unique(dados_subset$L_Value))

    if (!is.null(dados)) {      
      #print(dados_subset)
      p <- ggplot(dados_subset, aes(x = L_Value, y = Memoria_MiB)) +
        geom_jitter(width = if(dim == 1) 250 else if(dim == 2) 50 else 5, height = 0, alpha = 0.6, color = "blue", size = 2) +
        geom_smooth(method = "lm", formula = y ~ x, color = "red", se = TRUE, fill = "gray80") +
        scale_x_continuous(breaks = unique_L_values) +
        labs(
          title = paste("Regressão Pico de Memória:", toupper(lang), toupper(dim)),
          subtitle = "Pontos com jitter horizontal para visualização",
          x = "Tamanho do Problema (L)", 
          y = "Memória Pico (MiB)"
        ) +
        theme_bw()
      
        filename = sprintf("graphs/linear_regression_mempeak/linear_regression_mempeak_%s_%sd.pdf", lang, dim)
        ggsave(filename, p, width = 6, height = 4)
        print(paste("Saved:", filename))
    }
}

print("-------------------------------------------------------")
cat("Completed! Check 'graphs/linear_regression_mempeak'.\n\n")