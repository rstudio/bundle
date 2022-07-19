test_that("bundling + unbundling caret train objects", {
  skip_if_not_installed("caret")

  library(caret)

  predictors <- mtcars[, c("cyl", "disp", "hp")]

  set.seed(1)

  mod <-
    train(
      x = predictors,
      y = mtcars$mpg,
      method = "glm"
    )

  mod_bundle <- bundle(mod)
  mod_unbundled <- unbundle(mod_bundle)

  expect_s3_class(mod_bundle, "bundled_train")
  expect_s3_class(mod_unbundled, "train")

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
      library(caret)

      mod_unbundled_ <- unbundle(mod_bundle_)
      predict(mod_unbundled_, mtcars)
    },
    args = list(
      mod_bundle_ = mod_bundle
    )
  )

  expect_equal(mod_preds, mod_unbundled_preds_new)
})
