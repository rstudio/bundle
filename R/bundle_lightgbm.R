#' @templateVar class an `lgb.Booster`
#' @template title_desc
#'
#' @templateVar outclass `bundled_lgb.Booster`
#' @templateVar default \dontshow{.}
#' @template return_bundle
#' @family bundlers
#'
#' @param x An `lgb.Booster` object returned from [lightgbm::lgb.train()].
#' @template param_unused_dots
#' @rdname bundle_lightgbm
#' @seealso This method makes use of the `save_model_to_string()` R6 methods
#'   of `lgb.Booster` objects as well as [lightgbm::lgb.load()].
#' @examplesIf rlang::is_installed("lightgbm")
#' # fit model and bundle ------------------------------------------------
#' library(lightgbm)
#'
#' set.seed(1)
#'
#' cars_train <-
#'   lgb.Dataset(
#'     data = as.matrix(mtcars[1:25, 2:ncol(mtcars)]),
#'     label = mtcars[1:25, 1],
#'     params = list(feature_pre_filter = "false")
#'   )
#'
#' cars_test <- as.matrix(mtcars[26:32, 2:ncol(mtcars)])
#'
#' lgb_fit <-
#'   lgb.train(
#'     params = list(
#'       max_depth = 3,
#'       min_data_in_leaf = 5,
#'       objective = "regression"
#'     ),
#'     data = cars_train,
#'     nrounds = 5,
#'     verbose = -1
#'   )
#'
#' lgb_bundle <- bundle(lgb_fit)
#'
#' # then, after saveRDS + readRDS or passing to a new session ----------
#' lgb_unbundled <- unbundle(lgb_bundle)
#'
#' lgb_unbundled_preds <- predict(lgb_unbundled, cars_test)
#' @aliases bundle.lgb.Booster
#' @method bundle lgb.Booster
#' @export
bundle.lgb.Booster <- function(x, ...) {
  rlang::check_installed("lightgbm")
  rlang::check_dots_empty()

  model_string <- x$save_model_to_string(NULL)

  bundle_constr(
    object = model_string,
    situate = situate_constr(function(object) {
      res <- lightgbm::lgb.load(model_str = object)

      res$best_iter <- !!x$best_iter
      res$record_evals <- !!x$record_evals
      res$params <- !!x$params

      structure(res, class = !!class(x))
    }),
    desc_class = class(x)[1],
    pkg_versions = c("lightgbm" = utils::packageVersion("lightgbm"))
  )
}
