# bundle() machinery -------------------------------------------------------------

#' Bundling
#'
#' @description
#' `bundle()` methods provide a consistent interface to serialization
#' methods for statistical model objects. The created bundle can be saved,
#' then re-loaded and `unbundle()`d in a new R session for use in prediction.
#'
#' @templateVar outclass referencing the modeling function
#' @templateVar default . If a bundle method is not defined for the supplied object, `bundle.default` is the identity function.
#' @template return_bundle
#' @family bundlers
#'
#' @param x A model object to bundle.
#' @param ... Additional arguments to bundle methods.
#' @rdname bundle
#' @export
bundle <- function(x, ...) {
  UseMethod("bundle")
}

#' @export
bundle.default <- function(x, ...) x

# unbundle() machinery -----------------------------------------------------------

#' @rdname bundle
#' @export
unbundle <- function(x) {
  UseMethod("unbundle")
}

#' @export
unbundle.default <- function(x) x

#' @export
unbundle.bundle <- function(x) {
  x$situate(get_object(x))
}
