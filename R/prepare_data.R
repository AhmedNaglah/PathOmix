prepare_mofa_views <- function(data_list, view_names) {
  stopifnot(length(data_list) == length(view_names))

  common_rows <- Reduce(intersect, lapply(data_list, rownames))
  data_list <- lapply(data_list, function(x) x[common_rows, , drop = FALSE])

  view_list <- lapply(data_list, function(x) t(as.matrix(x)))
  names(view_list) <- view_names

  view_list <- lapply(view_list, function(mat) {
    mat[!is.finite(mat)] <- 0
    return(mat)
  })

  return(view_list)
}
