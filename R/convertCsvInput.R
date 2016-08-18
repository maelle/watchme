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
#' @return A \code{wearableCamImages} object which is a \code{tibble} with
#' \itemize{
#' \item participantID Name or ID number of the participant (character)
#' \item image_time Path or name of the image in order to be able to identify duplicates (character)
#' \item image_time Time and date of each image (POSIXt)
#' \item codes annotation(s) given to this image (character), e.g. separated by ','.
#' \item booleanCodes columns of boolean, indicating if a given code was given to a given picture. codes is a condensed form of this.
#' \item the attribute \code{dicoCoding} \code{tibble} for defining the codes with at least Code and Meaning column, possibly Group column for having groups of codes (e.g. sport encompasses running and swimming)
#' }
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
                         participant_id = "no_id",
                         pathDicoCoding, sepDicoCoding, formatDate = "ymd",
                         tz = "Asia/Kolkata") {
    ########################################################
    # Get dico coding
    ########################################################
    dicoCoding <- read.csv(pathDicoCoding, sep = sepDicoCoding, header = TRUE)
    dicoCoding <- dplyr::mutate_each_(dicoCoding, dplyr::funs_("tolower"), c("Code", "Meaning", "Group"))

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

    resultsCoding <- dplyr::mutate_(resultsCoding,
                             participant_id = ~participant_id)


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
    resultsCoding <-mutate_(resultsCoding,
                            image_time = lazyeval::interp(~functionDate(
                              as.character(image_time), tz = tz)))

    ########################################################
    # Find all codes
    ########################################################
    # create empty vector
    resultsCoding <- mutate_(resultsCoding,
                             annotation = lazyeval::interp(~tolower(annotation)))



    ########################################################
    # then first I create the table with binary variables
    ########################################################
    # one column for each possible code,
    # one line for each picture
    codes <- dicoCoding$Code
    resultsCoding <- dplyr::group_by(resultsCoding, image_path) %>%
      dplyr::mutate_(booleanCodes = lazyeval::interp(~list(vapply(codes, grepl, annotation,
                                                              FUN.VALUE = FALSE))))
    print(resultsCoding$booleanCodes[1])

    names(booleanCodes) <- dicoCoding$Code
    resultsCoding <- dplyr::select_(resultsCoding, quote(- annotation))
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
    codes <- booleanCodes %>%
      select_(~ image_time, ~ everything()) %>%
      gather(eventCode, boolean,
             2:(nCodes + 1)) %>%
      group_by_(~ image_time) %>%
      mutate_(eventCode = interp(~
              ifelse(boolean, eventCode, "")) ) %>%
    summarize_(codes = interp(~ toString(eventCode)))


    ########################################################
    # Done!
    ########################################################
    wearableCamImagesObject <- tibble::tibble_(list(participant_id,
                                                    image_time,
                                                    codes))
    return(wearableCamImagesObject)
    wearableCamImagesObject <- dplyr::bind_rows(wearableCamImagesObject,
                                                booleanCodes)
    #attributes(wearableCamImagesObject, "dicoCoding") <- dicoCoding
    return(wearableCamImagesObject)
}


