suppressPackageStartupMessages({
  library(dplyr)
  library(ggplot2)
  library(readr)
  library(stringr)
})

source("scripts/read_csv.R")

dir.create("graphs/linear_regression_mempeak", showWarnings = FALSE)

df_results <- read_csv_results() 

df_results <- df_results %>%
    mutate(
      L_Value = as.numeric(L_Value),
      Memoria_MiB = as.numeric(peak_mem) / (1024 * 1024)
    )

combinations_2 <- unique(df_results[, c("language", "dimension")])
combinations_2 <- combinations_2 %>% 
  arrange(language, dimension)

df_plot <- df_results

df_plot <- df_plot %>%
    mutate(
      L_Value = as.numeric(L_Value),
      Memoria_MiB = as.numeric(peak_mem) / (1024 * 1024)
    )

for (i in 1:nrow(combinations_2)) {
    
    lang  <- combinations_2$language[i]
    dim   <- combinations_2$dimension[i]
    
    dados_subset <- df_plot %>%
        filter(language == lang, dimension == dim)

    unique_L_values <- sort(unique(dados_subset$L_Value))

    color_fill <- if(lang == "python") "#377eb8" else "#984ea3" 

    p <- ggplot(dados_subset, aes(x = L_Value, y = Memoria_MiB)) +
    geom_jitter(width = if(dim == 1) 250 else if(dim == 2) 50 else 5, height = 0, alpha = 0.35, color = "black", size = 2) +
    geom_smooth(method = "lm", formula = y ~ x, color = color_fill, se = TRUE, fill = "gray80") +
    scale_x_continuous(breaks = unique_L_values) +
    labs(
        title = paste0("Linear regression: ", toupper(lang), " - ", toupper(dim), "D"),
        subtitle = "Memory Peak (MiB) vs Problem size (L)",
        x = "Problem Size (L)", 
        y = "Memory Peak (MiB)"
    ) +
    theme_bw() + 
    theme(
            plot.title = element_text(face = "bold", size = 16, hjust = 0), 
            plot.subtitle = element_text(size = 14, hjust = 0), 
            axis.title.x = element_text(size = 16),
            axis.title.y = element_text(size = 16),
            axis.text.x = element_text(size = 14),
            axis.text.y = element_text(size = 14),
            panel.grid.major.x = element_blank()
        )
          
      filename = sprintf("graphs/linear_regression_mempeak/linear_regression_mempeak_%s_%sd.pdf", lang, dim)
      ggsave(filename, p, width = 6, height = 4)
      print(paste("Saved:", filename))
}


print("-------------------------------------------------------")
cat("Completed! Check 'graphs/linear_regression_mempeak'.\n\n")