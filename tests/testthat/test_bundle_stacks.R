test_that("bundling + unbundling tidymodels stacks", {
  skip_if_not_installed("stacks")
  skip_if_not_installed("parsnip")
  skip_if_not_installed("workflows")

  library(stacks)

  set.seed(1)

  mod <-
    stacks() %>%
    add_candidates(reg_res_lr) %>%
    add_candidates(reg_res_svm) %>%
    blend_predictions(times = 10) %>%
    fit_members()

  mod_bundle <- bundle(mod)
  mod_unbundled <- unbundle(mod_bundle)

  expect_s3_class(mod_bundle, "bundled_model_stack")
  expect_s3_class(mod_bundle$object$coefs, "bundled_model_fit")
  expect_s3_class(mod_bundle$object$member_fits[[1]], "bundled_workflow")

  # ensure that the situater function didn't bring along the whole model
  expect_false("x" %in% names(environment(mod$situate)))

  mod_preds <- predict(mod, stacks::tree_frogs_reg_test)
  mod_unbundled_preds <- predict(mod_unbundled, new_data = stacks::tree_frogs_reg_test)

  expect_equal(mod_preds, mod_unbundled_preds)

  # only want bundled model and original preds to persist.
  # test again in new R session:
  mod_unbundled_preds_new <- callr::r(
    function(mod_bundle_) {
      library(bundle)
      library(stacks)

      mod_unbundled_ <- unbundle(mod_bundle_)
      predict(mod_unbundled_, stacks::tree_frogs_reg_test)
    },
    args = list(
      mod_bundle_ = mod_bundle
    )
  )

  expect_equal(mod_preds, mod_unbundled_preds_new)
})
