#' @templateVar class a tidymodels `workflow`
#' @template title_desc
#'
#' @templateVar outclass `bundled_workflow`
#' @templateVar default \dontshow{.}
#' @template return_bundle
#' @family bundlers
#'
#' @param x A [workflow][workflows::workflow] object returned
#'   from [workflows][workflows::workflows] or other tidymodels packages.
#' @template param_unused_dots
#'
#' @details This bundler wraps [bundle.model_fit()] and [bundle.recipe()].
#'
#' @examplesIf rlang::is_installed(c("workflows", "parsnip", "xgboost"))
#' # fit model and bundle ------------------------------------------------
#' library(workflows)
#' library(parsnip)
#' library(xgboost)
#'
#' set.seed(1)
#'
#' spec <-
#'   boost_tree(trees = 5, mtry = 3) %>%
#'   set_mode("regression") %>%
#'   set_engine("xgboost")
#'
#' rec <-
#'   recipe(mpg ~ ., data = mtcars) %>%
#'   step_log(hp)
#'
#' mod <-
#'   workflow() %>%
#'   add_model(spec) %>%
#'   add_recipe(rec) %>%
#'   fit(data = mtcars)
#'
#' mod_bundle <- bundle(mod)
#'
#' # then, after saveRDS + readRDS or passing to a new session ----------
#' mod_unbundled <- unbundle(mod_bundle)
#'
#' @rdname bundle_workflows
#' @aliases bundle.workflow bundle_workflow
#' @export
bundle.workflow <- function(x, ...) {
  rlang::check_installed("workflows")
  rlang::check_installed("parsnip")

  res <- x

  parsnip_fit <- x$fit$fit
  parsnip_bundle <- bundle(parsnip_fit)
  res$fit$fit <- parsnip_bundle

  recipe <- x$pre$actions$recipe$recipe
  recipes_bundle <- bundle(recipe)
  res$pre$actions$recipe$recipe <- recipes_bundle

  bundle_constr(
    object = res,
    situate = situate_constr(function(object) {
      fit_parsnip_bundled <- object$fit$fit
      fit_parsnip_unbundled <- bundle::unbundle(fit_parsnip_bundled)
      object$fit$fit <- fit_parsnip_unbundled

      recipe_bundled <- object$fit$pre$actions$recipe$recipe
      recipe_unbundled <- bundle::unbundle(recipe_bundled)
      object$fit$pre$actions$recipe$recipe <- recipe_unbundled

      structure(object, class = !!class(x))
    }),
    desc_class = "workflow",
    pkg_versions = c("workflows" = utils::packageVersion("workflows"))
  )
}
