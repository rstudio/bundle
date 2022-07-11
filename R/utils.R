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
  "extract_fit_engine", "map"
))







