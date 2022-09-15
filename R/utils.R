# constructors -----------------------------------------------------------------

#' Internal Functions
#'
#' These functions are not user-facing and are only exported for developer
#' extensions.
#'
#' @return The two `_constr()` functions are constructors that return a bundle
#' and a situater, respectively. `swap_element()` returns `x` after swapping
#' out the specified element.
#'
#' @rdname internal_functions
#' @keywords internal
#' @export
bundle_constr <- function(object, situate, desc_class) {
  res <- list(object = object, situate = situate)

  structure(
    res,
    class = c(paste0("bundled_", desc_class), "bundle")
  )
}

# adapted from carrier::crate -- control what data is packaged with the .fn
#' @rdname internal_functions
#' @keywords internal
#' @export
situate_constr <- function (fn) {
  env <- rlang::child_env(rlang::caller_env())
  fn <- rlang::eval_bare(rlang::enexpr(fn), env)
  rlang::env_poke_parent(env, rlang::base_env())

  structure(fn, class = c("situater", "function"))
}

# getters and setters ----------------------------------------------------------
get_object <- function(x) {
  x$object
}

set_object <- function(new_object, x) {
  x$object <- new_object

  x
}

# printing ---------------------------------------------------------------------
#' @export
print.bundle <- function(x, ...) {
  cat(glue::glue("bundled {gsub('bundled_', '', class(x)[1])} object.\n\n"))
}

# convenience functions --------------------------------------------------------
# "swap" an element of an object with its (un)bundled friend
#' @rdname internal_functions
#' @keywords internal
#' @export
swap_element <- function(x, ...) {
  component <- purrr::pluck(x, ...)

  if (inherits(component, "bundle")) {
    replacement <- unbundle(component)
  } else {
    replacement <- bundle(component)
  }

  if (!is.null(replacement)) {
    purrr::pluck(x, ...) <- replacement
  }

  x
}

# global variables -------------------------------------------------------------
utils::globalVariables(c(
  "extract_fit_engine", "getS3method", "map"
))

# imports ----------------------------------------------------------------------
#' @keywords internal
#' @importFrom purrr %>%
#' @export
NULL
