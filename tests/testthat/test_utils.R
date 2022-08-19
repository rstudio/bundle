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



