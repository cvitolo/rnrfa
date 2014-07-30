#' List of stations from UK NRFA
#' 
#' @author Claudia Vitolo
#'
#' @description This function pulls the list of stations (and related metadata), falling within a given bounding box, from the CEH National River Flow Archive website.
#' 
#' @details coordinates of bounding box are required in WGS84 (EPSG: 4326). If BB coordinates are missing, the function returns the list corresponding to the maximum extent of the network.
#'
#' @param LonMin Minimum longitude of bounding box
#' @param LonMax Maximum longitude of bounding box
#' @param LatMin Minimum latitude of bounding box
#' @param LatMax Maximum latitude of bounding box
#' 
#' @param mdCol name of column to filter
#' @param mdVal string to search in mdCol
#' 
#' @param minRec minimum number of recording years
#'
#' @return data.frame with list of stations and related metadata
#'
#' @examples
#' x <- getStationSummary() # this returns all the stations in the network
#' x <- getStationSummary(LonMin=-1, LonMax=1, LatMin=49, LatMax=51) # this returns 31 stations
#' 

getStationSummary <- function(LonMin=-10, LonMax=10, LatMin=48, LatMax=62,
                              mdCol = NULL, mdVal = NULL, minRec=NULL) {
  
  #require(rjson)
  
  options(warn=-1)
  
  ### FILTER BASED ON BOUNDING BOX ###
  
  url <- paste("http://www.ceh.ac.uk/nrfa/json/stationSummary?db=nrfa_public&stn=llbb%3A",
               LatMax,"%2C",LonMin,"%2C",LatMin,"%2C",LonMax, sep="")
  
  StationSummary <- fromJSON(file=url)
  if (length(as.list(StationSummary))==0){
    message("No GDF stations found within the bounding box.")
  }else{
    colNames <- names(StationSummary[[1]])
    
    class(StationSummary) <- "data.frame"
    attr(StationSummary, "row.names") <- c(NA_integer_, -length(StationSummary[[1]]))
    StationSummary <- data.frame(t(StationSummary))
    names(StationSummary) <- colNames
  }
  
  ### END (FILTER BASED ON BOUNDING BOX) ###
  
  ### FILTER BASED ON METADATA STRINGS/THRESHOLD ###
  
  temp <- StationSummary
  
  if (!is.null(mdCol) & !is.null(mdVal)) {
    if (is.numeric(unlist(eval(parse(text=paste('temp$',mdCol))))) 
        & (substr(mdVal, 1, 1)==">" | substr(mdVal, 1, 1)=="<" | substr(mdVal, 1, 1)=="=") ){
      if (substr(mdVal, 2, 2)=="="){
        threshold <- as.numeric(substr(mdVal, 3, nchar(mdVal)))
        newStationSummary <- subset(temp, 
                                    eval(parse(text=paste(mdCol,substr(mdVal, 1, 2),
                                                          substr(mdVal, 3, nchar(mdVal))))) )
      }else{
        threshold <- as.numeric(substr(mdVal, 2, nchar(mdVal)))
        newStationSummary <- subset(temp, 
                                    eval(parse(text=paste(mdCol,substr(mdVal, 1, 1),
                                                                substr(mdVal, 2, nchar(mdVal))))) )
      }
    }else{
      newStationSummary <- subset(temp, eval(parse(text=mdCol))==mdVal)    
    }
    StationSummary <- newStationSummary
  }
  
  ### END (FILTER BASED ON METADATA STRINGS/THRESHOLD) ###
  
  ### FILTER BASED ON MINIMUM RECONDING YEARS ###
  
  if (!is.null(minRec)) {
    temp <- StationSummary
    endYear <- as.numeric(unlist(temp$gdfEnd))
    endYear[is.na(endYear)] <- 0
    startYear <- as.numeric(unlist(temp$gdfStart))
    startYear[is.na(startYear)] <- 0
    recordingYears <- endYear-startYear
    goodRecordingYears <- which(recordingYears>=minRec)    
    StationSummary <- temp[goodRecordingYears,]
  }
  
  ### END (FILTER BASED ON MINIMUM RECONDING YEARS) ###
  
  return(StationSummary)
  
}
