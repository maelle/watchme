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
#' data('dummyWearableCamImages')
#' listWC <- list(dummyWearableCamImages, dummyWearableCamImages)
#' namesList <- c('Cain', 'Abel')
#' outputDifferences(listWC, namesList=namesList)
#' @export
#'
outputDifferences <- function(wearableCamImagesList, namesList=NULL){
  # Some checks for the namesList which is not a list but a vector.

  if (length(wearableCamImagesList) == 1){
    stop("Do not bother using this function if you only have one wearableCamImages object.")# nolint
  }

  if (!is.null(namesList)){
    if (length(namesList) != length(wearableCamImagesList)){
      stop("Not as many names as wearableCamImages objects")
    }
    if (length(levels(factor(namesList))) != length(namesList)){
      stop("Please provide unique names for the coders")
    }
  }

  if (is.null(namesList)){
    namesList <- as.character(1:length(wearableCamImagesList))
  }

  # check that all sets of codes to be compared have the same length

  getLengthCodes <- function(x){
    return(length(x@codes))
  }
  lengthRef <- getLengthCodes(wearableCamImagesList[[1]])
  lengthsCodes <- lapply(wearableCamImagesList, getLengthCodes)
  if (any(lengthsCodes != lengthRef)){
    stop("There should be the same number of pictures in each wearableCamImages object!")# nolint
  }


  # check that all objects used the same dicoCoding
  getDicoCoding <- function(x){
    return(x@dicoCoding)
  }
  dicoRef <- getDicoCoding(wearableCamImagesList[[1]])
  nElements <- nrow(dicoRef) * ncol(dicoRef)
  dicoCodings <- lapply(wearableCamImagesList, getDicoCoding)

  if (length(unique(lapply(dicoCodings,nrow))) != 1){
    stop("All wearableCamImages objects should have the same dicoCoding!")# nolint
  }
  if (length(unique(lapply(dicoCodings,ncol))) != 1){
    stop("All wearableCamImages objects should have the same dicoCoding!")# nolint
  }

  compareDicos <- function(x){
    return( sum(x == dicoRef) == nElements)
  }

  if (any(lapply(dicoCodings, compareDicos) == FALSE)){
    stop("All wearableCamImages objects
         should have the same dicoCoding!")
  }

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
    if(sum(miniTable[,3]) != 0){
      miniTable <- dplyr::tbl_df(miniTable)
      miniTable <- dplyr::arrange(miniTable,
                                  imageTime)
      names(miniTable)[3] <- "code"
      miniTable2 <- tidyr::spread(miniTable,
                                  coder, code)
      notEqual <- !(apply(miniTable2[,2:(nCoders + 1)], 1, sum)
                    %in% c(0, nCoders))
      if(sum(notEqual) != 0){
        miniTable2 <- dplyr::filter(miniTable2,
                                    notEqual)
        miniTable2[miniTable2 == TRUE] <- code
        miniTable2[miniTable2 == FALSE] <- ""
      }
      else{
        miniTable2 <- NULL
      }
      tableImages <- rbind(tableImages,
                           miniTable2)
    }

  }

  # One line per picture with all codes for each coder

  if(!is.null(tableImages)){
    tableImages <- dplyr::tbl_df(tableImages)
    tableImages <- dplyr::arrange(tableImages,
                           imageTime)
    tableImagesFinal <- NULL
    uniqueImages <- unique(tableImages$imageTime)
    for (image in uniqueImages){
      vectorImage <- paste0(tableImages[tableImages$imageTime ==
                                          image, 2:(nCoders + 1)])
      vectorImage <- gsub("c\\(", "", vectorImage)
      vectorImage <- gsub("\"", "", vectorImage)
      vectorImage <- gsub("\\)", "", vectorImage)
      vectorImage <- gsub(",", "", vectorImage)
      tableImagesFinal <- rbind(tableImagesFinal,
                                vectorImage)
    }
    tableImages <- dplyr::tbl_df(tableImagesFinal)
    names(tableImages) <- namesList
     tableImages <- dplyr::mutate(tableImages,
                                  imageTime = as.character(uniqueImages))
     tableImages <- dplyr::select(tableImages,
                                  imageTime, everything())
  }


return(tableImages)
}
