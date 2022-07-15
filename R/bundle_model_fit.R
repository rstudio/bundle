#' @templateVar class a parsnip `model_fit`
#' @template title_desc
#'
#' @templateVar outclass `bundled_model_fit`
#' @template return_bundle
#'
#' @param x A [model_fit][parsnip::model_fit] object returned
#'   from [parsnip][parsnip::parsnip] or other tidymodels packages.
#' @template param_unused_dots
#' @details Primarily, these tidiers call [bundle()] on the output of
#'   [parsnip::extract_fit_engine()]. See the class of the output of that
#'   function for more details on the bundling method for that object.
#'
#' @rdname bundle_model_fit
#' @aliases bundle.model_fit
#' @export
bundle.model_fit <- function(x, ...) {
  rlang::check_installed("parsnip")

  res <- x

  fit <- x$fit

  bundled_fit <- bundle(fit, ...)

  res$fit <- bundled_fit

  bundle_constr(
    object = res,
    situate = situate_constr(function(object) {
      fit_engine_bundled <- object$fit
      fit_engine_unbundled <- bundle::unbundle(fit_engine_bundled)

      object$fit <- fit_engine_unbundled

      structure(object, class = !!class(x))
    }),
    desc_class = "model_fit",
    pkg_versions = c("parsnip" = utils::packageVersion("parsnip"))
  )
}
