#' Plot trend
#'
#' @description This function plots a previously calculated trend.
#'
#' @param df Data frame containing at least 4 column:
#' lat (latitude), lon (longitude), slope and an additional user-defined column
#' \code{column_name}.
#' @param column_name name of the column to use for grouping the results.
#'
#' @return Two plots, side-by-side, the first showing the distribution of the
#' trend over a map, based on the slope of the linear model that describes the
#' trend. The second plot shows a boxplot of the slope grouped based on the
#' column Region. Region and slope can be user-defined.
#'
#' @export
#'
#' @examples
#' \dontrun{
#'   plot_trend(df, Region)
#' }

plot_trend <- function(df, column_name) {

  df$trend <- NA
  df$trend[df$slope >= 0]  <- "Positive"
  df$trend[df$slope < 0]  <- "Negative"

  # To avoid Note in R check
  lon <- lat <- trend <- slope <- NULL

  # Plot red dot for decreasing trend, blue dot for increasing trend
  tolerance <- (max(df$lon, na.rm = TRUE) - min(df$lon, na.rm = TRUE)) / 10
  m <- ggmap::get_map(location = c(min(df$lon, na.rm = TRUE) - 2 * tolerance,
                            min(df$lat, na.rm = TRUE) - 2 * tolerance,
                            max(df$lon, na.rm = TRUE) + tolerance,
                            max(df$lat, na.rm = TRUE)) + tolerance,
               maptype = "toner-lite")

  # Plot map
  plot1 <- ggmap::ggmap(m, alpha = 0.5) +
    ggplot2::geom_point(data = df,
                        ggplot2::aes(x = lon, y = lat, colour = trend),
                        alpha = 0.6,  size = 1) +
    ggplot2::scale_color_manual(values = c("Negative" = "red",
                                           "Positive" = "dodgerblue2")) +
    ggplot2::theme(legend.position = "top") +
    ggplot2::ggtitle("A")

  # Boxplot by NUTS1 region
  plot2 <- ggplot2::ggplot(df,
                           ggplot2::aes(x = eval(parse(text = column_name)),
                                        y = slope,
                                        group = eval(parse(text =
                                                             column_name)))) +
    ggplot2::geom_boxplot(outlier.shape = NA) +
    ggplot2::scale_y_continuous(limits = stats::quantile(df$slope,
                                                         c(0.05, 0.95))) +
    ggplot2::theme_minimal() + ggplot2::ylab("Slope") + ggplot2::xlab("") +
    ggplot2::coord_flip() +
    ggplot2::theme(plot.margin = ggplot2::unit(c(1, 1, 1, 1.2), "cm"),
                   axis.title.x = ggplot2::element_text(margin =
                                                          ggplot2::margin(10,
                                                                          0,
                                                                          0,
                                                                          0))) +
    ggplot2::ggtitle("B")

  return(list("A" = plot1, "B" = plot2))

}
