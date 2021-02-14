#' List of stations from UK NRFA
#'
#' @author Claudia Vitolo
#'
#' @description This function pulls the list of stations (and related metadata),
#' falling within a given bounding box, from the CEH National River Flow Archive
#' website.
#'
#' @param bbox this is a geographical bounding box (e.g. list(lon_min = -3.82,
#' lon_max = -3.63, lat_min = 52.43, lat_max = 52.52))
#' @param column_name name of column to filter
#' @param column_value string to search in column_name
#' @param min_rec minimum number of recording years
#' @param all if TRUE it returns all the available metadata. If FALSE, it
#' returns only the following columns: id, name, river, hydrometricArea,
#' operator, haName, catchmentArea, altitude, lat, lon.
#'
#' @details coordinates of bounding box are required in WGS84 (EPSG: 4326).
#' If BB coordinates are missing, the function returns the list corresponding to
#' the maximum extent of the network.
#'
#' @return tibble table containing the list of stations and related metadata
#'
#' @export
#'
#' @examples
#' \dontrun{
#'   # Retrieve all the stations in the network
#'   x <- catalogue()
#'
#'   # Define a bounding box:
#'   bbox <- list(lon_min=-3.82, lon_max=-3.63, lat_min=52.43, lat_max=52.52)
#'   # Get stations within the bounding box
#'   x <- catalogue(bbox)
#'
#'   # Get stations based on minimum catchment area
#'   x <- catalogue(column_name = "catchment-area", column_value = 2000)
#'
#'   # Get stations based on minimum number of recording years
#'   x <- catalogue(min_rec=30)
#' }
#'

catalogue <- function(bbox = NULL, column_name = NULL, column_value = NULL,
                      min_rec = NULL, all = TRUE) {

  # Prevent warnings and notes
  options(warn = -1)
  latitude <- longitude <- NULL

  parameters <- list(format = "json-object", station = "*", fields = "all")
  station_info <- nrfa_api(webservice = "station-info", parameters)
  # the station_info object is made of 3 elements:
  # 1. content (data), this is a list of one object called 'data'
  station_info_content <- station_info$content
  df <- station_info_content$data
  # 2. path (usually empty) - not needed here
  # 3. response (metadata, 10 fields) - currently not needed here

  ### FILTER BASED ON BOUNDING BOX ###
  if (!is.null(bbox)) {

    lon_min <- bbox$lon_min
    lon_max <- bbox$lon_max
    lat_min <- bbox$lat_min
    lat_max <- bbox$lat_max

    df <- df[(df$latitude > lat_min & df$latitude < lat_max) &
      (df$longitude > lon_min & df$longitude < lon_max), ]
  }

  ### FILTER BASED ON MINIMUM RECONDING YEARS ###
  if (!is.null(min_rec)) {
    end_year <- lubridate::year(df$`gdf-end-date`)
    end_year[is.na(end_year)] <- 0
    start_year <- lubridate::year(df$`gdf-start-date`)
    start_year[is.na(start_year)] <- 0
    recording_years <- end_year - start_year
    good_recording_years <- which(recording_years >= min_rec)
    df <- df[good_recording_years, ]
  }

  # FILTER BASED ON METADATA STRINGS/THRESHOLD
  if (is.null(column_name) & !is.null(column_value)) {
    stop("Enter valid column_name")
  }
  if (!is.null(column_name) & is.null(column_value)) {
    stop("Enter valid column_value")
  }
  if (!is.null(column_name) & !is.null(column_value)) {
    my_column <- unlist(eval(parse(text = paste0("df$`", column_name, "`"))))
    # The column contains numbers
    condition_1 <- is.numeric(my_column)
    if (condition_1) {
      my_column <- as.numeric(as.character(my_column))
      condition_2 <- substr(column_value, 1, 1) == ">"
      condition_3 <- substr(column_value, 1, 1) == "<"
      condition_4 <- substr(column_value, 1, 1) == "="
      if (condition_2 | condition_3 | condition_4) {
        if (substr(column_value, 2, 2) == "=") {
          threshold <- as.numeric(as.character(substr(column_value, 3,
                                                      nchar(column_value))))
          combined <- paste0("df$`", column_name, "`",
                             substr(column_value, 1, 2),
                             substr(column_value, 3, nchar(column_value)))
          my_expression <- eval(parse(text = combined))
          newstation_list <- subset(df, my_expression)
        }else{
          threshold <- as.numeric(as.character(substr(column_value, 2,
                                                      nchar(column_value))))
          combined_string <- paste("my_column",
                                   substr(column_value, 1, 1),
                                   substr(column_value, 2,
                                          nchar(column_value)))
          my_expression <- eval(parse(text = combined_string))
          newstation_list <- subset(df, my_expression)
        }
      }else{
        # Single value to match
        my_expression <- my_column == column_value
        newstation_list <- subset(df, my_expression)
      }
    }else{
      # The column contains characters
      my_expression <- my_column == column_value
      newstation_list <- subset(df, my_expression)
    }
    df <- newstation_list
  }

  # Convert data frame to tibble
  return(tibble::as_tibble(df))

}
