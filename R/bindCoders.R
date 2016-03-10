#' Creates a table with events from the image level annotation information,
#'  with an additional columns with the names of the coders.
#'
#' @importFrom dplyr tbl_df mutate_ everything
#' @importFrom lazyeval interp
#' @param wearableCamImagesList a list of \code{wearableCamImages} objects.
#' @param namesList (optional) a list of names for the coders. It must be the same length as wearableCamImagesList
#' and contains different names.
#' @param minDuration the minimal number of images for defining an event. Default is 1.
#' @return  A \code{tbl_df} with event index, start time (POSIXt),
#' end time (POSIXt), annotation (character) and coder name.
#' @examples
#' data('dummyWearableCamImages')
#' bindCoders(list(dummyWearableCamImages, dummyWearableCamImages), minDuration = 1)

#' @export
bindCoders <- function(wearableCamImagesList,
                       namesList = NULL, minDuration = 1) {
  # some sanity checks, see utils.R
  checkList(wearableCamImagesList = wearableCamImagesList,
            namesList = namesList)
  # give a default namesList is there is none
  if (is.null(namesList)){
    namesList <- as.character(1:length(wearableCamImagesList))
  }
    # get table of events
    temp <- lapply(wearableCamImagesList,
                   toEventLevel,
                   minDuration = minDuration)
    names(temp) <- namesList
    mergedTable <- do.call("rbind", temp)
    # coders names
    repCoders <- function(name, no){
      rep(name, nrow(temp[[name]]))
    }
    coders <- do.call("c", lapply(namesList,
                                 repCoders))
    # add the names to the table
    mergedTable <- mergedTable %>%
      mutate_(coder = interp(~ as.factor(coders)))
    return(mergedTable)
}
