#' Plot trend
#'
#' @description This function plots a previously calculated trend.
#'
#' @param df Data frame containing at least 4 column: lat (latitude), lon (longitude), Slope and an additonal user-defined column \code{columnName}.
#' @param columnName name of the column to use for grouping the results.
#'
#' @return Two plots, side-by-side, the first showing the distribution of the Trend over a map, based on the slope of the linear model that describes the trend. The second plot shows a boxplot of the Slope grouped based on the column Region. Region and Slope can be user-defined.
#'
#' @export
#'
#' @examples
#' \dontrun{
#'   plot_trend(df, Region)
#' }

plot_trend <- function(df, columnName){

  # A colorblind-friendly palette
  cbPalette <- c("#999999", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")

  df$Trend <- NA
  df$Trend[df$Slope >= 0]  <- "Positive"
  df$Trend[df$Slope < 0]  <- "Negative"

  # To avoid Note in R check
  lon <- lat <- Trend <- Slope <- NULL

  # Plot red dot for decreasing trend, blue dot for increasing trend
  tolerance <- (max(df$lon, na.rm = TRUE) - min(df$lon, na.rm = TRUE))/10
  m <- ggmap::get_map(location = c(min(df$lon, na.rm = TRUE)-2*tolerance,
                            min(df$lat, na.rm = TRUE)-2*tolerance,
                            max(df$lon, na.rm = TRUE)+tolerance,
                            max(df$lat, na.rm = TRUE))+tolerance,
               maptype = 'toner-lite')
  plot1 <- ggmap::ggmap(m, alpha=0.5) +
    ggplot2::geom_point(data = df,
                        ggplot2::aes(x = lon, y = lat, colour = Trend),
                        alpha = 0.6,  size = 1) +
    ggplot2::scale_color_manual(values=c("Negative"="red","Positive"="dodgerblue2")) +
    ggplot2::theme(legend.position="top")

  # Boxplot by NUTS1 region
  plot2 <- ggplot2::ggplot(df,
                           ggplot2::aes(x = eval(parse(text=columnName)),
                                        y = Slope,
                                        group = eval(parse(text=columnName)))) +
    ggplot2::geom_boxplot() +
    ggplot2::theme_minimal() + ggplot2::ylab("Slope") + ggplot2::xlab("") +
    ggplot2::coord_flip() +
    ggplot2::theme(plot.margin=ggplot2::unit(c(1,1,1,1.2),"cm"),
                   axis.title.x=
                     ggplot2::element_text(margin=ggplot2::margin(10,0,0,0)))

  cowplot::plot_grid(plot1, plot2, align='h', labels=c('A', 'B'))

}
