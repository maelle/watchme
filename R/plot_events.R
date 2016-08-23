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
  dataPlot <- df %>%
    tidyr::gather_("code", "value", dico$Code) %>%
    dplyr::filter_(~ value == TRUE) %>%
    dplyr::mutate_(code = interp(~factor(code, levels = dico$Code,
                                  ordered = TRUE))) %>%
    dplyr::arrange_(~ code)

dataPlot <- suppressWarnings(left_join(dataPlot,
                                       dico, by = c("code" = "Code")))

  p <- ggplot(dataPlot) +
    geom_point(aes_string("image_time", "Meaning", col = "Group")) +
    scale_color_viridis(discrete = TRUE) +
    facet_grid(Group ~ ., scales = "free_y")

  return(p)
}
