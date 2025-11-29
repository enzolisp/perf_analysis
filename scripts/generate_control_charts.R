suppressPackageStartupMessages({
  library(dplyr)
  library(ggplot2)
  library(readr)
  library(scales)
})

source("scripts/read_csv.R")

dir.create("graphs/control_charts", showWarnings = FALSE, recursive = TRUE)

print("Reading CSVs...")
df <- read_csv_results()
df$t_exec <- as.numeric(df$t_exec)

# Identifica combinações
combinacoes <- unique(df[, c("language", "dimension", "Size", "L_Value")]) %>%
  arrange(language, dimension, L_Value)

print(paste("Generating", nrow(combinacoes), "graphs..."))

# Função segura para formatar os labels do eixo Y
# Resolve o erro "argumento 'scientific' inválido"
formatador_seguro <- function(x) {
  # Aplica a lógica número por número
  sapply(x, function(val) {
    if (is.na(val)) return("")
    # Se for muito pequeno e diferente de zero, usa notação científica
    if (abs(val) < 0.001 && val != 0) {
      format(val, scientific = TRUE, digits = 4)
    } else {
      format(val, scientific = FALSE, digits = 4)
    }
  })
}

for (i in 1:nrow(combinacoes)) {
  lang  <- combinacoes$language[i]
  dim   <- combinacoes$dimension[i]
  sz    <- combinacoes$Size[i]
  l_val <- combinacoes$L_Value[i]
  
  # Filtra e adiciona índice de execução
  d_sub <- df %>% 
    filter(language == lang, dimension == dim, Size == sz) %>%
    mutate(Execucao = row_number())
  
  # Estatísticas
  media <- mean(d_sub$t_exec, na.rm = TRUE)
  desvio <- sd(d_sub$t_exec, na.rm = TRUE)
  # Evita divisão por zero no CV
  cv <- if(media != 0) (desvio / media) * 100 else 0 
  
  lim_sup <- media + desvio
  lim_inf <- media - desvio
  
  cor_main <- if(lang == "python") "#377eb8" else "#984ea3"
  
  # --- PLOT ---
  p <- ggplot(d_sub, aes(x = Execucao, y = t_exec)) +
    
    # 1. Faixa de Desvio Padrão
    geom_rect(aes(xmin = -Inf, xmax = Inf, ymin = lim_inf, ymax = lim_sup),
              fill = "gray90", alpha = 0.5) +
    
    # 2. Linha da Média
    geom_hline(yintercept = media, color = "red", linetype = "dashed") +
    
    # 3. Linha conectando as execuções
    geom_line(color = cor_main, alpha = 0.7) +
    
    # 4. Pontos
    geom_point(color = cor_main, size = 2) +
    
    # Eixo Y Corrigido (Usa a função formatador_seguro)
    scale_y_continuous(labels = formatador_seguro) +
    
    labs(
      title = paste("Estabilidade:", toupper(lang), toupper(dim), "-", sz),
      subtitle = sprintf("L=%s | Média: %.4g s | CV: %.2f%%", l_val, media, cv),
      x = "Número da Execução",
      y = "Tempo de Execução (s)"
    ) +
    
    theme_bw() +
    theme(
      plot.title = element_text(face = "bold", size = 12),
      axis.title = element_text(face = "bold")
    )
  
  nome_arquivo <- sprintf("graphs/control_charts/control_chart_%s_%s_%s.png", lang, dim, sz)
  ggsave(nome_arquivo, plot = p, width = 8, height = 6)
  print(paste("Saved:", nome_arquivo))
}

print("-------------------------------------------------------")
print("Completed! Check 'scripts/control_charts'.")
