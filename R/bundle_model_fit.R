#' @export
bundle.model_fit <- function(x, ...) {
  res <- x

  fit <- x$fit

  bundled_fit <- bundle(fit, ...)

  res$fit <- bundled_fit

  bundle_constr(
    object = res,
    situate = carrier::crate(function(object) {
      fit_engine_bundled <- object$fit
      fit_engine_unbundled <- bundle::unbundle(fit_engine_bundled)

      object$fit <- fit_engine_unbundled

      structure(object, class = !!class(x))
    }),
    desc_class = "model_fit",
    pkg_versions = c("parsnip" = utils::packageVersion("parsnip"))
  )
}
