#' Plot
#'
#' @param df
#'
#' @return
#' @export
#'
#' @examples
#' pathResults <- system.file('extdata', 'image_level_pinocchio.csv', package = 'watchme')
#' sepResults <- ','
#' pathDicoCoding <-  system.file('extdata', 'dicoCoding_pinocchio.csv', package = 'watchme')
#' sepDicoCoding <- ';'
#' data_pictures <- watchme_prepare_data(pathResults=pathResults, sepResults=sepResults,
#'               pathDicoCoding=pathDicoCoding, sepDicoCoding=sepDicoCoding)
#' watchme_plot_raw(data_pictures)
watchme_plot_raw <- function(df){
  dico <- attr(df, "dicoCoding")
  # nolint start
  dataPlot <- df %>%
    gather("code", "value", 4:ncol(df)) %>%
    filter_(~ value == TRUE) %>%
    mutate_(code = interp(~factor(code, levels = dico$Code,
                                  ordered = TRUE))) %>%
    arrange_(~ code)

dataPlot <- suppressWarnings(left_join(dataPlot,
                                       dico, by = c("code" = "Code")))

  p <- ggplot(dataPlot) +
    geom_point(aes(image_time, Meaning, col = Group)) +
    scale_color_viridis(discrete = TRUE) +
    facet_grid(Group ~ ., scales = "free_y")

  return(p)
}
