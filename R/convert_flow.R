#' Convert flow from cumecs to mm/d
#'
#' @description This function converts flow time series from cumecs (m3/s) to
#' mm/d by dividing the flow by the catchment area and converting it to mm/day.
#'
#' @param flow_cumecs This is the flow time series in cumecs (m3/s)
#' @param catchment_area This is the catchment are in Km2.
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

convert_flow <- function(flow_cumecs, catchment_area){

  # Convert area from Km2 to m2
  catchment_area <- catchment_area * 1000000

  # Convert 1 second to 1 day
  second2day <- 60 * 60 * 24

  # Convert flow from m3/s to mm/d
  converted_flow <- ((flow_cumecs * 1000) / catchment_area) * second2day

  return(converted_flow)

}
