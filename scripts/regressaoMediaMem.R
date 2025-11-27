# ==============================================================================
# SCRIPT: Análise de Memória MÉDIA (Docker) vs Tamanho
# ==============================================================================

if (!require("ggplot2")) install.packages("ggplot2")
if (!require("dplyr")) install.packages("dplyr")
if (!require("readr")) install.packages("readr")
if (!require("stringr")) install.packages("stringr")

library(ggplot2)
library(dplyr)
library(readr)
library(stringr)

# 1. Função de Conversão (Igual à anterior)
converte_memoria_para_mib <- function(mem_col) {
  mem_col <- str_trim(mem_col)
  valores <- as.numeric(str_extract(mem_col, "[0-9.]+"))
  unidades <- str_extract(mem_col, "[a-zA-Z]+")
  fator <- case_when(
    unidades == "GiB" ~ 1024,
    unidades == "MiB" ~ 1,
    unidades == "KiB" ~ 1/1024,
    unidades == "B"   ~ 1/(1024*1024),
    TRUE ~ 1
  )
  return(valores * fator)
}

# 2. Função de Leitura
ler_dados_docker_media <- function(lang, dim) {
  arquivo <- sprintf("../stats/performance/%s_%s_performance.csv", lang, dim)
  
  if (!file.exists(arquivo)) {
    warning(paste("Arquivo não encontrado:", arquivo))
    return(NULL)
  }
  
  df <- read_csv(arquivo, show_col_types = FALSE)
  if(nrow(df) == 0) return(NULL)
  
  df <- df %>% mutate(Mem_MiB = converte_memoria_para_mib(MemUsed))
  
  # AGREGAR POR EXECUÇÃO (ContainerID)
  df_agregado <- df %>%
    group_by(ContainerID) %>%
    # Filtro opcional: Remover medições muito baixas (< 1MB) que podem ser startup
    filter(Mem_MiB > 1) %>% 
    summarise(
      Linguagem = first(language),
      Dimensao = first(dimension),
      L_num = first(L_Value),
      
      # AQUI ESTÁ A MUDANÇA: USAMOS MEAN() AO INVÉS DE MAX()
      Memoria_Media_MiB = mean(Mem_MiB, na.rm = TRUE)
    ) %>%
    ungroup()
    
  return(df_agregado)
}

# 3. Configuração
LANG_ALVO <- "python"
DIM_ALVO  <- "3d" # Mude se quiser testar outro

print(paste("Calculando MÉDIA de memória para:", LANG_ALVO, DIM_ALVO))
dados <- ler_dados_docker_media(LANG_ALVO, DIM_ALVO)

if (is.null(dados)) stop("Dados não encontrados.")

# 4. Gerar Gráfico
print("Gerando gráfico...")

p <- ggplot(dados, aes(x = Memoria_Media_MiB, y = L_num)) +
  
  geom_smooth(method = "lm", formula = y ~ x, color = "orange", se = TRUE, fill = "gray60", alpha = 0.4) +

  geom_point(alpha = 0.7, size = 3, color = "#e6550d") +
  
  labs(
    title = paste("Consumo de Memória (Média):", toupper(LANG_ALVO), toupper(DIM_ALVO)),
    subtitle = "Média do uso de RAM durante a execução vs Tamanho L",
    x = "Memória Média (MiB)",
    y = "Tamanho do Problema (L)"
  ) +
  theme_bw()

# Salvar
nome_arquivo <- sprintf("../graphs/memoria_media_%s_%s.png", LANG_ALVO, DIM_ALVO)
ggsave(nome_arquivo, p, width = 8, height = 6)

print(paste("Gráfico salvo em:", nome_arquivo))
