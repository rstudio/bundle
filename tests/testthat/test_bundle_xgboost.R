test_that("bundling + unbundling xgboost fits", {
  skip_if_not_installed("xgboost")
  skip_if_not_installed("butcher")

  library(xgboost)

  data(agaricus.test)

  # define a function to fit a model -------------------------------------------
  fit_model <- function() {
    set.seed(1)

    data(agaricus.train)

    xgb <- xgboost(data = agaricus.train$data, label = agaricus.train$label,
                   max_depth = 2, eta = 1, nthread = 2, nrounds = 2,
                   objective = "binary:logistic")

    xgb
  }

  # pass fit fn to a new session, fit, bundle, return bundle -------------------
  mod_bundle <-
    callr::r(
      function(fit_model) {
        library(xgboost)

        mod <- fit_model()

        bundle::bundle(mod)
      },
      args = list(fit_model = fit_model)
    )

  # pass the bundle to a new session, unbundle it, return predictions ----------
  mod_unbundled_preds <-
    callr::r(
      function(mod_bundle, test_data) {
        library(xgboost)

        mod_unbundled <- bundle::unbundle(mod_bundle)

        predict(mod_unbundled, test_data)
      },
      args = list(
        mod_bundle = mod_bundle,
        test_data = agaricus.test$data
      )
    )

  # pass fit fn to a new session, fit, butcher, bundle, return bundle ----------
  mod_butchered_bundle <-
    callr::r(
      function(fit_model) {
        library(xgboost)

        mod <- fit_model()

        bundle::bundle(butcher::butcher(mod))
      },
      args = list(fit_model = fit_model)
    )

  # pass the bundle to a new session, unbundle it, return predictions ----------
  mod_butchered_unbundled_preds <-
    callr::r(
      function(mod_butchered_bundle, test_data) {
        library(bundle)

        mod_butchered_unbundled <- unbundle(mod_butchered_bundle)

        predict(mod_butchered_unbundled, test_data)
      },
      args = list(
        mod_butchered_bundle = mod_butchered_bundle,
        test_data = agaricus.test$data
      )
    )

  # run expectations -----------------------------------------------------------
  data(agaricus.test)

  mod_fit <- fit_model()
  mod_preds <- predict(mod_fit, agaricus.test$data)

  # check classes
  expect_s3_class(mod_bundle, "bundled_xgb.Booster")
  expect_s3_class(unbundle(mod_bundle), "xgb.Booster")

  # ensure that the situater function didn't bring along the whole model
  expect_false("x" %in% names(environment(mod_bundle$situate)))

  # pass silly dots
  expect_error(bundle(mod_fit, boop = "bop"), class = "rlib_error_dots")

  # compare predictions
  expect_equal(mod_preds, mod_unbundled_preds)
  expect_equal(mod_preds, mod_butchered_unbundled_preds)
})
