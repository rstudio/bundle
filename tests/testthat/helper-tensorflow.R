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
    error = function(e) FALSE
  )
  skip_if_not(isTRUE(has_tf), "TensorFlow is not available")
}
