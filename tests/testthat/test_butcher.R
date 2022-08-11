test_that("default bundlers can be pre-butchered", {
  skip_if_not_installed("butcher")

  library(butcher)

  mod <- lm(mpg ~ ., data = mtcars)
  mod_butchered <- butcher(mod)

  mod_bundle <- bundle(mod)
  mod_unbundled <- unbundle(mod_bundle)

  expect_silent({
    mod_butchered_bundle <- bundle(mod_butchered)
    mod_butchered_unbundled <- unbundle(mod_butchered_bundle)
  })

  expect_s3_class(mod_bundle, "lm")
  expect_s3_class(mod_unbundled, "lm")
  expect_s3_class(mod_butchered_unbundled, "lm")

  expect_equal(
    predict(mod, mtcars),
    predict(mod_butchered_unbundled, mtcars)
  )
})

test_that("trivial bundlers can be pre-butchered", {
  skip_if_not_installed("butcher")
  skip_if_not_installed("parsnip")
  skip_if_not_installed("callr")

  library(butcher)
  library(parsnip)
  library(callr)

  fit_no_bundler <-
    linear_reg() %>%
    set_mode("regression") %>%
    set_engine("lm") %>%
    fit(mpg ~ ., data = mtcars)

  fit_butchered <- butcher(fit_no_bundler)

  expect_silent({
    fit_butchered_bundle <- bundle(fit_butchered)
  })

  expect_s3_class(fit_butchered_bundle, "bundled_model_fit")

  fit_no_bundler_preds <- predict(fit_no_bundler, mtcars)

  expect_equal(
    predict(unbundle(fit_butchered_bundle), mtcars),
    fit_no_bundler_preds
  )

  fit_unbundled_preds_new <- r(
    function(fit_butchered_bundle) {
      library(bundle)
      library(parsnip)

      fit_butchered_unbundled <- unbundle(fit_butchered_bundle)
      predict(fit_butchered_unbundled, mtcars)
    },
    args = list(
      fit_butchered_bundle = fit_butchered_bundle
    )
  )

  expect_equal(fit_no_bundler_preds, fit_unbundled_preds_new)
})

