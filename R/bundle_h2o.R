#' @export
bundle.H2OMultinomialModel <- function(x) {
  bundle_h2o(x)
}

#' @export
bundle.H2OBinomialModel <- function(x) {
  bundle_h2o(x)
}

#' @export
bundle.H2ORegressionModel <- function(x) {
  bundle_h2o(x)
}

bundle_h2o <- function(x) {
    file_loc <- tempfile()

    if (x@have_mojo) {
        file_loc <- with_no_progress(h2o::h2o.save_mojo(x, path = file_loc))
    } else {
        file_loc <- with_no_progress(h2o::h2o.saveModel(x, path = file_loc))
    }

    raw <- serialize(file_loc, connection = NULL)

    bundle_constr(
      object = raw,
      desc_class = "h2o",
      situate = function(unserialized) {
        unserialized <- structure(unserialized, class = class(raw))

        if (x@have_mojo) {
          res <- with_no_progress(h2o::h2o.import_mojo(unserialize(unserialized)))
        } else {
          res <- with_no_progress(h2o::h2o.loadModel(unserialize(unserialized)))
        }

        res
      }
    )
}

with_no_progress <- function(expr) {
  rlang::eval_tidy(h2o:::with_no_h2o_progress(expr))
}
