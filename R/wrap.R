# wrap() machinery -------------------------------------------------------------

#' @export
wrap <- function(x, ...) {
  UseMethod("wrap")
}

#' @export
wrap.default <- function(x, ...) x

# unwrap() machinery -----------------------------------------------------------

#' @export
unwrap <- function(x, ...) {
  UseMethod("unwrap")
}

#' @export
unwrap.default <- function(x, ...) x
