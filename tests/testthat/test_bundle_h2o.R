test_that("bundling + unbundling h2o fits", {
  skip_if_not_installed("h2o")
  skip_if_not_installed("modeldata")
  library(h2o)
  library(modeldata)

  set.seed(1)

  h2o.init()

  n <- 100
  p <- 5

  reg_data <- mtcars %>% as.h2o()
  bin_data <- sim_noise(n, p, outcome = "classification", num_classes = 2) %>% as.h2o()
  multi_data <- sim_noise(n, p, outcome = "classification", num_classes = 3) %>% as.h2o()

  reg_fit <-
    h2o.glm(
      x = colnames(reg_data)[2:length(colnames(reg_data))],
      y = colnames(reg_data)[1],
      training_frame = reg_data
    )

  bin_fit <-
    h2o.glm(
      x = paste0("noise_", 1:5),
      y = "class",
      training_frame = bin_data
    )

  multi_fit <-
    h2o.glm(
      x = paste0("noise_", 1:5),
      y = "class",
      training_frame = multi_data
    )

  reg_bundle <- bundle(reg_fit)
  bin_bundle <- bundle(bin_fit)
  multi_bundle <- bundle(multi_fit)

  reg_unbundled <- unbundle(reg_bundle)
  bin_unbundled <- unbundle(bin_bundle)
  multi_unbundled <- unbundle(multi_bundle)

  reg_preds <- predict(reg_fit, reg_data)
  bin_preds <- predict(bin_fit, bin_data)
  multi_preds <- predict(multi_fit, multi_data)

  reg_unbundled_preds <- predict(reg_unbundled, reg_data)
  bin_unbundled_preds <- predict(bin_unbundled, bin_data)
  multi_unbundled_preds <- predict(multi_unbundled, multi_data)

  expect_equal(reg_preds$data, reg_unbundled_preds$data)
  expect_equal(bin_preds$data, bin_unbundled_preds$data)
  expect_equal(multi_preds$data, multi_unbundled_preds$data)

  # only want bundled models and original preds to persist.
  # test again in new R session:
  res <- callr::r(
    function(reg_bundle_,   reg_data_,
             bin_bundle_,   bin_data_,
             multi_bundle_, multi_data_) {
      library(bundle)
      library(h2o)

      h2o.init()

      reg_unbundled <- unbundle(reg_bundle_)
      bin_unbundled <- unbundle(bin_bundle_)
      multi_unbundled <- unbundle(multi_bundle_)

      reg_unbundled_preds <- predict(reg_unbundled, reg_data_)
      bin_unbundled_preds <- predict(bin_unbundled, bin_data_)
      multi_unbundled_preds <- predict(multi_unbundled, multi_data_)

      list(
        reg_unbundled_preds_new = reg_unbundled_preds$data,
        bin_unbundled_preds_new = bin_unbundled_preds$data,
        multi_unbundled_preds_new = multi_unbundled_preds$data
      )
    },
    args = list(
      reg_bundle_ = reg_bundle,
      reg_data_ = reg_data,
      bin_bundle_ = bin_bundle,
      bin_data_ = bin_data,
      multi_bundle_ = multi_bundle,
      multi_data_ = multi_data
    )
  )

  expect_equal(reg_preds$data, res$reg_unbundled_preds_new)
  expect_equal(bin_preds$data, res$bin_unbundled_preds_new)
  expect_equal(multi_preds$data, res$multi_unbundled_preds_new)
})
