#' @templateVar class a caret `train`
#' @template title_desc
#'
#' @templateVar outclass `bundled_train`
#' @templateVar default .
#' @template return_bundle
#' @family bundlers
#'
#' @param x A [train][caret::train] object returned
#'   from [caret::train()].
#' @template param_unused_dots
#' @details Primarily, these methods call [bundle()] on the output of
#'   `train_model_object$finalModel`. See the class of the output of that
#'   slot for more details on the bundling method for that object.
#' @template butcher_details
#' @examplesIf rlang::is_installed("caret") && identical(Sys.getenv("NOT_CRAN"), "true")
#' # fit model and bundle ------------------------------------------------
#' library(caret)
#'
#' predictors <- mtcars[, c("cyl", "disp", "hp")]
#'
#' set.seed(1)
#'
#' mod <-
#'   train(
#'     x = predictors,
#'     y = mtcars$mpg,
#'     method = "glm"
#'   )
#'
#' mod_bundle <- bundle(mod)
#'
#' # then, after saveRDS + readRDS or passing to a new session ----------
#' mod_unbundled <- unbundle(mod_bundle)
#'
#' mod_unbundled_preds <- predict(mod_unbundled, new_data = mtcars)
#' @rdname bundle_caret
#' @aliases bundle.train bundle_train
#' @export
bundle.train <- function(x, ...) {
  rlang::check_installed("caret")
  rlang::check_dots_empty()

  res <- swap_element(x, "finalModel")

  bundle_constr(
    object = res,
    situate = situate_constr(function(object) {
      res <- bundle::swap_element(object, "finalModel")

      structure(res, class = !!class(x))
    }),
    desc_class = "train"
  )
}
