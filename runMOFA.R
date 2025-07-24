library(yaml)
source("R/setup_env.R")
source("R/read_inputs.R")
source("R/prepare_data.R")
source("R/build_mofa_model.R")
source("R/plot_utils.R")
source("R/correlation_utils.R")

cfg <- yaml::read_yaml("config.yml")

if (!dir.exists(cfg$output_dir)) {
  dir.create(cfg$output_dir)
}

setup_environment(cfg$python_path, cfg$conda_env)
data_list <- read_input_files(cfg$input_dir, cfg$files)
view_list <- prepare_mofa_views(data_list, cfg$view_names)

MOFAobject <- build_and_run_mofa(view_list, cfg$view_names, cfg$output_file)

# plot_factor_cor(MOFAobject)

p<- plot_variance_explained2(MOFAobject, plot_total = TRUE)[[2]] +
  geom_hline(yintercept = 65.2, linetype = "dashed", color = "red") +
  annotate("text", x = Inf, y = 65.2, label = "65%", hjust = 1.1, vjust = -0.5, color = "red")

p2<- plot_variance_explained(
  MOFAobject,
  x = "view",
  y = "factor",
  max_r2 = 20,
  plot_total = TRUE
)[[1]] + theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1))

ggsave(filename = cfg$output_plot, plot = p, width = 10, height = 10)
ggsave(filename = cfg$output_plot2, plot = p2, width = 10, height = 10)

library(MOFA2)
library(tidyverse)

mofa_model <- load_model(cfg$output_file)
sample_annot <- read.csv(cfg$clinical_file)
factors <- get_factors(mofa_model, factors = "all", as.data.frame = TRUE)

# print(factors)
# print(sample_annot)

factors_annotated <- left_join(factors, sample_annot, by = "sample")

write.csv(factors_annotated, cfg$factors_filtered, row.names = FALSE)

df <- read.csv(cfg$factors_filtered, na.strings = c("", "NA"))

predictors <- cfg$contineous_predictors

cor_significance_table <- run_correlation_analysis(df, predictors)

write.csv(cor_significance_table, cfg$output_correlation_file, row.names = FALSE)

print(cor_significance_table)

significance_table <- run_kruskal_tests(df, cfg$categorical_predictors)
print(significance_table)

write.csv(significance_table, cfg$output_correlation_file2, row.names = FALSE)

