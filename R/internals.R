nrfa_api <- function(webservice, parameters, path = "") {

  if (!curl::has_internet()) stop("no internet")

  # Set a user agent
  ua <- httr::user_agent("https://github.com/ilapros/rnrfa")

  if (!(webservice %in% c("station-ids", "station-info", "time-series"))) {
    stop(paste("Invalid web service, try one of the following:",
               "station-ids, station-info, time-series"))
  }

  # Build the API endpoint URL
  root_entry_point <- "https://nrfaapps.ceh.ac.uk/nrfa/ws/"
  url <- paste0(root_entry_point, webservice, path)

  resp <- httr::GET(url = url, query = parameters, ua)

  # Check response
  if (httr::http_error(resp)) {
    message(
      sprintf("NRFA API request failed [%s]", httr::status_code(resp))
    )
    return(NULL)
  }

  # Check output format
  if (httr::http_type(resp) != "application/json") {
    message("API did not return json", call. = FALSE)
    return(NULL)
  }

  # Parse content
  page_content <- try(httr::content(resp, "text", encoding = "UTF-8"))
  if (class(page_content) == "try-error") {
    errs <- geterrmessage()
    message(paste("An unknwon error occurred when accessing the data",
                  "- with error message:", errs))
    return(NULL)
  }
  if (webservice == "station-ids") {
    parsed <- jsonlite::fromJSON(page_content, simplifyVector = TRUE)
  }
  if (webservice == "station-info") {
    parsed <- jsonlite::fromJSON(page_content, simplifyDataFrame = TRUE)
  }
  if (webservice == "time-series") {
    parsed <- jsonlite::fromJSON(page_content, simplifyDataFrame = TRUE)
  }

  # Return helpful S3 object
  structure(
    list(
      content = parsed,
      path = path,
      response = resp
    ),
    class = "nrfa_api")
}

print.nrfa_api <- function(x, ...) {
  cat("<NRFA ", x$path, ">\n", sep = "")
  str(x$content)
  invisible(x)
}

odd <- function(x) x %% 2 != 0

even <- function(x) x %% 2 == 0

get_ts_internal <- function(id, type, metadata, verbose, full_info) {

  if (!curl::has_internet()) stop("no internet")
  if(length(id) == 0) {
    message("id needs to be specified")
    return(NULL)
  }
  parameters <- list(format = "json-object",
                     station = id,
                     `data-type` = type)
  time_series <- nrfa_api(webservice = "time-series", parameters)
  # the time_series object is made of 3 elements:
  # 1. content
  # 2. path - currently not needed here
  # 3. response (metadata) - currently not needed here

  # GET DATA
  datastream <- time_series$content$`data-stream`
  if (length(datastream) == 0) {
    message("Empty data-stream")
    return(NULL)
  } else{
    datatime <- datastream[odd(seq_along(datastream))]
    datavalue <- datastream[even(seq_along(datastream))]
    # If datatime contains only year-month, the following adds a dummy day
    if (nchar(datatime[1]) == 7) {
      datatime <- paste(datatime, "-01", sep = "")
    }
    # Create the basic time series
    df <- data.frame(as.numeric(datavalue))
    names(df) <- type
    if (type %in% c("pot-stage", "pot-flow", "amax-stage", "amax-flow") &
        full_info) {
      station_info <- rnrfa::catalogue(column_name = "id",
                                       column_value = paste0("==", id))
      if (type %in% c("pot-stage", "pot-flow")) {
        rejected_periods <- unlist(station_info$`peak-flow-rejected-periods`,
                                   use.names = FALSE)

        periods <- vector(mode = "numeric", length = 0)
        periods <- as.Date(periods, origin = "1970-01-01")
        ### only do this when there are missing periods
        if (!is.null(rejected_periods)) {
          periods <- lapply(X = strsplit(rejected_periods, "[/]"),
                            FUN = as.Date)
          periods <- lapply(X = periods,
                            FUN = function(x) {
                              seq.Date(from = x[1], to = x[2], by = "day")
                            })
          periods <- do.call("c", periods)
        }
        df$rejected <- ifelse(test = as.Date(datatime) %in% periods,
                              yes = TRUE, no = FALSE)
      }
      if (type %in% c("amax-stage", "amax-flow")) {
        years <- unlist(station_info$`peak-flow-rejected-amax-years`,
                        use.names = FALSE)
        water_year <- lubridate::year(datatime) +
          ifelse(test = lubridate::month(datatime) <= 9, yes = -1, no = 0)
        df$rejected <- ifelse(test = water_year %in% years,
                              yes = TRUE, no = FALSE)
      }
    }
    df <- zoo::zoo(x = df, order.by = as.Date(datatime))
  }

  if (metadata) {

    # GET METADATA
    meta <- time_series$content[-which(names(time_series$content) ==
                                         "data-stream")]
    meta <- as.data.frame(meta, stringsAsFactors = FALSE)
    return(list("data" = df, "meta" = meta))

  }else{

    return(df)

  }

}

seasonal_averages_internal <- function(timeseries, season) {

  # seasonal aggregation:
  # seasons are labelled by the calendar quarter in which the season ends
  seasonal_mean <- aggregate(timeseries, zoo::as.yearqtr, mean) + 1 / 12

  if (season == "Winter") {
    quarter_number <- 1
  }
  if (season == "Spring") {
    quarter_number <- 2
  }
  if (season == "Summer") {
    quarter_number <- 3
  }
  if (season == "Autumn") {
    quarter_number <- 4
  }

  # Get indices of the relevant season
  idx <- seq(quarter_number, length(seasonal_mean), 4)
  seasonal_mean <- seasonal_mean[idx]

  # fit basic straight line
  fit <- stats::glm(seasonal_mean ~ seq(1, length(seasonal_mean)))
  # F-statistics of the significance test with the summary function
  # extract slope and p-value (for significance to be true, p should be < 0.05)
  co <- summary(fit)$coefficients[2, c(1, 4)] # only slope: coef(fit)[[2]]

  return(co)

}
