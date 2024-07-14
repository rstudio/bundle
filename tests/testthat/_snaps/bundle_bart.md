# bundle.bart errors informatively with model_spec input (#64)

    Code
      bundle(parsnip::bart())
    Condition
      Error in `bundle()`:
      ! `x` should be the output of `dbarts::bart()`, not a model specification from `parsnip::bart()`.
      * To bundle `parsnip::bart()` output, train it with `parsnip::fit()` first.

# bundle.bart errors informatively when `keeptrees = FALSE` (#64)

    Code
      bundle(fit)
    Condition
      Error in `bundle()`:
      ! `x` can't be bundled.
      * `x` must have been fitted with argument `keeptrees = TRUE`.

