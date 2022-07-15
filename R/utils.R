# constructors -----------------------------------------------------------------

#' Internal Functions
#'
#' These functions are not user-facing and are only exported for developer
#' extensions.
#'
#' @rdname internal_functions
#' @keywords internal
#' @export
bundle_constr <- function(object, situate, desc_class, pkg_versions) {
  res <- list(object = object, situate = situate)

  structure(
    res,
    class = c(paste0("bundled_", desc_class), "bundle"),
    pkg_versions = pkg_versions
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
#' Check whether an object has a bundling method
#'
#' Given a model object, this function will return whether the object
#' will dispatch to a method other than `bundle.default()` (the identity
#' function).
#'
#' Note that a return value of `FALSE` does not necessarily mean that
#' the object `x` cannot be saved and re-loaded in a new session---many model
#' objects, like [stats::lm()] and [stats::glm()] output, can be effectively
#' saved and re-loaded in a new session without any bundling.
#'
#' @seealso [bundle()], [unbundle()]
#' @inheritParams bundle
#' @return A logical.
#' @export
has_bundler <- function(x) {
  bundlers <- purrr::map(class(x), getS3method, f = "bundle", optional = TRUE)

  !all(purrr::map_lgl(bundlers, is.null))
}

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

# checks -----------------------------------------------------------------------

# ensure that packages needed for prediction are available. `x` is a
# bundle, here, with attribute "pkg_versions" containing versions and name
check_for_pkgs <- function(x) {
  pkg_versions <- attr(x, "pkg_versions")

  if (is.null(pkg_versions)) {
    return(x)
  }

  rlang::check_installed(names(pkg_versions), version = as.character(pkg_versions))

  attr(x, "pkg_versions") <- NULL

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
