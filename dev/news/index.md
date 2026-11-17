# Changelog

## bundle (development version)

- The vignette and tests now skip TensorFlow-dependent code when no
  Python is available, instead of erroring. Newer versions of reticulate
  error in this case rather than returning `NULL` from
  [`tensorflow::tf_version()`](https://rdrr.io/pkg/tensorflow/man/tf_config.html)
  ([\#83](https://github.com/rstudio/bundle/issues/83)).

## bundle 0.1.3

CRAN release: 2025-12-10

- Updated to support new versions of xgboost models
  ([\#75](https://github.com/rstudio/bundle/issues/75)).

## bundle 0.1.2

CRAN release: 2024-11-12

- Added bundle method for objects from
  [`dbarts::bart()`](https://rdrr.io/pkg/dbarts/man/bart.html) and, by
  extension, `parsnip::bart(engine = "dbarts")`
  ([\#64](https://github.com/rstudio/bundle/issues/64)).

- Bundling xgboost objects now takes extra steps to preserve `nfeatures`
  and `feature_names`
  ([\#67](https://github.com/rstudio/bundle/issues/67)).

## bundle 0.1.1

CRAN release: 2023-09-09

- Fixed bundling of recipes steps situated inside of workflows.

- Updated required version of xgboost
  ([\#62](https://github.com/rstudio/bundle/issues/62), thanks to
  [@MichaelChirico](https://github.com/MichaelChirico)).

## bundle 0.1.0

CRAN release: 2022-09-15

- Initial CRAN release of package
