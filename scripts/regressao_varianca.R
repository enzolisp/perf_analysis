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
      Tempo = as.numeric(t_exec)
    )
}

dir.create("graphs/graficos_regressao", showWarnings = FALSE)

linguagens <- c("python", "julia")
dimensoes  <- c("1d", "2d", "3d")

cat("\n=======================================================\n")
cat("   ANÁLISE DE REGRESSÃO: TEMPO DE EXECUÇÃO\n")
cat("=======================================================\n")

for (lang in linguagens) {
  for (dim in dimensoes) {
    
    dados <- ler_dados(lang, dim)
    
    if (!is.null(dados)) {
      # 1. Modelo Estatístico
      modelo <- lm(Tempo ~ L_num, data = dados)
      
      # 2. Exibição no Terminal
      cat(sprintf("\n>>> COMBINAÇÃO: %s %s <<<\n", toupper(lang), toupper(dim)))
      print(summary(modelo))
      cat("-------------------------------------------------------\n")
      
      p <- ggplot(dados, aes(x = L_num, y = Tempo)) +
        geom_point(alpha = 0.6, color = "blue", size = 2) +
        geom_smooth(method = "lm", formula = y ~ x, color = "red", se = TRUE, fill = "gray80") +
        labs(
          title = paste("Regressão Tempo:", toupper(lang), toupper(dim)),
          subtitle = "Tempo de Execução vs Tamanho do Problema (L)",
          x = "Tamanho L",
          y = "Tempo (s)"
        ) +
        theme_bw()
      
      ggsave(sprintf("graphs/graficos_regressao/regressao_%s_%s.png", lang, dim), p, width = 6, height = 4)
    
    }
  }
}
