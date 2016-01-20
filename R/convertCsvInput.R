#' Creates a wearableCamImages object from information read in a csv file.
#'
#' @importFrom lubridate ymd_hms mdy_hms
#' @param pathResults the path to the file with coding results
#' @param sepResults the separator in the file with coding results
#' @param pathDicoCoding the path to the file with the list of annotations
#' @param sepDicoCoding the separator in the file with the list of annotations
#' @param formatDate either 'ymd' or 'dmy'.
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
convertInput <- function(pathResults, sepResults,
                         pathDicoCoding, sepDicoCoding, formatDate = "ymd") {
    formatDate <- match.arg(formatDate, c("ymd", "mdy"))
    dicoCoding <- read.csv(pathDicoCoding, sep = sepDicoCoding, header = TRUE)
    dicoCoding$Code <- tolower(dicoCoding$Code)
    dicoCoding$Meaning <- tolower(dicoCoding$Meaning)
    dicoCoding$Group <- tolower(dicoCoding$Group)
    resultsCoding <- read.csv(pathResults, sep = sepResults, header = TRUE)
    participantID <- as.character(resultsCoding[1, 1])
    imagePath <- unique(as.character(resultsCoding$"image_path"))
    if (formatDate == "ymd") {
        timeDate <- lubridate::ymd_hms(
          as.character(resultsCoding$"image_time"))[
          !duplicated(as.character(resultsCoding$"image_path"))]
    }
    if (formatDate == "mdy") {
        timeDate <- lubridate::mdy_hms(
          as.character(resultsCoding$"image_time"))[
          !duplicated(as.character(resultsCoding$"image_path"))]
    }
    codeResults <- rep("", length(imagePath))
    for (i in 1:length(imagePath)) {
        codeResults[i] <- tolower(
          toString(as.character(resultsCoding$annotation[
          as.character(resultsCoding$"image_path") == imagePath[i]])))
    }
    temp <- NULL
    namesTemp <- NULL
    for (code in dicoCoding$Code) {
        temp <- cbind(temp, grepl(code, codeResults))
        namesTemp <- c(namesTemp, code)
    }
    temp <- as.data.frame(temp)
    names(temp) <- namesTemp
    codesBinaryVariables <- temp
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
    wearableCamImagesObject <- new("wearableCamImages",
                                   dicoCoding = dicoCoding,
                                   imagePath = imagePath,
                                   timeDate = timeDate,
                                   codes = codes,
                                   codesBinaryVariables = codesBinaryVariables,
                                   participantID = participantID)
    return(wearableCamImagesObject)
}
