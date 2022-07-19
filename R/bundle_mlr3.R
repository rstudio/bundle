#' @templateVar class an mlr3 `Learner`
#' @template title_desc
#'
#' @templateVar outclass `bundled_Learner`
#' @templateVar default .
#' @template return_bundle
#' @family bundlers
#'
#' @param x A [Learner][mlr3::Learner] object returned
#'   from [mlr3::lrn()] or other `mlr3` modeling functions.
#' @template param_unused_dots
#' @details Primarily, these methods call [bundle()] on the output of
#'   `train_model_object$model`. See the class of the output of that
#'   slot for more details on the bundling method for that object.
#' @examplesIf rlang::is_installed("mlr3")
#' # fit model and bundle ------------------------------------------------
#' library(mlr3)
#'
#' task <- tsk("mtcars")
#' mod <- lrn("regr.rpart")
#'
#' mod$train(task, row_ids = 1:26)
#'
#' mod_bundle <- bundle(mod)
#'
#' # then, after saveRDS + readRDS or passing to a new session ----------
#' mod_unbundled <- unbundle(mod_bundle)
#'
#' mod_unbundled_preds <- predict(mod_unbundled, new_data = mtcars[27:32,])
#' @rdname bundle_mlr3
#' @aliases bundle.Learner bundle_Learner
#' @export
bundle.Learner <- function(x, ...) {
  rlang::check_installed("mlr3")

  res <- swap_element(x, "model")

  bundle_constr(
    object = res,
    situate = situate_constr(function(object) {
      res <- bundle::swap_element(object, "model")

      structure(res, class = !!class(x))
    }),
    desc_class = "Learner",
    pkg_versions = c("mlr3" = utils::packageVersion("mlr3"))
  )
}
