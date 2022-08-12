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



