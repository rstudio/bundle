test_that("bundling + unbundling caret fits", {
  skip_if_not_installed("caret")
  skip_if_not_installed("butcher")

  library(caret)

  test_data <- mtcars[26:32, c("cyl", "disp", "hp")]

  # define a function to fit a model -------------------------------------------
  fit_model <- function() {
    predictors <- mtcars[1:25, c("cyl", "disp", "hp")]

    set.seed(1)

    mod <-
      train(
        x = predictors,
        y = mtcars[1:25, 1],
        method = "glm"
      )

    mod
  }

  # pass fit fn to a new session, fit, bundle, return bundle -------------------
  mod_bundle <-
    callr::r(
      function(fit_model) {
        library(caret)

        mod <- fit_model()

        bundle::bundle(mod)
      },
      args = list(fit_model = fit_model)
    )

  # pass the bundle to a new session, unbundle it, return predictions ----------
  mod_unbundled_preds <-
    callr::r(
      function(mod_bundle, test_data) {
        library(caret)

        mod_unbundled <- bundle::unbundle(mod_bundle)

        predict(mod_unbundled, test_data)
      },
      args = list(
        mod_bundle = mod_bundle,
        test_data = test_data
      )
    )

  # pass fit fn to a new session, fit, butcher, bundle, return bundle ----------
  mod_butchered_bundle <-
    callr::r(
      function(fit_model) {
        library(caret)

        mod <- fit_model()

        bundle::bundle(butcher::butcher(mod))
      },
      args = list(fit_model = fit_model)
    )

  # pass the bundle to a new session, unbundle it, return predictions ----------
  mod_butchered_unbundled_preds <-
    callr::r(
      function(mod_butchered_bundle, test_data) {
        library(caret)

        mod_butchered_unbundled <- bundle::unbundle(mod_butchered_bundle)

        predict(mod_butchered_unbundled, test_data)
      },
      args = list(
        mod_butchered_bundle = mod_butchered_bundle,
        test_data = test_data
      )
    )

  # run expectations -----------------------------------------------------------
  mod_fit <- fit_model()
  mod_preds <- predict(mod_fit, test_data)

  # check classes
  expect_s3_class(mod_bundle, "bundled_train")
  expect_s3_class(unbundle(mod_bundle), "train")

  # ensure that the situater function didn't bring along the whole model
  expect_false("x" %in% names(environment(mod_bundle$situate)))

  # pass silly dots
  expect_error(bundle(mod_fit, boop = "bop"), class = "rlib_error_dots")

  # compare predictions
  expect_equal(mod_preds, mod_unbundled_preds)
  expect_equal(mod_preds, mod_butchered_unbundled_preds)
})
