#' List of stations identification numbers from UK NRFA
#'
#' @author Claudia Vitolo
#'
#' @description This function pulls the list of station identification numbers.
#'
#' @return vector integer identification numbers (one for each station)
#'
#' @export
#'
#' @examples
#' \dontrun{
#'   # Retrieve all the stations ids
#'   x <- station_ids()
#' }
#'

station_ids <- function() {

  parameters <- list(format = "json-object")

  response <- nrfa_api(webservice = "station-ids", parameters)

  return(unlist(response$content, use.names = FALSE))

}
