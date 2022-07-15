#' @templateVar class an `xgb.Booster`
#' @template title_desc
#'
#' @templateVar outclass `bundled_xgb.Booster`
#' @template return_bundle
#'
#' @param x An `xgb.Booster` object returned from [xgboost::xgboost()] or
#'   [xgboost::xgb.train()].
#' @template param_unused_dots
#' @rdname bundle_xgboost
#' @seealso This method adapts the xgboost internal functions
#'   `predict.xgb.Booster.handle()` and `xgb.handleToBooster()`, as well
#'   as  [xgboost::xgb.serialize()].
#' @aliases bundle.xgb.Booster
#' @method bundle xgb.Booster
#' @export
bundle.xgb.Booster <- function(x, ...) {
  rlang::check_installed("xgboost")
  rlang::check_dots_empty()

  object <- xgboost::xgb.serialize(x)

  bundle_constr(
    object = object,
    situate = situate_constr(function(object) {
      unserialized <- xgboost::xgb.unserialize(object)

      # see xgboost:::predict.xgb.Booster.handle and xgboost:::xgb.handleToBooster
      res <- list(handle = unserialized, raw = NULL)
      class(res) <- "xgb.Booster"

      res$params <- list(
        objective = !!x$params$objective,
        num_class = !!x$params$num_class
      )

      res
    }),
    desc_class = class(x)[1],
    pkg_versions = c("xgboost" = utils::packageVersion("xgboost"))
  )
}
