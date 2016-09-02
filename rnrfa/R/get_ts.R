#' This function retrieves time series data.
#'
#' @author Claudia Vitolo
#'
#' @description Given the station identification number(s), this function retrieves data (time series in zoo format with accompanying metadata) from the WaterML2 service on the NRFA database. The time series can be of two types: \code{cmr} (catchment mean rainfall, monthly) or \code{gdf} (gauged daily flows, daily).
#'
#' @param id station identification number(s), each number should be in the range [3002,236051].
#' @param type This is character string that can have one of the two following values: "cmr" (to obtain catchment mean rainfall) or "gdf" (to obtain gauged daily flow).
#' @param metadata Logical, FALSE by default. If metadata = TRUE means that the result for a single station is a list with two elements: data (the time series) and meta (metadata).
#' @param cl (optional) This is a cluster object, created by the parallel package. This is set to NULL by default, which sends sequential calls to the server.
#' @param verbose (FALSE by default). If set to TRUE prints GET request on the console.
#'
#' @return list composed of as many objects as in the list of station identification numbers. Each object can be accessed using their names or index (e.g. x[[1]], x[[2]], and so forth). Each object contains a zoo time series.
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

get_ts <- function(id, type, metadata, cl, verbose){

  options(warn=-1)                                       # do not print warnings

  id <- as.character(id)         # in case it is a factor, convert to characters

  if (length(as.list(id)) == 0) {

    message("Please, enter valid id.")
    stop

  }else{

    if (length(as.list(id)) == 1) {

      # In the case of a single identification number
      if (metadata == TRUE) {
        tsList <- get_ts_internal(id, type, metadata, verbose)
      }else{
        tsList <- unlist(get_ts_internal(id, type, metadata, verbose))
      }

    }else{

      if (!is.null(cl)) {

        # Check the cluster is set correctly
        if ("SOCKcluster" %in% class(cl) | "cluster" %in% class(cl)){

          # clusterExport(cl = cl, varlist = c(type, metadata))

          # multiple identification numbers - simultaneous data retrieval
          tsList <- parallel::parLapply(cl = cl,
                                        X = as.list(id),
                                        fun = get_ts_internal,
                                        type, metadata, verbose)

        }else{
          stop('cl is not a cluster object!')
        }

      }else{

        # multiple identification numbers - sequential data retrieval
        tsList <- lapply(X = as.list(id), FUN = get_ts_internal,
                         type, metadata, verbose)
        names(tsList) <- id

      }

    }

  }

  return(tsList)

}


get_ts_internal <- function(idx, type, metadata, verbose){

  # idx <- "54022"
  # type <- "cmr"

  site_fetch <- httr::GET(url = "http://nrfaapps.ceh.ac.uk/",
                          path = "nrfa/xml/waterml2",
                          query = list(db = "nrfa_public",
                                       stn = idx,
                                       dt = type))

  if ( !httr::http_error(site_fetch) ){

    if (verbose) print(site_fetch[[1]])

    dataXML <- xml2::read_xml(site_fetch)

    # GET METADATA

    if (metadata == TRUE) {

      # dataList <- xml2::as_list(dataXML)

      # DocumentMetadata
      # DocumentMetadata <- unlist(dataList[[1]]$DocumentMetadata)

      # TimePeriod
      # TimePeriod <- unlist(dataList[[2]]$TimePeriod)

      # Dictionary
      # Dictionary <- unlist(dataList[[3]]$Dictionary)

      # MonitoringPoint
      # MonitoringPoint <- unlist(dataList[[4]]$MonitoringPoint)

      stationName <- trimws(xml2::xml_text(
        xml2::xml_find_all(dataXML, "//gml:identifier"))[3])

      typeOfMeasurement <- xml2::xml_text(xml2::xml_find_all(dataXML,
                                                             "//gml:remarks"))
      variable     <- trimws(unlist(strsplit(typeOfMeasurement, ","))[[1]])
      units        <- trimws(unlist(strsplit(typeOfMeasurement, ","))[[2]])
      typeFunction <- trimws(unlist(strsplit(typeOfMeasurement, ","))[[3]])
      timeStep     <- trimws(unlist(strsplit(typeOfMeasurement, ","))[[4]])

      coords <- xml2::xml_text(xml2::xml_find_all(dataXML, "//gml:pos"))
      Latitude <- as.numeric(unlist(strsplit(coords, " "))[1])
      Longitude <- as.numeric(unlist(strsplit(coords, " "))[2])

      timeZone <- xml2::xml_text(xml2::xml_find_all(dataXML,
                                                    "//wml2:zoneAbbreviation"))

      meta <- data.frame(cbind(stationName, Latitude, Longitude, variable,
                               units, typeFunction, timeStep, timeZone))

    }

    # GET DATA

    # OM_Observation
    # OM_Observation <- dataList[[5]]$OM_Observation

    ## MeasurementTVP
    ### time
    dataTime <- xml2::xml_text(xml2::xml_find_all(dataXML, "//wml2:time"))
    dataTime <- as.POSIXlt(gsub("[\r\n]", "", dataTime))
    ### value
    dataValue <- as.numeric(xml2::xml_text(xml2::xml_find_all(dataXML,
                                                              "//wml2:value")))

    myTS <- xts::xts(x = dataValue, order.by = dataTime)

    if ( any(is.na(dataTime)) ){

      toDelete <- which(is.na(dataTime))
      myTS <- myTS[-toDelete]

    }

    data <- myTS

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
