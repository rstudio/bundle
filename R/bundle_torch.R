#' @templateVar class a `luz_module_fitted`
#' @template title_desc
#'
#' @templateVar outclass `bundled_luz_module_fitted`
#' @templateVar default .
#' @template return_bundle
#' @family bundlers
#'
#' @param x A `luz_module_fitted` object returned from
#'   [luz::fit.luz_module_generator()].
#' @template param_unused_dots
#'
#' @details
#' For now, bundling methods for torch are only available
#' via the luz package, "a higher level API for torch providing
#' abstractions to allow for much less verbose training loops."
#'
#' @method bundle luz_module_fitted
#' @rdname bundle_torch
#' @seealso This method wraps [luz::luz_save()] and [luz::luz_load()].
#' @examplesIf rlang::is_installed(c("torch")) && identical(Sys.getenv("NOT_CRAN"), "true")
#' if (torch::torch_is_installed()) {
#' # fit model and bundle ------------------------------------------------
#' library(torch)
#' library(torchvision)
#' library(luz)
#'
#' set.seed(1)
#'
#' # example adapted from luz pkgdown article "Autoencoder"
#' dir <- tempdir()
#'
#' mnist_dataset2 <- torch::dataset(
#'   inherit = mnist_dataset,
#'   .getitem = function(i) {
#'     output <- super$.getitem(i)
#'     output$y <- output$x
#'     output
#'   }
#' )
#'
#' train_ds <- mnist_dataset2(
#'   dir,
#'   download = TRUE,
#'   transform = transform_to_tensor
#' )
#'
#' test_ds <- mnist_dataset2(
#'   dir,
#'   train = FALSE,
#'   transform = transform_to_tensor
#' )
#'
#' train_dl <- dataloader(train_ds, batch_size = 128, shuffle = TRUE)
#' test_dl <- dataloader(test_ds, batch_size = 128)
#'
#' net <- nn_module(
#'   "Net",
#'   initialize = function() {
#'     self$encoder <- nn_sequential(
#'       nn_conv2d(1, 6, kernel_size=5),
#'       nn_relu(),
#'       nn_conv2d(6, 16, kernel_size=5),
#'       nn_relu()
#'     )
#'     self$decoder <- nn_sequential(
#'       nn_conv_transpose2d(16, 6, kernel_size = 5),
#'       nn_relu(),
#'       nn_conv_transpose2d(6, 1, kernel_size = 5),
#'       nn_sigmoid()
#'     )
#'   },
#'   forward = function(x) {
#'     x %>%
#'       self$encoder() %>%
#'       self$decoder()
#'   },
#'   predict = function(x) {
#'     self$encoder(x) %>%
#'       torch_flatten(start_dim = 2)
#'   }
#' )
#'
#' mod <- net %>%
#'   setup(
#'     loss = nn_mse_loss(),
#'     optimizer = optim_adam
#'   ) %>%
#'   fit(train_dl, epochs = 1, valid_data = test_dl)
#'
#' mod_bundle <- bundle(mod)
#'
#'
#' # then, after saveRDS + readRDS or passing to a new session ----------
#' mod_unbundled <- unbundle(mod_bundle)
#'
#' mod_unbundled_preds <- predict(mod_unbundled, test_dl)
#' }
#'
#' @aliases bundle.luz_module_fitted
#' @export
bundle.luz_module_fitted <- function(x, ...) {
  rlang::check_installed("luz")
  rlang::check_installed("torch")
  rlang::check_dots_empty()

  suppressWarnings({
    con <- rawConnection(raw(), open = "wr")
    luz::luz_save(x, con)
    res <- rawConnectionValue(con)
  })

  close(con)

  bundle_constr(
    object = res,
    situate = situate_constr(function(object) {
      con <- rawConnection(object)
      on.exit({
        close(con)
      }, add = TRUE)
      res <- luz::luz_load(con)
    }),
    desc_class = class(x)[1]
  )
}
