#' Extract info from the waterml2.
#'
#' @author Claudia Vitolo
#'
#' @description This function retrieves the most important info from the waterml2 file given as a list.
#'
#' @param myList this is a nested list which comes from the conversion of waterml2 data
#'
#' @return named vector containing the following information: stationName, Latitude, Longitude, typeOfMeasurement
#'

findInfo <- function(myList){
  
  #require(stringr)
  
  temp <- myList[[1]][[1]]$Collection$samplingFeatureMember$MonitoringPoint$name$text
  stationName <- myList[[1]][[1]]$Collection$observationMember$OM_Observation$featureOfInterest[[2]]
  
  typeOfMeasurement <- myList[[1]][[1]]$Collection$localDictionary$Dictionary$dictionaryEntry$Definition$remarks
  
  temp <- myList[[1]][[1]]$Collection$samplingFeatureMember$MonitoringPoint$shape$Point$pos$text
  Latitude <- as.numeric(str_split(temp, " ")[[1]][1])  
  Longitude <- as.numeric(str_split(temp, " ")[[1]][2])  
  
  info <- data.frame(cbind(stationName,Latitude,Longitude,typeOfMeasurement))    
    
  return(info)
  
}
