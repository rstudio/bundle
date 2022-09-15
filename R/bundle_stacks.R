#' @templateVar class a tidymodels `model_stack`
#' @template title_desc
#'
#' @templateVar outclass `bundled_model_stack`
#' @templateVar default .
#' @template return_bundle
#' @family bundlers
#'
#' @param x A [model_stack][stacks::stacks] object returned
#'   from [fit_members()][stacks::fit_members].
#' @template param_unused_dots
#'
#' @details This bundler wraps [bundle.model_fit()] and [bundle.workflow()].
#' Both the fitted members and the meta-learner (in `x$coefs`) are bundled.
#'
#' @examplesIf rlang::is_installed(c("stacks")) && identical(Sys.getenv("NOT_CRAN"), "true")
#' # fit model and bundle ------------------------------------------------
#' library(stacks)
#'
#' set.seed(1)
#'
#' mod <-
#'   stacks() %>%
#'   add_candidates(reg_res_lr) %>%
#'   add_candidates(reg_res_svm) %>%
#'   blend_predictions(times = 10) %>%
#'   fit_members()
#'
#' mod_bundle <- bundle(mod)
#'
#' # then, after saveRDS + readRDS or passing to a new session ----------
#' mod_unbundled <- unbundle(mod_bundle)
#'
#' @rdname bundle_stacks
#' @aliases bundle.model_stack bundle_model_stack
#' @export
bundle.model_stack <- function(x, ...) {
  rlang::check_installed("stacks")
  rlang::check_installed("parsnip")
  rlang::check_installed("workflows")
  rlang::check_dots_empty()

  res <- x
  res[["member_fits"]] <- lapply(res[["member_fits"]], bundle)
  res <- swap_element(res, "coefs")

  bundle_constr(
    object = res,
    situate = situate_constr(function(object) {
      res <- object
      res[["member_fits"]] <- lapply(object[["member_fits"]], bundle::unbundle)
      res <- bundle::swap_element(res, "coefs")

      structure(res, class = !!class(x))
    }),
    desc_class = "model_stack"
  )
}
