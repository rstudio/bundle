# Bundle an `h2o` object

Bundling a model prepares it to be saved to a file and later restored
for prediction in a new R session. See the 'Value' section for more
information on bundles and their usage.

## Usage

``` r
# S3 method for class 'H2OAutoML'
bundle(x, id = NULL, n = NULL, ...)

# S3 method for class 'H2OMultinomialModel'
bundle(x, ...)

# S3 method for class 'H2OBinomialModel'
bundle(x, ...)

# S3 method for class 'H2ORegressionModel'
bundle(x, ...)
```

## Arguments

- x:

  An object returned from modeling functions in the
  [h2o](https://rdrr.io/pkg/h2o/man/h2o-package.html) package.

- id:

  A single character. The `model_id` entry in the leaderboard. Applies
  to AutoML output only. Supply only one of this argument or `n`.

- n:

  An integer giving the position in the leaderboard of the model to
  bundle. Applies to AutoML output only. Will be ignored if `id` is
  supplied.

- ...:

  Not used in this bundler and included for compatibility with the
  generic only. Additional arguments passed to this method will return
  an error.

## Value

A bundle object with subclass `bundled_h2o`.

Bundles are a list subclass with two components:

- object:

  An R object. Gives the output of native serialization methods from the
  model-supplying package, sometimes with additional classes or
  attributes that aid portability. This is often a
  [raw](https://rdrr.io/r/base/raw.html) object.

- situate:

  A function. The `situate()` function is defined when
  [`bundle()`](https://rstudio.github.io/bundle/reference/bundle.md) is
  called, though is a loose analogue of an
  [`unbundle()`](https://rstudio.github.io/bundle/reference/bundle.md)
  S3 method for that object. Since the function is defined on
  [`bundle()`](https://rstudio.github.io/bundle/reference/bundle.md), it
  has access to references and dependency information that can be saved
  alongside the `object` component. Calling
  [`unbundle()`](https://rstudio.github.io/bundle/reference/bundle.md)
  on a bundled object `x` calls `x$situate(x$object)`, returning the
  unserialized version of `object`. `situate()` will also restore needed
  references, such as server instances and environmental variables.

Bundles are R objects that represent a "standalone" version of their
analogous model object. Thus, bundles are ready for saving to a file;
saving with [`base::saveRDS()`](https://rdrr.io/r/base/readRDS.html) is
our recommended serialization strategy for bundles, unless documented
otherwise for a specific method.

To restore the original model object `x` in a new environment, load its
bundle with [`base::readRDS()`](https://rdrr.io/r/base/readRDS.html) and
run [`unbundle()`](https://rstudio.github.io/bundle/reference/bundle.md)
on it. The output of
[`unbundle()`](https://rstudio.github.io/bundle/reference/bundle.md) is
a model object that is ready to
[`predict()`](https://rdrr.io/r/stats/predict.html) on new data, and
other restored functionality (like plotting or summarizing) is supported
as a side effect only.

The bundle package wraps native serialization methods from
model-supplying packages. Between versions, those model-supplying
packages may change their native serialization methods, possibly
introducing problems with re-loading objects serialized with previous
package versions. The bundle package does not provide checks for these
sorts of changes, and ought to be used in conjunction with tooling for
managing and monitoring model environments like
[vetiver](https://rstudio.github.io/vetiver-r/reference/vetiver-package.html)
or [renv](https://rstudio.github.io/renv/reference/renv-package.html).

See
[`vignette("bundle")`](https://rstudio.github.io/bundle/articles/bundle.md)
for more information on bundling and its motivation.

## See also

These methods wrap
[`h2o::h2o.save_mojo()`](https://rdrr.io/pkg/h2o/man/h2o.save_mojo.html)
and
[`h2o::h2o.saveModel()`](https://rdrr.io/pkg/h2o/man/h2o.saveModel.html).

Other bundlers:
[`bundle()`](https://rstudio.github.io/bundle/reference/bundle.md),
[`bundle.bart()`](https://rstudio.github.io/bundle/reference/bundle_bart.md),
[`bundle.keras.engine.training.Model()`](https://rstudio.github.io/bundle/reference/bundle_keras.md),
[`bundle.luz_module_fitted()`](https://rstudio.github.io/bundle/reference/bundle_torch.md),
[`bundle.model_fit()`](https://rstudio.github.io/bundle/reference/bundle_parsnip.md),
[`bundle.model_stack()`](https://rstudio.github.io/bundle/reference/bundle_stacks.md),
[`bundle.recipe()`](https://rstudio.github.io/bundle/reference/bundle_recipe.md),
[`bundle.step_umap()`](https://rstudio.github.io/bundle/reference/bundle_embed.md),
[`bundle.train()`](https://rstudio.github.io/bundle/reference/bundle_caret.md),
[`bundle.workflow()`](https://rstudio.github.io/bundle/reference/bundle_workflows.md),
[`bundle.xgb.Booster()`](https://rstudio.github.io/bundle/reference/bundle_xgboost.md)

## Examples

``` r
# fit model and bundle ------------------------------------------------
library(h2o)
#> 
#> ----------------------------------------------------------------------
#> 
#> Your next step is to start H2O:
#>     > h2o.init()
#> 
#> For H2O package documentation, ask for help:
#>     > ??h2o
#> 
#> After starting H2O, you can use the Web UI at http://localhost:54321
#> For more information visit https://docs.h2o.ai
#> 
#> ----------------------------------------------------------------------
#> 
#> Attaching package: ‘h2o’
#> The following objects are masked from ‘package:stats’:
#> 
#>     cor, sd, var
#> The following objects are masked from ‘package:base’:
#> 
#>     %*%, %in%, &&, apply, as.factor, as.numeric, colnames,
#>     colnames<-, ifelse, is.character, is.factor, is.numeric,
#>     log, log10, log1p, log2, round, signif, trunc, ||

set.seed(1)

h2o.init()
#> 
#> H2O is not running yet, starting it now...
#> 
#> Note:  In case of errors look at the following log files:
#>     /tmp/Rtmp7BKvT0/file20107b172ff3/h2o_runner_started_from_r.out
#>     /tmp/Rtmp7BKvT0/file20102dc59578/h2o_runner_started_from_r.err
#> 
#> 
#> Starting H2O JVM and connecting: ... Connection successful!
#> 
#> R is connected to the H2O cluster: 
#>     H2O cluster uptime:         1 seconds 617 milliseconds 
#>     H2O cluster timezone:       UTC 
#>     H2O data parsing timezone:  UTC 
#>     H2O cluster version:        3.44.0.3 
#>     H2O cluster version age:    1 year, 11 months and 20 days 
#>     H2O cluster name:           H2O_started_from_R_runner_ydg016 
#>     H2O cluster total nodes:    1 
#>     H2O cluster total memory:   3.91 GB 
#>     H2O cluster total cores:    4 
#>     H2O cluster allowed cores:  4 
#>     H2O cluster healthy:        TRUE 
#>     H2O Connection ip:          localhost 
#>     H2O Connection port:        54321 
#>     H2O Connection proxy:       NA 
#>     H2O Internal Security:      FALSE 
#>     R Version:                  R version 4.5.2 (2025-10-31) 
#> Warning: 
#> Your H2O cluster version is (1 year, 11 months and 20 days) old. There may be a newer version available.
#> Please download and install the latest version from: https://h2o-release.s3.amazonaws.com/h2o/latest_stable.html
#> 

cars_h2o <- as.h2o(mtcars)
#>   |                                                                     |                                                             |   0%  |                                                                     |=============================================================| 100%

cars_fit <-
  h2o.glm(
    x = colnames(cars_h2o)[2:11],
    y = colnames(cars_h2o)[1],
    training_frame = cars_h2o
  )
#>   |                                                                     |                                                             |   0%  |                                                                     |=============================================================| 100%

cars_bundle <- bundle(cars_fit)

# then, after saveRDS + readRDS or passing to a new session ----------
cars_unbundled <- unbundle(cars_fit)

predict(cars_unbundled, cars_h2o[, 2:11])
#>   |                                                                     |                                                             |   0%  |                                                                     |=============================================================| 100%
#>    predict
#> 1 21.94826
#> 2 21.64605
#> 3 25.34547
#> 4 20.44883
#> 5 17.04492
#> 6 20.12585
#> 
#> [32 rows x 1 column] 

h2o.shutdown(prompt = FALSE)
```
