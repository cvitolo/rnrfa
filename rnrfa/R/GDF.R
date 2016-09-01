#' This function retrieves Gauged Daily Flow (GDF).
#'
#' @author Claudia Vitolo
#'
#' @description Given the station ID number(s), this function retrieves data (time series in zoo format with accompanying metadata) from the WaterML2 service on the NRFA database. Gauged Daily Flow is measured in mm/day.
#'
#' @param id station ID number(s), each number should be in the range [3002,236051].
#' @param metadata Logical, FALSE by default. If metadata = TRUE means that the result for a single station is a list with two elements: data (the time series) and meta (metadata).
#' @param cl (optional) This is a cluster object, created by the parallel package. This is set to NULL by default, which sends sequential calls to the server.
#'
#' @return list composed of as many objects as in the list of station ID numbers. Each object can be accessed using their names or index (e.g. x[[1]], x[[2]], and so forth). Each object contains a zoo time series.
#'
#' @export
#'
#' @examples
#' \dontrun{
#'   GDF(18019)
#'   GDF(c(54022,54090,54091))
#' }
#'

GDF <- function(id, metadata = FALSE, cl = NULL){

  flow <- getTS(id, type = "gdf", metadata, cl)

  return(flow)

}
