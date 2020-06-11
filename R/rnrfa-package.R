#' rnrfa: UK National River Flow Archive Data from R.
#'
#' Utility functions to retrieve data from the UK National River Flow Archive
#' (http://nrfa.ceh.ac.uk/). The package contains R wrappers to the UK NRFA data
#' temporary-API. There are functions to retrieve stations falling in a bounding
#' box, to generate a map and extracting time series and general information.
#'
#' @name rnrfa-package
#' @docType package
#' @title UK National River Flow Archive data from R
#'
#' @import rgdal
#' @importFrom curl has_internet
#' @importFrom ggmap ggmap get_map
#' @importFrom ggplot2 ggplot geom_point aes coord_flip scale_color_manual theme
#' @importFrom ggplot2 geom_boxplot theme_minimal ylab xlab unit element_text
#' @importFrom ggplot2 margin ggtitle
#' @importFrom graphics axis legend mtext par plot
#' @importFrom httr GET http_error
#' @importFrom jsonlite fromJSON
#' @importFrom lubridate year
#' @importFrom parallel parLapply
#' @importFrom sp coordinates proj4string CRS spTransform
#' @importFrom stats aggregate glm quantile
#' @importFrom tibble as_tibble
#' @importFrom utils str
#' @importFrom zoo zoo
#'
NULL
