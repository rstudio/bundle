#' @templateVar class an `h2o`
#' @template title_desc
#'
#' @templateVar outclass `bundled_h2o`
#' @template return_bundle
#'
#' @param x An object returned from modeling functions in the [h2o][h2o::h2o]
#'   package.
#' @param id A single character. The `model_id` entry in the leaderboard.
#'   Applies to AutoML output only. Supply only one of this argument or
#'   `n`.
#' @param n An integer giving the position in the leaderboard of the model
#'   to bundle. Applies to AutoML output only. Will be ignored if `id` is
#'   supplied.
#' @template param_unused_dots
#' @rdname bundle_h2o
#' @aliases bundle.H2OMultinomialModel
#' @export
bundle.H2OMultinomialModel <- function(x, ...) {
  bundle_h2o(x, ...)
}

#' @rdname bundle_h2o
#' @aliases bundle.H2OBinomialModel
#' @export
bundle.H2OBinomialModel <- function(x, ...) {
  bundle_h2o(x, ...)
}

#' @rdname bundle_h2o
#' @aliases bundle.H2ORegressionModel
#' @export
bundle.H2ORegressionModel <- function(x, ...) {
  bundle_h2o(x, ...)
}

#' @rdname bundle_h2o
#' @aliases bundle.H2OAutoML
#' @export
bundle.H2OAutoML <- function(x, id = NULL, n = NULL, ...) {
  rlang::check_dots_empty()

  bundle(select_from_automl(x, id = id, n = n))
}

bundle_h2o <- function(x, ...) {
  rlang::check_dots_empty()
  rlang::check_installed("h2o")

  file_loc <- tempfile()

  if (x@have_mojo) {
    file_loc <- with_no_progress(h2o::h2o.save_mojo(x, path = file_loc))
  } else {
    file_loc <- with_no_progress(h2o::h2o.saveModel(x, path = file_loc))
  }

  raw <- serialize(file_loc, connection = NULL)

  bundle_constr(
    object = raw,

    situate = situate_constr(function(unserialized) {
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
