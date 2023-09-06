test_that("bundling + unbundling keras fits", {
  skip_on_cran()
  skip_if_not_installed("keras")
  skip_if_not_installed("butcher")
  skip_if(is.null(tensorflow::tf_version()))

  library(keras)

  test_data <-
    mtcars[26:32, 2:ncol(mtcars)] %>%
    as.matrix() %>%
    scale()

  # define a function to fit a model -------------------------------------------
  fit_model <- function() {
    cars <- mtcars[1:25, ] %>%
      as.matrix() %>%
      scale()

    x_train <- cars[, 2:ncol(cars)]
    y_train <- cars[, 1]

    keras_fit <-
      keras_model_sequential()  %>%
      layer_dense(units = 1, input_shape = ncol(x_train), activation = 'linear') %>%
      compile(
        loss = 'mean_squared_error',
        optimizer = optimizer_adam(learning_rate = .01)
      )

    keras_fit %>%
      fit(
        x = x_train, y = y_train,
        epochs = 100, batch_size = 1,
        verbose = 0
      )

    keras_fit
  }

  # pass fit fn to a new session, fit, bundle, return bundle -------------------
  mod_bundle <-
    callr::r(
      function(fit_model) {
        library(keras)

        mod <- fit_model()

        bundle::bundle(mod)
      },
      args = list(fit_model = fit_model)
    )

  # pass the bundle to a new session, unbundle it, return predictions ----------
  mod_unbundled_preds <-
    callr::r(
      function(mod_bundle, test_data) {
        library(keras)

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
        library(keras)

        mod <- fit_model()

        bundle::bundle(butcher::butcher(mod))
      },
      args = list(fit_model = fit_model)
    )

  # pass the bundle to a new session, unbundle it, return predictions ----------
  mod_butchered_unbundled_preds <-
    callr::r(
      function(mod_butchered_bundle, test_data) {
        library(keras)

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
  expect_s3_class(mod_bundle, "bundled_keras")
  expect_s3_class(unbundle(mod_bundle), "keras.engine.training.Model")

  # ensure that the situater function didn't bring along the whole model
  expect_false("x" %in% names(environment(mod_bundle$situate)))

  # pass silly dots
  expect_error(bundle(mod_fit, boop = "bop"), class = "rlib_error_dots")

  # compare predictions
  expect_equal(mod_preds, mod_unbundled_preds)
  expect_equal(mod_preds, mod_butchered_unbundled_preds)
})
