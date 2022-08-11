test_that("bundling + unbundling step_umap", {
  skip_if_not_installed("embed")
  skip_if_not_installed("butcher")

  library(embed)
  library(butcher)

  skip_if_not(is_tf_available())

  set.seed(1)
  rec <- recipe(Species ~ ., data = iris) %>%
    step_umap(all_predictors(), outcome = vars(Species), num_comp = 2) %>%
    prep()

  baked_data <- bake(rec, iris)

  rec_bundled <- bundle(rec)
  step_umap_bundled <- bundle(rec$steps[[1]])
  expect_s3_class(rec_bundled, "bundled_recipe")
  expect_s3_class(step_umap_bundled, "bundled_step_umap")

  rec_unbundled <- unbundle(rec_bundled)
  step_umap_unbundled <- unbundle(step_umap_bundled)
  expect_s3_class(rec_unbundled, "recipe")
  expect_s3_class(step_umap_unbundled, "step_umap")

  baked_data_unbundled <- bake(rec_unbundled, iris)
  expect_equal(baked_data, baked_data_unbundled)

  bake_bundle_umap <-
    function(step_umap_bundled_) {
      library(bundle)
      library(recipes)
      library(embed)

      step_umap_unbundled <- unbundle(step_umap_bundled_)
      bake(step_umap_unbundled, iris)
    }

  baked_data_new <- callr::r(
    bake_bundle_umap,
    args = list(
      step_umap_bundled_ = step_umap_bundled
    )
  )

  expect_equal(as.data.frame(baked_data), as.data.frame(baked_data_new))

  # interaction with butcher
  expect_silent({
    rec_bundle_butchered <- bundle(butcher(rec))
  })

  baked_data_butchered <- callr::r(
    bake_bundle_umap,
    args = list(
      step_umap_bundled_ = step_umap_bundled
    )
  )

  expect_equal(as.data.frame(baked_data), as.data.frame(baked_data_butchered))
})
