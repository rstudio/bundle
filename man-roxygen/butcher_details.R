#' @section bundle and butcher:
#' The [butcher](https://butcher.tidymodels.org/) package allows you to remove
#' parts of a fitted model object that are not needed for prediction.
#'
#' This bundle method is compatible with pre-butchering. That is, for a
#' fitted model `x`, you can safely call:
#'
#' ```
#' res <-
#'   x |>
#'   butcher() |>
#'   bundle()
#' ```
#'
#' and predict with the output of `unbundle(res)` in a new R session.
#'
#' @md
