#instala os pacotes necessarios
if (!require("ggplot2")) install.packages("ggplot2")
if (!require("dplyr")) install.packages("dplyr")
if (!require("readr")) install.packages("readr")

library(ggplot2)
library(dplyr)
library(readr)

ler_dados_resultados <- function(lang, dim) {
  arquivo <- sprintf("stats/results/%s_%s_results.csv", lang, dim)
  
  if (file.exists(arquivo)) {
    df <- read_csv(arquivo, show_col_types = FALSE)
    
    if(nrow(df) == 0) return(NULL)

    df <- df %>%
      mutate(
        Linguagem = lang,
        Dimensao = toupper(dim),
        
        L_num = as.numeric(L_Value),
        L_fator = as.factor(L_Value),
        
        Tempo = as.numeric(t_exec)
      )
    
    df$L_fator <- factor(df$L_fator, levels = sort(unique(df$L_num)))
    
    return(df)
  } else {
    warning(paste("Arquivo não encontrado (pode ser normal se não rodou):", arquivo))
    return(NULL)
  }
}

#carregando dados
print("Carregando arquivos de resultados...")

#le todas as combinações posssives
dados_lista <- list(
  ler_dados_resultados("python", "1d"),
  ler_dados_resultados("python", "2d"),
  ler_dados_resultados("python", "3d"),
  ler_dados_resultados("julia", "1d"),
  ler_dados_resultados("julia", "2d"),
  ler_dados_resultados("julia", "3d")
)

#remove casos que não rodaram e junta tudo
dados_gerais <- bind_rows(dados_lista)

if(nrow(dados_gerais) == 0) {
  stop("Nenhum dado encontrado em stats/results/. Verifique se o experimento rodou.")
}

dados_gerais$Dimensao <- factor(dados_gerais$Dimensao, levels = c("1D", "2D", "3D"))

dir.create("stats/graficos", showWarnings = FALSE)
dir.create("stats/graficos/individuais", showWarnings = FALSE)

print("Dados carregados. Gerando gráficos...")

#GRÁFICOS AGRUPADOS (Linguagem + Dimensão, variando L)
combinacoes <- unique(dados_gerais[, c("Linguagem", "Dimensao")])

for(i in 1:nrow(combinacoes)) {
  lang <- combinacoes$Linguagem[i]
  dim  <- combinacoes$Dimensao[i]
  
  dados_subset <- dados_gerais %>%
    filter(Linguagem == lang, Dimensao == dim)
  
  cor_fill <- if(lang == "python") "#377eb8" else "#984ea3"
  
  p <- ggplot(dados_subset, aes(x = L_fator, y = Tempo)) +
    geom_boxplot(fill = cor_fill, alpha = 0.7) +
    geom_jitter(width = 0.1, size = 2, alpha = 0.6) +
    labs(
      title = sprintf("Desempenho: %s em %s", toupper(lang), dim),
      subtitle = "Distribuição do Tempo de Execução por Tamanho (L)",
      x = "Tamanho do Problema (L)",
      y = "Tempo Total (s)"
    ) +
    theme_bw() +
    theme(axis.text = element_text(size = 12))
  
  nome_arq <- sprintf("stats/graficos/individuais/boxplot_%s_%s.png", lang, tolower(dim))
  ggsave(nome_arq, p, width = 8, height = 6)
  print(paste("Salvo:", nome_arq))
}

#coloca tudo numa imagem só para comparação rápida
p_geral <- ggplot(dados_gerais, aes(x = L_fator, y = Tempo, fill = Linguagem)) +
  geom_boxplot(alpha = 0.8) +
  # divide os gráficos Scales="free"
  facet_grid(Linguagem ~ Dimensao, scales = "free") +
  scale_fill_manual(values = c("julia" = "#984ea3", "python" = "#377eb8")) +
  labs(
    title = "Visão Geral de Desempenho (Todos os Experimentos)",
    subtitle = "Comparação de Tempo de Execução (Eixos independentes)",
    x = "Tamanho L",
    y = "Tempo (s)"
  ) +
  theme_bw() +
  theme(legend.position = "bottom")

ggsave("stats/graficos/painel_geral.png", p_geral, width = 12, height = 8)
print("Salvo: stats/graficos/painel_geral.png")

#comparativo lado a lado, para ver Python vs Julia na mesma escala
p_comp <- ggplot(dados_gerais, aes(x = L_fator, y = Tempo, fill = Linguagem)) +
  geom_boxplot() +
  facet_wrap(~Dimensao, scales = "free", ncol = 3) +
  scale_fill_manual(values = c("julia" = "#984ea3", "python" = "#377eb8")) +
  labs(
    title = "Python vs Julia: Comparativo Direto",
    x = "Tamanho L",
    y = "Tempo (s)"
  ) +
  theme_bw()

ggsave("stats/graficos/comparativo_lado_a_lado.png", p_comp, width = 12, height = 6)
print("Salvo: stats/graficos/comparativo_lado_a_lado.png")

print("Concluído!")
