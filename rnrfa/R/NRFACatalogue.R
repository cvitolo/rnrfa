#' List of stations from UK NRFA
#'
#' @author Claudia Vitolo
#'
#' @description This function pulls the list of stations (and related metadata), falling within a given bounding box, from the CEH National River Flow Archive website.
#'
#' @details coordinates of bounding box are required in WGS84 (EPSG: 4326). If BB coordinates are missing, the function returns the list corresponding to the maximum extent of the network.
#'
#' @param lonMin Minimum latitude of bounding box
#' @param lonMax Maximum latitude of bounding box
#' @param latMin Minimum longitude of bounding box
#' @param latMax Maximum longitude of bounding box
#'
#' @param metadataColumn name of column to filter
#' @param entryValue string to search in metadataColumn#'
#' @param minRec minimum number of recording years
#'
#' @return data.frame with list of stations and related metadata
#'
#' @export
#'
#' @examples
#' x <- NRFACatalogue() # this returns all the stations in the network
#' x <- NRFACatalogue(lonMin=-1, lonMax=1, latMin=49, latMax=51) # this returns 31 stations
#'

NRFACatalogue <- function(lonMin=-10, lonMax=10, latMin=48, latMax=62,
                              metadataColumn = NULL, entryValue = NULL, minRec=NULL) {

  #require(rjson)

  options(warn=-1)

  ### FILTER BASED ON BOUNDING BOX ###

  url <- paste("http://www.ceh.ac.uk/nrfa/json/stationSummary?db=nrfa_public&stn=llbb%3A",
               latMax,"%2C",lonMin,"%2C",latMin,"%2C",lonMax, sep="")

  stationSummary <- fromJSON(file=url)
  if (length(as.list(stationSummary))==0){
    message("No GDF stations found within the bounding box.")
  }else{
    colNames <- names(stationSummary[[1]])

    class(stationSummary) <- "data.frame"
    attr(stationSummary, "row.names") <- c(NA_integer_, -length(stationSummary[[1]]))
    stationSummary <- data.frame(t(stationSummary))
    names(stationSummary) <- colNames
  }

  ### END (FILTER BASED ON BOUNDING BOX) ###

  ### FILTER BASED ON METADATA STRINGS/THRESHOLD ###

  temp <- stationSummary

  if (!is.null(metadataColumn) & !is.null(entryValue)) {
    if (is.numeric(unlist(eval(parse(text=paste('temp$',metadataColumn)))))
        & (substr(entryValue, 1, 1)==">" | substr(entryValue, 1, 1)=="<" | substr(entryValue, 1, 1)=="=") ){
      if (substr(entryValue, 2, 2)=="="){
        threshold <- as.numeric(substr(entryValue, 3, nchar(entryValue)))
        newstationSummary <- subset(temp,
                                    eval(parse(text=paste(metadataColumn,substr(entryValue, 1, 2),
                                                          substr(entryValue, 3, nchar(entryValue))))) )
      }else{
        threshold <- as.numeric(substr(entryValue, 2, nchar(entryValue)))
        newstationSummary <- subset(temp,
                                    eval(parse(text=paste(metadataColumn,substr(entryValue, 1, 1),
                                                                substr(entryValue, 2, nchar(entryValue))))) )
      }
    }else{
      newstationSummary <- subset(temp, eval(parse(text=metadataColumn))==entryValue)
    }
    stationSummary <- newstationSummary
  }

  ### END (FILTER BASED ON METADATA STRINGS/THRESHOLD) ###

  ### FILTER BASED ON MINIMUM RECONDING YEARS ###

  if (!is.null(minRec)) {
    temp <- stationSummary
    endYear <- as.numeric(unlist(temp$gdfEnd))
    endYear[is.na(endYear)] <- 0
    startYear <- as.numeric(unlist(temp$gdfStart))
    startYear[is.na(startYear)] <- 0
    recordingYears <- endYear-startYear
    goodRecordingYears <- which(recordingYears>=minRec)
    stationSummary <- temp[goodRecordingYears,]
  }

  ### END (FILTER BASED ON MINIMUM RECONDING YEARS) ###

  return(stationSummary)

}
