library(ggplot2)
library(dplyr)
library(readr)

dir.create("graphs/combined_boxplots", showWarnings = FALSE)

# --- Data Loading Function (No change needed here) ---
carregar_tudo_local <- function() {
  
  arquivos <- list.files(
    path = "stats/results/", 
    pattern = "_results\\.csv$",
    full.names = TRUE 
  )
  
  if (length(arquivos) == 0) {
    stop("ERRO: Nenhum arquivo '_results.csv' encontrado neste diretório.")
  }
  
  print(paste(length(arquivos), "CSV files found."))
  
  dados_lista <- lapply(arquivos, function(arq) {
    df <- read_csv(arq, show_col_types = FALSE)

    names(df)[names(df) == "L_value"] <- "L_Value"
    names(df)[names(df) == "avg_time"] <- "t_exec"
    
    return(df)
  })
  
  bind_rows(dados_lista)
}

print("Reading CSVs...")
dados <- carregar_tudo_local()

dados$L_Value <- as.numeric(dados$L_Value)
dados$t_exec <- as.numeric(dados$t_exec)

# --- Define New Combinations (Only language and dimension) ---
# We will generate a graph for each unique (language, dimension) pair.
combinacoes_grafico <- unique(dados[, c("language", "dimension")])
combinacoes_grafico <- combinacoes_grafico %>% arrange(language, dimension)

print(paste("Generating", nrow(combinacoes_grafico), "graphs..."))


for (i in 1:nrow(combinacoes_grafico)) {
  
  lang  <- combinacoes_grafico$language[i]
  dim   <- combinacoes_grafico$dimension[i]
  
  # --- 2. Filter the Data ---
  # Filters the main dataset 'dados' for the current combination, keeping ALL L_Value and Size data.
  dados_subset <- dados %>%
    filter(language == lang, dimension == dim)
  
  # Set colors
  cor_fill <- if(lang == "python") "#377eb8" else "#984ea3" # Blue for Python, Purple for Julia
  
  # --- 3. Create the Boxplot (L_Value on X-axis) ---
  # We use L_Value as the grouping factor on the X-axis.
  p <- ggplot(dados_subset, aes(x = factor(L_Value), y = t_exec)) + 
    
    # Boxplot and Jitter (Scatter points)
    # The 'fill' mapping is now outside aes() as the color is fixed by the outer loop,
    # OR you could map 'Size' to fill if you want to differentiate by Size within the graph.
    # We will use Size to differentiate the color/fill in the final plot.
    geom_boxplot(fill = cor_fill, alpha = 0.7, outlier.color = "red") + 
    geom_jitter(width = 0.1, alpha = 0.5, size = 1.5) + 
    
    # Optional: If you want to use the single color:
    # geom_boxplot(fill = cor_fill, alpha = 0.7, outlier.color = "red") + 
    
    # Labels and Title
    labs(
      title = paste("Performance:", toupper(lang), "in", toupper(dim)),
      subtitle = "Distribution of Execution Time by Problem Size (L)",
      x = "Problem Size (L)", 
      y = "Time (s)",
    ) +
    
    # Theme adjustments
    theme_bw() +
    theme(
      plot.title = element_text(face = "bold", size = 16, hjust = 0), # Left-aligned like example
      plot.subtitle = element_text(hjust = 0), # Left-aligned like example
      axis.text.x = element_text(size = 12),
      panel.grid.major.x = element_blank()
    )
  
  
  # --- 4. Save the Plot ---
  # Saves 6 graphs total (e.g., boxplot_julia_1d.png)
  nome_arquivo <- sprintf("graphs/combined_boxplots/boxplot_%s_%s.png", lang, dim)
  ggsave(nome_arquivo, plot = p, width = 8, height = 6) 
  print(paste("Saved:", nome_arquivo))

}