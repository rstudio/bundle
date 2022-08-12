test_that("bundling + unbundling torch fits", {
  skip_if_not_installed("torch")
  skip_if_not_installed("torchvision")
  skip_if_not_installed("luz")
  skip_if_not_installed("butcher")
  skip_on_cran()

  library(torch)
  library(torchvision)
  library(luz)
  library(butcher)

  if (Sys.getenv("TORCH_HOME") == "") {
    skip("pytorch or lantern not installed")
  }

  set.seed(1)

  # example adapted from luz pkgdown article "Autoencoder"
  dir <- tempdir()

  mnist_dataset2 <- torch::dataset(
    inherit = mnist_dataset,
    .getitem = function(i) {
      output <- super$.getitem(i)
      output$y <- output$x
      output
    }
  )

  train_ds <- mnist_dataset2(
    dir,
    download = TRUE,
    transform = transform_to_tensor
  )

  test_ds <- mnist_dataset2(
    dir,
    train = FALSE,
    transform = transform_to_tensor
  )

  train_dl <- dataloader(train_ds, batch_size = 128, shuffle = TRUE)
  test_dl <- dataloader(test_ds, batch_size = 128)

  net <- nn_module(
    "Net",
    initialize = function() {
      self$encoder <- nn_sequential(
        nn_conv2d(1, 6, kernel_size=5),
        nn_relu(),
        nn_conv2d(6, 16, kernel_size=5),
        nn_relu()
      )
      self$decoder <- nn_sequential(
        nn_conv_transpose2d(16, 6, kernel_size = 5),
        nn_relu(),
        nn_conv_transpose2d(6, 1, kernel_size = 5),
        nn_sigmoid()
      )
    },
    forward = function(x) {
      x %>%
        self$encoder() %>%
        self$decoder()
    },
    predict = function(x) {
      self$encoder(x) %>%
        torch_flatten(start_dim = 2)
    }
  )

  mod <- net %>%
    setup(
      loss = nn_mse_loss(),
      optimizer = optim_adam
    ) %>%
    fit(train_dl, epochs = 1, valid_data = test_dl)

  mod_bundle <- bundle(mod)
  mod_unbundled <- unbundle(mod_bundle)

  expect_s3_class(mod_bundle, "bundled_luz_module_fitted")
  expect_s3_class(mod_unbundled, "luz_module_fitted")

  # ensure that the situater function didn't bring along the whole model
  expect_false("x" %in% names(environment(mod_bundle$situate)))

  expect_error(bundle(mod, boop = "bop"), class = "rlib_error_dots")

  mod_preds <- as_array(predict(mod, test_dl))
  mod_unbundled_preds <- as_array(predict(mod_unbundled, test_dl))

  expect_equal(mod_preds[1:100,1:100], mod_unbundled_preds[1:100,1:100])

  # only want bundled model and original preds to persist.
  # test again in new R session:
  predict_bundle_torch <-
    function(mod_bundle, test_dl) {
      library(bundle)
      library(torch)
      library(luz)


      mod_unbundled <- unbundle(mod_bundle)
      as_array(predict(mod_unbundled, test_dl))
    }

  mod_unbundled_preds_new <- callr::r(
    predict_bundle_torch,
    args = list(
      mod_bundle = mod_bundle,
      test_dl = test_dl
    )
  )

  expect_equal(mod_preds[1:100,1:100], mod_unbundled_preds_new[1:100,1:100])

  # interaction with butcher
  expect_silent({
    mod_bundle_butchered <- bundle(butcher(mod))
  })

  mod_unbundled_preds_butchered <- callr::r(
    predict_bundle_torch,
    args = list(
      mod_bundle = mod_bundle_butchered,
      test_dl = test_dl
    )
  )

  expect_equal(mod_preds[1:100,1:100], mod_unbundled_preds_butchered[1:100,1:100])
})
