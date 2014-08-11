#' Generate map of UK NRFA stations.
#'
#' @author Claudia Vitolo
#'
#' @description This function takes as input a table of UK NRFA stations (output of getStationSummary() function) and generates a map using leaflet javascript library. 
#'
#' @param selectedStationSummary This is the data.frame containing at least a column called "gridReference" (in which OS Grid references are stored) with 1 row for each station. Alternatively the table could contain 2 columns called "Latitude" and "Longitude" containing the coordinates of stations in WGS84, with 1 row for each station.
#'
#' @return displays a map
#' 
#' @export 
#' 
#' @examples
#' # myStations <- GetStationSummary(lonMin=-1, lonMax=1, latMin=51, latMax=49)
#' # GenerateMap(myStations)
#' 

GenerateMap <- function(selectedStationSummary){
  
  library(rCharts)
  #require(zoo)
  
  if (dim(selectedStationSummary)[1] > 1481) {
    
    # load cached stationSummary
    load(system.file("data/stationSummary.rda", package = 'rnrfa'))
    stationSummary <- stationSummary
    selectedStationSummary <- stationSummary[1:1481,]
    rm(stationSummary)
    
  }
  
  coords <- NULL
  
  if ("Latitude" %in% names(selectedStationSummary) & "Longitude" %in% names(selectedStationSummary)) {
    
    coords <- data.frame("Latitude"=unlist(selectedStationSummary$Latitude), "Longitude"=unlist(selectedStationSummary$Longitude))
    
  }else{
    
    if ("gridReference" %in% names(selectedStationSummary)) {
      
      gridref <- unlist(selectedStationSummary$gridReference)
      
      coords <- data.frame("Latitude"=unlist(lapply(gridref,function(x) OSG2LatLon(OSGParse(unlist(x)))[1])), "Longitude"=unlist(lapply(gridref,function(x) OSG2LatLon(OSGParse(unlist(x)))[2])))
      
    }else{
      
      message("Provide a table with at least 1 column called gridReference.")
      
    }
    
  }
  
  if (!is.null(coords)){
    
    centerCoords <- c(mean(coords$Latitude),mean(coords$Longitude))
    
    myMap <- Leaflet$new()
    myMap$tileLayer(provider = 'Stamen.TonerLite')    
    myMap$setView(centerCoords, zoom = 6)
    
    if ("name" %in% names(selectedStationSummary) & "id" %in% names(selectedStationSummary)) {
      
      for (nStations in 1:dim(selectedStationSummary)[1]) {
        
        myMap$marker(c(coords$Latitude[[nStations]],coords$Longitude[[nStations]]), 
                     bindPopup = paste("<p> ",
                                       selectedStationSummary$name[[nStations]],
                                       " (id: ",
                                       selectedStationSummary$id[[nStations]],
                                       ") </p>",
                                       sep="") )
        
      }     
      
      myMap
      
    }else{
      
      myMap$marker(c(coords$Latitude[[nStations]],coords$Longitude[[nStations]]))
      
      myMap
      
    }
    
  }
  
}
