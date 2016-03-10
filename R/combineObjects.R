#' Combine objects with same pictures but different codes
#'
#' @importFrom dplyr tbl_df mutate_ group_by_ summarize_ ungroup
#' @importFrom tidyr gather
#' @importFrom lazyeval interp
#' @param wearableCamImagesList a list of \code{wearableCamImages} objects.
#' @param codeException One or several codes that are common between the objects.
#'
#' @return A \code{wearableCamImages} object.
#' @details The motivation was to create a single object based on several coding files
#' in the CHAI project: each pass/group of codes such as cooking and travel resulted in one file,
#' and we want to combine them.
#' For codeException codes, the annotation are merged: if an image has such a code in an object
#' and not in the other, the code is assigned to the image in the resulting object.
#' The code does not look for conflicts.
#' @export
#'
#' @examples
#' data(listWM)
#' object <- combineObjects(listWM, codeException = c("non codable"))
combineObjects <- function(wearableCamImagesList,
                           codeException = c("non codable")){
  ########################################################
  # check they have the same imageTime
  ########################################################
  getLengthCodes <- function(x){
    return(length(x$codes))
  }
  lengthRef <- getLengthCodes(wearableCamImagesList[[1]])
  lengthsCodes <- lapply(wearableCamImagesList, getLengthCodes)
  if (any(lengthsCodes != lengthRef)){
    stop("There should be the same number of pictures in each wearableCamImages object!")# nolint
  }

  times <- do.call("cbind", lapply(wearableCamImagesList,
                                   "[[", "timeDate"))
  if(any(lapply(apply(times,1, unique), length) > 1)){
    stop("All objects should have the same imageTime field, at least one difference here!")# nolint
  }

  ########################################################
  # assign a imagePath and timeDate
  ########################################################
  imagePath <- wearableCamImagesList[[1]]$imagePath
  timeDate <- wearableCamImagesList[[1]]$timeDate
  ########################################################
  # create a dicoCoding
  ########################################################
  dicoCoding <- unique(do.call("rbind",
                        lapply(wearableCamImagesList,
                               "[[", "dicoCoding")))

  ########################################################
  # boolean codes
  ########################################################
  booleanCodes <- tbl_df(do.call("cbind",
                          lapply(wearableCamImagesList,
                                 "[[", "booleanCodes")))
  for (code in codeException){
    booleanCodes[,code] <-
      (apply(booleanCodes[,grepl(code, names(booleanCodes))],
            1, sum) > 0)
  }
  booleanCodes <- booleanCodes[,dicoCoding$Code]
  ########################################################
  # and now I create a list
  ########################################################
  # one value for each picture
  # they are all codes for the same picture
  # but separated by commas
  # while in the original codeResults we could have
  # other separators... and other code:
  # here we only see what is in the dicoCoding.
  nCodes <- ncol(booleanCodes)
  codes <- booleanCodes  %>%
    mutate_(timeDate = interp(~ timeDate)) %>%
    select_(~ timeDate, ~ everything()) %>%
    gather(eventCode, boolean,
           2:(nCodes + 1)) %>%
    group_by_(~ timeDate) %>%
    mutate_(eventCode = interp(~
                                 ifelse(boolean, eventCode, "")) ) %>%
    summarize_(codes = interp(~ toString(eventCode)))
  codes <- codes$codes
  ########################################################
  # Done!
  ########################################################
  participantID <- wearableCamImagesList[[1]]$participantID
  wearableCamImagesObject <- wearableCamImages$new(dicoCoding = dicoCoding,# nolint
                                                   imagePath = imagePath,# nolint
                                                   timeDate = timeDate,# nolint
                                                   codes = codes,# nolint
                                                   booleanCodes = booleanCodes,# nolint
                                                   participantID = participantID)# nolint
  return(wearableCamImagesObject)
}
