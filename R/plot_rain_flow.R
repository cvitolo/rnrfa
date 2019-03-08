#' Plot rainfall and flow for a given station
#'
#' @description This function retrieves rainfall and flow time series for a
#' given catchment, divides the flow by the catchment area and converts it to
#' mm/day to that it can be comparable with the rainfall (mm/month). Finally it
#' generates a plots combining rainfall and flow information.
#'
#' @param id Station identification number
#' @param rain Rainfall time series, measured in mm/month
#' @param flow Flow time series, measured in m3/s
#' @param area Catchment area in Km2
#' @param title (optional) Plot title
#'
#' @return Plot rainfall and flow for a given station
#'
#' @export
#'
#' @examples
#' \dontrun{
#'   plot_rain_flow(id = 54090)
#' }

plot_rain_flow <- function(id = NULL,
                           rain = NULL, flow = NULL, area = NULL, title = ""){

  if (!is.null(id)){

    # Retrieve area (in Km2) from the catalogue
    meta <- catalogue(column_name = "id", column_value = id)
    title <- meta$name
    area <- as.numeric(as.character(meta$catchmentArea))

    # Retrieve rainfall data for station 54022
    rain <- get_ts(id, type = "cmr")

    # Retrieve flow data for station 54022
    flow <- get_ts(id, type = "gdf")

  }

  converted_flow <- convert_flow(flow, area)

  proportion <- ceiling((max(converted_flow, na.rm = T) -
                           min(converted_flow, na.rm = T)) / 3)

  graphics::par(mar = c(4, 4, 4, 4))

  xts::plot.xts(converted_flow,
                ylim = c(-proportion / 2, max(converted_flow) + proportion),
                main = title, xlab = "", ylab = "Flow [mm/d]",
                auto.grid = FALSE, minor.ticks = FALSE, major.ticks = "years",
                major.format = "%Y")

  # Add precipitation to the top
  graphics::par(bty = "n", new = T)
  graphics::plot(rain, type = "h", main = "",
                 ylim = rev(range(rain) * 5), # downward bars
                 yaxt = "n", xaxt = "n", ann = F, # do not plot x and y axis
                 auto.grid = FALSE, minor.ticks = FALSE,
                 col = "deepskyblue3") # suggested cosmetics

  # add right axis (4) to describe P
  graphics::axis(4, pretty(range(rain))[c(2, 4, 6, 8)],
                 col.axis = "deepskyblue3", col = "deepskyblue3", las = 1,
                 cex.axis = 0.8)
  graphics::mtext("Rain [mm/month]", side = 4, line = 3,
                  cex = graphics::par("cex.lab"),
                  col = "deepskyblue3", adj = 1)
  # reset border and overlay
  graphics::par(bty = "o", new = F)

  graphics::legend("bottom",
                   c("GDF", "CMR"),
                   horiz = TRUE,
                   y.intersp = 1,
                   bty = "n",
                   lwd = c(3, 2),
                   col = c("black", "deepskyblue3"),
                   cex = 1)

}
