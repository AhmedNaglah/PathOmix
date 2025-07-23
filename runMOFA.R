library(yaml)
source("R/setup_env.R")
source("R/read_inputs.R")
source("R/prepare_data.R")
source("R/build_mofa_model.R")
source("R/plot_utils.R")

cfg <- yaml::read_yaml("config.yml")

setup_environment(cfg$python_path, cfg$conda_env)
data_list <- read_input_files(cfg$input_dir, cfg$files)
view_list <- prepare_mofa_views(data_list, cfg$view_names)

MOFAobject <- build_and_run_mofa(view_list, cfg$view_names, cfg$output_file)

p <- plot_variance_explained2(MOFAobject, plot_total = TRUE)[[2]] +
  geom_hline(yintercept = 65.2, linetype = "dashed", color = "red") +
  annotate("text", x = Inf, y = 65.2, label = "65%", hjust = 1.1, vjust = -0.5, color = "red")

ggsave(filename = cfg$output_plot, plot = p, width = 10, height = 7)