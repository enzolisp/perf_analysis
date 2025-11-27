# ==============================================================================
# SCRIPT: Análise de Regressão (Corrigido e sem Avisos)
# ==============================================================================

if (!require("ggplot2")) install.packages("ggplot2")
if (!require("dplyr")) install.packages("dplyr")
if (!require("readr")) install.packages("readr")

library(ggplot2)
library(dplyr)
library(readr)

# 1. Função de Leitura
ler_dados <- function(lang, dim) {
  arquivo <- sprintf("stats/results/%s_%s_results.csv", lang, dim)
  
  if (!file.exists(arquivo)) {
    warning(paste("Arquivo não encontrado:", arquivo))
    return(NULL)
  }
  
  df <- read_csv(arquivo, show_col_types = FALSE)
  
  df <- df %>%
    mutate(
      Linguagem = lang,
      Dimensao = toupper(dim),
      L_num = as.numeric(L_Value),
      Tempo = as.numeric(t_exec)
    )
  return(df)
}

# 2. Configuração
LANG_ALVO <- "python"
DIM_ALVO  <- "3d"

print(paste("Carregando dados para:", LANG_ALVO, DIM_ALVO))
dados <- ler_dados(LANG_ALVO, DIM_ALVO)

if (is.null(dados)) stop("Dados não encontrados.")

# 3. Modelo Linear
modelo <- lm(Tempo ~ L_num, data = dados)
print("--- Resumo do Modelo Linear ---")
print(summary(modelo))

# 4. Gráfico Limpo
p1 <- ggplot(dados, aes(x = L_num, y = Tempo)) +
  geom_point(alpha = 0.6, color = "blue", size = 2) +
  
  # CORREÇÕES AQUI:
  # 1. Adicionado 'formula = y ~ x' para silenciar o aviso da fórmula
  # 2. Alterado 'size' para 'linewidth' (o novo padrão do ggplot2)
  geom_smooth(method = "lm", formula = y ~ x, color = "red", se = TRUE, fill = "gray80", linewidth = 1) +
  
  labs(
    title = paste("Regressão Linear:", toupper(LANG_ALVO), toupper(DIM_ALVO)),
    subtitle = "Tempo de Execução vs Tamanho do Problema (L)",
    x = "Tamanho L",
    y = "Tempo (s)"
  ) +
  theme_bw() +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    axis.text = element_text(size = 12)
  )

nome_p1 <- sprintf("stats/regressao_%s_%s.png", LANG_ALVO, DIM_ALVO)
ggsave(nome_p1, p1, width = 8, height = 6)

print(paste("Gráfico salvo sem avisos em:", nome_p1))
