#' @templateVar class a `catboost.Model`
#' @template title_desc
#'
#' @templateVar outclass `bundled_catboost.Model`
#' @templateVar default .
#' @template return_bundle
#' @family bundlers
#'
#' @param x A `catboost.Model` object returned from `catboost::catboost.train()`.
#' @template param_unused_dots
#' @rdname bundle_catboost
#' @seealso This method stores the raw serialized model bytes from the
#'   catboost model object and restores the C++ handle on unbundle.
#' @template butcher_details
#' @examplesIf rlang::is_installed(c("catboost", "parsnip", "bonsai"))
#' # fit model and bundle ------------------------------------------------
#' library(parsnip)
#' library(bonsai)
#'
#' set.seed(1)
#'
#' mod <- boost_tree(trees = 10) %>%
#'   set_engine("catboost", verbose = 0) %>%
#'   set_mode("classification") %>%
#'
#'   fit(Species ~ ., data = iris)
#' # extract the underlying catboost model
#' catboost_model <- mod$fit
#'
#' model_bundle <- bundle(catboost_model)
#'
#' # then, after saveRDS + readRDS or passing to a new session ----------
#' model_unbundled <- unbundle(model_bundle)
#' @aliases bundle.catboost.Model
#' @method bundle catboost.Model
#' @export
bundle.catboost.Model <- function(x, ...) {
  rlang::check_installed("catboost")
  rlang::check_dots_empty()

  # Save model to temp file and read raw bytes
  tmp_file <- withr::local_tempfile(fileext = ".cbm")
  rlang::eval_tidy(rlang::call2(
    "catboost.save_model",
    x,
    tmp_file,
    .ns = "catboost"
  ))
  object <- readBin(tmp_file, "raw", file.size(tmp_file))

  bundle_constr(
    object = object,
    situate = situate_constr(function(object) {
      # Write raw bytes to temp file and load model
      tmp_file <- withr::local_tempfile(fileext = ".cbm")
      writeBin(object, tmp_file)
      model <- rlang::eval_tidy(rlang::call2(
        "catboost.load_model",
        tmp_file,
        .ns = "catboost"
      ))

      # Restore metadata
      model$feature_importances <- !!x$feature_importances
      model$tree_count <- !!x$tree_count
      model$learning_rate <- !!x$learning_rate
      model$feature_count <- !!x$feature_count

      model
    }),
    desc_class = class(x)[1]
  )
}
