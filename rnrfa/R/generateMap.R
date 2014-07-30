#' Generate map of UK NRFA stations.
#'
#' @author Claudia Vitolo
#'
#' @description This function takes as input a table of UK NRFA stations (output of getStationSummary() function) and generates a map using leaflet javascript library. 
#'
#' @param StationSummary This is the data.frame containing at least a column called "gridReference" (in which OS Grid references are stored) with 1 row for each station. Alternatively the table could contain 2 columns called "Latitude" and "Longitude" containing the coordinates of stations in WGS84, with 1 row for each station.
#'
#' @return displays a map 
#' 
#' @examples
#' # myMap <- getStationSummary(LonMin=-1, LonMax=1, LatMin=51, LatMax=49)
#' # generateMap(myMap)
#' 

generateMap <- function(StationSummary){
  
  #require(rCharts)
  
  if (dim(StationSummary)[1] > 1481) {
    
    data(StationSummary)
    StationSummary <- StationSummary[1:1481,]
    rm(StationSummary)
    
  }
  
  coords <- NULL
  
  if ("Latitude" %in% names(StationSummary) & "Longitude" %in% names(StationSummary)) {
    
    coords <- data.frame("Latitude"=unlist(StationSummary$Latitude), "Longitude"=unlist(StationSummary$Longitude))
    
  }else{
    
    if ("gridReference" %in% names(StationSummary)) {
      
      gridref <- unlist(StationSummary$gridReference)
      
      coords <- data.frame("Latitude"=unlist(lapply(gridref,function(x) osg2latlon(osgparse(unlist(x)))[1])), "Longitude"=unlist(lapply(gridref,function(x) osg2latlon(osgparse(unlist(x)))[2])))
      
    }else{
      
      message("Provide a table with at least 1 column called gridReference.")
      
    }
    
  }
  
  if (!is.null(coords)){
    
    centerCoords <- c(mean(coords$Latitude),mean(coords$Longitude))
    
    myMap <- Leaflet$new()
    myMap$tileLayer(provider = 'Stamen.TonerLite')    
    myMap$setView(centerCoords, zoom = 6)
    
    if ("name" %in% names(StationSummary) & "id" %in% names(StationSummary)) {
      
      for (nStations in 1:dim(StationSummary)[1]) {
        
        myMap$marker(c(coords$Latitude[[nStations]],coords$Longitude[[nStations]]), 
                     bindPopup = paste("<p> ",
                                       StationSummary$name[[nStations]],
                                       " (id: ",
                                       StationSummary$id[[nStations]],
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
