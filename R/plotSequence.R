#' Plot sequences of events
#'
#' @param event_table a table of events created with the\code{toEventLevel} function (or having the same structure),
#'  including dico as attribute.
#' @param x_axis either 'time' or 'picture' index as x axis variable.
#' @return A \code{ggplot2} graph.
#' @examples
#' data('coding1')
#' library('ggplot2')
#' event_table <- watchme_aggregate(df = coding1)
#' watchme_plot_sequence(event_table)
#' watchme_plot_sequence(event_table, x_axis = "picture")


#' @export
watchme_plot_sequence <- function(event_table, x_axis = "time") {

  dico <- attr(event_table, "dico")

  if(is.null(dico)){
    stop("Provide a dico.")
  }

  dico <-dplyr::mutate_(dico,
                         Meaning = lazyeval::interp(~as.factor(Meaning)))

 p <- ggplot(event_table)

    if (x_axis == "time") {
        p <- p + geom_rect(aes_string(xmin = "start_time", xmax = "end_time",
                               ymin = 0, ymax = 2, fill = "meaning",
                               colour = "meaning"),
            alpha = 1)
    }
    if (x_axis == "picture") {
        p <- p + geom_rect(aes_string(xmin = "start_picture", xmax = "end_picture",
                               ymin = 0, ymax = 2, fill = "meaning",
                               colour = "meaning"),
            alpha = 1)
    }
    p <- p + theme(axis.line.y = element_blank(),
                   axis.ticks.y = element_blank(),
                   axis.text.y = element_blank(),
                   panel.grid.minor.y = element_blank(),
        panel.grid.major.y = element_blank()) +
        scale_fill_viridis(discrete = TRUE) +
        scale_color_viridis(discrete = TRUE)
    return(p)
}
