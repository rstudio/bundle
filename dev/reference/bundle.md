# Bundling

`bundle()` methods provide a consistent interface to serialization
methods for statistical model objects. The created bundle can be saved,
then re-loaded and `unbundle()`d in a new R session for use in
prediction.

## Usage

``` r
bundle(x, ...)

unbundle(x)
```

## Arguments

- x:

  A model object to bundle.

- ...:

  Additional arguments to bundle methods.

## Value

A bundle object with subclass referencing the modeling function. If a
bundle method is not defined for the supplied object, `bundle.default`
is the identity function.

Bundles are a list subclass with two components:

- object:

  An R object. Gives the output of native serialization methods from the
  model-supplying package, sometimes with additional classes or
  attributes that aid portability. This is often a
  [raw](https://rdrr.io/r/base/raw.html) object.

- situate:

  A function. The `situate()` function is defined when `bundle()` is
  called, though is a loose analogue of an `unbundle()` S3 method for
  that object. Since the function is defined on `bundle()`, it has
  access to references and dependency information that can be saved
  alongside the `object` component. Calling `unbundle()` on a bundled
  object `x` calls `x$situate(x$object)`, returning the unserialized
  version of `object`. `situate()` will also restore needed references,
  such as server instances and environmental variables.

Bundles are R objects that represent a "standalone" version of their
analogous model object. Thus, bundles are ready for saving to a file;
saving with [`base::saveRDS()`](https://rdrr.io/r/base/readRDS.html) is
our recommended serialization strategy for bundles, unless documented
otherwise for a specific method.

To restore the original model object `x` in a new environment, load its
bundle with [`base::readRDS()`](https://rdrr.io/r/base/readRDS.html) and
run `unbundle()` on it. The output of `unbundle()` is a model object
that is ready to [`predict()`](https://rdrr.io/r/stats/predict.html) on
new data, and other restored functionality (like plotting or
summarizing) is supported as a side effect only.

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
[`vignette("bundle")`](https://rstudio.github.io/bundle/dev/articles/bundle.md)
for more information on bundling and its motivation.

## See also

Other bundlers:
[`bundle.H2OAutoML()`](https://rstudio.github.io/bundle/dev/reference/bundle_h2o.md),
[`bundle.bart()`](https://rstudio.github.io/bundle/dev/reference/bundle_bart.md),
[`bundle.keras.engine.training.Model()`](https://rstudio.github.io/bundle/dev/reference/bundle_keras.md),
[`bundle.luz_module_fitted()`](https://rstudio.github.io/bundle/dev/reference/bundle_torch.md),
[`bundle.model_fit()`](https://rstudio.github.io/bundle/dev/reference/bundle_parsnip.md),
[`bundle.model_stack()`](https://rstudio.github.io/bundle/dev/reference/bundle_stacks.md),
[`bundle.recipe()`](https://rstudio.github.io/bundle/dev/reference/bundle_recipe.md),
[`bundle.step_umap()`](https://rstudio.github.io/bundle/dev/reference/bundle_embed.md),
[`bundle.train()`](https://rstudio.github.io/bundle/dev/reference/bundle_caret.md),
[`bundle.workflow()`](https://rstudio.github.io/bundle/dev/reference/bundle_workflows.md),
[`bundle.xgb.Booster()`](https://rstudio.github.io/bundle/dev/reference/bundle_xgboost.md)
