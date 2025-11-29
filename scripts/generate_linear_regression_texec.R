suppressPackageStartupMessages({
  library(dplyr)
  library(ggplot2)
  library(readr)
})

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

dir.create("graphs/linear_regression_texec", showWarnings = FALSE)

linguagens <- c("python", "julia")
dimensoes  <- c("1d", "2d", "3d")

for (lang in linguagens) {
  for (dim in dimensoes) {
    
    dados <- ler_dados(lang, dim)
    
    if (!is.null(dados)) {

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
      
      ggsave(sprintf("graphs/linear_regression_texec/linear_regression_texec_%s_%sd.png", lang, dim), p, width = 6, height = 4)
    
    }
  }
}