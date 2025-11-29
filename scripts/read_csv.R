suppressPackageStartupMessages({
  library(dplyr)
  library(ggplot2)
  library(readr)
})

read_csv_results <- function() {
  
    arquivos <- list.files(
        path = "stats/results/", 
        pattern = "_results\\.csv$",
        full.names = TRUE 
    )
    
    if (length(arquivos) == 0) {
        stop("ERROR: 'results.csv' file found.")
    }
    
    print(paste(length(arquivos), "CSV files found."))
    
    dados_lista <- lapply(arquivos, function(arq) {
        df <- read_csv(arq, show_col_types = FALSE)
        names(df)[names(df) == "L_value"] <- "L_Value"
        names(df)[names(df) == "avg_time"] <- "t_exec"
        
        return(df)
    })
 
    dados_lista <- bind_rows(dados_lista)
    return(dados_lista)
}
