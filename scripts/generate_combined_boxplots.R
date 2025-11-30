suppressPackageStartupMessages({
  library(dplyr)
  library(ggplot2)
  library(readr)
})

source("scripts/read_csv.R")

dir.create("graphs/combined_boxplots", showWarnings = FALSE)

df_results <- read_csv_results()

combinations_1 <- unique(df_results[, c("language", "dimension")])
combinations_1 <- combinations_1 %>% 
  arrange(language, dimension)

df_plot <- df_results

for (i in 1:nrow(combinations_1)) {
  
  lang <- combinations_1$language[i]
  dim <- combinations_1$dimension[i]
  sz <- combinations_1$Size[i]
  L <- combinations_1$L_Value[i]

  df_subset <- df_plot %>%
    filter(language == lang, dimension == dim)
  
  color_fill <- if(lang == "python") "#377eb8" else "#984ea3" 
  
  p <- ggplot(df_subset, aes(x = factor(L_Value), y = t_exec)) + 
    geom_boxplot(fill = color_fill, alpha = 0.7) + 
    geom_jitter(width = 0.15, alpha = 0.28, size = 1.8) + 
    labs(
      title = paste0(toupper(lang), " ", toupper(dim), "D - ", sz, " (L_Value = ", L, ")"),
      subtitle = "Distribution of Execution Time by Problem Size (L)",
      x = "Problem Size (L)", 
      y = "Time (s)",
    ) +
    theme_minimal() +
    theme(
      plot.title = element_text(face = "bold", size = 16, hjust = 0), 
      plot.subtitle = element_text(size = 14, hjust = 0), 
      axis.title.x = element_text(size = 16),
      axis.title.y = element_text(size = 16),
      axis.text.x = element_text(size = 14),
      axis.text.y = element_text(size = 14),
      panel.grid.major.x = element_blank()
    )
  
  filename <- sprintf("graphs/combined_boxplots/boxplot_%s_%sd.pdf", lang, dim)
  ggsave(filename, plot = p, width = 8, height = 6) 
  print(paste("Saved:", filename))

}

print("-------------------------------------------------------")
cat("Completed! Check 'graphs/combined_boxplots'.\n\n")