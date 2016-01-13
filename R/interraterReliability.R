#' Calculates interrater reliability using the irr package.
#' @importFrom irr kappa2 kappam.fleiss
#' @param wearableCamImagesList a list of \code{wearableCamImages} objects.
#' @param namesList (optional) a vector of names for the coders. It must be the same length as wearableCamImagesList
#' and contains different names.
#' @param oneToOne a boolean indicating whether Cohen's kappa should be calculated for each possible
#' pair of coders in case of more than 2 coders,
#' instead of Fleiss's Kappa for all coders at the same time.
#' @param byGroup boolean indicating whether the IRR should be calculated for each group of codes separately.
#' @param byCode boolean indicating whether the IRR should be calculated for each code separately. If both
#' byGroup and byCode are FALSE annotations are compared as they are, so make sure all raters use e.g. the same separator
#' between annotations when they give several codes to the same picture.
#' @return  A \code{tbl_df} presenting the results of a call to the \code{irr} function.
#' If there are only two raters the called function is \code{kappa2}, unweighted.
#'  If there are more than two raters and \code{oneToOne} is \code{FALSE}, the called function is \code{kappam.fleiss}.
#' @examples
#' data('dummyWearableCamImages')
#' listWC <- list(dummyWearableCamImages, dummyWearableCamImages)
#' namesList <- c('Cain', 'Abel')
#' irrWatchme(listWC, namesList=namesList)
#' listWC2 <- list(dummyWearableCamImages, dummyWearableCamImages, dummyWearableCamImages)
#' namesList <- c('Riri', 'Fifi', 'Loulou')
#' irrWatchme(listWC2, namesList=namesList)
#' irrWatchme(listWC2, namesList=namesList, oneToOne=TRUE)
#' irrWatchme(listWC, namesList=c('Cain', 'Abel'), oneToOne=TRUE, byCode=TRUE)
#' irrWatchme(listWC, namesList=c('Cain', 'Abel'), oneToOne=TRUE, byGroup=TRUE)

#' @export
irrWatchme <- function(wearableCamImagesList, namesList=NULL,
                       oneToOne=FALSE, byGroup=FALSE,
                       byCode=FALSE){

  # Some checks for the namesList which is not a list but a vector.

  if(length(wearableCamImagesList) == 1){
    stop("Do not bother using this function if you only have one wearableCamImages object.")# nolint
    }

  if (!is.null(namesList)){
    if(length(namesList) != length(wearableCamImagesList)){
      stop("Not as many names as wearableCamImages objects")
      }
    if(length(levels(factor(namesList))) != length(namesList)){
      stop("Please provide unique names for the coders")
      }
  }

  if(is.null(namesList)){
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

  if(length(unique(lapply(dicoCodings,nrow))) != 1){
    stop("All wearableCamImages objects should have the same dicoCoding!")# nolint
    }
  if(length(unique(lapply(dicoCodings,ncol))) != 1){
    stop("All wearableCamImages objects should have the same dicoCoding!")# nolint
    }

  compareDicos <- function(x){
    return( sum(x == dicoRef) == nElements)
  }

  if (any(lapply(dicoCodings, compareDicos) == FALSE)){
    stop("All wearableCamImages objects
         should have the same dicoCoding!")
    }

  # Easy, simply compares the equality of anotations
  if( !byGroup & !byCode){
  # create the table for comparing
  dat <- NULL
  for (i in 1:length(wearableCamImagesList)){
    dat <- cbind(dat, wearableCamImagesList[[i]]@codes)
  }

  dat <- as.data.frame(dat)
  names(dat) <- namesList

  if (length(wearableCamImagesList) == 2){
    results <- irr::kappa2(dat, "unweighted")
    tableResults <- data.frame(method=results$method,
                               pictures=results$subjects,
                               agreedOn=sum(dat[,1] == dat[,2]),
                               raters=results$raters,
                               ratersNames=
                                 paste(namesList[[1]], "and",
                                       namesList[[2]], sep=" "),
                               Kappa=results$value,
                               z=results$statistic,
                               pValue=results$p.value)
    tableResults <- dplyr::tbl_df(tableResults)
  }

  if (length(wearableCamImagesList) > 2 & !oneToOne){

    results <- irr::kappam.fleiss(dat)

    lengthOfUnique <- function(x){
      return(length(unique(x)))
    }

    agreedOn <- sum(apply(dat, 1, lengthOfUnique) == 1)


    tableResults <- data.frame(method=results$method,
                               pictures=results$subjects,
                               agreedOn=agreedOn,
                               raters=results$raters,
                               ratersNames=toString(namesList),
                               Kappa=results$value,
                               z=results$statistic,
                               pValue=results$p.value)
    tableResults <- dplyr::tbl_df(tableResults)
  }

  if (length(wearableCamImagesList) > 2 & oneToOne){

    pairs <- as.data.frame(t(combn(namesList, 2)))
    names(pairs) <- c("rater1", "rater2")

    tableResults <- NULL
    for (i in 1:nrow(pairs)){
      rater1 <- pairs$rater1[i]
      rater2 <- pairs$rater2[i]

      results <- irr::kappa2(dat[, c(rater1, rater2)], "unweighted")
      temp <- data.frame(method=results$method,
                         pictures=results$subjects,
                         agreedOn=sum(
                           dat[,rater1] == dat[,rater2]),
                         rater1=rater1,
                         rater2=rater2,
                         Kappa=results$value,
                         z=results$statistic,
                         pValue=results$p.value)
      tableResults <- rbind(tableResults, temp)
    }

    tableResults <- dplyr::tbl_df(tableResults)
  }

  return(tableResults)
}


  # If the IRR is to be calculated by group or by code,
  # it"s slightly more complicated.
  else{
    listResults <- list()

    if (byGroup & !byCode){
      for (group in dicoRef$Group){
        dat <- NULL
        namesDat <- NULL
        for (object in 1:length(wearableCamImagesList)){

          temp <- wearableCamImagesList[[object]]@codesBinaryVariables

          for (j in 1:ncol(temp)){
            for (i in 1:nrow(temp)){
              if (temp[i,j]){
                temp[i,j] <- names(temp)[j]
                }
              else {
                temp[i,j] <- ""
                }
            }
          }

          codes <- rep("", nrow(temp))
          for (i in 1:nrow(temp)){
            codes[i] <- toString(temp[i,])
          }

         dat <- cbind(dat, codes)
         namesDat <- c(namesDat, namesList[object])
        }
        dat <- as.data.frame(dat)
        names(dat) <- namesDat
        dat <- tbl_df(dat)
        if (length(wearableCamImagesList) == 2){
          results <- irr::kappa2(dat, "unweighted")
          tableResults <- data.frame(method=results$method,
                                     pictures=results$subjects,
                                     agreedOn=sum(dat[,1] == dat[,2]),
                                     raters=results$raters,
                                     ratersNames=
                                       paste(namesList[[1]], "and",
                                             namesList[[2]], sep=" "),
                                     Kappa=results$value,
                                     z=results$statistic,
                                     pValue=results$p.value)
          tableResults <- dplyr::tbl_df(tableResults)
        }

        if (length(wearableCamImagesList) > 2 & !oneToOne){

          results <- irr::kappam.fleiss(dat)

          lengthOfUnique <- function(x){
            return(length(unique(x)))
          }

          agreedOn <- sum(apply(dat, 1, lengthOfUnique) == 1)


          tableResults <- data.frame(method=results$method,
                                     pictures=results$subjects,
                                     agreedOn=agreedOn,
                                     raters=results$raters,
                                     ratersNames=toString(namesList),
                                     Kappa=results$value,
                                     z=results$statistic,
                                     pValue=results$p.value)
          tableResults <- dplyr::tbl_df(tableResults)
        }

        if (length(wearableCamImagesList) > 2 & oneToOne){

          pairs <- as.data.frame(t(combn(namesList, 2)))
          names(pairs) <- c("rater1", "rater2")

          tableResults <- NULL
          for (i in 1:nrow(pairs)){
            rater1 <- pairs$rater1[i]
            rater2 <- pairs$rater2[i]

            results <- kappa2(dat[, c(rater1, rater2)], "unweighted")
            temp <- data.frame(method=results$method,
                               pictures=results$subjects,
                               agreedOn=sum(dat[,rater1] == dat[,rater2]),
                               rater1=rater1,
                               rater2=rater2,
                               Kappa=results$value,
                               z=results$statistic,
                               pValue=results$p.value)
            tableResults <- rbind(tableResults, temp)
          }

          tableResults <- dplyr::tbl_df(tableResults)
        }


        listResults[[as.character(group)]] <- tableResults


      }
    }

    if(byCode){

      for (j in 1:ncol(wearableCamImagesList[[1]]@codesBinaryVariables)){
        code <- names(wearableCamImagesList[[1]]@codesBinaryVariables)[j]
        dat <- NULL
        for (i in 1:length(wearableCamImagesList)){
          dat <- cbind(dat,
                       wearableCamImagesList[[i]]@codesBinaryVariables[,j])
        }
        dat <- as.data.frame(dat)
        names(dat) <- namesList
        if (length(wearableCamImagesList)  ==  2){
          results <- kappa2(dat, "unweighted")
          tableResults <- data.frame(method=results$method,
                                     pictures=results$subjects,
                                     agreedOn=sum(dat[,1] == dat[,2]),
                                     rater1YesRater2No=sum(
                                       dat[,1] == TRUE & dat[,2] == FALSE),
                                     rater1NoRater2Yes=sum(
                                       dat[,1] == FALSE & dat[,2] == TRUE),
                                     raters=results$raters,
                                     ratersNames=paste(
                                       namesList[[1]], "and",
                                       namesList[[2]], sep=" "),
                                     Kappa=results$value,
                                     z=results$statistic,
                                     pValue=results$p.value)
          tableResults <- dplyr::tbl_df(tableResults)
        }

        if (length(wearableCamImagesList) > 2 & !oneToOne){

          results <- kappam.fleiss(dat)

          lengthOfUnique <- function(x){
            return(length(unique(x)))
          }

          agreedOn <- sum(apply(dat, 1, lengthOfUnique) == 1)


          tableResults <- data.frame(method=results$method,
                                     pictures=results$subjects,
                                     agreedOn=agreedOn,
                                     raters=results$raters,
                                     ratersNames=toString(namesList),
                                     Kappa=results$value,
                                     z=results$statistic,
                                     pValue=results$p.value)
          tableResults <- dplyr::tbl_df(tableResults)
        }

        if (length(wearableCamImagesList) > 2 & oneToOne){

          pairs <- as.data.frame(t(combn(namesList, 2)))
          names(pairs) <- c("rater1", "rater2")

          tableResults <- NULL
          for (i in 1:nrow(pairs)){
            rater1 <- pairs$rater1[i]
            rater2 <- pairs$rater2[i]

            results <- kappa2(dat[, c(rater1, rater2)], "unweighted")
            temp <- data.frame(method=results$method,
                               pictures=results$subjects,
                               agreedOn=sum(dat[,rater1] == dat[,rater2]),
                               rater1YesRater2No=
                                 sum(dat[,1] == TRUE &
                                       dat[,2] == FALSE),
                               rater1NoRater2Yes=
                                 sum(dat[,1] == FALSE &
                                       dat[,2] == TRUE),
                               rater1=rater1,
                               rater2=rater2,
                               Kappa=results$value,
                               z=results$statistic,
                               pValue=results$p.value)
            tableResults <- rbind(tableResults, temp)
          }

          tableResults <- dplyr::tbl_df(tableResults)
        }


        listResults[[code]] <- tableResults

      }

    }
    return(listResults)
  }



}
