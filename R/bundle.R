# bundle() machinery -------------------------------------------------------------

#' Bundling
#'
#' @description
#' `bundle()` methods provide a consistent interface to serialization
#' methods for statistical model objects. The outputted bundle can be saved,
#' re-loaded into a new R session, and `unbundle()`d in a new R session for
#' use in prediction.
#'
#' To read more about bundling and serialization, see
#' `vignette("bundle")`.
#'
#' To see a list of currently available bundlers, see
#' `methods(bundle)`.
#'
#' Click [here][bundle-package] for package-level documentation.
#'
#' @templateVar outclass referencing the modeling function
#' @templateVar default If a bundle method is not defined for the supplied object, `bundle.default` is the identity function.
#' @template return_bundle
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
  x <- check_for_pkgs(x)

  x$situate(get_object(x))
}
