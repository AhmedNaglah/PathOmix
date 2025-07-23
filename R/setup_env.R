setup_environment <- function(python_path, conda_env) {
  library(MOFA2)
  library(tidyverse)
  library(reticulate)

  use_python(python_path)
  reticulate::use_condaenv(conda_env, required = FALSE)

  cat("✔ Environment configured.\n")
  reticulate::py_config()
}