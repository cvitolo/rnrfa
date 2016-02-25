#' List of stations from UK NRFA
#'
#' @author Claudia Vitolo
#'
#' @description This function pulls the list of stations (and related metadata), falling within a given bounding box, from the CEH National River Flow Archive website.
#'
#' @param bbox this is a geographical bounding box (e.g. list(lonMin=-3.82, lonMax=-3.63, latMin=52.43, latMax=52.52))
#' @param metadataColumn name of column to filter
#' @param entryValue string to search in metadataColumn#'
#' @param minRec minimum number of recording years
#' @param verbose if TRUE prints warning messages
#'
#' @details coordinates of bounding box are required in WGS84 (EPSG: 4326). If BB coordinates are missing, the function returns the list corresponding to the maximum extent of the network.
#'
#' Offline you can browse the cached version running the command \code{data(stationSummary)}
#'
#' @return data.frame with list of stations and related metadata
#'
#' @examples
#' # Retrieve all the stations in the network
#' # x <- catalogue()
#'
#' # Define a bounding box:
#' bbox <- list(lonMin=-3.82, lonMax=-3.63, latMin=52.43, latMax=52.52)
#' # Get stations within the bounding box
#' x <- catalogue(bbox)
#'
#' # Get stations based on minimum number of recording years
#' # x <- catalogue(minRec=30)
#'

catalogue <- function(bbox = NULL, metadataColumn = NULL,
                           entryValue = NULL, minRec=NULL, verbose = FALSE) {

  # require(RCurl)
  # require(rjson)
  # require(plyr)

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

  url <- paste(website,"/json/stationSummary?db=nrfa_public&stn=llbb:",
               latMax,",",lonMin,",",latMin,",",lonMax, sep="")

  if( url.exists(url) ) {

    if (verbose) message("Retrieving data from live web data source.")

    # Get the JSON file
    stationListJSON <- fromJSON(file=url)
    # remove nested lists
    stationList <- llply(stationListJSON, unlist)
    stationColumns <- unique(unlist(lapply(stationListJSON, names)))
    cols2rm <- which(stationColumns %in% c("description", "start", "end",
                                           "primary-purpose",
                                           "measured-parameter",
                                           "how-parameter-measured",
                                           "high-flow-gauging-method",
                                           "previous-high-flow-gauging-method",
                                           "wing-wall-height", "bankfull-stage",
                                           "maximum-gauged-flow",
                                           "maximum-gauged-level"))
    stationColumns <- unique(unlist(lapply(stationListJSON, names)))[-cols2rm]
    selectedMeta <- lapply(stationList, function(x) {x[stationColumns]})
    stationList <- as.data.frame(do.call(rbind,selectedMeta))
    names(stationList) <- stationColumns
    ### END (FILTER BASED ON BOUNDING BOX) ###

    ### FILTER BASED ON METADATA STRINGS/THRESHOLD ###

    temp <- stationList

    if (is.null(metadataColumn) & !is.null(entryValue)) {
      message("Enter valid metadataColumn")
    }

    if (!is.null(metadataColumn) & is.null(entryValue)) {
      message("Enter valid entryValue")
    }

    if (!is.null(metadataColumn) & !is.null(entryValue)){

      if (metadataColumn == "id"){

        myRows <- which(stationList$id %in% entryValue)
        stationList <- stationList[myRows,]

      }else{

        myColumn <- unlist(eval(parse(text=paste('temp$',metadataColumn))))

        Condition1 <- all(!is.na(as.numeric(as.character(myColumn))))
        if (Condition1 == TRUE) myColumn <- as.numeric(as.character(myColumn))

        Condition2 <- substr(entryValue, 1, 1) == ">"
        Condition3 <- substr(entryValue, 1, 1) == "<"
        Condition4 <- substr(entryValue, 1, 1) == "="

        if (Condition1 & (Condition2 | Condition3 | Condition4)){

          if (substr(entryValue, 2, 2) == "="){

            threshold <- as.numeric(as.character(substr(entryValue, 3, nchar(entryValue))))
            combinedString <- paste(metadataColumn,
                                    substr(entryValue, 1, 2),
                                    substr(entryValue, 3, nchar(entryValue)))
            myExpression <- eval(parse(text=combinedString))
            newstationList <- subset(temp, myExpression)

          }else{
            threshold <- as.numeric(as.character(substr(entryValue, 2,
                                                        nchar(entryValue))))
            combinedString <- paste("myColumn",
                                    substr(entryValue, 1, 1),
                                    substr(entryValue, 2, nchar(entryValue)))
            myExpression <- eval(parse(text=combinedString))
            newstationList <- subset(temp, myExpression)
          }
        }else{
          myExpression <- myColumn==entryValue
          newstationList <- subset(temp, myExpression)
        }
        stationList <- newstationList

      }

    }

    ### END (FILTER BASED ON METADATA STRINGS/THRESHOLD) ###

    ### FILTER BASED ON MINIMUM RECONDING YEARS ###

    if (!is.null(minRec)) {
      temp <- stationList
      endYear <- as.numeric(as.character(unlist(temp$gdfEnd)))
      endYear[is.na(endYear)] <- 0
      startYear <- as.numeric(as.character(unlist(temp$gdfStart)))
      startYear[is.na(startYear)] <- 0
      recordingYears <- endYear-startYear
      goodRecordingYears <- which(recordingYears>=minRec)
      stationList <- temp[goodRecordingYears,]
    }

    ### END (FILTER BASED ON MINIMUM RECONDING YEARS) ###

    # Add lat and lon
    gridR <- OSGparse(gridRefs = unlist(stationList$gridReference),
                      CoordSystem = "WGS84")
    stationList$lat <- gridR$ylat
    stationList$lon <- gridR$xlon

    return(stationList)

  }else{

    message("The connection with the live web data source failed.")

    stop

  }

}
