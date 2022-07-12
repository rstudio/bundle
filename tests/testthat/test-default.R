test_that("bundling + unbundling with default method", {
  set.seed(1)

  mod <- lm(mpg ~ ., data = mtcars)

  mod_bundle <- bundle(mod)
  mod_unbundled <- unbundle(mod_bundle)

  expect_s3_class(mod_bundle, "lm")
  expect_s3_class(mod_unbundled, "lm")

  mod_preds <- predict(mod, mtcars)
  mod_unbundled_preds <- predict(mod_unbundled, mtcars)

  expect_equal(mod_preds, mod_unbundled_preds)

  # only want bundled model and original preds to persist.
  # test again in new R session:
  mod_unbundled_preds_new <- callr::r(
    function(mod_bundle) {
      library(bundle)

      mod_unbundled <- unbundle(mod_bundle)
      predict(mod_unbundled, mtcars)
    },
    args = list(
      mod_bundle = mod_bundle
    )
  )

  expect_equal(mod_preds, mod_unbundled_preds_new)
})
