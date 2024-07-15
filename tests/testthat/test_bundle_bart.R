test_that("bundling + unbundling bart fits", {
  skip_if_not_installed("dbarts")
  skip_if_not_installed("butcher")

  library(dbarts)

  # define a function to fit a model -------------------------------------------
  fit_model <- function() {
    mtcars$vs <- as.factor(mtcars$vs)

    set.seed(1)
    dbarts::bart(
      mtcars[c("disp", "hp")],
      mtcars$vs,
      keeptrees = TRUE,
      verbose = FALSE
    )
  }

  # pass fit fn to a new session, fit, bundle, return bundle -------------------
  mod_bundle <-
    callr::r(
      function(fit_model) {
        library(dbarts)

        mod <- fit_model()

        bundle::bundle(mod)
      },
      args = list(fit_model = fit_model)
    )

  # pass the bundle to a new session, unbundle it, return predictions ----------
  mod_unbundled_preds <-
    callr::r(
      function(mod_bundle, test_data) {
        library(dbarts)

        mod_unbundled <- bundle::unbundle(mod_bundle)

        set.seed(1)
        predict(mod_unbundled, test_data)
      },
      args = list(
        mod_bundle = mod_bundle,
        test_data = mtcars
      )
    )

  # pass fit fn to a new session, fit, butcher, bundle, return bundle ----------
  mod_butchered_bundle <-
    callr::r(
      function(fit_model) {
        library(dbarts)

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

        set.seed(1)
        predict(mod_butchered_unbundled, test_data)
      },
      args = list(
        mod_butchered_bundle = mod_butchered_bundle,
        test_data = mtcars
      )
    )

  # run expectations -----------------------------------------------------------
  mod_fit <- fit_model()
  set.seed(1)
  mod_preds <- predict(mod_fit, mtcars)

  # check classes
  expect_s3_class(mod_bundle, "bundled_bart")
  expect_s3_class(unbundle(mod_bundle), "bart")

  # ensure that the situater function didn't bring along the whole model
  expect_false("x" %in% names(environment(mod_bundle$situate)))

  # pass silly dots
  expect_error(bundle(mod_fit, boop = "bop"), class = "rlib_error_dots")

  # compare predictions
  expect_equal(mod_preds, mod_unbundled_preds)
  expect_equal(mod_preds, mod_butchered_unbundled_preds)
})

test_that("bundle.bart errors informatively with model_spec input (#64)", {
  skip_if_not_installed("parsnip")

  expect_snapshot(error = TRUE, bundle(parsnip::bart()))
})

test_that("bundle.bart errors informatively when `keeptrees = FALSE` (#64)", {
  skip_if_not_installed("dbarts")

  mtcars$vs <- as.factor(mtcars$vs)

  set.seed(1)
  fit <-
    dbarts::bart(
      mtcars[c("disp", "hp")],
      mtcars$vs,
      keeptrees = FALSE,
      verbose = FALSE
    )

  expect_snapshot(error = TRUE, bundle(fit))
})
