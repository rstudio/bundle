# constructors -----------------------------------------------------------------

#' @export
wrap_constr <- function(object, desc_class, situate) {
  res <- list(object = object, situate = situate)

  structure(
    res,
    class = c(paste0("wrapped_", desc_class), "gift")
  )
}

#' @export
unwrap_constr <- function(x) {
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
print.gift <- function(x) {
  cat(glue::glue("wrapped {gsub('wrapped_', '', class(x)[1])} object:\n\n"))
}

# checks -----------------------------------------------------------------------












