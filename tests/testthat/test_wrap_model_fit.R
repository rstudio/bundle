test_that("wrapping + unwrapping parsnip model_fits", {
  skip_if_not_installed("parsnip")
  library(parsnip)

  set.seed(1)

  mod <-
    boost_tree(trees = 5, mtry = 3) %>%
    set_mode("regression") %>%
    set_engine("xgboost") %>%
    fit(mpg ~ ., data = mtcars)

  mod_wrapped <- wrap(mod)
  mod_unwrapped <- unwrap(mod_wrapped)

  expect_snapshot(mod_wrapped)
  expect_snapshot(mod_unwrapped)

  mod_preds <- predict(mod, mtcars)
  # currently errors: parsnip subsets the fit object at xgb_predict,
  #   which isn't fair game for a serialized object
  mod_unwrapped_preds <- predict(mod_unwrapped, new_data = mtcars)

  expect_equal(mod_preds, mod_unwrapped_preds)

  pred_env <-
    rlang::new_environment(
      data = list(
        mod_unwrapped_ = mod_unwrapped,
        mod_preds_ = mod_preds
      )
    )

  withr::with_environment(pred_env, {
    mod_unwrapped_preds <- predict(mod_unwrapped_, mtcars)
    expect_equal(mod_preds_, mod_unwrapped_preds)
  })
})
