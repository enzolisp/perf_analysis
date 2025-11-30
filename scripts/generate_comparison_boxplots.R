suppressPackageStartupMessages({
  library(dplyr)
  library(ggplot2)
  library(readr)
})

source("scripts/read_csv.R")

dir.create("graphs/comparison_boxplots", showWarnings = FALSE)

df_results <- read_csv_results()

dims <- unique(df_results$dimension)

df_plot <- df_results

dimensions <- unique(df_plot$dimension)

for (dim in dimensions) {
  
  df_subset <- df_plot %>% 
    filter(dimension == dim)
  
  p <- ggplot(df_subset, aes(x = language, y = t_exec, fill = language)) +
    geom_boxplot() +
    geom_jitter(alpha = 0.28, size = 3, position = position_jitterdodge(jitter.width = 0.1, dodge.width = 0.75)) + 
    facet_wrap(~ L_Value, ncol = 3) +
    scale_fill_manual(values = c(python = "#377eb8", julia  = "#984ea3")) +
    labs(
      title = paste0(dim, "D"),
      subtitle = "Execution Time",
      y = "Time (s)",
      x = "Language"
    ) +
    theme_minimal() + 
    theme(legend.position = "none") + 
    theme(
      plot.title = element_text(face = "bold", size = 16, hjust = 0), 
      plot.subtitle = element_text(size = 14, hjust = 0), 
      axis.title.x = element_text(size = 16),
      axis.title.y = element_text(size = 16),
      axis.text.x = element_text(size = 14),
      axis.text.y = element_text(size = 14),
      panel.grid.major.x = element_blank()
    )

  filename <- sprintf("graphs/comparison_boxplots/boxplot_%sd.pdf", dim)
  ggsave(filename, p, width = 12, height = 4, dpi = 300)
  print(paste("Saved:", filename))
}

print("-------------------------------------------------------")
cat("Completed! Check 'graphs/comparison_boxplots.pdf'.\n\n")