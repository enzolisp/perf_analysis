suppressPackageStartupMessages({
  library(dplyr)
  library(ggplot2)
  library(readr)
})

# Make sure the 'scripts/read_csv.R' file exists and the function
# 'read_csv_results()' is defined within it to read your data.
source("scripts/read_csv.R")

dir.create("graphs/linear_regression_texec", showWarnings = FALSE)

# 1. Read the data
dados <- read_csv_results() 

# 2. Ensure L_num is explicitly treated as a numeric variable
dados <- dados %>%
  mutate(L_Value = as.numeric(L_Value))

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
    
    cor_fill <- if(lang == "python") "#377eb8" else "#984ea3" 

    p <- ggplot(dados_subset, aes(x = L_Value, y = t_exec)) +
      # Scatter plot of the data points
      geom_jitter(width = if(dim == 1) 250 else if(dim == 2) 50 else 5, height = 0, alpha = 0.6, color = "blue", size = 2) +
      
      # Add the Linear Regression Line
      geom_smooth(method = "lm", formula = y ~ x, color = cor_fill, se = TRUE, fill = "gray80") +
      
      # 🌟 THE FIX IS HERE: Set the axis breaks to only the L_num values present in the data
      scale_x_continuous(breaks = unique_L_values) +
      
      # Labels and Titles
      labs(
        title = paste("Regressão Tempo:", toupper(lang), toupper(dim)),
        subtitle = "Tempo de Execução vs Tamanho do Problema (L)",
        x = "Tamanho L",
        y = "Tempo (s)"
      ) +
      
      # Use a clean, black-and-white theme
      theme_bw()
    
    # Save the plot as a pdf file
    nome_arquivo = sprintf("graphs/linear_regression_texec/linear_regression_texec_%s_%sd.pdf", lang, dim)
    ggsave(
      filename = sprintf("graphs/linear_regression_texec/linear_regression_texec_%s_%sd.pdf", lang, dim), 
      plot = p, 
      width = 6, 
      height = 4
    )
    print(paste("Saved:", nome_arquivo))
  }
}

print("-------------------------------------------------------")
cat("Completed! Check 'graphs/linear_regression_texec'.\n\n")