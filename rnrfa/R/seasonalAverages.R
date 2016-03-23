#' Calculate seasonal averages
#'
#' @description This calculates the seasonal averages from a time series.
#'
#' @param timeseries Time series (xts class).
#' @param season Name of the season (Autumn, Winter, Spring, Summer)
#' @param startSeason String encoding the start of the season (e.g. for spring in the northen hemisphere this is "03-21")
#' @param endSeason String encoding the end of the season (e.g. for spring in the northen emisphere this is "06-20")
#'
#' @return Seasonal averages.
#'
#' @examples
#' # seasonalAverages(df, season = "Spring")

# Extract data between 21st March and 20th June and calculate averages
# library(xts)
seasonalAverages <- function(myts, season = "Spring",
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
  for (myyear in unique(year(myts))){
    myInterval <- paste(myyear, "-", startSeason, "::",
                        myyear, "-", endSeasn, sep="")
    meanAnnualSpring <- c(meanAnnualSpring,
                          mean(as.xts(myts)[myInterval], na.rm = TRUE))
  }

  # basic straight line of fit
  fit <- glm(meanAnnualSpring~seq(1, length(meanAnnualSpring)))
  co <- coef(fit)

  return(co[[2]])

}
