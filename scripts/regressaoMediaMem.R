library(ggplot2)
library(dplyr)
library(readr)
library(stringr)

# Função de conversão
converte_mem <- function(x) {
  val <- as.numeric(str_extract(x, "[0-9.]+"))
  unit <- str_extract(x, "[a-zA-Z]+")
  mult <- case_when(unit=="GiB"~1024, unit=="MiB"~1, unit=="KiB"~1/1024, TRUE~1/(1024^2))
  return(val * mult)
}

# Função de leitura
ler_dados_media <- function(lang, dim) {
  arquivo <- sprintf("%s_%s_performance.csv", lang, dim)
  if (!file.exists(arquivo)) arquivo <- paste0("stats/performance/", arquivo)
  if (!file.exists(arquivo)) return(NULL)
  
  read_csv(arquivo, show_col_types = FALSE) %>%
    mutate(Mem_MiB = converte_mem(MemUsed)) %>%
    group_by(ContainerID) %>%
    summarise(
      L_num = first(L_Value),
      Mem_Media = mean(Mem_MiB, na.rm = TRUE)
    ) %>%
    ungroup()
}

linguagens <- c("python", "julia")
dimensoes  <- c("1d", "2d", "3d")

cat("\n=======================================================\n")
cat("   ANÁLISE DE REGRESSÃO: MÉDIA DE MEMÓRIA\n")
cat("=======================================================\n")

for (lang in linguagens) {
  for (dim in dimensoes) {
    
    dados <- ler_dados_media(lang, dim)
    
    if (!is.null(dados)) {
      # 1. Modelo Estatístico
      modelo <- lm(Mem_Media ~ L_num, data = dados)
      
      # 2. Exibição no Terminal
      cat(sprintf("\n>>> COMBINAÇÃO: %s %s <<<\n", toupper(lang), toupper(dim)))
      print(summary(modelo))
      cat("-------------------------------------------------------\n")
      
      p <- ggplot(dados, aes(x = L_num, y = Mem_Media)) +
        geom_point(alpha = 0.6, color = "darkgreen", size = 2) +
        geom_smooth(method = "lm", formula = y ~ x, color = "black", se = TRUE, fill = "gray80") +
        labs(
          title = paste("Regressão Média de Memória:", toupper(lang), toupper(dim)),
          x = "Tamanho do Problema (L)", 
          y = "Memória Média (MiB)"
        ) +
        theme_bw()
      
      ggsave(sprintf("stats/regressao_media_mem_%s_%s.png", lang, dim), p, width = 6, height = 4)
    }
  }
}
