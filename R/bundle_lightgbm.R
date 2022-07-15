#' @templateVar class an `lgb.Booster`
#' @template title_desc
#'
#' @templateVar outclass `bundled_lgb.Booster`
#' @template return_bundle
#'
#' @param x An `lgb.Booster` object returned from [lightgbm::lgb.train()].
#' @template param_unused_dots
#' @rdname bundle_lightgbm
#' @aliases bundle.lgb.Booster
#' @method bundle lgb.Booster
#' @export
bundle.lgb.Booster <- function(x, ...) {
  rlang::check_installed("lightgbm")
  rlang::check_dots_empty()

  model_string <- x$save_model_to_string(NULL)

  bundle_constr(
    object = model_string,
    situate = situate_constr(function(object) {
      res <- lightgbm::lgb.load(model_str = object)

      res$best_iter <- !!x$best_iter
      res$record_evals <- !!x$record_evals
      res$params <- !!x$params

      structure(res, class = !!class(x))
    }),
    desc_class = class(x)[1],
    pkg_versions = c("lightgbm" = utils::packageVersion("lightgbm"))
  )
}
