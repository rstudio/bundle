#' @templateVar class a tidymodels `workflow`
#' @template title_desc
#'
#' @templateVar outclass `bundled_workflow`
#' @templateVar default .
#' @template return_bundle
#' @family bundlers
#'
#' @param x A [workflow][workflows::workflow] object returned
#'   from [workflows][workflows::workflows] or other tidymodels packages.
#' @template param_unused_dots
#'
#' @details This bundler wraps [bundle.model_fit()] and [bundle.recipe()].
#'
#' @template butcher_details
#'
#' @examplesIf rlang::is_installed(c("workflows", "parsnip", "recipes", "xgboost"))
#' # fit model and bundle ------------------------------------------------
#' library(workflows)
#' library(recipes)
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
  rlang::check_dots_empty()

  res <- swap_element(x, "fit", "fit")
  res <- swap_element(res, "pre", "mold", "blueprint", "recipe")

  bundle_constr(
    object = res,
    situate = situate_constr(function(object) {
      res <- bundle::swap_element(object, "fit", "fit")
      res <- bundle::swap_element(res, "pre", "mold", "blueprint", "recipe")

      structure(res, class = !!class(x))
    }),
    desc_class = "workflow"
  )
}
