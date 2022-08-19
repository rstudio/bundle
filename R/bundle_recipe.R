#' @templateVar class a `recipe`
#' @template title_desc
#'
#' @templateVar outclass `bundled_recipe`
#' @templateVar default .
#' @template return_bundle
#' @family bundlers
#'
#' @param x A [recipe][recipes::recipe] object returned
#'   from [recipes][recipes::recipe].
#' @template param_unused_dots
#' @details The method call [bundle()] on every step in the
#'   [recipe][recipes::recipe] object. See the classes of individual steps
#'   for more details on the bundling method for that object.
#' @rdname bundle_recipe
#' @aliases bundle.recipe bundle_recipe
#' @export
bundle.recipe <- function(x, ...) {
  rlang::check_dots_empty()

  res <- x
  steps_bundled <- purrr::map(res$steps, bundle::bundle)
  res$steps <- steps_bundled

  bundle_constr(
    object = res,
    situate = situate_constr(function(object) {
      steps_unbundled <- purrr::map(object$steps, bundle::unbundle)
      object$steps <- steps_unbundled
      structure(object, class = !!class(x))
    }),
    desc_class = "recipe"
  )
}
