test_that("bundling + unbundling h2o fits (regression)", {
  skip_on_cran()
  skip_if(!interactive())
  skip_if_not_installed("h2o")
  skip_if_not_installed("butcher")

  library(h2o)
  library(butcher)

  test_data <- mtcars

  # define a function to fit a model -------------------------------------------
  fit_model <- function() {
    reg_data <- as.h2o(mtcars)

    reg_fit <-
      h2o.glm(
        x = colnames(reg_data)[2:length(colnames(reg_data))],
        y = colnames(reg_data)[1],
        training_frame = reg_data
      )
  }

  # pass fit fn to a new session, fit, bundle, return bundle -------------------
  mod_bundle <-
    callr::r(
      function(fit_model) {
        library(h2o)

        h2o.init()

        mod <- fit_model()

        res <- bundle::bundle(mod)

        h2o.shutdown(prompt = FALSE)

        res
      },
      args = list(fit_model = fit_model)
    )

  # pass the bundle to a new session, unbundle it, return predictions ----------
  mod_unbundled_preds <-
    callr::r(
      function(mod_bundle, test_data) {
        library(h2o)

        h2o.init()

        mod_unbundled <- bundle::unbundle(mod_bundle)

        res <- predict(mod_unbundled, as.h2o(test_data))

        res <- as.data.frame(res)

        h2o.shutdown(prompt = FALSE)

        res
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
        library(h2o)

        h2o.init()

        mod <- fit_model()

        res <- bundle::bundle(butcher::butcher(mod))

        h2o.shutdown(prompt = FALSE)

        res
      },
      args = list(fit_model = fit_model)
    )

  # pass the bundle to a new session, unbundle it, return predictions ----------
  mod_butchered_unbundled_preds <-
    callr::r(
      function(mod_butchered_bundle, test_data) {
        library(h2o)

        h2o.init()

        mod_butchered_unbundled <- bundle::unbundle(mod_butchered_bundle)

        res <- predict(mod_butchered_unbundled, as.h2o(test_data))

        res <- as.data.frame(res)

        h2o.shutdown(prompt = FALSE)

        res

      },
      args = list(
        mod_butchered_bundle = mod_butchered_bundle,
        test_data = test_data
      )
    )

  # run expectations -----------------------------------------------------------
  h2o.init()

  mod_fit <- fit_model()
  mod_preds <- predict(mod_fit, as.h2o(test_data))
  mod_preds <- as.data.frame(mod_preds)

  # pass silly dots
  expect_error(bundle(mod_fit, boop = "bop"), class = "rlib_error_dots")

  # check classes
  expect_s3_class(mod_bundle, "bundled_h2o")
  expect_s4_class(unbundle(mod_bundle), "H2ORegressionModel")

  h2o.shutdown(prompt = FALSE)

  # ensure that the situater function didn't bring along the whole model
  expect_false("x" %in% names(environment(mod_bundle$situate)))

  # compare predictions
  expect_equal(mod_preds, mod_unbundled_preds)
  expect_equal(mod_preds, mod_butchered_unbundled_preds)

})

test_that("bundling + unbundling h2o fits (binary)", {
  skip_if(!interactive())
  skip_if_not_installed("h2o")
  skip_if_not_installed("modeldata")
  skip_if_not_installed("butcher")

  library(h2o)
  library(modeldata)
  library(butcher)

  set.seed(2)

  test_data <-
    modeldata::sim_noise(100, 5, outcome = "classification", num_classes = 2)

  # define a function to fit a model -------------------------------------------
  fit_model <- function() {
    set.seed(1)

    bin_data <-
      as.h2o(
        modeldata::sim_noise(100, 5, outcome = "classification", num_classes = 2)
      )

    bin_fit <-
      h2o.glm(
        x = paste0("noise_", 1:5),
        y = "class",
        training_frame = bin_data
      )

    bin_fit
  }

  # pass fit fn to a new session, fit, bundle, return bundle -------------------
  mod_bundle <-
    callr::r(
      function(fit_model) {
        library(h2o)

        h2o.init()

        mod <- fit_model()

        res <- bundle::bundle(mod)

        h2o.shutdown(prompt = FALSE)

        res
      },
      args = list(fit_model = fit_model)
    )

  # pass the bundle to a new session, unbundle it, return predictions ----------
  mod_unbundled_preds <-
    callr::r(
      function(mod_bundle, test_data) {
        library(h2o)

        h2o.init()

        mod_unbundled <- bundle::unbundle(mod_bundle)

        res <- predict(mod_unbundled, as.h2o(test_data))

        res <- as.data.frame(res)

        h2o.shutdown(prompt = FALSE)

        res
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
        library(h2o)

        h2o.init()

        mod <- fit_model()

        res <- bundle::bundle(butcher::butcher(mod))

        h2o.shutdown(prompt = FALSE)

        res
      },
      args = list(fit_model = fit_model)
    )

  # pass the bundle to a new session, unbundle it, return predictions ----------
  mod_butchered_unbundled_preds <-
    callr::r(
      function(mod_butchered_bundle, test_data) {
        library(h2o)

        h2o.init()

        mod_butchered_unbundled <- bundle::unbundle(mod_butchered_bundle)

        res <- predict(mod_butchered_unbundled, as.h2o(test_data))

        res <- as.data.frame(res)

        h2o.shutdown(prompt = FALSE)

        res
      },
      args = list(
        mod_butchered_bundle = mod_butchered_bundle,
        test_data = test_data
      )
    )

  # run expectations -----------------------------------------------------------
  h2o.init()

  mod_fit <- fit_model()
  h2o_test_data <- as.h2o(test_data)
  mod_preds <- predict(mod_fit, h2o_test_data)
  mod_preds <- as.data.frame(mod_preds)

  # check classes
  expect_s3_class(mod_bundle, "bundled_h2o")
  expect_s4_class(unbundle(mod_bundle), "H2OBinomialModel")

  # pass silly dots
  expect_error(bundle(mod_fit, boop = "bop"), class = "rlib_error_dots")

  h2o.shutdown(prompt = FALSE)

  # ensure that the situater function didn't bring along the whole model
  expect_false("x" %in% names(environment(mod_bundle$situate)))

  # compare predictions
  expect_equal(mod_preds, mod_unbundled_preds)
  expect_equal(mod_preds, mod_butchered_unbundled_preds)


})

test_that("bundling + unbundling h2o fits (multinomial)", {
  skip_if(!interactive())
  skip_if_not_installed("h2o")
  skip_if_not_installed("modeldata")
  skip_if_not_installed("butcher")

  library(h2o)
  library(modeldata)
  library(butcher)

  set.seed(2)

  test_data <-
    modeldata::sim_noise(100, 5, outcome = "classification", num_classes = 3)

  # define a function to fit a model -------------------------------------------
  fit_model <- function() {
    set.seed(1)

    multi_data <-
      as.h2o(
        modeldata::sim_noise(100, 5, outcome = "classification", num_classes = 3)
      )

    multi_fit <-
      h2o.glm(
        x = paste0("noise_", 1:5),
        y = "class",
        training_frame = multi_data
      )

    multi_fit
  }

  # pass fit fn to a new session, fit, bundle, return bundle -------------------
  mod_bundle <-
    callr::r(
      function(fit_model) {
        library(h2o)

        h2o.init()

        mod <- fit_model()

        res <- bundle::bundle(mod)

        h2o.shutdown(prompt = FALSE)

        res
      },
      args = list(fit_model = fit_model)
    )

  # pass the bundle to a new session, unbundle it, return predictions ----------
  mod_unbundled_preds <-
    callr::r(
      function(mod_bundle, test_data) {
        library(h2o)

        h2o.init()

        mod_unbundled <- bundle::unbundle(mod_bundle)

        res <- predict(mod_unbundled, as.h2o(test_data))

        res <- as.data.frame(res)

        h2o.shutdown(prompt = FALSE)

        res
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
        library(h2o)

        h2o.init()

        mod <- fit_model()

        res <- bundle::bundle(butcher::butcher(mod))

        h2o.shutdown(prompt = FALSE)

        res
      },
      args = list(fit_model = fit_model)
    )

  # pass the bundle to a new session, unbundle it, return predictions ----------
  mod_butchered_unbundled_preds <-
    callr::r(
      function(mod_butchered_bundle, test_data) {
        library(h2o)

        h2o.init()

        mod_butchered_unbundled <- bundle::unbundle(mod_butchered_bundle)

        res <- predict(mod_butchered_unbundled, as.h2o(test_data))

        res <- as.data.frame(res)

        h2o.shutdown(prompt = FALSE)

        res
      },
      args = list(
        mod_butchered_bundle = mod_butchered_bundle,
        test_data = test_data
      )
    )

  # run expectations -----------------------------------------------------------
  h2o.init()

  mod_fit <- fit_model()
  mod_preds <- predict(mod_fit, as.h2o(test_data))
  mod_preds <- as.data.frame(mod_preds)

  # check classes
  expect_s3_class(mod_bundle, "bundled_h2o")
  expect_s4_class(unbundle(mod_bundle), "H2OMultinomialModel")

  # pass silly dots
  expect_error(bundle(mod_fit, boop = "bop"), class = "rlib_error_dots")

  h2o.shutdown(prompt = FALSE)

  # ensure that the situater function didn't bring along the whole model
  expect_false("x" %in% names(environment(mod_bundle$situate)))

  # compare predictions
  expect_equal(mod_preds, mod_unbundled_preds)
  expect_equal(mod_preds, mod_butchered_unbundled_preds)
})

test_that("bundling + unbundling h2o fits (automl regression)", {
  skip_if(!interactive())
  skip_if_not_installed("h2o")
  skip_if_not_installed("butcher")

  library(h2o)
  library(butcher)

  test_data <- mtcars

  # define a function to fit a model -------------------------------------------
  fit_model <- function() {
    reg_data <-
      as.h2o(mtcars)

    reg_fit <-
      h2o.automl(
        x = colnames(reg_data)[2:length(colnames(reg_data))],
        y = colnames(reg_data)[1],
        training_frame = reg_data,
        max_runtime_secs = 5
      )

    reg_fit
  }

  # pass fit fn to a new session, fit, bundle, return bundle -------------------
  mod_bundle <-
    callr::r(
      function(fit_model) {
        library(h2o)

        h2o.init()

        mod <- fit_model()

        res <- bundle::bundle(mod)

        h2o.shutdown(prompt = FALSE)

        res
      },
      args = list(fit_model = fit_model)
    )

  # pass the bundle to a new session, unbundle it, return predictions ----------
  mod_unbundled_preds <-
    callr::r(
      function(mod_bundle, test_data) {
        library(h2o)

        h2o.init()

        mod_unbundled <- bundle::unbundle(mod_bundle)

        res <- predict(mod_unbundled, as.h2o(test_data))

        res <- as.data.frame(res)

        h2o.shutdown(prompt = FALSE)

        res
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
        library(h2o)

        h2o.init()

        mod <- fit_model()

        res <- bundle::bundle(butcher::butcher(mod))

        h2o.shutdown(prompt = FALSE)

        res
      },
      args = list(fit_model = fit_model)
    )

  # pass the bundle to a new session, unbundle it, return predictions ----------
  mod_butchered_unbundled_preds <-
    callr::r(
      function(mod_butchered_bundle, test_data) {
        library(h2o)

        h2o.init()

        mod_butchered_unbundled <- bundle::unbundle(mod_butchered_bundle)

        res <- predict(mod_butchered_unbundled, as.h2o(test_data))

        res <- as.data.frame(res)

        h2o.shutdown(prompt = FALSE)

        res
      },
      args = list(
        mod_butchered_bundle = mod_butchered_bundle,
        test_data = test_data
      )
    )

  # run expectations -----------------------------------------------------------
  h2o.init()

  mod_fit <- fit_model()
  mod_preds <- predict(mod_fit, as.h2o(test_data))
  mod_preds <- as.data.frame(mod_preds)

  # check classes
  expect_s3_class(mod_bundle, "bundled_h2o")
  expect_s4_class(unbundle(mod_bundle), "H2ORegressionModel")

  # pass silly dots
  expect_error(bundle(mod_fit, boop = "bop"), class = "rlib_error_dots")

  h2o.shutdown(prompt = FALSE)

  # ensure that the situater function didn't bring along the whole model
  expect_false("x" %in% names(environment(mod_bundle$situate)))

  # compare predictions
  expect_equal(mod_preds, mod_unbundled_preds)
  expect_equal(mod_preds, mod_butchered_unbundled_preds)
})

test_that("bundling + unbundling h2o fits (automl classification)", {
  skip_if(!interactive())
  skip_if_not_installed("h2o")
  skip_if_not_installed("modeldata")
  skip_if_not_installed("butcher")

  library(h2o)
  library(modeldata)
  library(butcher)

  set.seed(2)

  test_data <-
    modeldata::sim_noise(100, 5, outcome = "classification", num_classes = 2)

  # define a function to fit a model -------------------------------------------
  fit_model <- function() {
    set.seed(1)

    bin_data <-
      as.h2o(
        modeldata::sim_noise(100, 5, outcome = "classification", num_classes = 2)
      )

    bin_fit <-
      h2o.automl(
        x = paste0("noise_", 1:5),
        y = "class",
        training_frame = bin_data,
        max_runtime_secs = 5
      )

    bin_fit
  }

  # pass fit fn to a new session, fit, bundle, return bundle -------------------
  mod_bundle <-
    callr::r(
      function(fit_model) {
        library(h2o)

        h2o.init()

        mod <- fit_model()

        res <- bundle::bundle(mod)

        h2o.shutdown(prompt = FALSE)

        res
      },
      args = list(fit_model = fit_model)
    )

  # pass the bundle to a new session, unbundle it, return predictions ----------
  mod_unbundled_preds <-
    callr::r(
      function(mod_bundle, test_data) {
        library(h2o)

        h2o.init()

        mod_unbundled <- bundle::unbundle(mod_bundle)

        res <- predict(mod_unbundled, as.h2o(test_data))

        res <- as.data.frame(res)

        h2o.shutdown(prompt = FALSE)

        res
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
        library(h2o)

        h2o.init()

        mod <- fit_model()

        res <- bundle::bundle(butcher::butcher(mod))

        h2o.shutdown(prompt = FALSE)

        res
      },
      args = list(fit_model = fit_model)
    )

  # pass the bundle to a new session, unbundle it, return predictions ----------
  mod_butchered_unbundled_preds <-
    callr::r(
      function(mod_butchered_bundle, test_data) {
        library(h2o)

        h2o.init()

        mod_butchered_unbundled <- bundle::unbundle(mod_butchered_bundle)

        res <- predict(mod_butchered_unbundled, as.h2o(test_data))

        res <- as.data.frame(res)

        h2o.shutdown(prompt = FALSE)

        res
      },
      args = list(
        mod_butchered_bundle = mod_butchered_bundle,
        test_data = test_data
      )
    )

  # run expectations -----------------------------------------------------------
  h2o.init()

  mod_fit <- fit_model()
  mod_preds <- predict(mod_fit, as.h2o(test_data))
  mod_preds <- as.data.frame(mod_preds)

  # check classes
  expect_s3_class(mod_bundle, "bundled_h2o")
  expect_s4_class(unbundle(mod_bundle), "H2OBinomialModel")

  # pass silly dots
  expect_error(bundle(mod_fit, boop = "bop"), class = "rlib_error_dots")

  h2o.shutdown(prompt = FALSE)

  # ensure that the situater function didn't bring along the whole model
  expect_false("x" %in% names(environment(mod_bundle$situate)))

  # compare predictions
  expect_equal(mod_preds$data, mod_unbundled_preds$data)
  expect_equal(mod_preds$data, mod_butchered_unbundled_preds$data)
})
