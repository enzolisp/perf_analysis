suppressPackageStartupMessages({
  library(dplyr)
  library(ggplot2)
  library(readr)
  library(scales)
})

source("scripts/read_csv.R")

dir.create("graphs/control_charts", showWarnings = FALSE, recursive = TRUE)

df_results <- read_csv_results()

combinations_1 <- unique(df_results[, c("language", "dimension", "Size", "L_Value")]) %>%
  arrange(language, dimension, L_Value)

df_plot <- df_results

formatador_seguro <- function(x) {
  sapply(x, function(val) {
    if (is.na(val)) return("")
    if (abs(val) < 0.001 && val != 0) {
      format(val, scientific = TRUE, digits = 4)
    } else {
      format(val, scientific = FALSE, digits = 4)
    }
  })
}

for (i in 1:nrow(combinations_1)) {
  
  lang <- combinations_1$language[i]
  dim <- combinations_1$dimension[i]
  sz <- combinations_1$Size[i]
  L <- combinations_1$L_Value[i]
  
  d_sub <- df_plot %>% 
    filter(language == lang, dimension == dim, Size == sz) %>%
    mutate(Execucao = row_number())
  
  media <- mean(d_sub$t_exec, na.rm = TRUE)
  desvio <- sd(d_sub$t_exec, na.rm = TRUE)
  
  cv <- if(media != 0) (desvio / media) * 100 else 0 
  
  lim_sup <- media + desvio
  lim_inf <- media - desvio
  
  color_fill <- if(lang== "python") "#377eb8" else "#984ea3"
    
  p <- ggplot(d_sub, aes(x = Execucao, y = t_exec)) +
    geom_rect(aes(xmin = -Inf, xmax = Inf, ymin = lim_inf, ymax = lim_sup), fill = "gray90", alpha = 0.5) +
    geom_hline(yintercept = media, color = "red", linetype = "dashed") +
    geom_line(color = color_fill, alpha = 0.7) +
    geom_point(color = color_fill, size = 2) +
    scale_y_continuous(labels = formatador_seguro) +
    labs(
      title = paste0("Control Chart: ", toupper(lang), " ", toupper(dim), "D - ", sz, "(L = ", L, ")"),
      subtitle = sprintf("Mean: %.4g s | CV: %.2f%%", media, cv),
      x = "Number of execution",
      y = "Time (s)"
    ) +
    theme_bw() +
    theme(
      plot.title = element_text(face = "bold", size = 14, hjust = 0), 
      plot.subtitle = element_text(size = 14, hjust = 0), 
      axis.title.x = element_text(size = 16),
      axis.title.y = element_text(size = 16),
      axis.text.x = element_text(size = 12),
      axis.text.y = element_text(size = 14),
      panel.grid.major.x = element_blank()
    )
  
  filename <- sprintf("graphs/control_charts/control_chart_%s_%s_%sd.pdf", lang, sz, dim)
  ggsave(filename, plot = p, width = 8, height = 6)
  print(paste("Saved:", filename))
}

print("-------------------------------------------------------")
cat("Completed! Check 'graphs/control_charts'.\n\n")
