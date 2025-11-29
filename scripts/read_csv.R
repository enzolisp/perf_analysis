suppressPackageStartupMessages({
  library(dplyr)
  library(ggplot2)
  library(readr)
})

read_csv_results <- function() {
  
    files <- list.files(
        path = "stats/results/", 
        pattern = "_results\\.csv$",
        full.names = TRUE 
    )
    
    if (length(files) == 0) {
        stop("ERROR: 'results.csv' file found.")
    }
    
    print(paste(length(files), "CSV files found."))
    
    df_list <- lapply(files, function(arq) {
        df <- read_csv(arq, show_col_types = FALSE)
        names(df)[names(df) == "L_value"] <- "L_Value"
        names(df)[names(df) == "avg_time"] <- "t_exec"
        
        return(df)
    })
 
    df_list <- bind_rows(df_list)
    return(df_list)
}

read_csv_performance <- function() {
  
    files <- list.files(
        path = "stats/performance/", 
        pattern = "_performance\\.csv$",
        full.names = TRUE 
    )
    
    if (length(files) == 0) {
        stop("ERROR: 'performance.csv' file found.")
    }
    
    print(paste(length(files), "CSV files found."))
    
    df_list <- lapply(files, function(arq) {
        df <- read_csv(arq, show_col_types = FALSE)
        #names(df)[names(df) == "L_value"] <- "L_Value"
        #names(df)[names(df) == "avg_time"] <- "t_exec"
        
        return(df)
    })
 
    df_list <- bind_rows(df_list)
    return(df_list)
}
