read_input_files <- function(input_dir, files) {
  read_and_process <- function(filename) {
    read.csv(file.path(input_dir, filename), stringsAsFactors = FALSE) %>% 
      column_to_rownames('PID') %>%
      scale()
  }

  data_list <- list()
  for (file in files) {
    var_name <- file %>%
      str_remove(".csv") %>%
      str_replace_all(" ", "_") %>%
      str_replace_all("\\(|\\)", "")
    
    mat <- read_and_process(file)

    if (var_name %in% c("sc_PT_44", "somascan_plasma_44")) {
      variances <- apply(mat, 2, var, na.rm = TRUE)
      top_features <- order(variances, decreasing = TRUE)[1:ceiling(0.3 * length(variances))]
      mat <- mat[, top_features, drop = FALSE]
    }

    data_list[[var_name]] <- mat
  }
  return(data_list)
}
