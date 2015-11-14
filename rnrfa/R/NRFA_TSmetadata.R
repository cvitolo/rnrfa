#' This function retrieves metadata from wml time series of gauged daily flow from the NRFA database.
#'
#' @author Claudia Vitolo
#'
#' @description Given the station ID number(s), this function retrieves data (time series in zoo format) and metadata.
#'
#' @param ID station ID number(s), each number should be in the range [3002,236051].
#'
#' @return list composed of as many objects as in the list of station ID numbers. Each object can be accessed using their names or index (e.g. x[[1]], x[[2]], and so forth). Each object contains a data.frame.
#'
#' @examples
#' # One station
#' NRFA_TSmetadata(3001)
#' # Multiple stations
#' # x <- NRFA_TSmetadata(c(3001,3002,3003))
#' # View(x$ID3001)
#' # View(x[[1]])
#'

NRFA_TSmetadata <- function(ID){

  # require(RCurl)
  # require(XML2R)
  # require(stringr)
  # require(zoo)

  options(warn=-1) # do not print warnings

  wml <- list()

  counter <- 0

  for (stationID in ID){

    counter <- counter + 1

    website <- "http://nrfaapps.ceh.ac.uk/nrfa"

    url <- paste(website,"/xml/waterml2?db=nrfa_public&stn=",
                 stationID,"&dt=gdf",sep="")

    if ( url.exists(url) ){

      doc <- urlsToDocs(url)
      nodes <- docsToNodes(doc,xpath="/")
      myList <- nodesToList(nodes)

      wml[[counter]] <- FindInfo(myList)

      if (length(ID) == 1) {

        wml <- wml[[1]]
        return( wml )

      }else{

        names(wml)[[counter]] <- paste("ID",stationID,sep="")

      }

    }else{

      message(paste("For station", stationID,"there is no available online dataset in waterml format"))

    }

  }

  return( wml )

}
