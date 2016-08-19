#' Plot
#'
#' @param df
#'
#' @return
#' @export
#'
#' @examples
plot_events <- function(df){
  # nolint start
  dataPlot <- df %>%
    gather("code", "value", 2:ncol(dataPlot)) %>%
    filter_(~ value == TRUE) %>%
    mutate_(code = interp(~factor(code, levels = dico$Code,
                                  ordered = TRUE))) %>%
    arrange_(~ code) %>%
    left_join(dico, by = c("code" = "Code"))

  p <- vegalite(renderer = "canvas",
                export = TRUE,
                background = "white") %>%
    cell_size(1000, 800) %>%
    add_data(dataPlot) %>%
    encode_y("code", "nominal",
             sort = "none") %>%
    encode_color("Group", "nominal") %>%
    encode_x("timeDate", "temporal") %>%
    timeunit_x("yearmonthdayhoursminutesseconds")%>%
    axis_x(title = "Time of day",
           format="%a, %H:%M",
           labelAngle=0)  %>%
    axis_y(axisWidth=0,
           title = "Activity", grid = TRUE)  %>%
    mark_tick(size = 1,
              thickness = 10, opacity = 1)

  return(p)
}
