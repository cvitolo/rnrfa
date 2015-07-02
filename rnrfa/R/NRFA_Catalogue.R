#' List of stations from UK NRFA
#'
#' @author Claudia Vitolo
#'
#' @description This function pulls the list of stations (and related metadata), falling within a given bounding box, from the CEH National River Flow Archive website.
#'
#' @param bbox this is a geographical bounding box (e.g. list(lonMin=-3.82, lonMax=-3.63, latMin=52.43, latMax=52.52))#'
#' @param metadataColumn name of column to filter
#' @param entryValue string to search in metadataColumn#'
#' @param minRec minimum number of recording years
#'
#' @details coordinates of bounding box are required in WGS84 (EPSG: 4326). If BB coordinates are missing, the function returns the list corresponding to the maximum extent of the network.
#'
#' @return data.frame with list of stations and related metadata
#'
#' @export
#'
#' @examples
#' # Retrieve all the stations in the network (1537)
#' x <- NRFA_Catalogue()
#'
#' # Define a bounding box:
#' # bbox <- list(lonMin=-3.82, lonMax=-3.63, latMin=52.43, latMax=52.52)
#' # x <- NRFA_Catalogue(bbox) # this returns 9 stations
#' # x <- NRFA_Catalogue(minRec=30) # this returns 1048 stations
#'

NRFA_Catalogue <- function(bbox = NULL, metadataColumn = NULL,
                           entryValue = NULL, minRec=NULL) {

  # require(RCurl)
  # require(rjson)

  options(warn=-1)

  ### FILTER BASED ON BOUNDING BOX ###

  if (!is.null(bbox)){

    lonMin <- bbox$lonMin
    lonMax <- bbox$lonMax
    latMin <- bbox$latMin
    latMax <- bbox$latMax

  }else{

    lonMin <- -180
    lonMax <- +180
    latMin <- -90
    latMax <- +90

  }

  website <- "http://nrfaapps.ceh.ac.uk/nrfa"

  url <- paste(website,"/json/stationSummary?db=nrfa_public&stn=llbb%3A",
               latMax,"%2C",lonMin,"%2C",latMin,"%2C",lonMax, sep="")

  if( url.exists(url) ) {

    message("Retrieving data from live web data source.")

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

    if (!is.null(metadataColumn)){

      if (metadataColumn == "id"){

        myRows <- which(stationSummary$id %in% entryValue)
        stationSummary <- stationSummary[myRows,]

      }else{

        if (!is.null(metadataColumn) & !is.null(entryValue)) {

          myColumn <- unlist(eval(parse(text=paste('temp$',metadataColumn))))

          Condition1 <- is.numeric(myColumn)
          Condition2 <- substr(entryValue, 1, 1) == ">"
          Condition3 <- substr(entryValue, 1, 1) == "<"
          Condition4 <- substr(entryValue, 1, 1) == "="

          if (Condition1 & (Condition2 | Condition3 | Condition4)){

            if (substr(entryValue, 2, 2)=="="){

              threshold <- as.numeric(substr(entryValue, 3, nchar(entryValue)))
              combinedString <- paste(metadataColumn,
                                     substr(entryValue, 1, 2),
                                     substr(entryValue, 3, nchar(entryValue)))
              myExpression <- eval(parse(text=combinedString))
              newstationSummary <- subset(temp, myExpression)

            }else{
              threshold <- as.numeric(substr(entryValue, 2, nchar(entryValue)))
              combinedString <- paste(metadataColumn,
                                      substr(entryValue, 1, 1),
                                      substr(entryValue, 2, nchar(entryValue)))
              myExpression <- eval(parse(text=combinedString))
              newstationSummary <- subset(temp, myExpression)
            }
          }else{
            myExpression <- eval(parse(text=metadataColumn))==entryValue
            newstationSummary <- subset(temp, myExpression)
          }
          stationSummary <- newstationSummary
        }

      }

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

  }else{

    message("The connection with the live web data source failed.")

    stop

  }

}
