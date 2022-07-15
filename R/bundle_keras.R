#' @templateVar class a `keras`
#' @template title_desc
#'
#' @templateVar outclass `bundled_keras`
#' @templateVar default \dontshow{.}
#' @template return_bundle
#'
#' @param x An object returned from modeling functions in the
#'   [keras][keras::keras-package] package.
#' @template param_unused_dots
#' @rdname bundle_keras
#' @seealso This method wraps [keras::serialize_model()] and
#'   [keras::unserialize_model()].
#' @examplesIf FALSE
#' # fit model and bundle ------------------------------------------------
#' library(keras)
#'
#' set.seed(1)
#'
#' mnist <- dataset_mnist()
#' x_train <- mnist$train$x
#' y_train <- mnist$train$y
#' x_test <- mnist$test$x
#' y_test <- mnist$test$y
#'
#' x_train <- array_reshape(x_train, c(nrow(x_train), 784))
#' x_test <- array_reshape(x_test, c(nrow(x_test), 784))
#'
#' x_train <- x_train / 255
#' x_test <- x_test / 255
#'
#' y_train <- to_categorical(y_train, 10)
#' y_test <- to_categorical(y_test, 10)
#'
#' mod <- keras_model_sequential()
#'
#' mod %>%
#'   layer_dense(units = 128, activation = 'relu', input_shape = c(784)) %>%
#'   layer_dropout(rate = 0.4) %>%
#'   layer_dense(units = 64, activation = 'relu') %>%
#'   layer_dropout(rate = 0.3) %>%
#'   layer_dense(units = 10, activation = 'softmax')
#'
#' mod %>% compile(
#'   loss = 'categorical_crossentropy',
#'   optimizer = optimizer_rmsprop(),
#'   metrics = c('accuracy')
#' )
#'
#' mod %>% fit(
#'   x_train, y_train,
#'   epochs = 5, batch_size = 128,
#'   validation_split = 0.2,
#'   verbose = 0
#' )
#'
#' mod_bundle <- bundle(mod)
#'
#' # then, after saveRDS + readRDS or passing to a new session ----------
#' mod_unbundled <- unbundle(mod_bundle)
#'
#' predict(mod_unbundled, x_test)
#'
#' @aliases bundle.keras.engine.training.Model
#' @method bundle keras.engine.training.Model
#' @export
bundle.keras.engine.training.Model <- function(x, ...) {
  rlang::check_installed("keras")
  rlang::check_dots_empty()

  serialized <- keras::serialize_model(x)

  bundle_constr(
    object = serialized,
    situate = situate_constr(function(object) {
      res <- keras::unserialize_model(object)

      res
    }),
    desc_class = "keras",
    pkg_versions = c("keras" = utils::packageVersion("keras"))
  )
}
