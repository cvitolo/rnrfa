#' This function retrieves time series of gauged daily flow from the NRFA database.
#'
#' @author Claudia Vitolo
#'
#' @description Given the station ID number, this function retrieves the time series in zoo format. 
#'
#' @param stnID Station ID number, it should be in the range [3002,236051]. See table containing the most uptodate list (load(GDFtable))
#'
#' @return time series of class zoo
#'
#' @examples
#' searchNRFA(3002)
#'

searchNRFA <- function(stnID){
  
  #require(RCurl)
  #require(XML2R)
  
  # The table with all the stations is obtained from:
  # with Xmin = -8, Xmax = 2, Ymin=49, Ymax=58
  # GDFtable <- read.csv("/home/claudia/Dropbox/Repos/r_rnrfa/GDFtable.csv",sep="\t", skip=1)
  # headerGDFtable <- c("Stations ID No.", "River", "Location", "Area (km2)", "GDF data period",  "GDF download")
  # names(GDFtable) <- headerGDFtable
  # save(GDFtable,file="~/GDFtable.rda")
  
  # get an example waterml file from ceda website:
  # url <- "http://www.ceh.ac.uk/nrfa/xml/waterml2?db=nrfa_public&stn=92001&dt=gdf"
  
  url <- paste("http://www.ceh.ac.uk/nrfa/xml/waterml2?db=nrfa_public&stn=",stnID,"&dt=gdf",sep="")
  
  if ( url.exists(url)==TRUE ){
    
    doc <- urlsToDocs(url)
    nodes <- docsToNodes(doc,xpath="/")
    myList <- nodesToList(nodes)
    
    myMetadata <- findInfo(myList)

    myTS <- findTS(myList)
    
  }else{
    
    message("For this station there is not available online dataset in waterml format")
    
  }
    
  return( list("Metadata"=myMetadata,
               "TS"=myTS,
               "fullList"=myList) )
  
}
