#' @export
wrap.H2OMultinomialModel <- function(x, ...) {
  wrap_h2o(x, ...)
}

#' @export
wrap.H2OBinomialModel <- function(x, ...) {
  wrap_h2o(x, ...)
}

#' @export
wrap.H2ORegressionModel <- function(x, ...) {
  wrap_h2o(x, ...)
}

wrap_h2o <- function(x, ...) {
    file_loc <- tempfile()
    if (x@have_mojo) {
        file_loc <- with_no_progress(h2o::h2o.save_mojo(x, path = file_loc))
    } else {
        file_loc <- with_no_progress(h2o::h2o.saveModel(x, path = file_loc))
    }
    raw <- serialize(file_loc, connection = NULL)
    attr(raw, "mojo") <- x@have_mojo
    wrap_constr(raw, x)
}

#' @export
unwrap.wrapped_H2OMultinomialModel <- function(x, ...) {
  unwrap_h2o(x, ...)
}

#' @export
unwrap.wrapped_H2OBinomialModel <- function(x, ...) {
  unwrap_h2o(x, ...)
}

#' @export
unwrap.wrapped_H2ORegressionModel <- function(x, ...) {
  unwrap_h2o(x, ...)
}

unwrap_h2o <- function(x, ...) {
  x <- unwrap_constr(x)
  if (attr(x, "mojo")) {
    res <- with_no_progress(h2o::h2o.import_mojo(unserialize(x)))
  } else {
    res <- with_no_progress(h2o::h2o.loadModel(unserialize(x)))
  }
  res
}

with_no_progress <- function(expr) {
  rlang::eval_tidy(h2o:::with_no_h2o_progress(expr))
}
