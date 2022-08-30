#' @templateVar class an `xgb.Booster`
#' @template title_desc
#'
#' @templateVar outclass `bundled_xgb.Booster`
#' @templateVar default .
#' @template return_bundle
#' @family bundlers
#'
#' @param x An `xgb.Booster` object returned from [xgboost::xgboost()] or
#'   [xgboost::xgb.train()].
#' @template param_unused_dots
#' @rdname bundle_xgboost
#' @seealso This method adapts the xgboost functions [xgboost::xgb.save.raw()]
#'   and [xgboost::xgb.load.raw()].
#' @template butcher_details
#' @examplesIf rlang::is_installed("xgboost")
#' # fit model and bundle ------------------------------------------------
#' library(xgboost)
#'
#' set.seed(1)
#'
#' data(agaricus.train)
#' data(agaricus.test)
#'
#' xgb <- xgboost(data = agaricus.train$data, label = agaricus.train$label,
#'                max_depth = 2, eta = 1, nthread = 2, nrounds = 2,
#'                objective = "binary:logistic")
#'
#' xgb_bundle <- bundle(xgb)
#'
#' # then, after saveRDS + readRDS or passing to a new session ----------
#' xgb_unbundled <- unbundle(xgb_bundle)
#'
#' xgb_unbundled_preds <- predict(xgb_unbundled, agaricus.test$data)
#' @aliases bundle.xgb.Booster
#' @method bundle xgb.Booster
#' @export
bundle.xgb.Booster <- function(x, ...) {
  rlang::check_installed("xgboost")
  rlang::check_dots_empty()

  object <- xgboost::xgb.save.raw(x, raw_format = "ubj")

  bundle_constr(
    object = object,
    situate = situate_constr(function(object) {
      res <- xgboost::xgb.load.raw(object, as_booster = TRUE)

      res$params <- list(
        objective = !!x$params$objective,
        num_class = !!x$params$num_class
      )

      res
    }),
    desc_class = class(x)[1]
  )
}
