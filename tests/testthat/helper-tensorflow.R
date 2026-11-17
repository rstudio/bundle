skip_if_no_tensorflow <- function() {
  skip_if_not_installed("tensorflow")
  # keras declares its Python requirements with `py_require()` when it loads,
  # which must happen before `tf_version()` initializes Python
  if (rlang::is_installed("keras")) {
    loadNamespace("keras")
  }
  # newer reticulate errors (rather than returns `NULL`) when no Python is found
  has_tf <- tryCatch(
    !is.null(tensorflow::tf_version()),
    error = function(e) e
  )
  if (isTRUE(has_tf)) {
    return(invisible())
  }
  # CI sets up Python and TensorFlow, so a missing TensorFlow there is a
  # broken environment that should not be hidden behind a skip
  if (identical(Sys.getenv("CI"), "true")) {
    msg <- if (inherits(has_tf, "error")) conditionMessage(has_tf) else ""
    fail(paste("TensorFlow is not available on CI.", msg))
  }
  skip("TensorFlow is not available")
}
