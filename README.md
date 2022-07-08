
<!-- README.md is generated from README.Rmd. Please edit that file -->

# bundle

*NOTE: This package is very early on in its development and is not yet
minimally functional.*

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![CRAN
status](https://www.r-pkg.org/badges/version/bundle)](https://CRAN.R-project.org/package=bundle)
<!-- badges: end -->

R holds most objects in memory. However, some models store their data in
locations that are not included when one uses `save()` or `saveRDS()`.
bundle provides a common API to capture this information, situate it
within a portable object, and restore it for use in new settings.

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
library(callr)

# fit an boosted tree with xgboost via parsnip
mod <-
    boost_tree(trees = 5, mtry = 3) %>%
    set_mode("regression") %>%
    set_engine("xgboost") %>%
    fit(mpg ~ ., data = mtcars[1:25,])

# bundle the model
bundled_mod <-
  bundle(mod)

# load the model in a fresh R session and predict on new data
r(
  func = function(bundled_mod) {
    library(bundle)
    library(parsnip)
    
    unbundled_mod <- 
      unbundle(bundled_mod)

    predict(unbundled_mod, new_data = mtcars[26:32,])
  },
  args = list(
    bundled_mod = bundled_mod
  )
)
#> # A tibble: 7 × 1
#>   .pred
#>   <dbl>
#> 1  22.3
#> 2  18.9
#> 3  17.1
#> 4  11.8
#> 5  14.2
#> 6  11.8
#> 7  17.1
```
