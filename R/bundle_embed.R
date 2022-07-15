#' @export
bundle.step_umap <- function(x, ...) {
  rlang::check_installed("uwot")
  rlang::check_dots_empty(...)

  res <- x
  file_loc <- tempfile()
  umap_fit <- res$object
  uwot::save_uwot(umap_fit, file_loc)
  raw <- serialize(file_loc, connection = NULL)
  res$object <- raw

  bundle_constr(
    object = res,
    situate = situate_constr(function(object) {
      umap_fit <- uwot::load_uwot(unserialize(object$object))
      umap_fit$mod_dir <- NULL
      object$object <- umap_fit
      object
    }),
    desc_class = "step_umap",
    pkg_versions = c("uwot" = utils::packageVersion("uwot"))
  )
}
