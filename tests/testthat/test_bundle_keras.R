test_that("bundling + unbundling keras fits", {
  skip_if_not_installed("keras")
  library(keras)

  set.seed(1)

  # example fit adapted from keras basics vignette
  mnist <- dataset_mnist()
  x_train <- mnist$train$x
  y_train <- mnist$train$y
  x_test <- mnist$test$x
  y_test <- mnist$test$y

  x_train <- array_reshape(x_train, c(nrow(x_train), 784))
  x_test <- array_reshape(x_test, c(nrow(x_test), 784))

  x_train <- x_train / 255
  x_test <- x_test / 255

  y_train <- to_categorical(y_train, 10)
  y_test <- to_categorical(y_test, 10)

  mod <- keras_model_sequential()

  mod %>%
    layer_dense(units = 128, activation = 'relu', input_shape = c(784)) %>%
    layer_dropout(rate = 0.4) %>%
    layer_dense(units = 64, activation = 'relu') %>%
    layer_dropout(rate = 0.3) %>%
    layer_dense(units = 10, activation = 'softmax')

  mod %>% compile(
    loss = 'categorical_crossentropy',
    optimizer = optimizer_rmsprop(),
    metrics = c('accuracy')
  )

  mod %>% fit(
    x_train, y_train,
    epochs = 5, batch_size = 128,
    validation_split = 0.2,
    verbose = 0
  )

  mod_bundle <- bundle(mod)
  mod_unbundled <- unbundle(mod_bundle)

  expect_s3_class(mod_bundle, "bundled_keras")
  expect_s3_class(mod_unbundled, "keras.engine.training.Model")

  mod_preds <- predict(mod, x_test)
  mod_unbundled_preds <- predict(mod_unbundled, x_test)

  expect_equal(mod_preds, mod_unbundled_preds)

  # only want bundled model and original preds to persist.
  # test again in new R session:
  mod_unbundled_preds_new <- callr::r(
    function(mod_bundle, x_test) {
      library(bundle)
      library(keras)

      mod_unbundled <- unbundle(mod_bundle)
      predict(mod_unbundled, x_test)
    },
    args = list(
      mod_bundle = mod_bundle,
      x_test = x_test
    )
  )

  expect_equal(mod_preds, mod_unbundled_preds_new)
})
