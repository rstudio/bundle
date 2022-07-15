#' @templateVar class an `h2o`
#' @template title_desc
#'
#' @templateVar outclass `bundled_h2o`
#' @template return_bundle
#'
#' @param x An object returned from modeling functions in the
#'   [keras][keras::keras-package] package.
#' @template param_unused_dots
#' @rdname bundle_keras
#' @seealso This method wraps [keras::serialize_model()] and
#'   [keras::unserialize_model()].
#' @aliases bundle.keras.engine.training.Model
#' @method bundle keras.engine.training.Model
#' @export
bundle.keras.engine.training.Model <- function(x, ...) {
  rlang::check_installed("keras")
  rlang::check_dots_empty()

  serialized <- keras::serialize_model(x)

  bundle_constr(
    object = serialized,
    situate = situate_constr(function(object) {
      res <- keras::unserialize_model(object)

      res
    }),
    desc_class = "keras",
    pkg_versions = c("keras" = utils::packageVersion("keras"))
  )
}
