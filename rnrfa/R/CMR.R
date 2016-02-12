#' This function retrieves data from wml time series of Catchment Monthly Rainfall from the NRFA database.
#'
#' @author Claudia Vitolo
#'
#' @description Given the station ID number(s), this function retrieves data (time series in zoo format).
#'
#' @param ID station ID number(s), each number should be in the range [3002,236051].
#'
#' @return list composed of as many objects as in the list of station ID numbers. Each object can be accessed using their names or index (e.g. x[[1]], x[[2]], and so forth). Each object contains a zoo time series.
#'
#' @examples
#' CMR(18019)
#'

CMR <- function(ID){

  # require(RCurl)
  # require(XML2R)
  # require(stringr)
  # require(zoo)

  options(warn=-1) # do not print warnings

  website <- "http://nrfaapps.ceh.ac.uk/nrfa"

  url <- paste(website,"/xml/waterml2?db=nrfa_public&stn=", ID,"&dt=cmr",sep="")

  if ( url.exists(url) ){

    doc <- urlsToDocs(url)
    nodes <- docsToNodes(doc,xpath="/")
    myList <- nodesToList(nodes)

    wml <- FindTS(myList)


  }else{

    message(paste("For station", ID,
                  "there is no available online dataset in waterml format"))

  }

  return(wml)

}
