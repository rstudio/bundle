#' @method bundle xgb.Booster
#' @export
bundle.xgb.Booster <- function(x, ...) {
  object <- xgboost::xgb.serialize(x)

  bundle_constr(
    object = object,
    desc_class = class(x)[1],
    situate = function(unserialized) {
      unserialized$params$objective <- x$params$objective

      unserialized
    }
  )
}

#' @method unbundle bundled_xgb.Booster
#' @export
unbundle.bundled_xgb.Booster <- function(x, ...) {
  res <- xgboost::xgb.unserialize(get_object(x))

  unbundle_constr(res)
}
