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
#' @description
#' Given a model object, this function will return whether the object
#' will dispatch to a non-trivial bundler. For most objects, `has_bundler()`
#' simply returns whether the object will dispatch to `bundle.default()`, the
#' identity function. For some objects, whose bundling methods recurse into
#' elements of the inputted object, `has_bundler()` returns whether the
#' final dispatch to a `bundle()` method is `bundle.default()` for _all_ of
#' the recursed elements. More plainly---if bundling an object `x` will make a
#' call to native serialization methods anywhere inside its interals,
#' `has_bundler(x)` will return `TRUE`.
#'
#' Note that a return value of `FALSE` does not necessarily mean that
#' the object `x` cannot be saved and re-loaded in a new session---many model
#' objects, like [stats::lm()] and [stats::glm()] output, can be effectively
#' saved and re-loaded in a new session without any bundling.
#'
#' @section bundle and butcher:
#' butcher is an R package that allows users to remove parts of a fitted model
#' object that are not needed for prediction. However, native serialization
#' methods for some model objects need access to elements that are removed
#' by [butcher::butcher()].
#'
#' The `has_bundler()` function is thus a convenient helper to (conservatively)
#' determine whether an object can be [butcher::butcher()]ed before bundling.
#' If `has_bundler(x)` is `FALSE`, then one can safely [butcher::butcher()]
#' before bundling. To prepare an object for efficient and safe serialization,
#' then, use:
#'
#' ```
#' if (!has_bundler(x)) {
#'   x <- butcher(x)
#' }
#'
#' bundle(x)
#' ```
#'
#' @seealso [bundle()], [unbundle()]
#' @inheritParams bundle
#' @return A logical.
#' @rdname has_bundler
#' @export
has_bundler <- function(x) {
  UseMethod("has_bundler")
}

#' @rdname has_bundler
#' @export
has_bundler.workflow <- function(x) {
  rlang::check_installed("workflows")

  model_fit <- workflows::extract_fit_parsnip(x)
  recipe <- workflows::extract_recipe(x)

  has_bundler(model_fit) || has_bundler(recipe)
}

#' @rdname has_bundler
#' @export
has_bundler.model_fit <- function(x) {
  rlang::check_installed("parsnip")

  engine_fit <- parsnip::extract_fit_engine(x)

  has_bundler(engine_fit)
}

#' @rdname has_bundler
#' @export
has_bundler.recipe <- function(x) {
  any(purrr::map_lgl(x$steps, has_bundler))
}

#' @rdname has_bundler
#' @export
has_bundler.default <- function(x) {
  bundlers <- purrr::map(class(x), getS3method, f = "bundle", optional = TRUE)

  !all(purrr::map_lgl(bundlers, is.null))
}

has_bundler_error <- function(x) {
  cli::cli_warn(c(
    "!" = "`has_bundler()` is not well-defined for a(n) `{class(x)[1]}` object.",
    "i" = "Please call `has_bundler()` on the object to be supplied to `bundle()`."
  ))

  return(invisible(FALSE))
}

#' @rdname has_bundler
#' @export
has_bundler.bundle <- has_bundler_error

#' @rdname has_bundler
#' @export
has_bundler.model_spec <- has_bundler_error

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
