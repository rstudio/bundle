# Internal Functions

These functions are not user-facing and are only exported for developer
extensions.

## Usage

``` r
bundle_constr(object, situate, desc_class)

situate_constr(fn)

swap_element(x, ...)
```

## Value

The two `_constr()` functions are constructors that return a bundle and
a situater, respectively. `swap_element()` returns `x` after swapping
out the specified element.
