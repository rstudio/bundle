test_that("bundling + unbundling tidymodels workflows (xgboost)", {
  skip_if_not_installed("workflows")
  skip_if_not_installed("parsnip")
  skip_if_not_installed("xgboost")

  library(workflows)
  library(parsnip)
  library(xgboost)

  set.seed(1)

  spec <-
    boost_tree(trees = 5, mtry = 3) %>%
    set_mode("regression") %>%
    set_engine("xgboost")

  rec <-
    recipe(mpg ~ ., data = mtcars) %>%
    step_log(hp)

  mod <-
    workflow() %>%
    add_model(spec) %>%
    add_recipe(rec) %>%
    fit(data = mtcars)

  mod_bundle <- bundle(mod)
  mod_unbundled <- unbundle(mod_bundle)

  expect_s3_class(mod_bundle, "bundled_workflow")
  expect_s3_class(mod_unbundled, "workflow")

  # ensure that the situater function didn't bring along the whole model
  expect_false("x" %in% names(environment(mod$situate)))

  mod_preds <- predict(mod, mtcars)
  mod_unbundled_preds <- predict(mod_unbundled, new_data = mtcars)

  expect_equal(mod_preds, mod_unbundled_preds)

  # only want bundled model and original preds to persist.
  # test again in new R session:
  mod_unbundled_preds_new <- callr::r(
    function(mod_bundle_) {
      library(bundle)
      library(parsnip)
      library(workflows)
      library(xgboost)

      mod_unbundled_ <- unbundle(mod_bundle_)
      predict(mod_unbundled_, mtcars)
    },
    args = list(
      mod_bundle_ = mod_bundle
    )
  )

  expect_equal(mod_preds, mod_unbundled_preds_new)
})
