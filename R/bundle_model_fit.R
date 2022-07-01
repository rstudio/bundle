#' @export
bundle.model_fit <- function(x, ...) {
  res <- x

  fit <- extract_fit_engine(x)
  bundled_fit <- bundle(fit)

  res$fit <- bundled_fit

  bundle_constr(res, class(res)[1], situate = identity)
}

#' @export
unbundle.model_fit <- function(x, ...) {
  fit_parsnip <- get_object(x)
  fit_engine_bundled <- extract_fit_engine(fit_parsnip)
  fit_engine_unbundled <- unbundle(fit_engine_bundled)

  x$object$fit <- fit_engine_unbundled

  unbundle_constr(x)
}
