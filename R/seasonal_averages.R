#' Calculate seasonal averages
#'
#' @description This calculates the seasonal averages from a time series.
#'
#' @param timeseries Time series (xts class).
#' @param season Name of the season (Autumn, Winter, Spring, Summer)
#' @param startseason String encoding the start of the season (e.g. for spring
#' in the northen hemisphere this is "03-21")
#' @param endseason String encoding the end of the season (e.g. for spring in
#' the northen emisphere this is "06-20")
#' @param parallel Logical, FALSE by default. If parallel = TRUE means that the
#' function can be used in parallel computations.
#'
#' @return A vector containing the seasonal average and significance level
#' (p-value) for each time series.
#'
#' @export
#'
#' @examples
#' \dontrun{
#'   seasonal_averages(cmr(18019), season = "Spring")
#'   seasonal_averages(list(cmr(18019), cmr(18019)), season = "Spring")
#' }
#'

seasonal_averages <- function(timeseries, season = "Spring",
                              startseason = NULL, endseason = NULL,
                              parallel = FALSE){

  if (length(as.list(timeseries)) == 0) {

    message("Please, enter valid time series.")
    stop

  }else{

    if (length(as.list(timeseries)) > 1 & parallel == FALSE){

      # multiple time series
      tslist <- lapply(X = as.list(timeseries),
                       FUN = seasonal_averages_internal,
                       season, startseason, endseason)

    }else{

      # this is the case of a single time series
      tslist <- seasonal_averages_internal(timeseries,
                                          season, startseason, endseason)

    }

  }

  return(tslist)

}

seasonal_averages_internal <- function(timeseries, season = "Spring",
                                       startseason = NULL, endseason = NULL){

  if (is.null(startseason) & is.null(endseason)){

    if (season == "Autumn") {
      startseason <- "09-21"
      endseason   <- "12-20"
    }
    if (season == "Winter") {
      startseason <- "12-21"
      endseason   <- "03-20"
    }
    if (season == "Spring") {
      startseason <- "03-21"
      endseason   <- "06-20"
    }
    if (season == "Summer") {
      startseason <- "06-21"
      endseason   <- "09-20"
    }

  }

  meanannualspring <- c()
  for (myyear in unique(xts::.indexyear(timeseries) + 1900)){
    myinterval <- paste(myyear, "-", startseason, "::",
                        myyear, "-", endseason, sep = "")
    meanannualspring <- c(meanannualspring,
                          mean(timeseries[myinterval], na.rm = TRUE))
  }

  # basic straight line of fit
  fit <- stats::glm(meanannualspring~seq(1, length(meanannualspring)))
  # F-statistics of the significance test with the summary function
  # extract slope and p-value (for significance to be true, p should be < 0.05)
  co <- summary(fit)$coefficients[2, c(1, 4)] # only slope: coef(fit)[[2]]

  return(as.numeric(co))

}
