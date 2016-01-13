#' Creates a table with summary statistics for event of each (sub)category.
#'
#' @importFrom dplyr tbl_df
#' @param eventTable a table of events created with the\code{toEventLevel} function (or having the same structure).
#' @return A data table with the (sub)category, the number of identified events, the average number of pictures, and the average duration in seconds.
#' @examples
#' data('dummyWearableCamImages')
#' library('ggplot2')
#' eventTable <- toEventLevel(wearableCamImagesObject=dummyWearableCamImages)
#' summaryEventTable(eventTable)

#' @export
summaryEventTable <- function(eventTable) {
    eventMeaning <- NULL
    noOfEvents <- NULL
    meanNoOfPictures <- NULL
    meanDuration <- NULL
    for (code in levels(eventTable$eventCode)) {
        subtable <- dplyr::filter(eventTable, eventCode == code)  # nolint
        eventMeaning <- c(eventMeaning, as.character(subtable$activity[1]))
        noOfEvents <- c(noOfEvents, nrow(subtable))
        meanNoOfPictures <- c(meanNoOfPictures, mean(subtable$noOfPictures))
        meanDuration <- c(meanDuration,
                          mean(subtable$endTime - subtable$startTime))
    }
    summaryTable <- data.frame(eventMeaning, noOfEvents,
                               round(meanNoOfPictures, digits = 2),
                               round(meanDuration, digits = 2))
    names(summaryTable) <- c("activity", "noOfEvents",
                             "meanNoOfPictures", "meanDuration")
    summaryTable <- dplyr::tbl_df(summaryTable)
    return(summaryTable)
}
