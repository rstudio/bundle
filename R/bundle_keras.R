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
