test_that("wrapping + unwrapping xgboost fits", {
  skip_if_not_installed("xgboost")
  library(xgboost)

  set.seed(1)

  data(agaricus.train)
  data(agaricus.test)

  xgb <- xgboost(data = agaricus.train$data, label = agaricus.train$label,
                 max_depth = 2, eta = 1, nthread = 2, nrounds = 2,
                 objective = "binary:logistic")

  xgb_wrap <- wrap(xgb)
  xgb_unwrapped <- unwrap(xgb_wrap)

  expect_snapshot(xgb_wrap)

  xgb_preds <- predict(xgb, agaricus.test$data)
  xgb_unwrapped_preds <- predict(xgb_unwrapped, agaricus.test$data)

  expect_equal(xgb_preds, xgb_unwrapped_preds)

  # only want xgb_unwrapped and xgb_preds to persist, test again in new env
  pred_env <-
    rlang::new_environment(
      data = list(
        xgb_unwrapped_ = xgb_unwrapped,
        xgb_preds_ = xgb_preds,
        agaricus.test_ = agaricus.test
      )
    )

  withr::with_environment(pred_env, {
    xgb_unwrapped_preds <- predict(xgb_unwrapped_, agaricus.test_$data)
    expect_equal(xgb_preds_, xgb_unwrapped_preds)
  })
})
