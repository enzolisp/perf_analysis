suppressPackageStartupMessages({
  library(dplyr)
  library(ggplot2)
  library(readr)
  library(stringr)
})

source("scripts/read_csv.R")

df_results <- read_csv_results()

df_plot <- df_results

df_plot$L_fator <- factor(df_plot$L_Value, levels = sort(unique(df_plot$L_Value)))

p <- ggplot(df_plot, aes(x = L_fator, y = t_exec, fill = language)) +
  geom_boxplot(alpha = 0.8) +
  geom_jitter(width = 0.15, alpha = 0.28, size = 1.5) + 
  
  facet_grid(language ~ dimension, scales = "free") +
  scale_fill_manual(values = c("julia" = "#984ea3", "python" = "#377eb8")) +
  labs(
    title = "Overview of every experiment",
    subtitle = "Execution Time",
    x = "Problem Size (L)",
    y = "Time (s)"
  ) +
  theme_bw() +
  theme(legend.position = "none") +
  theme( 
    plot.title = element_text(face = "bold", size = 14, hjust = 0), 
    plot.subtitle = element_text(size = 14, hjust = 0), 
    axis.title.x = element_text(size = 16),
    axis.title.y = element_text(size = 16),
    axis.text.x = element_text(size = 14),
    axis.text.y = element_text(size = 14),
    panel.grid.major.x = element_blank()
  )

ggsave("graphs/general_boxplot.pdf", p, width = 12, height = 8)
print("Saved: graphs/general_boxplot.pdf")

print("-------------------------------------------------------")
cat("Completed! Check 'graphs'.\n\n")