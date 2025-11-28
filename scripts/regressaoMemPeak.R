library(ggplot2)
library(dplyr)
library(readr)

# Função de leitura
ler_dados <- function(lang, dim) {
  arquivo <- sprintf("%s_%s_results.csv", lang, dim)
  if (!file.exists(arquivo)) arquivo <- paste0("stats/results/", arquivo)
  if (!file.exists(arquivo)) return(NULL)
  
  read_csv(arquivo, show_col_types = FALSE) %>%
    mutate(
      L_num = as.numeric(L_Value),
      Memoria_MiB = as.numeric(peak_mem) / (1024 * 1024)
    )
}

dir.create("graphs/graficos_regressaoMemPeak", showWarnings = FALSE)

# Definição das combinações
linguagens <- c("python", "julia")
dimensoes  <- c("1d", "2d", "3d")

cat("\n=======================================================\n")
cat("   ANÁLISE DE REGRESSÃO: PICO DE MEMÓRIA (PEAK MEMORY)\n")
cat("=======================================================\n")

for (lang in linguagens) {
  for (dim in dimensoes) {
    
    dados <- ler_dados(lang, dim)
    
    if (!is.null(dados)) {
      # 1. Modelo Estatístico
      modelo <- lm(Memoria_MiB ~ L_num, data = dados)
      
      # 2. Exibição no Terminal
      cat(sprintf("\n>>> COMBINAÇÃO: %s %s <<<\n", toupper(lang), toupper(dim)))
      print(summary(modelo))
      cat("-------------------------------------------------------\n")
      
      p <- ggplot(dados, aes(x = L_num, y = Memoria_MiB)) +
        geom_point(alpha = 0.6, color = "darkblue", size = 2) +
        geom_smooth(method = "lm", formula = y ~ x, color = "red", se = TRUE, fill = "gray80") +
        labs(
          title = paste("Regressão Pico de Memória:", toupper(lang), toupper(dim)),
          subtitle = "Pontos com jitter horizontal para visualização",
          x = "Tamanho do Problema (L)", 
          y = "Memória Pico (MiB)"
        ) +
        theme_bw()
      
      ggsave(sprintf("graphs/graficos_regressaoMemPeak/regressao_peak_mem_%s_%s.png", lang, dim), p, width = 6, height = 4)
    
    }
  }
}
