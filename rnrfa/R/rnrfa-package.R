#' rnrfa: UK National River Flow Archive Data from R.
#'
#' Utility functions to retrieve data from the UK National River Flow Archive. The package contains R wrappers to the UK NRFA data temporary-API. There are functions to retrieve stations falling in a bounding box, to generate a map and extracting time series and general information.
#'
#' @name rnrfa-package
#' @docType package
#' @title UK National River Flow Archive data from R
#'
#' @importFrom utils packageDescription
#' @importFrom cowplot plot_grid
#' @importFrom plyr llply
#' @importFrom graphics axis legend mtext par plot
#' @importFrom stats glm
#' @importFrom httr GET http_error
#' @importFrom xml2 read_xml
#' @importFrom stringr str_sub
#' @importFrom xts xts .indexyear plot.xts
#' @importFrom rjson fromJSON
#' @importFrom ggmap ggmap get_map
#' @importFrom ggplot2 ggplot geom_point aes coord_flip scale_color_manual theme geom_boxplot theme_minimal ylab xlab unit element_text margin
#' @importFrom sp coordinates proj4string CRS spTransform
#' @importFrom parallel parLapply
#'
NULL

#' StationSummary dataset.
#'
#' This dataset contains all the NRFA stations (latest update: February 2016).
#'
#' @name StationSummary
#' @aliases StationSummary
#' @docType data
#' @title StationSummary
#' @description table containing details for 1537 stations.
#' @usage data(StationSummary)
#'
#' @format{
#' A data frame with 1539 gauging stations and the following 20 variables.
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
#' \item{\code{lat}}{a numeric vector of latitude coordinates}
#' \item{\code{lon}}{a numeric vector of longitude coordinates}
#' }
#' }
#' @details This is the full set of river station that can be retrieved using UK NRFA APIs.
#'
#' @source http://nrfaapps.ceh.ac.uk/data/nrfa/
#' @examples data(StationSummary)
#' @keyword datasets
#'
