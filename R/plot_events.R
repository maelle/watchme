#' Plot
#' @import ggplot2
#' @import viridis
#'
#' @param df A \code{tibble} created by \code{watchme_prepare_data}.
#'
#' @return a \code{ggplot}.
#' @export
#'
#' @examples
#' data("coding_example")
#' watchme_plot_raw(coding_example)
watchme_plot_raw <- function(df){
  dico <- attr(df, "dico")
  # nolint start
  dataPlot <- suppressWarnings(tidyr::gather_(df, "code",
                                              "value", dico$Code))
  dataPlot <- dataPlot %>%
    dplyr::filter_(~ value == TRUE) %>%
    dplyr::mutate_(code = interp(~factor(code, levels = dico$Code,
                                  ordered = TRUE))) %>%
    dplyr::arrange_(~ code)

dataPlot <- suppressWarnings(left_join(dataPlot,
                                       dico, by = c("code" = "Code")))
dataPlot <- mutate_(dataPlot, falsetime = lazyeval::interp(~ update(image_time,
                                                                    year = lubridate::year(image_time) + 100)))
  values_col <-  viridis_pal()(length(unique(dico$Group)))
  names(values_col) <- unique(dico$Group)
  p <- ggplot(dataPlot) +
    geom_point(aes_string("image_time", "Meaning", col = "Group"),
               shape = 108, size = 2) +
    scale_color_manual(values = values_col) +
    scale_x_datetime(date_breaks = "1 hour",
                     labels = scales::date_format(format = "%Y-%b-%d %H:%M:%S",
                                                  tz = lubridate::tz(dataPlot$image_time)),
                     limits = c(min(dataPlot$image_time), max(dataPlot$image_time))) +
    xlab("Time") +
    ylab("") +
    theme(axis.text.x = element_text(angle = 45, hjust = 1))+
    facet_grid(Group ~ ., scales = "free_y") +
    geom_point(aes_string("falsetime", "Meaning", col = "Group"),
               size = 2) +
    theme(legend.position = "top")

  return(p)
}
