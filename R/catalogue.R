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
#' Offline you can browse the cached version running the command
#' \code{data(stationSummary)}
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
#'   # Get stations based on minimum number of recording years
#'   x <- catalogue(min_rec=30)
#' }
#'

catalogue <- function(bbox = NULL, column_name = NULL, column_value = NULL,
                      min_rec = NULL, all = TRUE) {

  options(warn = -1)

  ### FILTER BASED ON BOUNDING BOX ###

  if (!is.null(bbox)){

    lon_min <- bbox$lon_min
    lon_max <- bbox$lon_max
    lat_min <- bbox$lat_min
    lat_max <- bbox$lat_max

  }else{

    lon_min <- -180
    lon_max <- +180
    lat_min <- -90
    lat_max <- +90

  }

  my_bbox <- paste0(lat_max, ",", lon_min, ",", lat_min, ",", lon_max)

  site_fetch <- httr::GET(url = "http://nrfaapps.ceh.ac.uk/",
                          path = "nrfa/json/stationSummary",
                          query = list(db = "nrfa_public",
                                       stn = paste0("llbb:", my_bbox)))

  if (!httr::http_error(site_fetch)) {

    # Get the JSON file
    station_list_json <- rjson::fromJSON(file = site_fetch[[1]])
    # remove nested lists
    station_list <- plyr::llply(station_list_json, unlist)

    if (length(station_list_json) == 0) {

      message("NRFA services seem temporarily unavailable, try again later.")

    }else{

      station_columns <- unique(unlist(lapply(station_list_json, names)))
      cols2rm <- which(station_columns %in%
                         c("description", "start", "end",
                           "primary-purpose",
                           "measured-parameter",
                           "how-parameter-measured",
                           "high-flow-gauging-method",
                           "previous-high-flow-gauging-method",
                           "wing-wall-height", "bankfull-stage",
                           "maximum-gauged-flow",
                           "maximum-gauged-level"))
      temp <- lapply(station_list_json, names)
      station_columns <- unique(unlist(temp))[-cols2rm]
      selected_meta <- lapply(station_list,
                              function(x){
                                x[station_columns]
                                })
      station_list <- as.data.frame(do.call(rbind, selected_meta))
      names(station_list) <- station_columns
      ### END (FILTER BASED ON BOUNDING BOX) ###

      ### FILTER BASED ON METADATA STRINGS/THRESHOLD ###

      temp <- station_list

      if (is.null(column_name) & !is.null(column_value)) {
        message("Enter valid column_name")
      }

      if (!is.null(column_name) & is.null(column_value)) {
        message("Enter valid column_value")
      }

      if (!is.null(column_name) & !is.null(column_value)){

        if (column_name == "id"){

          my_rows <- which(station_list$id %in% column_value)
          station_list <- station_list[my_rows, ]

        }else{

          my_column <- unlist(eval(parse(text = paste("temp$", column_name))))

          condition_1 <- all(!is.na(as.numeric(as.character(my_column))))
          if (condition_1 == TRUE){
            my_column <- as.numeric(as.character(my_column))
          }
          condition_2 <- substr(column_value, 1, 1) == ">"
          condition_3 <- substr(column_value, 1, 1) == "<"
          condition_4 <- substr(column_value, 1, 1) == "="

          if (condition_1 & (condition_2 | condition_3 | condition_4)){

            if (substr(column_value, 2, 2) == "="){

              threshold <- as.numeric(as.character(substr(column_value,
                                                          3,
                                                          nchar(column_value))))
              combined_string <- paste(column_name,
                                      substr(column_value, 1, 2),
                                      substr(column_value, 3,
                                             nchar(column_value)))
              my_expression <- eval(parse(text = combined_string))
              newstation_list <- subset(temp, my_expression)

            }else{
              threshold <- as.numeric(as.character(substr(column_value, 2,
                                                          nchar(column_value))))
              combined_string <- paste("my_column",
                                      substr(column_value, 1, 1),
                                      substr(column_value, 2,
                                             nchar(column_value)))
              my_expression <- eval(parse(text = combined_string))
              newstation_list <- subset(temp, my_expression)
            }
          }else{
            my_expression <- my_column == column_value
            newstation_list <- subset(temp, my_expression)
          }
          station_list <- newstation_list

        }

      }

      ### END (FILTER BASED ON METADATA STRINGS/THRESHOLD) ###

      ### FILTER BASED ON MINIMUM RECONDING YEARS ###

      if (!is.null(min_rec)) {
        temp <- station_list
        end_year <- as.numeric(as.character(unlist(temp$gdfEnd)))
        end_year[is.na(end_year)] <- 0
        start_year <- as.numeric(as.character(unlist(temp$gdfStart)))
        start_year[is.na(start_year)] <- 0
        recording_years <- end_year - start_year
        good_recording_years <- which(recording_years >= min_rec)
        station_list <- temp[good_recording_years, ]
      }

      ### END (FILTER BASED ON MINIMUM RECONDING YEARS) ###

      if (nrow(station_list) > 0) {

        # Add lat and lon
        grid_r <- osg_parse(grid_refs = unlist(station_list$gridReference),
                           coord_system = "WGS84")
        station_list$lat <- grid_r$lat
        station_list$lon <- grid_r$lon

        # change columns' data types (remove factors)
        station_list[] <- lapply(station_list, as.character)

        if (!all) {
          station_list <- station_list[, c("id", "name", "location", "river",
                                         "lat", "lon")]
        }

        return(tibble::as_tibble(station_list))

      }else{

        message("No station found using the selected criteria!")

      }

    }

  }else{

    message("The connection with the live web data source failed.")

    stop

  }

}
