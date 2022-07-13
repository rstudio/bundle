#' @export
bundle.recipe <- function(x, ...) {
  res <- x
  steps_bundled <- purrr::map(res$steps, bundle::bundle)
  res$steps <- steps_bundled

  bundle_constr(
    object = res,
    situate = situate_constr(function(object) {
      steps_unbundled <- purrr::map(object$steps, bundle::unbundle)
      object$steps <- steps_unbundled
      structure(object, class = !!class(x))
    }),
    desc_class = "recipe",
    pkg_versions = c("recipes" = utils::packageVersion("recipes"))
  )
}
