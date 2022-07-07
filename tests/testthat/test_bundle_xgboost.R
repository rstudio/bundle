test_that("bundling + unbundling xgboost fits", {
  skip_if_not_installed("xgboost")
  library(xgboost)

  set.seed(1)

  data(agaricus.train)
  data(agaricus.test)

  xgb <- xgboost(data = agaricus.train$data, label = agaricus.train$label,
                 max_depth = 2, eta = 1, nthread = 2, nrounds = 2,
                 objective = "binary:logistic")

  xgb_bundle <- bundle(xgb)
  xgb_unbundled <- unbundle(xgb_bundle)

  xgb_preds <- predict(xgb, agaricus.test$data)
  xgb_unbundled_preds <- predict(xgb_unbundled, agaricus.test$data)

  expect_equal(xgb_preds, xgb_unbundled_preds)

  # only want bundled model, prediction data, and original preds to persist.
  # test again in new R session:
  callr::r(
    function(xgb_bundle_, xgb_preds_, agaricus.test_) {
      library(bundle)
      library(xgboost)

      xgb_unbundled <- unbundle(xgb_bundle_)
      xgb_unbundled_preds <- predict(xgb_unbundled, agaricus.test_$data)
      testthat::expect_equal(xgb_preds_, xgb_unbundled_preds)
    },
    args = list(
      xgb_bundled_ = xgb_bundle,
      xgb_preds_ = xgb_preds,
      agaricus.test_ = agaricus.test
    )
  )
})
