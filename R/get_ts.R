#' This function retrieves time series data.
#'
#' @author Claudia Vitolo
#'
#' @description Given the station identification number(s), this function
#' retrieves data (time series in zoo format with accompanying metadata) from
#' the WaterML2 service on the NRFA database. The time series can be of two
#' types: \code{cmr} (catchment mean rainfall, monthly) or \code{gdf}
#' (gauged daily flows, daily).
#'
#' @param id station identification number(s), each number should be in the
#' range [3002,236051].
#' @param type This is character string that can have one of the two following
#' values: "cmr" (to obtain catchment mean rainfall) or "gdf" (to obtain gauged
#' daily flow).
#' @param metadata Logical, FALSE by default. If metadata = TRUE means that the
#' result for a single station is a list with two elements: data (the time
#' series) and meta (metadata).
#' @param cl (optional) This is a cluster object, created by the parallel
#' package. This is set to NULL by default, which sends sequential calls to the
#' server.
#' @param verbose (FALSE by default). If set to TRUE prints GET request on the
#' console.
#'
#' @return list composed of as many objects as in the list of station
#' identification numbers. Each object can be accessed using their names or
#' index (e.g. x[[1]], x[[2]], and so forth). Each object contains a zoo time
#' series.
#'
#' @examples
#' \dontrun{
#'   get_ts(18019, type = "cmr")
#'
#'   get_ts(c(54022,54090,54091), type = "cmr")
#'
#'   get_ts(18019, type = "gdf")
#'
#'   get_ts(c(54022,54090,54091), type = "gdf")
#' }
#'

get_ts <- function(id, type, metadata = FALSE, cl = NULL, verbose = FALSE){

  options(warn = -1)                                     # do not print warnings

  id <- as.character(id)         # in case it is a factor, convert to characters

  if (length(as.list(id)) == 0) {

    message("Please, enter valid id.")
    stop

  }else{

    if (length(as.list(id)) == 1) {

      # In the case of a single identification number
      if (metadata == TRUE) {
        ts_list <- get_ts_internal(id, type, metadata, verbose)
      }else{
        ts_list <- unlist(get_ts_internal(id, type, metadata, verbose))
      }

    }else{

      if (!is.null(cl)) {

        # Check the cluster is set correctly
        if ("SOCKcluster" %in% class(cl) | "cluster" %in% class(cl)){

          # multiple identification numbers - simultaneous data retrieval
          ts_list <- parallel::parLapply(cl = cl,
                                        X = as.list(id),
                                        fun = get_ts_internal,
                                        type, metadata, verbose)
          names(ts_list) <- id

        }else{
          stop("cl is not a cluster object!")
        }

      }else{

        # multiple identification numbers - sequential data retrieval
        ts_list <- lapply(X = as.list(id), FUN = get_ts_internal,
                         type, metadata, verbose)
        names(ts_list) <- id

      }

    }

  }

  return(ts_list)

}


get_ts_internal <- function(idx, type, metadata, verbose){

  site_fetch <- httr::GET(url = "http://nrfaapps.ceh.ac.uk/",
                          path = "nrfa/xml/waterml2",
                          query = list(db = "nrfa_public",
                                       stn = idx,
                                       dt = type))

  if (!httr::http_error(site_fetch) &
       all(class(try(expr = xml2::read_xml(site_fetch), silent = TRUE)) !=
       "try-error")){

    if (verbose) print(site_fetch[[1]])

    data_xml <- xml2::read_xml(site_fetch)

    # GET METADATA

    if (metadata == TRUE) {

      station_name <- trimws(xml2::xml_text(
        xml2::xml_find_all(data_xml, "//gml:identifier"))[3])

      measurement_type <- xml2::xml_text(xml2::xml_find_all(data_xml,
                                                            "//gml:remarks"))
      variable     <- trimws(unlist(strsplit(measurement_type, ","))[[1]])
      units        <- trimws(unlist(strsplit(measurement_type, ","))[[2]])
      type_function <- trimws(unlist(strsplit(measurement_type, ","))[[3]])
      time_step     <- trimws(unlist(strsplit(measurement_type, ","))[[4]])

      coords <- xml2::xml_text(xml2::xml_find_all(data_xml, "//gml:pos"))
      latitude <- as.numeric(unlist(strsplit(coords, " "))[1])
      longitude <- as.numeric(unlist(strsplit(coords, " "))[2])

      time_zone <- xml2::xml_text(xml2::xml_find_all(data_xml,
                                                    "//wml2:zoneAbbreviation"))

      meta <- data.frame(cbind(station_name, latitude, longitude, variable,
                               units, type_function, time_step, time_zone))

    }

    # GET DATA

    # MeasurementTVP
    # time
    datatime <- xml2::xml_text(xml2::xml_find_all(data_xml, "//wml2:time"))
    datatime <- as.POSIXlt(gsub("[\r\n]", "", datatime))
    # value
    datavalue <- as.numeric(xml2::xml_text(xml2::xml_find_all(data_xml,
                                                              "//wml2:value")))

    my_ts <- xts::xts(x = datavalue, order.by = datatime)

    if (any(is.na(datatime))){

      todelete <- which(is.na(datatime))
      my_ts <- my_ts[-todelete]

    }

    data <- my_ts

  }else{

    message(paste("For station", idx,
                  "there is no available online dataset in waterml format."))

    data <- NULL
    if (metadata) meta <- NULL

  }

  if (metadata) {
    return(list("data" = data, "meta" = meta))
  }else{
    return(data)
  }

}
