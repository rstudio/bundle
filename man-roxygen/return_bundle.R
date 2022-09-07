#' @return A bundle object with subclass <%= outclass %><%= default %>
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
#'     be saved alongside the `object` component. Calling [unbundle()] on a
#'     bundled object `x` calls `x$situate(x$object)`, returning the
#'     unserialized version of `object`. `situate()` will also restore needed
#'     references, such as server instances and environmental variables.}
#'
#' Bundles are R objects that represent a "standalone" version of their
#' analogous model object. Thus, bundles are ready for saving to a file; saving
#' with [base::saveRDS()] is our recommended serialization strategy for bundles,
#' unless documented otherwise for a specific method.
#'
#' To restore the original model object `x` in a new environment, load its
#' bundle with [base::readRDS()] and run [unbundle()] on it. The output
#' of [unbundle()] is a model object that is ready to [predict()] on new data,
#' and other restored functionality (like plotting or summarizing) is supported
#' as a side effect only.
#'
#' The bundle package wraps native serialization methods from model-supplying
#' packages. Between versions, those model-supplying packages may change their
#' native serialization methods, possibly introducing problems with re-loading
#' objects serialized with previous package versions. The bundle package does
#' not provide checks for these sorts of changes, and ought to be used in
#' conjunction with tooling for managing and monitoring model environments
#' like [vetiver][vetiver::vetiver] or [renv][renv::renv].
#'
#' See `vignette("bundle")` for more information on bundling and its motivation.
#'
#' @md
