test_that("bundling + unbundling tidymodels workflows (xgboost + step_log)", {
  skip_if_not_installed("workflows")
  skip_if_not_installed("parsnip")
  skip_if_not_installed("recipes")
  skip_if_not_installed("xgboost")
  skip_if_not_installed("butcher")

  library(workflows)
  library(parsnip)
  library(recipes)
  library(xgboost)
  library(butcher)

  # define a function to fit a model -------------------------------------------
  fit_model <- function() {
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

    mod
  }

  # pass fit fn to a new session, fit, bundle, return bundle -------------------
  mod_bundle <-
    callr::r(
      function(fit_model) {
        library(workflows)
        library(parsnip)
        library(recipes)
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
        library(workflows)
        library(parsnip)
        library(recipes)
        library(xgboost)

        mod_unbundled <- bundle::unbundle(mod_bundle)

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
        library(workflows)
        library(parsnip)
        library(recipes)
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
        library(workflows)
        library(parsnip)
        library(recipes)
        library(xgboost)

        mod_butchered_unbundled <- bundle::unbundle(mod_butchered_bundle)

        predict(mod_butchered_unbundled, test_data)
      },
      args = list(
        mod_butchered_bundle = mod_butchered_bundle,
        test_data = mtcars
      )
    )

  # run expectations -----------------------------------------------------------
  mod_fit <- fit_model()
  mod_preds <- predict(mod_fit, mtcars)

  # check classes
  expect_s3_class(mod_bundle, "bundled_workflow")
  expect_s3_class(unbundle(mod_bundle), "workflow")

  # ensure that the situater function didn't bring along the whole model
  expect_false("x" %in% names(environment(mod_bundle$situate)))

  # pass silly dots
  expect_error(bundle(mod_fit, boop = "bop"), class = "rlib_error_dots")

  # compare predictions
  expect_equal(mod_preds, mod_unbundled_preds)
  expect_equal(mod_preds, mod_butchered_unbundled_preds)
})

test_that("bundling + unbundling tidymodels workflows (lm + step_umap)", {
  skip_on_cran()
  skip_if_not_installed("workflows")
  skip_if_not_installed("parsnip")
  skip_if_not_installed("recipes")
  skip_if_not_installed("embed")
  skip_if_not_installed("butcher")
  skip_if(is.null(tensorflow::tf_version()))

  library(workflows)
  library(parsnip)
  library(recipes)
  library(embed)
  library(butcher)

  # define a function to fit a model -------------------------------------------
  fit_model <- function() {
    set.seed(1)

    spec <-
      linear_reg() %>%
      set_mode("regression") %>%
      set_engine("lm")

    rec <-
      recipe(mpg ~ ., data = mtcars) %>%
      step_umap(all_predictors(), outcome = vars(mpg), num_comp = 2)

    mod <-
      workflow() %>%
      add_model(spec) %>%
      add_recipe(rec) %>%
      fit(data = mtcars)

    mod
  }

  # pass fit fn to a new session, fit, bundle, return bundle -------------------
  mod_bundle <-
    callr::r(
      function(fit_model) {
        library(workflows)
        library(parsnip)
        library(recipes)
        library(embed)

        mod <- fit_model()

        bundle::bundle(mod)
      },
      args = list(fit_model = fit_model)
    )

  # pass the bundle to a new session, unbundle it, return predictions ----------
  mod_unbundled_preds <-
    callr::r(
      function(mod_bundle, test_data) {
        library(workflows)
        library(parsnip)
        library(recipes)
        library(embed)

        mod_unbundled <- bundle::unbundle(mod_bundle)

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
        library(workflows)
        library(parsnip)
        library(recipes)
        library(embed)

        mod <- fit_model()

        bundle::bundle(butcher::butcher(mod))
      },
      args = list(fit_model = fit_model)
    )

  # pass the bundle to a new session, unbundle it, return predictions ----------
  mod_butchered_unbundled_preds <-
    callr::r(
      function(mod_butchered_bundle, test_data) {
        library(workflows)
        library(parsnip)
        library(recipes)
        library(embed)

        mod_butchered_unbundled <- bundle::unbundle(mod_butchered_bundle)

        predict(mod_butchered_unbundled, test_data)
      },
      args = list(
        mod_butchered_bundle = mod_butchered_bundle,
        test_data = mtcars
      )
    )

  # run expectations -----------------------------------------------------------
  mod_fit <- fit_model()
  mod_preds <- predict(mod_fit, mtcars)

  # check classes
  expect_s3_class(mod_bundle, "bundled_workflow")
  expect_s3_class(unbundle(mod_bundle), "workflow")

  # ensure that the situater function didn't bring along the whole model
  expect_false("x" %in% names(environment(mod_bundle$situate)))

  # pass silly dots
  expect_error(bundle(mod_fit, boop = "bop"), class = "rlib_error_dots")

  # compare predictions
  expect_equal(mod_preds, mod_unbundled_preds)
  expect_equal(mod_preds, mod_butchered_unbundled_preds)
})
