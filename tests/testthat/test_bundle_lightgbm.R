test_that("bundling + unbundling lightgbm fits", {
  skip_if_not_installed("lightgbm")
  library(lightgbm)

  set.seed(1)

  cars_train <-
    lgb.Dataset(
      data = as.matrix(mtcars[1:25, 2:ncol(mtcars)]),
      label = mtcars[1:25, 1],
      params = list(feature_pre_filter = "false")
    )

  cars_test <- as.matrix(mtcars[26:32, 2:ncol(mtcars)])

  lgb_fit <-
    lgb.train(
      params = list(
        max_depth = 3,
        min_data_in_leaf = 5,
        objective = "regression"
      ),
      data = cars_train,
      nrounds = 5,
      verbose = -1
    )

  lgb_bundle <- bundle(lgb_fit)
  lgb_unbundled <- unbundle(lgb_bundle)

  expect_s3_class(lgb_bundle, "bundled_lgb.Booster")
  expect_s3_class(lgb_unbundled, "lgb.Booster")

  # ensure that the situater function didn't bring along the whole model
  expect_false("x" %in% names(environment(lgb_bundle$situate)))

  expect_error(bundle(lgb_fit, boop = "bop"), class = "rlib_error_dots")

  lgb_preds <- predict(lgb_fit, cars_test)
  lgb_unbundled_preds <- predict(lgb_unbundled, cars_test)

  expect_equal(lgb_preds, lgb_unbundled_preds)

  # only want bundled model and original preds to persist.
  # test again in new R session:
  lgb_unbundled_preds_new <- callr::r(
    function(lgb_bundle_, cars_test) {
      library(bundle)
      library(lightgbm)

      lgb_unbundled <- unbundle(lgb_bundle_)
      predict(lgb_unbundled, cars_test)
    },
    args = list(
      lgb_bundle_ = lgb_bundle,
      cars_test = cars_test
    )
  )

  expect_equal(lgb_preds, lgb_unbundled_preds_new)
})
