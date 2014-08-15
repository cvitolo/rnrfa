#' Converts UK National Grid Reference to easting/northing coordinates (epsg:27700).
#'
#' @author Claudia Vitolo
#'
#' @description This function converts an OS reference to easting/northing coordinates (UK National Grid, epsg:27700). 
#'
#' @param gridRef This is a string that expresses the UK Grid Reference.
#'
#' @return vector made of two elements: the easting and northing coordinates. 
#' 
#' @export
#' 
#' @references This function is based on the following post: http://stackoverflow.com/questions/23017053/how-to-convert-uk-grid-reference-to-latitude-and-longitude-in-r/23023744?noredirect=1#23023744
#'
#' @examples
#' # single entry
#' OSGParse("TQ722213")
#' 
#' # multiple entries
#' OSGParse(c("SN831869","SN829838","SN824853","SN824842","SN826854"))
#' 

OSGParse <- function(gridRef) {
  
  if ( length(gridRef) > 1 ) {
    
    x <- unlist(gridRef)
    df <- data.frame(matrix(NA,ncol=2,nrow=length(x))) 
    names(df) <- c("Easting","Northing")
    
    for (i in 1:length(x)){
      df[i,"Easting"] <- OSGParse1(x[i])[1]
      df[i,"Northing"] <- OSGParse1(x[i])[2]
    }    
    
  }else{
    df <- data.frame(matrix(NA,ncol=2,nrow=1))
    names(df) <- c("Easting","Northing")
    df[1,"Easting"] <- OSGParse1(gridRef)[1]
    df[1,"Northing"] <- OSGParse1(gridRef)[2]
  }
  
  return(df)
  
}

OSGParse1 <- function(gridRef) {
  
  gridRef <- toupper(gridRef)
  
  # get numeric values of letter references, mapping A->0, B->1, C->2, etc:
  l1 <- as.numeric(charToRaw(substr(gridRef,1,1))) - 65
  l2 <- as.numeric(charToRaw(substr(gridRef,2,2))) - 65
  
  # shuffle down letters after 'I' since 'I' is not used in grid:
  if (l1 > 7) l1 <- l1 - 1
  if (l2 > 7) l2 <- l2 - 1
  
  # convert grid letters into 100km-square indexes from false origin - grid square SV
  
  e <- ((l1-2) %% 5) * 5 + (l2 %% 5)
  n <- (19 - floor(l1/5) *5 ) - floor(l2/5)
  
  if (e<0 || e>6 || n<0 || n>12) { return(c(NA,NA)) }
  
  # skip grid letters to get numeric part of ref, stripping any spaces:
  
  ref.num <- gsub(" ", "", substr(gridRef, 3, nchar(gridRef)))
  ref.mid <- floor(nchar(ref.num) / 2)
  ref.len <- nchar(ref.num)
  
  if (ref.len >= 10) { return(c(NA,NA)) }
  
  e <- paste(e, substr(ref.num, 0, ref.mid), sep="", collapse="")
  n <- paste(n, substr(ref.num, ref.mid+1, ref.len), sep="", collapse="")
  
  nrep <- 5 - match(ref.len, c(0,2,4,6,8))
  
  e <- as.numeric(paste(e, "0", rep("0", nrep), sep="", collapse=""))
  n <- as.numeric(paste(n, "0", rep("0", nrep), sep="", collapse=""))
  
  return(c(e,n))
  
}
