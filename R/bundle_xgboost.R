#' @method bundle xgb.Booster
#' @export
bundle.xgb.Booster <- function(x) {
  object <- xgboost::xgb.serialize(x)

  bundle_constr(
    object = object,
    desc_class = class(x)[1],
    situate = carrier::crate(function(object) {
      unserialized <- xgboost::xgb.unserialize(object)

      # see xgboost:::predict.xgb.Booster.handle and xgboost:::xgb.handleToBooster
      res <- list(handle = unserialized, raw = NULL)
      class(res) <- "xgb.Booster"

      res$params <- list(
        objective = !!x$params$objective,
        num_class = !!x$params$num_class
      )

      res
    })
  )
}
