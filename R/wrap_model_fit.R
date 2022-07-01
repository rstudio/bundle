#' @export
wrap.model_fit <- function(x, ...) {
  res <- x

  fit <- extract_fit_engine(x)
  wrapped_fit <- wrap(fit)

  res$fit <- wrapped_fit

  wrap_constr(res, class(res)[1], situate = identity)
}

#' @export
unwrap.model_fit <- function(x, ...) {
  fit_parsnip <- get_object(x)
  fit_engine_wrapped <- extract_fit_engine(fit_parsnip)
  fit_engine_unwrapped <- unwrap(fit_engine_wrapped)

  x$object$fit <- fit_engine_unwrapped

  unwrap_constr(x)
}
