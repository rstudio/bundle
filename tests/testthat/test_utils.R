test_that("error without needed packages / insufficient versions", {
  skip_if_not_installed("xgboost")
  library(xgboost)

  set.seed(1)

  data(agaricus.train)
  data(agaricus.test)

  xgb <- xgboost(data = agaricus.train$data, label = agaricus.train$label,
                 max_depth = 2, eta = 1, nthread = 2, nrounds = 2,
                 objective = "binary:logistic")

  # check that needed versions are present after bundling
  xgb_bundle <- bundle(xgb)
  versions <- attr(xgb_bundle, "pkg_versions")
  expect_s3_class(versions, "package_version")
  expect_true("xgboost" %in% names(versions))

  # check that unbundle will error if it needs to:
  # 1) insufficient version
  attr(xgb_bundle, "pkg_versions") <-
    structure(c("xgboost" = "1000000.0.0"), class = class(versions))

  expect_error(unbundle(xgb_bundle), class = "rlib_error_package_not_found")

  # 2) needed package not installed
  attr(xgb_bundle, "pkg_versions") <-
    structure(c("boopBopBeepPackage" = "1.0.0"), class = class(versions))

  expect_error(unbundle(xgb_bundle), class = "rlib_error_package_not_found")
})

test_that("has_bundler works (default)", {
  x <- 1L

  class(x) <- "boop"
  expect_false(has_bundler(x))

  class(x) <- c("boop", "bop")
  expect_false(has_bundler(x))

  class(x) <- c("boop", "keras.engine.training.Model")
  expect_true(has_bundler(x))

  class(x) <- c("keras.engine.training.Model", "boop")
  expect_true(has_bundler(x))

  class(x) <- c("keras.engine.training.Model")
  expect_true(has_bundler(x))
})

test_that("has_bundler.workflow works", {
  skip_if_not_installed("workflows")
  skip_if_not_installed("recipes")
  skip_if_not_installed("parsnip")
  skip_if_not_installed("xgboost")
  skip_if_not_installed("embed")

  library(workflows)
  library(recipes)
  library(parsnip)
  library(xgboost)
  library(embed)

  skip_if_not(is_tf_available())

  set.seed(1)

  spec_with_bundler <-
    boost_tree(trees = 5, mtry = 3) %>%
    set_mode("regression") %>%
    set_engine("xgboost")

  spec_no_bundler <-
    linear_reg() %>%
    set_mode("regression") %>%
    set_engine("lm")

  rec_with_bundler <-
    recipe(mpg ~ ., data = mtcars) %>%
    step_umap(all_predictors(), outcome = vars(mpg), num_comp = 2)

  rec_no_bundler <-
    recipe(mpg ~ ., data = mtcars) %>%
    step_log(hp)

  # both the spec and recipe have a non-trivial bundler
  expect_true(
    has_bundler(
      workflow() %>%
        add_model(spec_with_bundler) %>%
        add_recipe(rec_with_bundler) %>%
        fit(data = mtcars)
    )
  )

  # just the spec has a non-trivial bundler
  expect_true(
    has_bundler(
      workflow() %>%
        add_model(spec_with_bundler) %>%
        add_recipe(rec_no_bundler) %>%
        fit(data = mtcars)
    )
  )

  # just the recipe has a non-trivial bundler
  expect_true(
    has_bundler(
      workflow() %>%
        add_model(spec_no_bundler) %>%
        add_recipe(rec_with_bundler) %>%
        fit(data = mtcars)
    )
  )

  # neither the spec and recipe have a non-trivial bundler
  expect_false(
    has_bundler(
      workflow() %>%
        add_model(spec_no_bundler) %>%
        add_recipe(rec_no_bundler) %>%
        fit(data = mtcars)
    )
  )
})

test_that("has_bundler.model_fit works", {
  skip_if_not_installed("parsnip")
  skip_if_not_installed("xgboost")

  library(parsnip)
  library(xgboost)

  set.seed(1)

  spec <-
    boost_tree(trees = 5, mtry = 3) %>%
    set_mode("regression") %>%
    set_engine("xgboost")

  fit_with_bundler <-
    spec %>%
    fit(mpg ~ ., data = mtcars)

  fit_no_bundler <-
    linear_reg() %>%
    set_mode("regression") %>%
    set_engine("lm") %>%
    fit(mpg ~ ., data = mtcars)

  expect_true( has_bundler(fit_with_bundler))
  expect_false(has_bundler(fit_no_bundler))

  expect_warning(spec_has_bundler <- has_bundler(spec))
  expect_false(spec_has_bundler)
})

test_that("has_bundler.recipe works", {
  skip_if_not_installed("recipes")
  skip_if_not_installed("embed")

  library(recipes)
  library(embed)

  skip_if_not(is_tf_available())

  rec_with_bundler <-
    recipe(mpg ~ ., data = mtcars) %>%
    step_umap(all_predictors(), outcome = vars(mpg), num_comp = 2)

  rec_no_bundler <-
    recipe(mpg ~ ., data = mtcars) %>%
    step_log(hp)

  rec_with_both <-
    recipe(mpg ~ ., data = mtcars) %>%
    step_umap(all_predictors(), outcome = vars(mpg), num_comp = 2) %>%
    step_log(hp)

  expect_true( has_bundler(rec_with_bundler))
  expect_false(has_bundler(rec_no_bundler))
  expect_true( has_bundler(rec_with_both))
})

test_that("has_bundler.bundle works", {
  x <- 1L
  class(x) <- "bundle"

  expect_snapshot_warning(bundle_has_bundler <- has_bundler(x))
  expect_false(bundle_has_bundler)
})

test_that("situate constructor works", {
  a <- list(b = rnorm(1e7), c = 1L)

  a_1 <- function() {
    a_ <- a

    function() {
      a$c
    }
  }

  a_2 <- function() {
    a_ <- a

    situate_constr(function() {
      !!a$c
    })
  }

  a_1_env <- environment(a_1())
  a_2_env <- environment(a_2())

  expect_true( "a_" %in% names(a_1_env))
  expect_false("a_" %in% names(a_2_env))
})

test_that("swap_element works", {
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

  res <- swap_element(mod, "fit")
  res_ <- swap_element(res, "fit")

  expect_s3_class(res$fit, "bundle")
  expect_s3_class(res_$fit, "xgb.Booster")

  expect_silent(silly <- swap_element(mod, "silly", "nonexistent", "element"))
  expect_equal(mod, silly)
})



