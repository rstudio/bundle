#' @export
wrap.recipe <- function(x, ...) {
  res <- map(x$steps, wrap)

  wrap_constr(res)
}

#' @export
unwrap.wrapped_recipe <- function(x, ...) {
  res <- map(x$steps, unwrap)

  unwrap_constr(res)
}
