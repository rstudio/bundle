# Bundle a `bart` object

Bundling a model prepares it to be saved to a file and later restored
for prediction in a new R session. See the 'Value' section for more
information on bundles and their usage.

## Usage

``` r
# S3 method for class 'bart'
bundle(x, ...)
```

## Arguments

- x:

  A `bart` object returned from
  [`dbarts::bart()`](https://rdrr.io/pkg/dbarts/man/bart.html). Notably,
  this ought not to be the output of
  [`parsnip::bart()`](https://parsnip.tidymodels.org/reference/bart.html).

- ...:

  Not used in this bundler and included for compatibility with the
  generic only. Additional arguments passed to this method will return
  an error.

## Value

A bundle object with subclass `bundled_bart`.

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

## bundle and butcher

The [butcher](https://butcher.tidymodels.org/) package allows you to
remove parts of a fitted model object that are not needed for
prediction.

This bundle method is compatible with pre-butchering. That is, for a
fitted model `x`, you can safely call:

    res <-
      x |>
      butcher() |>
      bundle()

and predict with the output of `unbundle(res)` in a new R session.

## See also

Other bundlers:
[`bundle()`](https://rstudio.github.io/bundle/reference/bundle.md),
[`bundle.H2OAutoML()`](https://rstudio.github.io/bundle/reference/bundle_h2o.md),
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
library(dbarts)

mtcars$vs <- as.factor(mtcars$vs)

set.seed(1)
fit <- dbarts::bart(mtcars[c("disp", "hp")], mtcars$vs, keeptrees = TRUE)
#> 
#> Running BART with binary y
#> 
#> number of trees: 200
#> number of chains: 1, default number of threads 1
#> tree thinning rate: 1
#> Prior:
#>  k prior fixed to 2.000000
#>  power and base for tree prior: 2.000000 0.950000
#>  use quantiles for rule cut points: false
#>  proposal probabilities: birth/death 0.50, swap 0.10, change 0.40; birth 0.50
#> data:
#>  number of training observations: 32
#>  number of test observations: 0
#>  number of explanatory variables: 2
#> 
#> Cutoff rules c in x<=c vs x>c
#> Number of cutoffs: (var: number of possible c):
#> (1: 100) (2: 100) 
#> offsets:
#>  reg : 0.00 0.00 0.00 0.00 0.00
#> Running mcmc loop:
#> iteration: 100 (of 1000)
#> iteration: 200 (of 1000)
#> iteration: 300 (of 1000)
#> iteration: 400 (of 1000)
#> iteration: 500 (of 1000)
#> iteration: 600 (of 1000)
#> iteration: 700 (of 1000)
#> iteration: 800 (of 1000)
#> iteration: 900 (of 1000)
#> iteration: 1000 (of 1000)
#> total seconds in loop: 0.275979
#> 
#> Tree sizes, last iteration:
#> [1] 2 2 2 2 2 2 3 3 2 2 3 2 2 2 3 2 3 2 
#> 2 2 3 5 2 3 2 3 2 1 2 3 2 3 2 2 3 2 2 3 
#> 3 2 2 2 2 2 2 2 3 1 2 2 2 2 2 2 2 3 3 1 
#> 2 3 2 2 1 2 2 3 2 2 2 2 2 3 2 2 2 1 2 2 
#> 3 3 2 3 3 2 2 5 2 2 2 2 2 2 2 2 5 2 2 2 
#> 2 2 2 2 2 2 3 1 2 2 2 2 2 2 2 2 2 1 2 2 
#> 2 2 2 3 2 2 2 2 2 3 3 3 4 3 2 3 1 2 3 2 
#> 2 2 3 2 3 2 3 2 2 3 2 2 2 2 2 2 2 2 3 2 
#> 2 2 2 2 3 2 3 2 2 2 3 2 1 2 2 2 2 3 2 3 
#> 3 2 2 2 2 2 2 2 2 2 2 2 2 2 2 1 4 2 2 2 
#> 3 2 
#> 
#> Variable Usage, last iteration (var:count):
#> (1: 122) (2: 124) 
#> DONE BART
#> 

fit_bundle <- bundle(fit)

# then, after saveRDS + readRDS or passing to a new session ----------
fit_unbundled <- unbundle(fit_bundle)

fit_unbundled_preds <- predict(fit_unbundled, mtcars)
```
