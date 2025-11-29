suppressPackageStartupMessages({
  library(dplyr)
  library(ggplot2)
  library(readr)
})

source("scripts/read_csv.R")

# Output directory
dir.create("graphs/comparison_boxplots", showWarnings = FALSE)

# Load data
df <- read_csv_results()

# Unique dimensions
dims <- unique(df$dimension)

for (d in dims) {
  
  df_sub <- df %>% filter(dimension == d)
  
  p <- ggplot(df_sub, aes(x = language, y = t_exec, fill = language)) +
    geom_boxplot() +
    geom_jitter(width = 0.1, alpha = 0.5, size = 1.5) + 
    facet_wrap(~ L_Value, ncol = 3) +
    scale_fill_manual(values = c(
      python = "#377eb8",
      julia  = "#984ea3"
    )) +
    labs(
      title = paste("Dimension:", d),
      y = "t_exec",
      x = "Language"
    ) +
    theme_minimal(base_size = 14)
  
  # Output filename
  filename <- sprintf("graphs/comparison_boxplots/boxplot_%sd.png", d)
  
  ggsave(filename, p, width = 12, height = 4, dpi = 300)
}
