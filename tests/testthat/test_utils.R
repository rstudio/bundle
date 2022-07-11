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
