#' rnrfa: UK NRFA data from R.
#'
#' This is an R wrapper to the UK NRFA data API at http://... There are functions to retrieve stations falling in a bounding box, to generate a map and extracting time series and general information. It also contain the dataset \code{StationSummary}.
#'
#' @version 0.1.0
#' @name rnrfa-package
#' @aliases rnrfa
#' @docType package
#' @title UK National River Flow Archive data from R
#' @author Claudia Vitolo <claudia.vitolo@gmail.com>, Matthew Fry <mfry@ceh.ac.uk>
#'

#' StationSummary dataset.
#'
#' This dataset contains all the NRFA stations.
#'
#' @name StationSummary
#' @aliases StationSummary
#' @docType data
#' @title StationSummary
#' @description table containing details for 1537 stations.
#' @usage data(StationSummary)
#'
#' @format{
#' A data frame with 1537 observations on the following 20 variables.
#' @describe{
#' \item{\code{id}}{a list vector}
#' \item{\code{name}}{a list vector}
#' \item{\code{location}}{a list vector}
#' \item{\code{river}}{a list vector}
#' \item{\code{stationDescription}}{a list vector}
#' \item{\code{catchmentDescription}}{a list vector}
#' \item{\code{hydrometricArea}}{a list vector}
#' \item{\code{operator}}{a list vector}
#' \item{\code{haName}}{a list vector}
#' \item{\code{gridReference}}{a list vector}
#' \item{\code{stationType}}{a list vector}
#' \item{\code{catchmentArea}}{a list vector}
#' \item{\code{gdfStart}}{a list vector}
#' \item{\code{gdfEnd}}{a list vector}
#' \item{\code{farText}}{a list vector}
#' \item{\code{categories}}{a list vector}
#' \item{\code{altitude}}{a list vector}
#' \item{\code{sensitivity}}{a list vector}
#' \item{\code{Latitude}}{a numeric vector}
#' \item{\code{Longitude}}{a numeric vector}
#' }
#' }
#' @details This is the full set of river station that can be retrieved using UK NRFA APIs.
#'
#' @source http://nrfaapps.ceh.ac.uk/data/nrfa/
#' @examples data(StationSummary)
#' @keyword datasets
#'
