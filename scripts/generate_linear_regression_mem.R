suppressPackageStartupMessages({
  library(dplyr)
  library(ggplot2)
  library(readr)
  library(stringr)
})

converte_mem <- function(x) {
  val <- as.numeric(str_extract(x, "[0-9.]+"))
  unit <- str_extract(x, "[a-zA-Z]+")
  mult <- case_when(unit=="GiB"~1024, unit=="MiB"~1, unit=="KiB"~1/1024, TRUE~1/(1024^2))
  return(val * mult)
}


# Make sure the 'scripts/read_csv.R' file exists and the function
# 'read_csv_results()' is defined within it to read your data.
source("scripts/read_csv.R")

dir.create("graphs/linear_regression_mem", showWarnings = FALSE)

# 1. Read the data
dados <- read_csv_performance() 

# 2. Ensure L_num is explicitly treated as a numeric variable
dados <- dados %>%
    mutate(Mem_MiB = converte_mem(MemUsed)) %>%
    group_by(ContainerID, language, dimension) %>%
    summarise(
        L_Value = first(L_Value),
        Mem_Media = mean(Mem_MiB, na.rm = TRUE),
        .groups = 'drop' # <-- Tells dplyr to fully ungroup the output
    ) %>%
    ungroup()

# 3. Determine unique combinations for plotting
combinacoes_grafico <- unique(dados[, c("language", "dimension")])
combinacoes_grafico <- combinacoes_grafico %>% arrange(language, dimension)

# 4. Loop through combinations and generate plots
for (i in 1:nrow(combinacoes_grafico)) {
  
  lang  <- combinacoes_grafico$language[i]
  dim   <- combinacoes_grafico$dimension[i]
  
  dados_subset <- dados %>%
    filter(language == lang, dimension == dim)

  if (nrow(dados_subset) > 0) {
    
    # 🌟 NEW: Get the unique L_num values from the subset to use as axis breaks
    unique_L_values <- sort(unique(dados_subset$L_Value))
    
    p <- ggplot(dados_subset, aes(x = L_Value, y = Mem_Media)) +
        geom_point(alpha = 0.6, color = "darkgreen", size = 2) +
        geom_smooth(method = "lm", formula = y ~ x, color = "black", se = TRUE, fill = "gray80") +
        scale_x_continuous(breaks = unique_L_values) +
        labs(
          title = paste("Regressão Média de Memória:", toupper(lang), toupper(dim)),
          x = "Tamanho do Problema (L)", 
          y = "Memória Média (MiB)"
        ) +
        theme_bw()
    # Save the plot as a PNG file
    nome_arquivo = sprintf("graphs/linear_regression_mem/linear_regression_mem_%s_%sd.png", lang, dim)
    ggsave(filename = nome_arquivo, plot = p, width = 6, height = 4)
    print(paste("Saved:", nome_arquivo))
  }
}

print("-------------------------------------------------------")
cat("Completed! Check 'graphs/linear_regression_mem'.\n\n")