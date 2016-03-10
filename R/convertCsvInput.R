#' Creates a wearableCamImages object from information read in a csv file.
#'
#' @importFrom lubridate ymd_hms mdy_hms
#' @importFrom dplyr tbl_df mutate_ group_by_ summarize_ ungroup
#' @importFrom tidyr gather
#' @importFrom lazyeval interp
#' @param pathResults the path to the file with coding results
#' @param sepResults the separator in the file with coding results
#' @param pathDicoCoding the path to the file with the list of annotations
#' @param sepDicoCoding the separator in the file with the list of annotations
#' @param formatDate either 'ymd' or 'dmy'.
#' @param tz timezone
#' @param quoteSign the quote argument of read.table for the results, default is "\'"
#' @return A \code{wearableCamImages} object.
#' @details
#' Please check the format that both files should have by looking at the provided
#' example data.
#' However you could consider write your own function for converting the input
#' instead of having to re-format all your existing data,
#' which we could even add to the package.
#' @examples
#' pathResults <- system.file('extdata', 'image_level_pinocchio.csv', package = 'watchme')
#' sepResults <- ','
#' pathDicoCoding <-  system.file('extdata', 'dicoCoding_pinocchio.csv', package = 'watchme')
#' sepDicoCoding <- ';'
#' wearableCamImagesObject <- convertInput(pathResults=pathResults, sepResults=sepResults,
#'               pathDicoCoding=pathDicoCoding, sepDicoCoding=sepDicoCoding)
#' class(wearableCamImagesObject)

#' @export
convertInput <- function(pathResults, sepResults, quoteSign = "\'",
                         pathDicoCoding, sepDicoCoding, formatDate = "ymd",
                         tz = "Asia/Kolkata") {
    ########################################################
    # Get dico coding
    ########################################################
    dicoCoding <- read.csv(pathDicoCoding, sep = sepDicoCoding, header = TRUE)
    dicoCoding$Code <- tolower(dicoCoding$Code)
    dicoCoding$Meaning <- tolower(dicoCoding$Meaning)
    dicoCoding$Group <- tolower(dicoCoding$Group)

    ########################################################
    # open results
    ########################################################
    resultsCoding <- read.table(pathResults, sep = sepResults,
                                header = TRUE, quote = quoteSign)
    # deal with different formats
    if(ncol(resultsCoding) != 4){
      resultsCoding <- resultsCoding[,1:3]
    }

    # When it comes from XnView MP, wrong names
    if(grepl("Filename", names(resultsCoding)[1])){
      names(resultsCoding) <- c("image_path",
                                "image_time",
                                "annotation")
    }

    # if several rows for one image, merge annotation
    resultsCoding <- resultsCoding %>%
      group_by_(~ image_path,~ image_time) %>%  # nolint
      summarize_(annotation = interp(~ toString(annotation))) %>%
      ungroup()
    imagePath <- resultsCoding$"image_path"
    ########################################################
    # participantID
    ########################################################
    # well participantID will not always make sense
    participantID <- as.character(resultsCoding[1, 1])

    ########################################################
    # convert time date
    ########################################################
    functionDate <-
    formatDate <- match.arg(formatDate, c("ymd", "mdy"))
    if (formatDate == "ymd") {
      functionDate <- lubridate::ymd_hms
    }
    if (formatDate == "mdy") {
      functionDate <- lubridate::mdy_hms
    }
    timeDate <- functionDate(
      as.character(resultsCoding$"image_time"), tz = tz)
    ########################################################
    # Find all codes
    ########################################################
    # create empty vector
    codeResults <- tolower(resultsCoding$annotation)
    ########################################################
    # then first I create the table with binary variables
    ########################################################
    # one column for each possible code,
    # one line for each picture
    temp <- list()
    for (code in dicoCoding$Code) {
        temp[[code]] <- grepl(code, codeResults)
    }
    temp <- as.data.frame(do.call("cbind", temp))
    booleanCodes <- dplyr::tbl_df(temp)
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
    wearableCamImagesObject <- wearableCamImages$new(dicoCoding = tbl_df(dicoCoding),# nolint
                                                     imagePath = imagePath,# nolint
                                                     timeDate = timeDate,# nolint
                                                     codes = codes,# nolint
                                                     booleanCodes = booleanCodes,# nolint
                                                     participantID = participantID)# nolint
    return(wearableCamImagesObject)
}
