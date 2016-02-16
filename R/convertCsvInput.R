#' Creates a wearableCamImages object from information read in a csv file.
#'
#' @importFrom lubridate ymd_hms mdy_hms
#' @param pathResults the path to the file with coding results
#' @param sepResults the separator in the file with coding results
#' @param pathDicoCoding the path to the file with the list of annotations
#' @param sepDicoCoding the separator in the file with the list of annotations
#' @param formatDate either 'ymd' or 'dmy'.
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
                         pathDicoCoding, sepDicoCoding, formatDate = "ymd") {
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
    ########################################################
    # participantID
    ########################################################
    # well participantID will not always make sense
    participantID <- as.character(resultsCoding[1, 1])
    imagePath <- unique(as.character(resultsCoding$"image_path"))

    ########################################################
    # convert time date
    ########################################################
    formatDate <- match.arg(formatDate, c("ymd", "mdy"))
    if (formatDate == "ymd") {
        timeDate <- lubridate::ymd_hms(
          as.character(resultsCoding$"image_time"))
    }
    if (formatDate == "mdy") {
        timeDate <- lubridate::mdy_hms(
          as.character(resultsCoding$"image_time"))
    }

    ########################################################
    # Find all codes
    ########################################################
    # create empty vector
    codeResults <- rep("", length(imagePath))
    # loop over pictures
    # quite complicated
    # because sometimes >1 line per picture
    for (i in 1:length(imagePath)) {
        codeResults[i] <- tolower(
          toString(as.character(resultsCoding$annotation[
          as.character(resultsCoding$"image_path") == imagePath[i]])))
    }

    ########################################################
    # then first I create the table with binary variables
    ########################################################
    # one column for each possible code,
    # one line for each picture
    temp <- NULL
    namesTemp <- NULL
    for (code in dicoCoding$Code) {
        temp <- cbind(temp, grepl(code, codeResults))
        namesTemp <- c(namesTemp, code)
    }
    temp <- as.data.frame(temp)
    names(temp) <- namesTemp
    codesBinaryVariables <- temp

    ########################################################
    # and now I create a list
    ########################################################
    # one value for each picture
    # they are all codes for the same picture
    # but separated by commas
    # while in the original codeResults we could have
    # other separators... and other code:
    # here we only see what is in the dicoCoding.
    for (j in 1:ncol(temp)) {
        for (i in 1:nrow(temp)) {
            if (temp[i, j]) {
                temp[i, j] <- names(temp)[j]
            } else {
                temp[i, j] <- ""
            }
        }
    }
    codes <- rep("", nrow(temp))
    for (i in 1:nrow(temp)) {
        codes[i] <- toString(temp[i, ])
    }
    ########################################################
    # Done!
    ########################################################
    wearableCamImagesObject <- new("wearableCamImages",
                                   dicoCoding = dicoCoding,
                                   imagePath = imagePath,
                                   timeDate = timeDate,
                                   codes = codes,
                                   codesBinaryVariables =
                                     codesBinaryVariables,
                                   participantID = participantID)
    return(wearableCamImagesObject)
}
