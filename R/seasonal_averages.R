#' Calculate seasonal averages
#'
#' @description This calculates the seasonal averages from a time series.
#'
#' @param timeseries Time series (zoo class).
#' @param season Name of the season, which corresponds to a quarter:
#' Winter (Q1), Spring (Q2), Summer (Q3), Autumn (Q4)
#'
#' @return A vector containing the seasonal average and significance level
#' (p-value) for each time series.
#'
#' @export
#'
#' @examples
#' \dontrun{
#'   seasonal_averages(timeseries = cmr(18019), season = "Spring")
#'   seasonal_averages(list(cmr(18019), cmr(18019)), season = "Spring")
#' }
#'

seasonal_averages <- function(timeseries, season = "Spring") {

  if (length(as.list(timeseries)) == 0) {

    message("Please, enter valid time series.")
    stop

  }else{

    tslist <- lapply(X = as.list(timeseries), FUN = seasonal_averages_internal,
                     season)

    if (length(tslist) == 1) {
      tslist <- unlist(tslist)
    }

  }

  return(tslist)

}
