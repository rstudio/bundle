#' @method wrap xgb.Booster
#' @export
wrap.xgb.Booster <- function(x, ...) {
  object <- xgboost::xgb.serialize(x)

  wrap_constr(
    object = object,
    desc_class = class(x)[1],
    situate = function(unserialized) {
      unserialized$params$objective <- x$params$objective

      unserialized
    }
  )
}

#' @method unwrap wrapped_xgb.Booster
#' @export
unwrap.wrapped_xgb.Booster <- function(x, ...) {
  res <- xgboost::xgb.unserialize(get_object(x))

  unwrap_constr(res)
}
