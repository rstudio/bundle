test_that("bundling + unbundling mlr3 Learner objects", {
  skip_if_not_installed("mlr3")

  # fit model and bundle ------------------------------------------------
  library(mlr3)

  task <- tsk("mtcars")
  mod <- lrn("regr.rpart")

  mod$train(task, row_ids = 1:26)

  mod_bundle <- bundle(mod)
  mod_unbundled <- unbundle(mod_bundle)

  expect_s3_class(mod_bundle, "bundled_Learner")
  expect_s3_class(mod_unbundled, "Learner")

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
      library(mlr3)

      mod_unbundled_ <- unbundle(mod_bundle_)
      predict(mod_unbundled_, mtcars)
    },
    args = list(
      mod_bundle_ = mod_bundle
    )
  )

  expect_equal(mod_preds, mod_unbundled_preds_new)
})
