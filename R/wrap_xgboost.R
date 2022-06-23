#' @method wrap xgb.Booster
#' @export
wrap.xgb.Booster <- function(x, ...) {
  raw <- xgboost::xgb.serialize(x)

  wrap_constr(raw, x)
}

#' @method unwrap wrapped_xgb.Booster
#' @export
unwrap.wrapped_xgb.Booster <- function(x, ...) {
  unwrap_constr(x)

  xgboost::xgb.unserialize(x)
}
