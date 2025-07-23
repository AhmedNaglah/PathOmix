build_and_run_mofa <- function(view_list, view_names, model_outfile) {
  MOFAobject <- create_mofa(view_list)
  views_names(MOFAobject) <- view_names

  data_opts <- get_default_data_options(MOFAobject)
  data_opts$scale_views <- TRUE

  model_opts <- get_default_model_options(MOFAobject)
  model_opts$num_factors <- 10

  train_opts <- get_default_training_options(MOFAobject)

  MOFAobject <- prepare_mofa(MOFAobject, data_opts, model_opts, train_opts)
  MOFAobject <- run_mofa(MOFAobject, outfile = model_outfile)

  return(MOFAobject)
}