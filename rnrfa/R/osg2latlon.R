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
#' @references This function is based on the following forum post: https://stat.ethz.ch/pipermail/r-sig-geo/2010-November/010141.htm
#'
#' @examples
#' # single entry
#' osg2latlon(c(572200,121300))
#' 
#' # use result from osgparse() function
#' osg2latlon(osgparse("TQ722213"))
#' 
#' # multiple entries & use result from osgparse() function
#' osg2latlon(osgparse(c("SN831869","SN829838","SN824853","SN824842","SN826854")))
#

osg2latlon1 <- function(en) {
  
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

osg2latlon <- function(en) {
  
  # en <- c(572200,121300)
  # en <- osgparse(c("SN831869","SN829838","SN824853","SN824842","SN826854"))
  enTemp <- as.numeric(unlist(en))
  
  if ( length(enTemp) > 2 ) {
    
      df <- data.frame(matrix(NA,ncol=2,nrow=dim(en)[1])) 
      names(df) <- c("Latitude","Longitude")
      
      for (i in 1:dim(en)[1]){
        df[i,"Latitude"] <- osg2latlon1(unlist(en[i,]))[1]
        df[i,"Longitude"] <- osg2latlon1(unlist(en[i,]))[2]
      }    
    
  }else{
    
    df <- data.frame(matrix(NA,ncol=2,nrow=1))
    names(df) <- c("Latitude","Longitude")
    df[1,"Latitude"] <- osg2latlon1(en)[1]
    df[1,"Longitude"] <- osg2latlon1(en)[2]
    
  }
  
  return(df)
  
}
