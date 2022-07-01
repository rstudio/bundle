
<!-- README.md is generated from README.Rmd. Please edit that file -->

# bundle

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![CRAN
status](https://www.r-pkg.org/badges/version/bundle)](https://CRAN.R-project.org/package=bundle)
<!-- badges: end -->

The goal of the bundle package is to provide a consistent interface for
[serializing](https://en.wikipedia.org/wiki/Serialization) R objects
that may reference data outside of R-allocated memory.

## Installation

You can install the development version of bundle like so:

``` r
pak::pak("simonpcouch/bundle")
```

## Example

A common use case for serialization in R is the storing of model objects
for later use in prediction tasks. For instance, we can train a boosted
tree model, serialize it, and then later load it into another R session
to generate predictions on new data:

``` r
library(bundle)
library(parsnip)

mod <-
    boost_tree(trees = 5, mtry = 3) %>%
    set_mode("regression") %>%
    set_engine("xgboost") %>%
    fit(mpg ~ ., data = mtcars[1:20,])

bundled_mod <-
  bundle(mod)

unbundled_mod <- 
  unbundle(bundled_mod)

predict(unbundled_mod, new_data = mtcars[21:32,])
```
