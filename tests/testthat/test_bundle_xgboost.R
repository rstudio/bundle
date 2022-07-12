test_that("bundling + unbundling xgboost fits", {
  skip_if_not_installed("xgboost")
  skip_if_not_installed("lobstr")
  library(xgboost)

  set.seed(1)

  data(agaricus.train)
  data(agaricus.test)

  xgb <- xgboost(data = agaricus.train$data, label = agaricus.train$label,
                 max_depth = 2, eta = 1, nthread = 2, nrounds = 2,
                 objective = "binary:logistic")

  xgb_bundle <- bundle(xgb)
  xgb_unbundled <- unbundle(xgb_bundle)

  expect_s3_class(xgb_bundle, "bundled_xgb.Booster")
  expect_s3_class(xgb_unbundled, "xgb.Booster")

  expect_true(lobstr::obj_size(xgb_bundle) < lobstr::obj_size(xgb))

  expect_error(bundle(xgb, boop = "bop"), class = "rlib_error_dots")

  xgb_preds <- predict(xgb, agaricus.test$data)
  xgb_unbundled_preds <- predict(xgb_unbundled, agaricus.test$data)

  expect_equal(xgb_preds, xgb_unbundled_preds)

  # only want bundled model and original preds to persist.
  # test again in new R session:
  xgb_unbundled_preds_new <- callr::r(
    function(xgb_bundle_, agaricus.test_) {
      library(bundle)
      library(xgboost)

      xgb_unbundled <- unbundle(xgb_bundle_)
      predict(xgb_unbundled, agaricus.test_$data)
    },
    args = list(
      xgb_bundle_ = xgb_bundle,
      agaricus.test_ = agaricus.test
    )
  )

  expect_equal(xgb_preds, xgb_unbundled_preds_new)
})
