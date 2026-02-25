test_that("bundling + unbundling catboost fits", {
  skip_if_not_installed("catboost")
  skip_if_not_installed("bonsai")
  skip_if_not_installed("parsnip")
  skip_if_not_installed("butcher")

  library(parsnip)
  library(bonsai)

  # define a function to fit a model -------------------------------------------
  fit_model <- function() {
    library(parsnip)
    library(bonsai)

    model <- boost_tree(trees = 10) %>%
      set_engine("catboost", verbose = 0, random_seed = 1) %>%
      set_mode("classification") %>%
      fit(Species ~ ., data = iris)

    model$fit
  }

  # pass fit fn to a new session, fit, bundle, return bundle -------------------
  mod_bundle <-
    callr::r(
      function(fit_model) {
        mod <- fit_model()

        bundle::bundle(mod)
      },
      args = list(fit_model = fit_model)
    )

  # pass the bundle to a new session, unbundle it, return predictions ----------
  mod_unbundled_preds <-
    callr::r(
      function(mod_bundle, test_data) {
        library(catboost)

        mod_unbundled <- bundle::unbundle(mod_bundle)

        test_pool <- catboost.load_pool(data = test_data)

        catboost.predict(mod_unbundled, test_pool, prediction_type = "Class")
      },
      args = list(
        mod_bundle = mod_bundle,
        test_data = iris[, 1:4]
      )
    )

  # pass fit fn to a new session, fit, butcher, bundle, return bundle ----------
  mod_butchered_bundle <-
    callr::r(
      function(fit_model) {
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
        library(catboost)

        mod_butchered_unbundled <- unbundle(mod_butchered_bundle)

        test_pool <- catboost.load_pool(data = test_data)

        catboost.predict(
          mod_butchered_unbundled,
          test_pool,
          prediction_type = "Class"
        )
      },
      args = list(
        mod_butchered_bundle = mod_butchered_bundle,
        test_data = iris[, 1:4]
      )
    )

  # run expectations -----------------------------------------------------------
  mod_fit <- fit_model()
  test_pool <- catboost::catboost.load_pool(data = iris[, 1:4])
  mod_preds <- catboost::catboost.predict(
    mod_fit,
    test_pool,
    prediction_type = "Class"
  )

  # check classes
  expect_s3_class(mod_bundle, "bundled_catboost.Model")
  expect_s3_class(unbundle(mod_bundle), "catboost.Model")

  # ensure that the situater function didn't bring along the whole model
  expect_false("x" %in% names(environment(mod_bundle$situate)))

  # pass silly dots
  expect_error(bundle(mod_fit, boop = "bop"), class = "rlib_error_dots")

  # compare predictions
  expect_equal(mod_preds, mod_unbundled_preds)
  expect_equal(mod_preds, mod_butchered_unbundled_preds)

  # verify metadata is preserved
  mod_unbundled <- unbundle(mod_bundle)
  expect_identical(mod_unbundled$tree_count, mod_fit$tree_count)
  expect_identical(mod_unbundled$learning_rate, mod_fit$learning_rate)
  expect_identical(mod_unbundled$feature_count, mod_fit$feature_count)
})

test_that("bundling + unbundling bonsai catboost model_fit", {
  skip_if_not_installed("catboost")
  skip_if_not_installed("bonsai")
  skip_if_not_installed("parsnip")

  # define a function to fit a model -------------------------------------------
  fit_model <- function() {
    library(parsnip)
    library(bonsai)

    model <- boost_tree(trees = 10) %>%
      set_engine("catboost", verbose = 0, random_seed = 1) %>%
      set_mode("classification") %>%
      fit(Species ~ ., data = iris)

    model
  }

  # pass fit fn to a new session, fit, bundle, and also get preds before bundle
  result <-
    callr::r(
      function(fit_model, test_data) {
        library(parsnip)
        library(bonsai)

        mod <- fit_model()

        # Get predictions before bundling
        preds_before <- predict(mod, test_data)

        list(
          bundle = bundle::bundle(mod),
          preds_before = preds_before
        )
      },
      args = list(fit_model = fit_model, test_data = iris)
    )

  mod_bundle <- result$bundle
  mod_preds <- result$preds_before

  # pass the bundle to a new session, unbundle it, return predictions ----------
  mod_unbundled_preds <-
    callr::r(
      function(mod_bundle, test_data) {
        library(parsnip)
        library(bonsai)

        mod_unbundled <- bundle::unbundle(mod_bundle)

        predict(mod_unbundled, test_data)
      },
      args = list(
        mod_bundle = mod_bundle,
        test_data = iris
      )
    )

  # run expectations -----------------------------------------------------------
  # check classes
  expect_s3_class(mod_bundle, "bundled_model_fit")

  # compare predictions - the unbundled model should give same preds as original
  expect_equal(mod_preds, mod_unbundled_preds)
})
