#' Creates a table with events from the image level annotation information.
#'
#' @importFrom  dplyr tbl_df filter
#' @importFrom lubridate ymd_hms
#' @param wearableCamImagesObject the werableCamImagesObject contining the image level annotation information
#' (and the dico coding, of course)
#' @param minDuration the minimal number of images for defining an event. Default is 1.
#' @return A \code{tbl_df} with event index, start time (POSIXt), end time (POSIXt) and eventCode (character).
#' @examples
#' data('dummyWearableCamImages')
#' eventTable <- toEventLevel(wearableCamImagesObject=dummyWearableCamImages)
#' eventTable
#' eventTable2 <- toEventLevel(wearableCamImagesObject=dummyWearableCamImages, minDuration = 2)
#' eventTable2

#' @export
toEventLevel <- function(wearableCamImagesObject, minDuration = 1) {
    # Extract dicoCoding
    dicoCoding <- wearableCamImagesObject@dicoCoding
    # Extract codes
    resultsCoding <- wearableCamImagesObject@codes
    # Extract times
    timeDate <- wearableCamImagesObject@timeDate
    # Prepare variables for the table of events
    eventIndex <- c(0)
    startTime <- NULL
    endTime <- NULL
    startPicture <- NULL
    endPicture <- NULL
    eventCode <- NULL
    noOfPictures <- 0
    eventCounter <- 0
    # Fill table
    for (possibleCode in dicoCoding[, 1]) {
        for (line in 1:length(resultsCoding)) {
            if (grepl(possibleCode, resultsCoding[line])) {
                eventCounter <- eventCounter + 1
                eventIndex <- c(eventIndex, eventCounter)
                startTime <- c(startTime, as.character(timeDate[line]))
                startPicture <- c(startPicture, line)
                lineFirstDifferent <- min(which(!grepl(possibleCode,
                                                       resultsCoding[
                                                         line + 1:length(resultsCoding)]))) +# nolint
                  line
                resultsCoding[line:(lineFirstDifferent - 1)] <- gsub(possibleCode, "",# nolint
                                                                     resultsCoding[# nolint
                                                                       line:(lineFirstDifferent -  1)])# nolint
                endTime <- c(endTime,
                             as.character(timeDate[lineFirstDifferent - 1]))
                endPicture <- c(endPicture, lineFirstDifferent - 1)
                eventCode <- c(eventCode, possibleCode)
                noOfPictures <- c(noOfPictures, lineFirstDifferent - line)
            }
        }
    }
    activity <- rep("NA", length(eventCode))
    group <- rep("NA", length(eventCode))
    for (i in 1:length(activity)) {
        activity[i] <- as.character(
          dicoCoding$Meaning[dicoCoding$Code == eventCode[i]])
        group[i] <- as.character(
          dicoCoding$Group[dicoCoding$Code == eventCode[i]])
    }
    tableEvents <- data.frame(eventIndex = eventIndex[2:length(eventIndex)],
                              startTime = lubridate::ymd_hms(startTime),
        endTime = lubridate::ymd_hms(endTime), eventCode = eventCode,
        noOfPictures = noOfPictures[2:length(eventIndex)],
        activity = activity, group = group, startPicture = startPicture,
        endPicture = endPicture)
    tableEvents <- dplyr::tbl_df(tableEvents)
    tableEvents <- dplyr::filter(tableEvents, noOfPictures >= minDuration)
    return(tableEvents)
}
