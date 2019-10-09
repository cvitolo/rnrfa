nrfa_api <- function(webservice, parameters, path = "") {

  if (!curl::has_internet()) stop("no internet")

  # Set a user agent
  ua <- httr::user_agent("https://github.com/cvitolo/rnrfa")

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
    stop(
      sprintf("NRFA API request failed [%s]", httr::status_code(resp)),
      call. = FALSE
    )
  }

  # Check output format
  if (httr::http_type(resp) != "application/json") {
    stop("API did not return json", call. = FALSE)
  }

  # Parse content
  page_content <- httr::content(resp, "text", encoding = "UTF-8")
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
