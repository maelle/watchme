#' Allows to merge several \code{wearableCamImages} objects,
#' i.e. for looking at coding results of one rater.
#'
#' @param wearableCamImagesList a list of 2 \code{wearableCamImages} objects.
#' @return A list of \code{wearableCamImages} objects.
#' @examples
#' data("dummyWearableCamImages")
#' wearableCamImagesList <- list(dummyWearableCamImages, dummyWearableCamImages)
#' correctedList <- combineObjects(wearableCamImagesList)

#' @export
combineObjects <- function(wearableCamImagesList){
  # check that all objects used the same dicoCoding
  getDicoCoding <- function(x){
    return(x@dicoCoding)
  }
  dicoRef <- getDicoCoding(wearableCamImagesList[[1]])
  nElements <- nrow(dicoRef)*ncol(dicoRef)
  dicoCodings <- lapply(wearableCamImagesList, getDicoCoding)

  compareDicos <- function(x){
    return( sum(x==dicoRef)==nElements)
  }

  if (any(lapply(dicoCodings, compareDicos)==FALSE)){stop("All wearableCamImages objects should have the same dicoCoding!")}

  dicoCoding <- wearableCamImagesList[[1]]@dicoCoding

  imagePath <- NULL
  timeDate <- as.POSIXct(NA)
  codes <- NULL
  codesBinaryVariables <- NULL
  participantID <- NULL

  for(i in 1:length(wearableCamImagesList)){
    imagePath <- c(imagePath, wearableCamImagesList[[i]]@imagePath)
    timeDate <- c(timeDate, wearableCamImagesList[[i]]@timeDate)
    codes <- c(codes, wearableCamImagesList[[i]]@codes)
    codesBinaryVariables <- rbind(codesBinaryVariables, wearableCamImagesList[[i]]@codesBinaryVariables)
    participantID <- c(participantID, wearableCamImagesList[[i]]@participantID)
  }

  wearableCamImagesObject <- new("wearableCamImages",
                                 dicoCoding=dicoCoding,
                                 imagePath=imagePath,
                                 timeDate=timeDate[2:length(timeDate)],
                                 codes=codes,
                                 codesBinaryVariables=codesBinaryVariables,
                                 participantID=participantID)

  return(wearableCamImagesObject)
}
