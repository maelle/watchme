#' Creates a table with events from the image level annotation information,
#'  with an additional columns with the names of the coders.
#'
#' @param wearableCamImagesList a list of \code{wearableCamImages} objects.
#' @param namesList (optional) a list of names for the coders. It must be the same length as wearableCamImagesList
#' and contains different names.
#'  @param minDuration the minimal number of images for defining an event. Default is 1.
#' @return  A \code{tbl_df} with event index, start time (POSIXt),
#' end time (POSIXt), annotation (character) and coder name.
#' @examples
#' data("dummyWearableCamImages")
#' bindCoders(list(dummyWearableCamImages, dummyWearableCamImages), minDuration = 1)

#' @export
bindCoders <- function(wearableCamImagesList, namesList=NULL, minDuration=1){
  if(length(wearableCamImagesList)==1){stop("Don't bother using this function if you only have one wearableCamImages object.")}

  if (!is.null(namesList)){
    if(length(namesList)!=length(wearableCamImagesList)){stop("Not as many names as wearableCamImages objects")}
    if(length(levels(factor(namesList)))!=length(namesList)){stop("Please provide unique names for the coders")}
  }

  if(is.null(namesList)){
    namesList <- as.character(1:length(wearableCamImagesList))
  }

  mergedTable <- NULL

  for (i in 1:length(wearableCamImagesList)){

    temp <- toEventLevel(wearableCamImagesList[[i]], minDuration = minDuration)

    mergedTable <- rbind(mergedTable,
                         cbind(temp,
                               coder=rep(namesList[i], nrow(temp))))
  }

  mergedTable <- dplyr::tbl_df(mergedTable)
  return(mergedTable)
}
