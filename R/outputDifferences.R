#' Outputs images for which codes are different among coders
#'
#' @importFrom dplyr tbl_df
#' @importFrom tidyr spread
#' @param wearableCamImagesList a list of \code{wearableCamImages} objects.
#' @param namesList (optional) a vector of names for the coders. It must be the same length as wearableCamImagesList
#' and contains different names.
#'
#' @return A \code{tbl_df} with image name, image time, and one column for each coder.
#' @examples
#' \dontrun{
#' data(IO1)
#' data(IO2)
#' listObjects <- list(IO1, IO2)
#' namesList <- c("coder1", "coder2")
#' outputDifferences(listObjects, namesList)
#' }
#' @export
#'
outputDifferences <- function(wearableCamImagesList, namesList=NULL){
  # some sanity checks, see utils.R
  checkList(wearableCamImagesList = wearableCamImagesList,
            namesList = namesList)
  # give a default namesList is there is none
  if (is.null(namesList)){
    namesList <- as.character(1:length(wearableCamImagesList))
  }
  # take one dicoCoding (they're all the same)
  dicoRef <- wearableCamImagesList[[1]]@dicoCoding
  # Now off to find different codes
  dicoCoding <- dicoRef
  tableImages <- NULL
  bigTable <- NULL
  nCoders <- length(namesList)

  # table with all binary variables
  for (i in 1:length(wearableCamImagesList)){
    binaryTable <- wearableCamImagesList[[i]]@codesBinaryVariables
    imageTime <- wearableCamImagesList[[i]]@timeDate
    coder <- namesList[i]
    binaryTable <- cbind(coder=rep(coder, nrow(binaryTable)),
                         imageTime=imageTime,
                         binaryTable)
    binaryTable <- unique(binaryTable)
    bigTable <- rbind(bigTable, binaryTable)
  }

  # One table for each code
  # and then spread it for having one columns for each coder
  # and extract lines with differences
  for (code in dicoCoding$Code){
    miniTable <- bigTable[,c("coder",
                             "imageTime", code)]
    # only if the code is present in one of the tables
    if(sum(miniTable[,3]) != 0){
      miniTable <- dplyr::tbl_df(miniTable)
      miniTable <- dplyr::arrange(miniTable,
                                  imageTime)
      names(miniTable)[3] <- "code"
      # spread the table
      # in order to have a column for each coder
      miniTable2 <- tidyr::spread(miniTable,
                                  coder, code)
      # do the coder have the same code for the picture?
      notEqual <- !(apply(miniTable2[,2:(nCoders + 1)], 1, sum)
                    %in% c(0, nCoders))
      # only keep lines with differences
        miniTable2 <- dplyr::filter(miniTable2,
                                    notEqual)
        # transform and bind if there are lines
       if (nrow(miniTable2) > 0){
         miniTable2[miniTable2 == TRUE] <- code
         miniTable2[miniTable2 == FALSE] <- ""
         # table with differences for all codes
         tableImages <- rbind(tableImages,
                              miniTable2)
       }
    }

  }

  # Now one line per picture with all codes for each coder
  # this is much easier to read

  if(!is.null(tableImages)){
    tableImages <- dplyr::tbl_df(tableImages)
    tableImages <- dplyr::arrange(tableImages,
                           imageTime)
    tableImagesFinal <- NULL
    uniqueImages <- unique(tableImages$imageTime)
    # loop over all unique image
    for (image in uniqueImages){
      # and for each coder paste all the codes he had applied
      vectorImage <- paste0(tableImages[tableImages$imageTime ==
                                          image, 2:(nCoders + 1)])
      vectorImage <- gsub("c\\(", "", vectorImage)
      vectorImage <- gsub("\"", "", vectorImage)
      vectorImage <- gsub("\\)", "", vectorImage)
      vectorImage <- gsub(",", "", vectorImage)
      # remember that we have lines only for pictures
      # for which coders disagree on at least one code
      # so no further filterin
      tableImagesFinal <- rbind(tableImagesFinal,
                                vectorImage)
    }
    # make a tbl_df, and give right names
    tableImages <- dplyr::tbl_df(tableImagesFinal)
    names(tableImages) <- namesList

    tableImages <- dplyr::mutate(tableImages,
                                 imageTime = as.character(uniqueImages))
    tableImages <- dplyr::select(tableImages,
                                 imageTime, everything())

  }


return(tableImages)
}
