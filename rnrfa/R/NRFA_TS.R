#' This function retrieves time series of gauged daily flow from the NRFA database.
#'
#' @author Claudia Vitolo
#'
#' @description Given the station ID number(s), this function retrieves data (time series in zoo format) and metadata.
#'
#' @param ID station ID number(s), each number should be in the range [3002,236051].
#'
#' @return list composed of as many objects as in the list of station ID numbers. Each object can be accessed as x[[1]], x[[2]], and so forth. Each object contains a list of other two objects: data and metadata.
#'
#' @export
#'
#' @examples
#' # One station
#' NRFA_TS(3001)
#' # Multiple stations
#' # NRFA_TS(c(3001,3002,3003)); plot(x[[1]]$data)
#'

NRFA_TS <- function(ID){

  #require(RCurl)
  #require(XML2R)

  options(warn=-1) # do not print warnings

  wml <- list()

  counter <- 0

  for (stationID in ID){

    counter <- counter + 1

    url <- paste("http://www.ceh.ac.uk/nrfa/xml/waterml2?db=nrfa_public&stn=",stationID,"&dt=gdf",sep="")

    if ( url.exists(url)==TRUE ){

      doc <- urlsToDocs(url)
      nodes <- docsToNodes(doc,xpath="/")
      myList <- nodesToList(nodes)

      metadata <- FindInfo(myList)
      data <- FindTS(myList)

      stationInfo <- list("metadata"=metadata, "data"=data)

      wml[[counter]] <- stationInfo

    }else{

      message(paste("For station", stationID,"there is no available online dataset in waterml format"))

    }

  }

  if (length(ID) == 1) wml <- wml[[1]]

  return( wml )

}
