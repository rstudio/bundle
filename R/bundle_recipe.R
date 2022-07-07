#' @export
bundle.recipe <- function(x) {
  res <- map(x$steps, bundle)

  bundle_constr(res)
}

#' @export
unbundle.bundled_recipe <- function(x) {
  res <- map(x$steps, unbundle)

  unbundle_constr(res)
}
