#' @templateVar class an `h2o`
#' @template title_desc
#'
#' @templateVar outclass `bundled_h2o`
#' @templateVar default .
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
#' @seealso These methods wrap [h2o::h2o.save_mojo()] and
#'   [h2o::h2o.saveModel()].
#' @examplesIf rlang::is_installed(c("h2o")) && identical(Sys.getenv("NOT_CRAN"), "true")
#' # fit model and bundle ------------------------------------------------
#' library(h2o)
#'
#' set.seed(1)
#'
#' h2o.init()
#'
#' cars_h2o <- as.h2o(mtcars)
#'
#' cars_fit <-
#'   h2o.glm(
#'     x = colnames(cars_h2o)[2:11],
#'     y = colnames(cars_h2o)[1],
#'     training_frame = cars_h2o
#'   )
#'
#' cars_bundle <- bundle(cars_fit)
#'
#' # then, after saveRDS + readRDS or passing to a new session ----------
#' cars_unbundled <- unbundle(cars_fit)
#'
#' predict(cars_unbundled, cars_h2o[, 2:11])
#'
#' h2o.shutdown()
#'
#' @family bundlers
#' @rdname bundle_h2o
#' @aliases bundle.H2OAutoML
#' @export
bundle.H2OAutoML <- function(x, id = NULL, n = NULL, ...) {
  rlang::check_dots_empty()

  bundle(select_from_automl(x, id = id, n = n))
}

#' @aliases bundle.H2OMultinomialModel
#' @rdname bundle_h2o
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

bundle_h2o <- function(x, ...) {
  rlang::check_dots_empty()
  rlang::check_installed("h2o")

  file_loc <- withr::local_tempdir(pattern = "bundle")

  if (x@have_mojo) {
    file_loc <- h2o::h2o.save_mojo(x, path = file_loc)
  } else {
    file_loc <- h2o::h2o.saveModel(x, path = file_loc)
  }
  raw <- readBin(file_loc, "raw", file.size(file_loc), endian = "little")

  bundle_constr(
    object = raw,
    situate = situate_constr(function(object) {
      new_file <- withr::local_tempfile(pattern = "unbundle")
      writeBin(object, new_file, endian = "little")
      if (!!x@have_mojo) {
        res <- h2o::h2o.import_mojo(new_file)
      } else {
        res <- h2o::h2o.loadModel(new_file)
      }

      res
    }),
    desc_class = "h2o"
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
