#' Creates a table with events from the image level annotation information.
#'
#' @importFrom  dplyr tbl_df filter_ mutate_ select_ arrange_ left_join "%>%"
#' @importFrom lazyeval interp
#' @importFrom lubridate ymd_hms
#' @importFrom tidyr gather
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
    dicoCoding <- wearableCamImagesObject$dicoCoding
    # Extract codes
    resultsCoding <- wearableCamImagesObject$booleanCodes
    # Extract times
    timeDate <- wearableCamImagesObject$timeDate # nolint

    nCodes <- ncol(resultsCoding)
    tableEvents <- resultsCoding %>%
      mutate_(timeDate = interp(~ timeDate)) %>%
      mutate_(index = interp(~1:nrow(resultsCoding))) %>%
      select_(~ timeDate,  ~ index, ~ everything()) %>%
      gather(eventCode, boolean,
             3:(nCodes + 2)) %>%
      filter_(~ boolean) %>%
      mutate_(group = interp(~ c(0, cumsum(diff(index) != 1)) )) %>%
      group_by_(~ eventCode,
                ~ group) %>%
      summarize_(startTime = interp(~ min(timeDate)),
                 endTime = interp(~ max(timeDate)),
                 noOfPictures = interp(~ length(timeDate)),
                 startPicture = interp(~ min(index)),
                 endPicture = interp(~ max(index))) %>%
      dplyr::left_join(dicoCoding,
                       by = c("eventCode" = "Code")) %>%
      select_(~ (- group)) %>%
      mutate_(group = interp(~ Group)) %>%
      select_(~ (- Group)) %>%
      mutate_(activity = interp(~ as.factor(Meaning))) %>%
      select_(~ (- Meaning)) %>%
      arrange_(~ eventCode) %>%
      filter_(interp(~ noOfPictures >= minDuration)) %>%
      ungroup()

    return(tableEvents)
}
