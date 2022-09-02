# Testing strategy for bundle

Many bundling methods rely on temporary files to interface with native serialization methods from modeling packages. However, the resulting bundles ought not to depend on the existence of those temporary files, which likely will not exist at `unbundle()` time. 

The testing strategy for the package thus must pay close attention to when temporary files will persist. Note that, within an R session, the output of `tempdir()` is stable and (kindof) unique, though that directory will be deleted when the session is closed.

The testing strategy for bundles acknowledges this:

* Define a function to fit a model
	* Pass that function to a new session, run it, bundle the output, return the bundle
      		* Pass the bundle (and test data) to a new session, unbundle it, generate and return predictions
	* Pass that function to a new session, run it, butcher the output, bundle the butchered out, return the bundle
      		* Pass the bundle (and test data) to a new session, unbundle it, generate and return predictions

At that point, we have the properly generated predictions from the bundled and butchered+bundled objects (and know whether either of those callr sessions errored out). We're then free to run all testthat expectations and compare the predictions of each model object.

The template for this testing strategy with an example model-supplying package modLibrary is as follows:

``` r
test_that("bundling + unbundling modLibrary fits", {
  skip_if_not_installed("modLibrary")
  skip_if_not_installed("butcher")

  library(modLibrary)

  test_data <- mtcars

  # define a function to fit a model -------------------------------------------
  fit_model <- function() {
    # code to fit a model using modLibrary
  }

  # pass fit fn to a new session, fit, bundle, return bundle -------------------
  mod_bundle <-
    callr::r(
      function(fit_model) {
        library(modLibrary)

        mod <- fit_model()

        bundle::bundle(mod)
      },
      args = list(fit_model = fit_model)
    )

  # pass the bundle to a new session, unbundle it, return predictions ----------
  mod_unbundled_preds <-
    callr::r(
      function(mod_bundle, test_data) {
        library(modLibrary)

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
        library(modLibrary)

        mod <- fit_model()

        bundle::bundle(butcher::butcher(mod))
      },
      args = list(fit_model = fit_model)
    )

  # pass the bundle to a new session, unbundle it, return predictions ----------
  mod_butchered_unbundled_preds <-
    callr::r(
      function(mod_butchered_bundle, test_data) {
        library(modLibrary)

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
  expect_s3_class(mod_bundle, "bundled_mod_class")
  expect_s3_class(unbundle(mod_bundle), "mod_class")

  # ensure that the situater function didn't bring along the whole model
  expect_false("x" %in% names(environment(mod_bundle$situate)))

  # pass silly dots
  expect_error(bundle(mod_fit, boop = "bop"), class = "rlib_error_dots")

  # compare predictions
  expect_equal(mod_preds, mod_unbundled_preds)
  expect_equal(mod_preds, mod_butchered_unbundled_preds)
})
```
