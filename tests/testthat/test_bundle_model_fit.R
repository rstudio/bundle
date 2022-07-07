test_that("bundling + unbundling parsnip model_fits", {
  skip_if_not_installed("parsnip")
  skip_if_not_installed("xgboost")

  library(parsnip)
  library(xgboost)

  set.seed(1)

  mod <-
    boost_tree(trees = 5, mtry = 3) %>%
    set_mode("regression") %>%
    set_engine("xgboost") %>%
    fit(mpg ~ ., data = mtcars)

  mod_bundled <- bundle(mod)
  mod_unbundled <- unbundle(mod_bundled)

  mod_preds <- predict(mod, mtcars)
  mod_unbundled_preds <- predict(mod_unbundled, new_data = mtcars)

  expect_equal(mod_preds, mod_unbundled_preds)

  # only want unbundled model, prediction data, and original preds to persist.
  # test again in new R session:
  callr::r(
    function(mod_unbundled_, mod_preds_) {
      library(parsnip)
      library(xgboost)

      mod_unbundled_preds <- predict(mod_unbundled_, mtcars)
      expect_equal(mod_preds_, mod_unbundled_preds)
    },
    args = list(
      mod_unbundled_ = mod_unbundled,
      mod_preds_ = mod_preds
    )
  )
})
