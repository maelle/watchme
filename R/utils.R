checkList <- function(wearableCamImagesList, namesList=NULL){
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

  if (length(unique(lapply(dicoCodings, nrow))) != 1){
    stop("All wearableCamImages objects should have the same dicoCoding!")# nolint
  }
  if (length(unique(lapply(dicoCodings, ncol))) != 1){
    stop("All wearableCamImages objects should have the same dicoCoding!")# nolint
  }

  compareDicos <- function(x){
    return(sum(x == dicoRef) == nElements)
  }

  if (any(lapply(dicoCodings, compareDicos) == FALSE)){
    stop("All wearableCamImages objects  should have the same dicoCoding!")# nolint
  }
}



