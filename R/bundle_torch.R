#' @templateVar class a `luz_module_fitted`
#' @template title_desc
#'
#' @templateVar outclass `bundled_luz_module_fitted`
#' @template return_bundle
#'
#' @param x A `luz_module_fitted` object returned from
#'   [luz::fit.luz_module_generator()].
#' @template param_unused_dots
#'
#' @details
#' For now, bundling methods for torch are only available
#' via the luz package, "a higher level API for torch providing
#' abstractions to allow for much less verbose training loops."
#'
#' These bundlers rely on serialization methods from luz and torch,
#' which are [described by the package authors][torch::torch_save]
#' as "experimental" and not for "use for long term storage."
#'
#' @method bundle luz_module_fitted
#' @rdname bundle_torch
#' @aliases bundle.luz_module_fitted
#' @export
bundle.luz_module_fitted <- function(x, ...) {
  rlang::check_installed("luz")
  rlang::check_installed("torch")
  rlang::check_dots_empty()

  res <- x

  # see luz::luz_save and luz:::model_to_raw
  suppressWarnings({
    con <- rawConnection(raw(), open = "wr")
    torch::torch_save(res$model, con)
    serialized_model <- rawConnectionValue(con)
    res$ctx$.serialized_model <- serialized_model
    res$ctx$.serialization_version <- 2L
  })

  close(con)

  bundle_constr(
    object = res,
    situate = situate_constr(function(object) {
      # see luz::luz_load and luz:::model_from_raw
      con <- rawConnection(object$ctx$.serialized_model)
      on.exit({
        close(con)
      }, add = TRUE)
      res <- torch::torch_load(con)

      object$model <- res
      object$ctx$.serialized_model <- NULL
      object$ctx$.serialization_version <- NULL

      structure(object, class = !!class(x))
    }),
    desc_class = class(x)[1],
    pkg_versions = c("luz" = utils::packageVersion("luz"))
  )
}
