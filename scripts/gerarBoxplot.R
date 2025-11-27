# ==============================================================================
# SCRIPT: Gerar 18 Boxplots Individuais (Lendo do diretório atual)
# ==============================================================================

if (!require("ggplot2")) install.packages("ggplot2")
if (!require("dplyr")) install.packages("dplyr")
if (!require("readr")) install.packages("readr")

library(ggplot2)
library(dplyr)
library(readr)

# Cria uma pasta para organizar a saída (para não misturar com os scripts)
dir.create("../graphs/graficos_individuais", showWarnings = FALSE)

# 1. Carregar todos os arquivos _results.csv do diretório ATUAL
carregar_tudo_local <- function() {
  # Procura arquivos no padrão "algo_algo_results.csv" na pasta atual (.)
  arquivos <- list.files(pattern = "../stats/results/_results\\.csv$")
  
  if (length(arquivos) == 0) {
    stop("ERRO: Nenhum arquivo '_results.csv' encontrado neste diretório.")
  }
  
  print(paste("Encontrados", length(arquivos), "arquivos CSV."))
  
  dados_lista <- lapply(arquivos, function(arq) {
    # Lê o CSV silenciosamente
    df <- read_csv(arq, show_col_types = FALSE)
    
    # Padronização de nomes de coluna (caso haja versões antigas misturadas)
    # Garante que tenhamos 'L_Value', 't_exec' e 'Size'
    names(df)[names(df) == "L_value"] <- "L_Value"
    names(df)[names(df) == "avg_time"] <- "t_exec"
    
    return(df)
  })
  
  bind_rows(dados_lista)
}

# Carrega os dados
print("Lendo CSVs...")
dados <- carregar_tudo_local()

# Garante tipos corretos
dados$L_Value <- as.numeric(dados$L_Value)
dados$t_exec <- as.numeric(dados$t_exec)

# 2. Identificar as 18 combinações únicas
combinacoes <- unique(dados[, c("language", "dimension", "Size", "L_Value")])

# Ordenar para processar em ordem lógica (1d -> 2d -> 3d)
combinacoes <- combinacoes %>% arrange(language, dimension, L_Value)

print(paste("Gerando", nrow(combinacoes), "gráficos individuais..."))

# 3. Loop para gerar e salvar cada gráfico
for (i in 1:nrow(combinacoes)) {
  
  lang  <- combinacoes$language[i]
  dim   <- combinacoes$dimension[i]
  sz    <- combinacoes$Size[i]
  l_val <- combinacoes$L_Value[i]
  
  # Filtra APENAS os dados dessa configuração específica
  dados_subset <- dados %>%
    filter(language == lang, dimension == dim, Size == sz)
  
  # Define cor (Azul para Python, Roxo para Julia)
  cor_fill <- if(lang == "python") "#377eb8" else "#984ea3"
  
  # Cria o gráfico (Eixo X vazio, pois é um único boxplot)
  p <- ggplot(dados_subset, aes(x = "", y = t_exec)) +
    geom_boxplot(fill = cor_fill, alpha = 0.7, width = 0.5, outlier.color = "red") +
    geom_jitter(width = 0.05, alpha = 0.6, size = 3) + # Mostra os pontos individuais
    
    labs(
      title = paste(toupper(lang), toupper(dim), "-", sz, "(L =", l_val, ")"),
      subtitle = "Tempo de Execução (s)",
      x = "", # Sem título no eixo X
      y = "Tempo (s)"
    ) +
    theme_bw() +
    theme(
      plot.title = element_text(face = "bold", size = 14),
      axis.text.x = element_blank(), # Remove texto do eixo X
      axis.ticks.x = element_blank(), # Remove ticks do eixo X
      panel.grid.major.x = element_blank()
    )
  
  # Nome do arquivo organizado
  nome_arquivo <- sprintf("../graphs/graficos_individuais/boxplot_%s_%s_%s.png", lang, dim, sz)
  
  ggsave(nome_arquivo, plot = p, width = 6, height = 6)
  print(paste("Salvo:", nome_arquivo))
}

print("-------------------------------------------------------")
print("Concluído! Verifique a pasta 'graficos_individuais'.")
