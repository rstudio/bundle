#' @section bundle and butcher:
#' butcher is an R package that allows users to remove parts of a fitted model
#' object that are not needed for prediction.
#'
#' This bundle method is compatible with pre-butchering. That is, for a
#' fitted model `x`, users can safely call:
#'
#' ```
#' res <-
#'   x %>%
#'   butcher() %>%
#'   bundle()
#' ```
#'
#' and predict with the output of `unbundle(res)` in a new R session.
#'
#' @md
