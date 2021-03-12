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
#' @param type The following data-types are available:
#' \itemize{
#'   \item gdf = Gauged daily flows
#'   \item gmf = Gauged monthly flows
#'   \item ndf = Naturalised daily flows
#'   \item nmf = Naturalised monthly flows
#'   \item cdr = Catchment daily rainfall
#'   \item cdr-d = Catchment daily rainfall distance to rain gauge
#'   \item cmr = Catchment monthly rainfall
#'   \item pot-stage = Peaks over threshold stage
#'   \item pot-flow = Peaks over threshold flow
#'   \item gauging-stage = Gauging stage
#'   \item gauging-flow = Gauging flow
#'   \item amax-stage = Annual maxima stage
#'   \item amax-flow = Annual maxima flow
#' }
#' @param metadata Logical, FALSE by default. If metadata = TRUE means that the
#' result for a single station is a list with two elements: data (the time
#' series) and meta (metadata).
#' @param cl (optional) This is a cluster object, created by the parallel
#' package. This is set to NULL by default, which sends sequential calls to the
#' server.
#' @param verbose (FALSE by default). If set to TRUE prints GET request on the
#' console.
#' @param full_info Logical, FALSE by default. If full_info = TRUE, the function
#' will retrieve info on rejected periods and return a data frame rather than a
#' time series.
#'
#' @return list composed of as many objects as in the list of station
#' identification numbers. Each object can be accessed using their names or
#' indexes (e.g. x[[1]], x[[2]], and so forth). Each object contains a time
#' series of class \code{zoo/xts}.
#'
#' @export
#'
#' @examples
#' \dontrun{
#'   get_ts(18019, type = "cmr")
#'   get_ts(c(54022,54090,54091), type = "cmr")
#'   get_ts(18019, type = "gdf")
#'   get_ts(c(54022,54090,54091), type = "gdf")
#'   plot(get_ts(id = 23001, type = "ndf"))
#'   plot(get_ts(id = 23001, type = "nmf"))
#' }
#'

get_ts <- function(id, type, metadata = FALSE, cl = NULL, verbose = FALSE,
                   full_info = FALSE) {

  options(warn = -1)                                     # do not print warnings

  id <- as.character(id)         # in case it is a factor, convert to characters

  if (length(as.list(id)) == 0) {

    message("Please, enter valid id.")
    return(NULL)

  }else{

    if (length(as.list(id)) == 1) {

      # In the case of a single identification number
      if (metadata == TRUE) {
        ts_list <- get_ts_internal(id, type, metadata, verbose, full_info)
      }else{
        if (type %in% c("pot-stage", "pot-flow", "amax-stage", "amax-flow") &
            full_info) {
          ts_list <- get_ts_internal(id, type, metadata, verbose,
                                            full_info)
        }else{
          ts_list <- unlist(get_ts_internal(id, type, metadata, verbose,
                                            full_info))
        }
      }

    }else{

      if (!is.null(cl)) {

        # Check the cluster is set correctly
        if ("SOCKcluster" %in% class(cl) | "cluster" %in% class(cl)) {

          # multiple identification numbers - simultaneous data retrieval
          ts_list <- parallel::parLapply(cl = cl,
                                        X = as.list(id),
                                        fun = get_ts_internal,
                                        type, metadata, verbose, full_info)
          names(ts_list) <- id

        }else{
          stop("cl is not a cluster object!")
        }

      }else{

        # multiple identification numbers - sequential data retrieval
        ts_list <- lapply(X = as.list(id), FUN = get_ts_internal,
                         type, metadata, verbose, full_info)
        names(ts_list) <- id

      }

    }

  }

  return(ts_list)

}
