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

#' @export
bundle.H2OAutoML <- function(x, id = NULL, n = NULL, ...) {
  rlang::check_dots_empty()

  bundle(select_from_automl(x, id = id, n = n))
}

bundle_h2o <- function(x, ...) {
  rlang::check_dots_empty()

  file_loc <- tempfile()

  if (x@have_mojo) {
    file_loc <- with_no_progress(h2o::h2o.save_mojo(x, path = file_loc))
  } else {
    file_loc <- with_no_progress(h2o::h2o.saveModel(x, path = file_loc))
  }

  raw <- serialize(file_loc, connection = NULL)

  bundle_constr(
    object = raw,

    situate = carrier::crate(function(unserialized) {
      unserialized <- structure(unserialized, class = class(raw))

      if (!!x@have_mojo) {
        res <- h2o:::with_no_h2o_progress(h2o::h2o.import_mojo(unserialize(unserialized)))
      } else {
        res <- h2o:::with_no_h2o_progress(h2o::h2o.loadModel(unserialize(unserialized)))
      }

      res
    }),
    desc_class = "h2o",
    pkg_versions = c("h2o" = utils::packageVersion("h2o"))
  )
}

select_from_automl <- function(x, id = NULL, n = NULL) {
  if (!is.null(id)) {
    x <- h2o::h2o.getModel(id)
  } else if (!is.null(n)) {
    lb <- as.data.frame(x@leaderboard)
    id <- lb[n, "model_id"]
    x <- h2o::h2o.getModel(id)
  } else {
    x <- x@leader
  }
  x
}

with_no_progress <- function(expr) {
  rlang::eval_tidy(h2o:::with_no_h2o_progress(expr))
}
