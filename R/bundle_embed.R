#' @export
bundle.step_umap <- function(x, ...) {
  rlang::check_installed("uwot")
  rlang::check_dots_empty(...)

  res <- x
  file_loc <- tempfile()
  uwot::save_uwot(res$object, file_loc)
  raw <- serialize(file_loc, connection = NULL)
  res$object <- raw

  bundle_constr(
    object = res,
    situate = situate_constr(function(step) {
      unserialized <- uwot::load_uwot(unserialize(step$object))
      unserialized$mod_dir <- NULL
      step$object <- unserialized
      step
    }),
    desc_class = class(x)[1],
    pkg_versions = c("uwot" = utils::packageVersion("uwot"))
  )
}
