suppressPackageStartupMessages({
  library(dplyr)
  library(ggplot2)
  library(readr)
})

read_csv_results <- function() {
  
    print("Reading CSVs...")

    files <- c(
        "stats/results/julia_1d_results.csv",
        "stats/results/julia_2d_results.csv",
        "stats/results/julia_3d_results.csv",
        "stats/results/python_1d_results.csv",
        "stats/results/python_2d_results.csv",
        "stats/results/python_3d_results.csv"
    )
    
    if (length(files) == 0) {
        stop("ERROR: 'results.csv' file found.")
    }
    
    print(paste(length(files), "CSV files found."))
    
    df_list <- lapply(files, function(arq) {
        df <- read_csv(arq, show_col_types = FALSE)        
        return(df)
    })
 
    df_list <- bind_rows(df_list)
    return(df_list)
}

read_csv_performance <- function() {
    
    print("Reading CSVs...")

    files <- c(
        "stats/performance/julia_1d_performance.csv",
        "stats/performance/julia_2d_performance.csv",
        "stats/performance/julia_3d_performance.csv",
        "stats/performance/python_1d_performance.csv",
        "stats/performance/python_2d_performance.csv",
        "stats/performance/python_3d_performance.csv"
    )
    
    if (length(files) == 0) {
        stop("ERROR: 'performance.csv' file found.")
    }
    
    print(paste(length(files), "CSV files found."))
    
    df_list <- lapply(files, function(arq) {
        df <- read_csv(arq, show_col_types = FALSE)        
        return(df)
    })
 
    df_list <- bind_rows(df_list)
    return(df_list)
}
