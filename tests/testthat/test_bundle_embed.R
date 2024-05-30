test_that("bundling + unbundling step_umap", {
  skip_on_cran()
  skip_if_not_installed("embed")
  skip_if_not_installed("butcher")
  skip_if(is.null(tensorflow::tf_version()))
  skip_if_not_installed("irlba", "2.3.5.2")

  library(embed)

  # define a function to prep a recipe ------------------------------------------
  prep_rec <- function() {
    set.seed(1)

    rec <- recipe(mpg ~ ., data = mtcars) %>%
      step_umap(all_predictors(), outcome = vars(mpg), num_comp = 2) %>%
      prep()

    rec
  }

  # pass prep fn to a new session, prep, bundle, return bundle -----------------
  rec_bundle <-
    callr::r(
      function(prep_rec) {
        library(embed)

        mod <- prep_rec()

        bundle::bundle(mod)
      },
      args = list(prep_rec = prep_rec)
    )

  # pass the bundle to a new session, unbundle it, return baked data -----------
  rec_unbundled_data <-
    callr::r(
      function(rec_bundle, test_data) {
        library(embed)

        rec_unbundled <- bundle::unbundle(rec_bundle)

        bake(rec_unbundled, test_data)
      },
      args = list(
        rec_bundle = rec_bundle,
        test_data = mtcars
      )
    )

  # pass prep fn to a new session, fit, butcher, bundle, return bundle ---------
  rec_butchered_bundle <-
    callr::r(
      function(prep_rec) {
        library(embed)

        mod <- prep_rec()

        bundle::bundle(butcher::butcher(mod))
      },
      args = list(prep_rec = prep_rec)
    )

  # pass that function to a new session, prep, bundle, return bundle -----------
  rec_butchered_unbundled_data <-
    callr::r(
      function(rec_butchered_bundle, test_data) {
        library(embed)

        rec_butchered_unbundled <- bundle::unbundle(rec_butchered_bundle)

        bake(rec_butchered_unbundled, test_data)
      },
      args = list(
        rec_butchered_bundle = rec_butchered_bundle,
        test_data = mtcars
      )
    )

  # run expectations -----------------------------------------------------------
  rec_fit <- prep_rec()
  rec_data <- bake(rec_fit, mtcars)

  # check classes
  expect_s3_class(rec_bundle, "bundled_recipe")
  expect_s3_class(rec_bundle$object$steps[[1]], "bundled_step_umap")
  expect_s3_class(unbundle(rec_bundle), "recipe")

  # ensure that the situater function didn't bring along the whole recipe
  expect_false("x" %in% names(environment(rec_bundle$situate)))

  # pass silly dots
  expect_error(bundle(rec_fit, boop = "bop"), class = "rlib_error_dots")

  # compare baked data
  expect_equal(as.data.frame(rec_data), as.data.frame(rec_unbundled_data))
  expect_equal(as.data.frame(rec_data), as.data.frame(rec_butchered_unbundled_data))
})
