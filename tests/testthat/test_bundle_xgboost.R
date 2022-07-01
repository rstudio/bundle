test_that("bundleping + unbundleping xgboost fits", {
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

  expect_snapshot(xgb_bundle)

  xgb_preds <- predict(xgb, agaricus.test$data)
  xgb_unbundled_preds <- predict(xgb_unbundled, agaricus.test$data)

  expect_equal(xgb_preds, xgb_unbundled_preds)

  # only want xgb_unbundled and xgb_preds to persist, test again in new env
  pred_env <-
    rlang::new_environment(
      data = list(
        xgb_unbundled_ = xgb_unbundled,
        xgb_preds_ = xgb_preds,
        agaricus.test_ = agaricus.test
      )
    )

  withr::with_environment(pred_env, {
    xgb_unbundled_preds <- predict(xgb_unbundled_, agaricus.test_$data)
    expect_equal(xgb_preds_, xgb_unbundled_preds)
  })
})
