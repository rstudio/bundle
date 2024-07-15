#' @templateVar class a `bart`
#' @template title_desc
#'
#' @templateVar outclass `bundled_bart`
#' @templateVar default .
#' @template return_bundle
#' @family bundlers
#'
#' @param x A `bart` object returned from [dbarts::bart()]. Notably, this ought
#' not to be the output of [parsnip::bart()].
#' @template param_unused_dots
#' @rdname bundle_bart
#' @template butcher_details
#' @examplesIf rlang::is_installed(c("dbarts"))
#' # fit model and bundle ------------------------------------------------
#' library(dbarts)
#'
#' mtcars$vs <- as.factor(mtcars$vs)
#'
#' set.seed(1)
#' fit <- dbarts::bart(mtcars[c("disp", "hp")], mtcars$vs, keeptrees = TRUE)
#'
#' fit_bundle <- bundle(fit)
#'
#' # then, after saveRDS + readRDS or passing to a new session ----------
#' fit_unbundled <- unbundle(fit_bundle)
#'
#' fit_unbundled_preds <- predict(fit_unbundled, mtcars)
#' @aliases bundle.bart
#' @method bundle bart
#' @export
bundle.bart <- function(x, ...) {
  rlang::check_installed("dbarts")
  rlang::check_dots_empty()

  # `parsnip::bart()` and `dbarts::bart()` unfortunately both inherit from `bart`
  if (inherits(x, "model_spec")) {
    rlang::abort(c(
      paste0("`x` should be the output of `dbarts::bart()`, not a model ",
             "specification from `parsnip::bart()`."),
      "To bundle `parsnip::bart()` output, train it with `parsnip::fit()` first."
    ))
  }

  if (is.null(x$fit)) {
    rlang::abort(c(
      "`x` can't be bundled.",
      "`x` must have been fitted with argument `keeptrees = TRUE`."
    ))
  }

  # "touch" the object's state (#64)
  invisible(x$fit$state)

  bundle_constr(
    object = x,
    situate = situate_constr(identity),
    desc_class = class(x)[1]
  )
}
