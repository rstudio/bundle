#' @templateVar class a `keras`
#' @template title_desc
#'
#' @templateVar outclass `bundled_keras`
#' @templateVar default .
#' @template return_bundle
#' @family bundlers
#'
#' @param x An object returned from modeling functions in the
#'   [keras][keras::keras-package] package.
#' @template param_unused_dots
#' @rdname bundle_keras
#' @seealso This method wraps [keras::save_model_tf()] and
#'   [keras::load_model_tf()].
#' @details This bundler does not currently support custom keras extensions,
#'   such as use of a [keras::new_layer_class()] or custom metric function.
#'   In such situations, consider using [keras::with_custom_object_scope()].
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
  rlang::check_installed("withr")
  rlang::check_dots_empty()

  file_loc <- fs::file_temp(pattern = "bundle", ext = ".tar.gz")
  tmp_dir <- fs::dir_create(tempdir(), "bundle")
  keras::save_model_tf(x, tmp_dir)

  withr::with_dir(
    tmp_dir,
    utils::tar(
      tarfile = file_loc,
      compression = "gzip",
      tar = "internal"
    )
  )

  serialized <- serialize(file_loc, connection = NULL)

  bundle_constr(
    object = serialized,
    situate = situate_constr(function(object) {
      unbundle_dir <- fs::dir_create(tempdir(), "unbundle")
      utils::untar(unserialize(object), exdir = unbundle_dir)
      res <- keras::load_model_tf(unbundle_dir)

      res
    }),
    desc_class = "keras"
  )
}
