library(dplyr)
library(tidyr)

# Function to compute correlation for a single factor and predictor
compute_correlation <- function(filtered_df, f, p) {
  tryCatch({
    test <- cor.test(filtered_df$value, filtered_df[[p]], use = "complete.obs", method = "pearson")
    data.frame(
      factor = f,
      predictor = p,
      p_value = test$p.value,
      r_squared = test$estimate^2
    )
  }, error = function(e) {
    data.frame(
      factor = f,
      predictor = p,
      p_value = NA,
      r_squared = NA
    )
  })
}

# Main wrapper function
run_correlation_analysis <- function(df, predictors) {
  cor_results <- list()
  
  for (f in unique(df$factor)) {
    filtered_df <- df %>% filter(factor == f)
    
    for (p in predictors) {
      cor_results[[length(cor_results) + 1]] <- compute_correlation(filtered_df, f, p)
    }
  }
  
  cor_df <- bind_rows(cor_results)
  
  cor_df <- cor_df %>%
    mutate(significance = case_when(
      is.na(p_value) ~ "NA",
      p_value < 0.05 ~ "*",
      TRUE ~ "ns"
    ))
  
  cor_df %>%
    select(factor, predictor, significance) %>%
    pivot_wider(names_from = predictor, values_from = significance)
}


run_kruskal_tests <- function(df, group_vars) {
  results <- list()
  
  for (f in unique(df$factor)) {
    filtered_df <- df %>% filter(factor == f)
    
    for (g in group_vars) {
      test_result <- tryCatch({
        test <- kruskal.test(as.formula(paste("value ~", g)), data = filtered_df)
        data.frame(
          factor = f,
          group_var = g,
          p_value = test$p.value
        )
      }, error = function(e) {
        data.frame(
          factor = f,
          group_var = g,
          p_value = NA
        )
      })
      
      results[[length(results) + 1]] <- test_result
    }
  }
  
  kruskal_results <- bind_rows(results) %>%
    mutate(significance = case_when(
      is.na(p_value) ~ "NA",
      p_value < 0.05 ~ "*",
      TRUE ~ "ns"
    ))
  
  significance_table <- kruskal_results %>%
    select(factor, group_var, significance) %>%
    pivot_wider(names_from = group_var, values_from = significance)
  
  return(significance_table)
}
