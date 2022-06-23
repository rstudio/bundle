#' @export
wrap.model_fit <- function(x, ...) {
  res <- x

  fit <- extract_fit_engine(x)
  wrapped_fit <- wrap(fit)

  res$fit <- wrapped_fit

  wrap_constr(res, x)
}

#' @export
unwrap.model_fit <- function(x, ...) {
  res <- unwrap_constr(x)

  wrapped_fit <- extract_fit_engine(x)
  fit <- unwrap(wrapped_fit)

  res$fit <- fit

  res
}
