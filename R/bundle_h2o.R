#' @export
bundle.H2OMultinomialModel <- function(x, ...) {
  bundle_h2o(x, ...)
}

#' @export
bundle.H2OBinomialModel <- function(x, ...) {
  bundle_h2o(x, ...)
}

#' @export
bundle.H2ORegressionModel <- function(x, ...) {
  bundle_h2o(x, ...)
}

bundle_h2o <- function(x, ...) {
    file_loc <- tempfile()
    if (x@have_mojo) {
        file_loc <- with_no_progress(h2o::h2o.save_mojo(x, path = file_loc))
    } else {
        file_loc <- with_no_progress(h2o::h2o.saveModel(x, path = file_loc))
    }
    raw <- serialize(file_loc, connection = NULL)
    attr(raw, "mojo") <- x@have_mojo
    bundle_constr(raw, x)
}

#' @export
unbundle.bundled_H2OMultinomialModel <- function(x, ...) {
  unbundle_h2o(x, ...)
}

#' @export
unbundle.bundled_H2OBinomialModel <- function(x, ...) {
  unbundle_h2o(x, ...)
}

#' @export
unbundle.bundled_H2ORegressionModel <- function(x, ...) {
  unbundle_h2o(x, ...)
}

unbundle_h2o <- function(x, ...) {
  x <- unbundle_constr(x)
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
