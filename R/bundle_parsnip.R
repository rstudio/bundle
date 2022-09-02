#' @templateVar class a parsnip `model_fit`
#' @template title_desc
#'
#' @templateVar outclass `bundled_model_fit`
#' @templateVar default .
#' @template return_bundle
#' @family bundlers
#'
#' @param x A [model_fit][parsnip::model_fit] object returned
#'   from [parsnip][parsnip::parsnip] or other tidymodels packages.
#' @template param_unused_dots
#' @details Primarily, these methods call [bundle()] on the output of
#'   [parsnip::extract_fit_engine()]. See the class of the output of that
#'   function for more details on the bundling method for that object.
#' @template butcher_details
#' @examplesIf rlang::is_installed("parsnip") && rlang::is_installed("xgboost")
#' # fit model and bundle ------------------------------------------------
#' library(parsnip)
#' library(xgboost)
#'
#' set.seed(1)
#'
#' mod <-
#'   boost_tree(trees = 5, mtry = 3) %>%
#'   set_mode("regression") %>%
#'   set_engine("xgboost") %>%
#'   fit(mpg ~ ., data = mtcars)
#'
#' mod_bundle <- bundle(mod)
#'
#' # then, after saveRDS + readRDS or passing to a new session ----------
#' mod_unbundled <- unbundle(mod_bundle)
#'
#' mod_unbundled_preds <- predict(mod_unbundled, new_data = mtcars)
#' @rdname bundle_parsnip
#' @aliases bundle.model_fit bundle_model_fit
#' @export
bundle.model_fit <- function(x, ...) {
  rlang::check_installed("parsnip")
  rlang::check_dots_empty()

  res <- swap_element(x, "fit")

  bundle_constr(
    object = res,
    situate = situate_constr(function(object) {
      res <- bundle::swap_element(object, "fit")

      structure(res, class = !!class(x))
    }),
    desc_class = "model_fit"
  )
}
