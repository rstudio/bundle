#' @return A bundle object with subclass <%= outclass %>. <%= default %>
#'
#' Bundles are a list subclass with two components:
#'
#'   \item{object}{An R object. Gives the output of native serialization
#'     methods from the model-supplying package, sometimes with additional
#'     classes or attributes that aid portability. This is often
#'     a [raw][base::raw] object.}
#'   \item{situate}{A function. The `situate()` function is defined when
#'     [bundle()] is called, though is a loose analogue of an [unbundle()] S3
#'     method for that object. Since the function is defined on [bundle()], it
#'     has access to references and dependency information that can
#'     be saved alongside the `object` component. This allows for more
#'     resilient serialization.}
#'
#' Bundles are R objects that represent a "standalone" version of their
#' analogous model object. Thus, bundles are ready for saving to file---saving
#' with [base::saveRDS()] is our recommended serialization strategy for bundles,
#' unless documented otherwise for a specific method.
#'
#' To restore the inputted model object `x` in a new environment, load its
#' bundle with [base::readRDS()] and run [unbundle()] on it. The output
#' of [unbundle()] is a model object that is ready to [predict()] on new data,
#' and other restored functionality (like plotting or summarizing) is supported
#' as a side effect only.
#'
#' See `vignette("bundle")` for more information on bundling and its motivation.
#'
#' @md
