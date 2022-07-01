# constructors -----------------------------------------------------------------

#' @export
bundle_constr <- function(object, desc_class, situate) {
  res <- list(object = object, situate = situate)

  structure(
    res,
    class = c(paste0("bundled_", desc_class), "bundle")
  )
}

#' @export
unbundle_constr <- function(x) {
  structure(
    x$situate(get_object(x)),
    class = class(get_object(x))
  )
}

# getters and setters ----------------------------------------------------------
get_object <- function(x) {
  x$object
}


# printing ---------------------------------------------------------------------
#' @export
print.bundle <- function(x) {
  cat(glue::glue("bundled {gsub('bundled_', '', class(x)[1])} object:\n\n"))
}

# checks -----------------------------------------------------------------------












