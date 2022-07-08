# constructors -----------------------------------------------------------------

#' Internal Functions
#'
#' These functions are not user-facing and are only exported for developer
#' extensions.
#'
#' @rdname internal_functions
#' @keywords internal
#' @export
bundle_constr <- function(object, desc_class, situate) {
  res <- list(object = object, situate = situate)

  structure(
    res,
    class = c(paste0("bundled_", desc_class), "bundle")
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




# global variables -------------------------------------------------------------
utils::globalVariables(c(
  "extract_fit_engine", "map"
))







