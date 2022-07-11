# bundle() machinery -------------------------------------------------------------

#' Bundling
#'
#' `bundle()` methods provide a consistent interface to serialization
#' methods. The outputted bundle can be `unbundle()`d in a new R session
#' and used as desired.
#'
#' To read more about bundling and serialization, see
#' `vignette("bundle")`.
#'
#' To see a list of currently available bundlers, see
#' `methods(bundle)`.
#'
#' @param x An R object to bundle.
#' @rdname bundle
#' @export
bundle <- function(x) {
  UseMethod("bundle")
}

#' @export
bundle.default <- function(x) x

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
