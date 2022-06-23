# constructors -----------------------------------------------------------------

#' @export
wrap_constr <- function(raw, orig) {
  structure(
    raw,
    class = c("gift", paste0("wrapped_", class(orig)[1]), class(raw))
  )
}

#' @export
unwrap_constr <- function(x) {
  structure(
    x,
    class = class(x)[3:length(class(x))]
  )
}

# printing ---------------------------------------------------------------------
#' @export
print.gift <- function(x) {
  unwrapped <- unwrap(x)

  cat(glue::glue("wrapped {gsub('wrapped_', '', class(x)[2])} object:\n\n"))

  print(unwrapped)
}

# checks -----------------------------------------------------------------------












