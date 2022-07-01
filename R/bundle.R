# bundle() machinery -------------------------------------------------------------

#' @export
bundle <- function(x, ...) {
  UseMethod("bundle")
}

#' @export
bundle.default <- function(x, ...) x

# unbundle() machinery -----------------------------------------------------------

#' @export
unbundle <- function(x, ...) {
  UseMethod("unbundle")
}

#' @export
unbundle.default <- function(x, ...) x
