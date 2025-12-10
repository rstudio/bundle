# Bundle a tidymodels `workflow` object

Bundling a model prepares it to be saved to a file and later restored
for prediction in a new R session. See the 'Value' section for more
information on bundles and their usage.

## Usage

``` r
# S3 method for class 'workflow'
bundle(x, ...)
```

## Arguments

- x:

  A [workflow](https://workflows.tidymodels.org/reference/workflow.html)
  object returned from
  [workflows](https://workflows.tidymodels.org/reference/workflows-package.html)
  or other tidymodels packages.

- ...:

  Not used in this bundler and included for compatibility with the
  generic only. Additional arguments passed to this method will return
  an error.

## Value

A bundle object with subclass `bundled_workflow`.

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

## Details

This bundler wraps
[`bundle.model_fit()`](https://rstudio.github.io/bundle/reference/bundle_parsnip.md)
and
[`bundle.recipe()`](https://rstudio.github.io/bundle/reference/bundle_recipe.md).

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
[`bundle.bart()`](https://rstudio.github.io/bundle/reference/bundle_bart.md),
[`bundle.keras.engine.training.Model()`](https://rstudio.github.io/bundle/reference/bundle_keras.md),
[`bundle.luz_module_fitted()`](https://rstudio.github.io/bundle/reference/bundle_torch.md),
[`bundle.model_fit()`](https://rstudio.github.io/bundle/reference/bundle_parsnip.md),
[`bundle.model_stack()`](https://rstudio.github.io/bundle/reference/bundle_stacks.md),
[`bundle.recipe()`](https://rstudio.github.io/bundle/reference/bundle_recipe.md),
[`bundle.step_umap()`](https://rstudio.github.io/bundle/reference/bundle_embed.md),
[`bundle.train()`](https://rstudio.github.io/bundle/reference/bundle_caret.md),
[`bundle.xgb.Booster()`](https://rstudio.github.io/bundle/reference/bundle_xgboost.md)

## Examples

``` r
# fit model and bundle ------------------------------------------------
library(workflows)
library(recipes)
#> Loading required package: dplyr
#> 
#> Attaching package: ‘dplyr’
#> The following objects are masked from ‘package:stats’:
#> 
#>     filter, lag
#> The following objects are masked from ‘package:base’:
#> 
#>     intersect, setdiff, setequal, union
#> 
#> Attaching package: ‘recipes’
#> The following object is masked from ‘package:stats’:
#> 
#>     step
library(parsnip)
library(xgboost)

set.seed(1)

spec <-
  boost_tree(trees = 5, mtry = 3) |>
  set_mode("regression") |>
  set_engine("xgboost")

rec <-
  recipe(mpg ~ ., data = mtcars) |>
  step_log(hp)

mod <-
  workflow() |>
  add_model(spec) |>
  add_recipe(rec) |>
  fit(data = mtcars)

mod_bundle <- bundle(mod)

# then, after saveRDS + readRDS or passing to a new session ----------
mod_unbundled <- unbundle(mod_bundle)
```
