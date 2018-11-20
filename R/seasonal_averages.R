#' Calculate seasonal averages
#'
#' @description This calculates the seasonal averages from a time series.
#'
#' @param timeseries Time series (xts class).
#' @param season Name of the season (Autumn, Winter, Spring, Summer)
#' @param startSeason String encoding the start of the season (e.g. for spring
#' in the northen hemisphere this is "03-21")
#' @param endSeason String encoding the end of the season (e.g. for spring in
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
                             startSeason = NULL, endSeason = NULL,
                             parallel = FALSE){

  if (length(as.list(timeseries)) == 0) {

    message("Please, enter valid time series.")
    stop

  }else{

    if (length(as.list(timeseries)) > 1 & parallel == FALSE){

      # multiple time series
      tsList <- lapply(X = as.list(timeseries),
                       FUN = seasonal_averages_internal,
                       season, startSeason, endSeason)

    }else{

      # this is the case of a single time series
      tsList <- seasonal_averages_internal(timeseries,
                                          season, startSeason, endSeason)

    }

  }

  return(tsList)

}

seasonal_averages_internal <- function(timeseries, season = "Spring",
                                      startSeason = NULL, endSeason = NULL){

  if (is.null(startSeason) & is.null(endSeason)){

    if (season == "Autumn") {
      startSeason <- "09-21"
      endSeason   <- "12-20"
    }
    if (season == "Winter") {
      startSeason <- "12-21"
      endSeason   <- "03-20"
    }
    if (season == "Spring") {
      startSeason <- "03-21"
      endSeason   <- "06-20"
    }
    if (season == "Summer") {
      startSeason <- "06-21"
      endSeason   <- "09-20"
    }

  }

  meanAnnualSpring <- c()
  for (myyear in unique(xts::.indexyear(timeseries) + 1900)){
    myInterval <- paste(myyear, "-", startSeason, "::",
                        myyear, "-", endSeason, sep = "")
    meanAnnualSpring <- c(meanAnnualSpring,
                          mean(timeseries[myInterval], na.rm = TRUE))
  }

  # basic straight line of fit
  fit <- stats::glm(meanAnnualSpring~seq(1, length(meanAnnualSpring)))
  # F-statistics of the significance test with the summary function
  # extract slope and p-value (for significance to be true, p should be < 0.05)
  co <- summary(fit)$coefficients[2, c(1, 4)] # only slope: coef(fit)[[2]]

  return(as.numeric(co))

}
