#' @export
bundle.model_fit <- function(x) {
  res <- x

  fit <- extract_fit_engine(x)
  bundled_fit <- bundle(fit)

  res$fit <- bundled_fit

  bundle_constr(
    res,
    "model_fit",
    situate = function(object) {
      fit_engine_bundled <- extract_fit_engine(object)
      fit_engine_unbundled <- unbundle(fit_engine_bundled)

      object$fit <- fit_engine_unbundled

      structure(object, class = class(x))
    }
  )
}
