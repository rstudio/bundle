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

  # only want unbundled models, prediction data, and original preds to persist.
  # test again in new R session:
  callr::r(
    function(reg_unbundled_,   reg_preds_,   reg_data_,
             bin_unbundled_,   bin_preds_,   bin_data_,
             multi_unbundled_, multi_preds_, multi_data_) {
      library(h2o)

      reg_unbundled_preds <- predict(reg_unbundled_, reg_data)
      bin_unbundled_preds <- predict(bin_unbundled_, bin_data)
      multi_unbundled_preds <- predict(multi_unbundled_, multi_data)

      expect_equal(reg_preds_$data, reg_unbundled_preds$data)
      expect_equal(bin_preds_$data, bin_unbundled_preds$data)
      expect_equal(multi_preds_$data, multi_unbundled_preds$data)
    },
    args = list(
      reg_unbundled_ = reg_unbundled,
      reg_preds_ = reg_preds,
      reg_data_ = reg_data,
      bin_unbundled_ = bin_unbundled,
      bin_preds_ = bin_preds,
      bin_data_ = bin_data,
      multi_unbundled_ = multi_unbundled,
      multi_preds_ = multi_preds,
      multi_data_ = multi_data
    )
  )
})
