#' @templateVar class a tidymodels `workflow_set`
#' @template title_desc
#'
#' @templateVar outclass `bundled_workflow_set`
#' @templateVar default \dontshow{.}
#' @template return_bundle
#' @family bundlers
#'
#' @param x A [workflow_set][workflowsets::workflow_set] object returned
#'   from [workflowsets][workflowsets::workflowsets] or other tidymodels packages.
#' @template param_unused_dots
#'
#' @details This bundler wraps [bundle.workflow()], [bundle.model_fit()]
#'   and [bundle.recipe()].
#'
#' @examplesIf rlang::is_installed(c("workflowsets", "parsnip", "xgboost"))
#' # fit model and bundle ------------------------------------------------
#' library(workflowsets)
#' library(tune)
#' library(parsnip)
#' library(xgboost)
#'
#' set.seed(1)
#'
#' knn_spec <-
#'   nearest_neighbor(neighbors = tune()) %>%
#'   set_engine("kknn") %>%
#'   set_mode("regression")
#'
#' bt_spec <-
#'   boost_tree(trees = 5, mtry = 3) %>%
#'   set_mode("regression") %>%
#'   set_engine("xgboost")
#'
#' rec <-
#'   recipe(mpg ~ ., data = mtcars) %>%
#'   step_log(hp) %>%
#'   list(rec = .)
#'
#' specs <- list(knn = knn_spec, booster = bt_spec)
#'
#' mod <-
#'   workflow_set(rec, specs, cross = TRUE)
#'
#' mod_bundle <- bundle(mod)
#'
#' # then, after saveRDS + readRDS or passing to a new session ----------
#' mod_unbundled <- unbundle(mod_bundle)
#'
#' @rdname bundle_workflowsets
#' @aliases bundle.workflow_set bundle_workflow_set
#' @export
bundle.workflow_set <- function(x, ...) {
  rlang::check_installed("workflowsets")
  rlang::check_installed("parsnip")

  res <- x

  bundle_constr(
    object = res,
    situate = situate_constr(function(object) {
      structure(object, class = !!class(x))
    }),
    desc_class = "workflow_set",
    pkg_versions = c("workflowsets" = utils::packageVersion("workflowsets"))
  )
}
