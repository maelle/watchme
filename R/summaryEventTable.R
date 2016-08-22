#' Creates a table with summary statistics for event of each (sub)category.
#'
#' @importFrom dplyr tbl_df mutate_ group_by_ summarize_
#' @importFrom lazyeval interp
#' @param eventTable a table of events created with the\code{watchme_aggregate} function (or having the same structure).
#' @return A data table with the (sub)category, the number of identified events, the average number of pictures, and the average duration in seconds.
#' @examples
#' data('coding_example')
#' eventTable <- watchme_aggregate(df = coding_example)
#' watchme_summarize_events(eventTable)

#' @export
watchme_summarize_events <- function(eventTable) {
      mutate_(eventTable,
                  duration = interp(~ difftime(end_time,
                                               start_time,
                                               units = "secs"))) %>%
      group_by_(~ meaning) %>%
      summarize_(meanNoOfPictures = interp(~ mean(no_pictures)),
                  meanDuration = interp(~ mean(duration)),
                  noOfEvents = interp(~ length(duration)))
}
