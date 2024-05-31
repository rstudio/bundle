#' @templateVar class a `step_umap`
#' @template title_desc
#'
#' @templateVar outclass `bundled_step_umap`
#' @templateVar default .
#' @template return_bundle
#' @family bundlers
#'
#' @param x A [step_umap][embed::step_umap] object returned
#'   from [embed][embed::step_umap].
#' @template param_unused_dots
#' @seealso This method wraps [uwot::save_uwot()] and [uwot::load_uwot()].
#' @template butcher_details
#' @examplesIf rlang::is_installed(c("recipes", "embed", "irlba (>= 2.3.5.2)"))
#' # fit model and bundle ------------------------------------------------
#' library(recipes)
#' library(embed)
#'
#' set.seed(1)
#'
#' rec <- recipe(Species ~ ., data = iris) %>%
#'   step_normalize(all_predictors()) %>%
#'   step_umap(all_predictors(), outcome = vars(Species), num_comp = 2) %>%
#'   prep()
#'
#' rec_bundle <- bundle(rec)
#'
#' # then, after saveRDS + readRDS or passing to a new session ----------
#' rec_unbundled <- unbundle(rec_bundle)
#'
#' bake(rec_unbundled, new_data = iris)
#' @rdname bundle_embed
#' @aliases bundle.step_umap bundle_step_umap
#' @export
bundle.step_umap <- function(x, ...) {
  rlang::check_dots_empty()
  rlang::check_installed("uwot")

  res <- x
  umap_fit <- res$object
  file_loc <- withr::local_tempfile(pattern = "bundle")
  uwot::save_uwot(umap_fit, file_loc)
  raw <- readBin(file_loc, "raw", file.size(file_loc), endian = "little")
  res$object <- raw

  bundle_constr(
    object = res,
    situate = situate_constr(function(object) {
      new_file <- withr::local_tempfile(pattern = "unbundle")
      writeBin(object$object, new_file, endian = "little")
      umap_fit <- uwot::load_uwot(new_file)
      umap_fit$mod_dir <- NULL
      object$object <- umap_fit
      object
    }),
    desc_class = "step_umap"
  )
}
