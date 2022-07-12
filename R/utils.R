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







