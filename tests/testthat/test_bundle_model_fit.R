test_that("bundleping + unbundleping parsnip model_fits", {
  skip_if_not_installed("parsnip")
  library(parsnip)

  set.seed(1)

  mod <-
    boost_tree(trees = 5, mtry = 3) %>%
    set_mode("regression") %>%
    set_engine("xgboost") %>%
    fit(mpg ~ ., data = mtcars)

  mod_bundled <- bundle(mod)
  mod_unbundled <- unbundle(mod_bundled)

  expect_snapshot(mod_bundled)
  expect_snapshot(mod_unbundled)

  mod_preds <- predict(mod, mtcars)
  # currently errors: parsnip subsets the fit object at xgb_predict,
  #   which isn't fair game for a serialized object
  mod_unbundled_preds <- predict(mod_unbundled, new_data = mtcars)

  expect_equal(mod_preds, mod_unbundled_preds)

  pred_env <-
    rlang::new_environment(
      data = list(
        mod_unbundled_ = mod_unbundled,
        mod_preds_ = mod_preds
      )
    )

  withr::with_environment(pred_env, {
    mod_unbundled_preds <- predict(mod_unbundled_, mtcars)
    expect_equal(mod_preds_, mod_unbundled_preds)
  })
})
