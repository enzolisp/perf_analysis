suppressPackageStartupMessages({
  library(dplyr)
  library(ggplot2)
  library(readr)
})

source("scripts/read_csv.R")

dir.create("graphs/individual_boxplots", showWarnings = FALSE)

df_results <- read_csv_results()

combinations_1 <- unique(df_results[, c("language", "dimension", "Size", "L_Value")])
combinations_1 <- combinations_1 %>% 
  arrange(language, dimension, L_Value)

df_plot <- df_results

for (i in 1:nrow(combinations_1)) {
  
  lang <- combinations_1$language[i]
  dim <- combinations_1$dimension[i]
  sz <- combinations_1$Size[i]
  L <- combinations_1$L_Value[i]
  
  df_subset <- df_plot %>%
    filter(language == lang, dimension == dim, L_Value == L)
  
  color_fill <- if(lang == "python") "#377eb8" else "#984ea3"
  
  p <- ggplot(df_subset, aes(x = "", y = t_exec)) +
    geom_boxplot(fill = color_fill, alpha = 1, width = 0.5, outlier.shape = NA) +
    geom_jitter(width = 0.2, alpha = 0.6, size = 3) + 
    labs(
      title = paste0(toupper(lang)," ", toupper(dim), "D" ," - ", sz, " (L = ", L, ")"),
      subtitle = "Execution Time",
      x = NULL, 
      y = "Time (s)"
    ) +
    theme_minimal() +
    theme(
      plot.title = element_text(face = "bold", size = 16),
      plot.subtitle = element_text(size = 14),
      axis.title.y = element_text(size = 16),
      axis.text.x = element_blank(), 
      axis.text.y = element_text(size = 12),
      axis.ticks.x = element_blank(),
      panel.grid.major.x = element_blank(),
      panel.grid.minor= element_blank()
    )
    
  filename <- sprintf("graphs/individual_boxplots/boxplot_%s_%s_%sd.pdf", lang, sz, dim)
  ggsave(filename, plot = p, width = 6, height = 6)
  print(paste("Saved:", filename))

}

print("-------------------------------------------------------")
cat("Completed! Check 'graphs/individual_boxplots'.\n\n")
