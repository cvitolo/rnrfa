#' Convert flow from cumecs to mm/d
#'
#' @description This function converts flow time series from cumecs (m3/s) to mm/d by dividing the flow by the catchment area and converting it to mm/day.
#'
#' @param flowCumecs This is the flow time series in cumecs (m3/s)
#' @param catchmentArea This is the catchment are in Km2.
#'
#' @return Flow time series in mm/d
#'
#' @export
#'
#' @examples
#' \dontrun{
#'   convert_flow(30, 2)
#' }
#'

convert_flow <- function(flowCumecs, catchmentArea){

  # Convert area from Km2 to m2
  catchmentArea <- catchmentArea*1000000

  # Convert 1 second to 1 day
  second2day <- 60*60*24

  # Convert flow from m3/s to mm/d
  convertedFlow <- ((flowCumecs*1000)/catchmentArea)*second2day

  return(convertedFlow)

}
