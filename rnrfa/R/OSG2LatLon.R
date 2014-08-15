#' Converts easting/northing to latitude/longitude.
#'
#' @author Claudia Vitolo
#'
#' @description This function converts easting and northing coordinates (UK National Grid, epsg:27700) and converts them to longitute and latitude (WGS84, epsg:4326). It uses rgadal and sp functionalities for coordinates transformations.
#'
#' @param en this is a vector containing the easting and northing coordinates.
#'
#' @return vector made of two elements: the latitude and longitude. 
#' 
#' @export
#' 
#' @references This function is based on the following forum post: https://stat.ethz.ch/pipermail/r-sig-geo/2010-November/010141.htm
#'
#' @examples
#' # single entry
#' OSG2LatLon(c(572200,121300))
#' 
#' # use result from OSGParse() function
#' OSG2LatLon(OSGParse("TQ722213"))
#' 
#' # multiple entries & use result from OSGParse() function
#' OSG2LatLon(OSGParse(c("SN831869","SN829838","SN824853","SN824842","SN826854")))
#

OSG2LatLon <- function(en) {
  
  enTemp <- as.numeric(unlist(en))
  
  if ( length(enTemp) > 2 ) {
    
      df <- data.frame(matrix(NA,ncol=2,nrow=dim(en)[1])) 
      names(df) <- c("Latitude","Longitude")
      
      for (i in 1:dim(en)[1]){
        df[i,"Latitude"] <- OSG2LatLon1(unlist(en[i,]))[1]
        df[i,"Longitude"] <- OSG2LatLon1(unlist(en[i,]))[2]
      }    
    
  }else{
    
    df <- data.frame(matrix(NA,ncol=2,nrow=1))
    names(df) <- c("Latitude","Longitude")
    df[1,"Latitude"] <- OSG2LatLon1(en)[1]
    df[1,"Longitude"] <- OSG2LatLon1(en)[2]
    
  }
  
  return(df)
  
}

OSG2LatLon1 <- function(en) {
  
  #require(rgdal)
  #require(sp)
  
  myX <- as.numeric(unlist(en[1]))
  myY <- as.numeric(unlist(en[2]))
  
  pt <- data.frame(x=myX,y=myY)
  coordinates(pt)=~x+y
  
  # Set the Coordinate Reference System (CRS) to UK National Grid.
  proj4string(pt)=CRS("+init=epsg:27700")
  
  # Transform coordinates to WGS84:
  ptNew <- spTransform(pt,CRS("+init=epsg:4326"))
  
  latitude <- unname(ptNew$y)
  longitude <- unname(ptNew$x)
  
  return(c(latitude,longitude))
  
}
