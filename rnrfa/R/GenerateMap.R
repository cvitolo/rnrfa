#' Generate map of gauging stations.
#'
#' @author Claudia Vitolo
#'
#' @description This function takes as input a table of UK NRFA stations (output of getStationSummary() function) and generates a map using leaflet javascript library.
#'
#' @param selectedStationSummary This is the data.frame containing at least a column called "gridReference" (in which OS Grid references are stored) with 1 row for each station. Alternatively the table could contain 2 columns called "Latitude" and "Longitude" containing the coordinates of stations in WGS84, with 1 row for each station.
#'
#' @return displays a map
#'
#' @examples
#' # bbox <- list(lonMin=-3.82, lonMax=-3.63, latMin=52.43, latMax=52.52)
#' # myStations <- NRFA_Catalogue(bbox)
#' # GenerateMap(myStations)
#'

GenerateMap <- function(selectedStationSummary){

  # library(devtools)
  # if(!require(rCharts)) install_github('ramnathv/rCharts')

  # Load packages and sample data
  # library(zoo)
  # library(rCharts)

  coords <- NULL

  if ("Latitude" %in% names(selectedStationSummary) &
      "Longitude" %in% names(selectedStationSummary)) {

    coords <- data.frame("Latitude"=unlist(selectedStationSummary$Latitude),
                         "Longitude"=unlist(selectedStationSummary$Longitude))

  }else{

    if ("gridReference" %in% names(selectedStationSummary)) {

      gridref <- unlist(selectedStationSummary$gridReference)

      coords <- data.frame("Latitude"=unlist(lapply(gridref,
                                                    function(x) OSG2LatLon(OSGParse(unlist(x)))[1])),
                           "Longitude"=unlist(lapply(gridref,
                                                     function(x) OSG2LatLon(OSGParse(unlist(x)))[2])))

    }else{

      message("Provide a table with at least 1 column called gridReference.")

    }

  }

  if (!is.null(coords)){

    centerCoords <- c(mean(coords$Latitude),mean(coords$Longitude))

    myMap <- rCharts::Leaflet$new()
    myMap$tileLayer(provider = 'Stamen.TonerLite')
    myMap$setView(centerCoords, zoom = 6)

    for (nStations in 1:dim(selectedStationSummary)[1]) {

      myMap$marker(c(coords$Latitude[[nStations]],coords$Longitude[[nStations]]),
                   bindPopup = paste("<p> ", selectedStationSummary$name[[nStations]],
                                     " id: ", selectedStationSummary$id[[nStations]],
                                     " </p>", sep="") )

    }

    myMap

  }

}
