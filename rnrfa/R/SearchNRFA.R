#' This function retrieves time series of gauged daily flow from the NRFA database.
#'
#' @author Claudia Vitolo
#'
#' @description Given the station ID number, this function retrieves the time series in zoo format. 
#'
#' @param stationID Station ID number, it should be in the range [3002,236051]. 
#'
#' @return time series of class zoo
#' 
#' @export
#'
#' @examples
#' SearchNRFA(3001)
#'

SearchNRFA <- function(stationID){
  
  #require(RCurl)
  #require(XML2R)
  
  url <- paste("http://www.ceh.ac.uk/nrfa/xml/waterml2?db=nrfa_public&stn=",stationID,"&dt=gdf",sep="")
  
  if ( url.exists(url)==TRUE ){
    
    doc <- urlsToDocs(url)
    nodes <- docsToNodes(doc,xpath="/")
    myList <- nodesToList(nodes)
    
    myMetadata <- FindInfo(myList)

    myTS <- FindTS(myList)
    
  }else{
    
    message("For this station there is not available online dataset in waterml format")
    
  }
    
  return( list("wmlInfo"=myMetadata,
               "wmlTS"=myTS) )
  
}
