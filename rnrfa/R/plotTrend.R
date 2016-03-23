#' Plot trend
#'
#' @description This function plots a previously calculated trend.
#'
#' @param df Data frame containing at least 3 column: lat (latitude), lon (longitude), Slope and Region.
#'
#' @return Two plots, side-by-side, the first showing the distribution of the Trend over a map, based on the slope of the linear model that describes the trend. The second plot shows a boxplot of the Slope grouped based on the column Region. Region and Slope can be user-defined.
#'
#' @examples
#' # plotTrend(df)

plotTrend <- function(df){

  df$Trend <- NA
  df$Trend[df$Slope > 0]  <- "Positive"
  df$Trend[df$Slope == 0] <- "Stable"
  df$Trend[df$Slope < 0]  <- "Negative"

  # To avoid Note in R check
  lon <- lat <- Trend <- Slope <- Region <- NULL

  # Plot red dot for decreasing trend, blue dot for increasing trend
  # library(ggmap)
  tolerance <- (max(df$lon) - min(df$lon))/10
  m <- get_map(location = c(min(df$lon)-2*tolerance, min(df$lat)-2*tolerance,
                            max(df$lon)+tolerance, max(df$lat))+tolerance,
               maptype = 'toner-lite')
  plot1 <- ggmap(m, alpha=0.5) +
    geom_point(data = df, aes(x = lon, y = lat, colour = Trend),
               alpha = 0.6,  size = 2) +
    scale_color_manual(values = c("red", "dodgerblue2", "darkgreen")) +
    theme(legend.position="top") # + ggtitle("SPRING")

  # Boxplot by NUTS1 region
  plot2 <- ggplot(df, aes(x = Region, y = Slope, group = Region)) +
    geom_boxplot() +
    theme_minimal() + ylab("Slope ") +
    coord_flip() + theme(plot.margin=unit(c(1,1,1,1.2),"cm"),
                         axis.title.x=element_text(margin=margin(10,0,0,0)))

  # require(cowplot)
  plot_grid(plot1, plot2, align='h', labels=c('A', 'B'))

}
