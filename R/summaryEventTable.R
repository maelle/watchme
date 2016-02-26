#' Creates a table with summary statistics for event of each (sub)category.
#'
#' @importFrom dplyr tbl_df mutate_ group_by_ summarize_
#' @importFrom lazyeval interp
#' @param eventTable a table of events created with the\code{toEventLevel} function (or having the same structure).
#' @return A data table with the (sub)category, the number of identified events, the average number of pictures, and the average duration in seconds.
#' @examples
#' data('dummyWearableCamImages')
#' library('ggplot2')
#' eventTable <- toEventLevel(wearableCamImagesObject=dummyWearableCamImages)
#' summaryEventTable(eventTable)

#' @export
summaryEventTable <- function(eventTable) {
      mutate_(eventTable,
                  duration = interp(~ difftime(endTime,
                                               startTime,
                                               units = "secs"))) %>%
      group_by_(~ activity) %>%
      summarize_(meanNoOfPictures = interp(~ mean(noOfPictures)),
                  meanDuration = interp(~ mean(duration)),
                  noOfEvents = interp(~ length(duration)))
}
