
<!-- README.md is generated from README.Rmd. Please edit that file -->

# bundle

*NOTE: This package is very early on in its development and is not yet
minimally functional.*

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![CRAN
status](https://www.r-pkg.org/badges/version/bundle)](https://CRAN.R-project.org/package=bundle)
[![Codecov test
coverage](https://codecov.io/gh/simonpcouch/bundle/branch/main/graph/badge.svg)](https://app.codecov.io/gh/simonpcouch/bundle?branch=main)
[![R-CMD-check](https://github.com/simonpcouch/bundle/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/simonpcouch/bundle/actions/workflows/R-CMD-check.yaml)
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

bundle prepares model objects so that they can be effectively saved and
re-loaded for use in new R sessions. To demonstrate using bundle, we
will train a boosted tree model, bundle it, and then pass the bundle
into another R session to generate predictions on new data.

First, loading needed packages:

``` r
library(bundle)
library(parsnip)
library(callr)
```

Fitting the boosted tree model:

``` r
# fit an boosted tree with xgboost via parsnip
mod <-
    boost_tree(trees = 5, mtry = 3) %>%
    set_mode("regression") %>%
    set_engine("xgboost") %>%
    fit(mpg ~ ., data = mtcars[1:25,])

mod
#> parsnip model object
#> 
#> ##### xgb.Booster
#> raw: 7.9 Kb 
#> call:
#>   xgboost::xgb.train(params = list(eta = 0.3, max_depth = 6, gamma = 0, 
#>     colsample_bytree = 1, colsample_bynode = 0.3, min_child_weight = 1, 
#>     subsample = 1, objective = "reg:squarederror"), data = x$data, 
#>     nrounds = 5, watchlist = x$watchlist, verbose = 0, nthread = 1)
#> params (as set within xgb.train):
#>   eta = "0.3", max_depth = "6", gamma = "0", colsample_bytree = "1", colsample_bynode = "0.3", min_child_weight = "1", subsample = "1", objective = "reg:squarederror", nthread = "1", validate_parameters = "TRUE"
#> xgb.attributes:
#>   niter
#> callbacks:
#>   cb.evaluation.log()
#> # of features: 10 
#> niter: 5
#> nfeatures : 10 
#> evaluation_log:
#>  iter training_rmse
#>     1     14.631798
#>     2     10.866714
#>     3      8.150259
#>     4      6.164353
#>     5      4.704108
```

Now that the model is fitted, we’ll prepare it to be passed to another R
session by bundling it:

``` r
# bundle the model
bundled_mod <-
  bundle(mod)

bundled_mod
#> bundled model_fit object.
```

Passing the model to another R session and generating predictions on new
data:

``` r
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
#> 1  22.1
#> 2  20.7
#> 3  18.6
#> 4  16.3
#> 5  18.6
#> 6  11.8
#> 7  20.7
```

For a more in-depth demonstration of the package, see the main vignette
with:

``` r
vignette("bundle")
#> Warning: vignette 'bundle' not found
```

## Code of Conduct

Please note that the bundle project is released with a [Contributor Code
of
Conduct](https://contributor-covenant.org/version/2/1/CODE_OF_CONDUCT.html).
By contributing to this project, you agree to abide by its terms.
