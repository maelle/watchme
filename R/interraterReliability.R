#' Calculates interrater agreement using the irr package. A unit of comparison is one picture.
#' @importFrom irr kappa2 kappam.fleiss
#' @importFrom dplyr tbl_df "%>%"
#' @importFrom data.table setattr
#' @param wearableCamImagesList a list of \code{wearableCamImages} objects.
#' @param namesList (optional) a vector of names for the coders. It must be the same length as wearableCamImagesList
#' and contains different names.
#' @param oneToOne a boolean indicating whether Cohen's kappa should be calculated for each possible
#' pair of coders in case of more than 2 coders,
#' instead of Fleiss's Kappa for all coders at the same time.
#' @param byGroup boolean indicating whether the IRR should be calculated for each group of codes separately. The meaning is, agreement = giving a code of the same group.
#' @param byCode boolean indicating whether the IRR should be calculated for each code separately. If both
#' byGroup and byCode are FALSE annotations are compared as they are.
#' @return  A \code{tbl_df} presenting the results of a call to the \code{irr} function.
#' If there are only two raters the called function is \code{kappa2}, unweighted.
#'  If there are more than two raters and \code{oneToOne} is \code{FALSE}, the called function is \code{kappam.fleiss}.
#' @examples
#' data('IO1')
#' data('IO2')
#' listWC <- list(IO1, IO2)
#' namesList <- c('Cain', 'Abel')
#' iraWatchme(listWC, namesList=namesList)
#' listWC2 <- list(IO1, IO1, IO2)
#' namesList <- c('Riri', 'Fifi', 'Loulou')
#' iraWatchme(listWC2, namesList=namesList)
#' iraWatchme(listWC2, namesList=namesList, oneToOne=TRUE)
#' iraWatchme(listWC, namesList=c('Cain', 'Abel'), oneToOne=TRUE, byCode=TRUE)
#' iraWatchme(listWC, namesList=c('Cain', 'Abel'), oneToOne=TRUE, byGroup=TRUE)

#' @export
iraWatchme <- function(wearableCamImagesList, namesList=NULL,
                       oneToOne=FALSE, byGroup=FALSE,
                       byCode=FALSE){
  # some sanity checks, see utils.R
  checkList(wearableCamImagesList = wearableCamImagesList,
            namesList = namesList)
  # give a default namesList is there is none
  if (is.null(namesList)){
    namesList <- as.character(1:length(wearableCamImagesList))
  }

  # take one dicoCoding (they're all the same)
  dicoRef <- wearableCamImagesList[[1]]@dicoCoding

  # Easy, simply compares the equality of annotations
    if ( !byGroup & !byCode){
    # create the table for comparing
    dat <- NULL
    for (i in 1:length(wearableCamImagesList)){
      dat <- cbind(dat, as.factor(wearableCamImagesList[[i]]@codes))
    }

    dat <- as.data.frame(dat)
    dat <- dplyr::tbl_df(dat)
     # make sure the levels are the same
    # even if one coder has not used one code
    names(dat) <- namesList
    levelsAll <- unique(unlist(lapply(dat, levels)))
    for (i in 1:length(wearableCamImagesList)){
      setattr(dat[,i], "levels", levelsAll)
    }

    if (length(wearableCamImagesList) == 2){
      results <- irr::kappa2(dat, "unweighted")
      tableResults <- data.frame(method = results$method,
                                 pictures = results$subjects,
                                 agreedOn = sum(dat[,1] == dat[,2]),
                                 raters = results$raters,
                                 ratersNames =
                                   paste(namesList[[1]], "and",
                                         namesList[[2]], sep=" "),
                                 Kappa = results$value,
                                 z = results$statistic,
                                 pValue = results$p.value)
      tableResults <- dplyr::tbl_df(tableResults)
    }

    if (length(wearableCamImagesList) > 2 & !oneToOne){

      results <- irr::kappam.fleiss(dat)

      lengthOfUnique <- function(x){
        return(length(unique(x)))
      }

      agreedOn <- sum(apply(dat, 1, lengthOfUnique) == 1)


      tableResults <- data.frame(method = results$method,
                                 pictures = results$subjects,
                                 agreedOn = agreedOn,
                                 raters = results$raters,
                                 ratersNames = toString(namesList),
                                 Kappa = results$value,
                                 z = results$statistic,
                                 pValue = results$p.value)
      tableResults <- dplyr::tbl_df(tableResults)
    }

    if (length(wearableCamImagesList) > 2 & oneToOne){

      pairs <- as.data.frame(t(combn(namesList, 2)))
      names(pairs) <- c("rater1", "rater2")

      tableResults <- NULL
      for (i in 1:nrow(pairs)){
        rater1 <- pairs$rater1[i]
        rater2 <- pairs$rater2[i]

        results <- irr::kappa2(dat[, c(rater1, rater2)],
                               "unweighted")

        temp <- data.frame(method = results$method,
                           pictures = results$subjects,
                           agreedOn = sum(
                             dat[,rater1]  ==  dat[,rater2]),
                           rater1 = rater1,
                           rater2 = rater2,
                           Kappa = results$value,
                           z = results$statistic,
                           pValue = results$p.value)
        tableResults <- rbind(tableResults, temp)
      }

      tableResults <- dplyr::tbl_df(tableResults)
    }


}


  # If the IRR is to be calculated by group or by code,
  # it"s slightly more complicated.
  else{
    listResults <- list()

    if (byGroup & !byCode){
      for (group in unique(dicoRef$Group)){
        dat <- NULL
        namesDat <- NULL
        for (object in 1:length(wearableCamImagesList)){
          # filter only for the group
          # and then look whether any code for this group
          temp <- wearableCamImagesList[[object]]@codesBinaryVariables
          temp <- temp[, filter(dicoRef,
                                Group == group)$Code]
          temp <- as.data.frame(temp)
          temp <- (apply(temp, 1, sum) >= 1)

         # bind, one column per coder
         dat <- cbind(dat, as.factor(temp))
         namesDat <- c(namesDat, namesList[object])
        }
        dat <- as.data.frame(dat)
        names(dat) <- namesDat
        dat <- tbl_df(dat)

        if (length(wearableCamImagesList) == 2){
          results <- irr::kappa2(dat, "unweighted")
          tableResults <- data.frame(method = results$method,
                                     pictures = results$subjects,
                                     agreedOn = sum(dat[,1] == dat[,2]),
                                     raters = results$raters,
                                     ratersNames =
                                       paste(namesList[[1]], "and",
                                             namesList[[2]],
                                             sep = " "),
                                     Kappa = results$value,
                                     z = results$statistic,
                                     pValue = results$p.value,
                                     group = group)
          tableResults <- dplyr::tbl_df(tableResults)
        }

        # more than two coders, but kappam.fleiss
        # (global measure of agreement)
        if (length(wearableCamImagesList) > 2 & !oneToOne){

          results <- irr::kappam.fleiss(dat)

          lengthOfUnique <- function(x){
            return(length(unique(x)))
          }

          agreedOn <- sum(apply(dat, 1, lengthOfUnique) == 1)


          tableResults <- data.frame(method = results$method,
                                     pictures = results$subjects,
                                     agreedOn = agreedOn,
                                     raters = results$raters,
                                     ratersNames = toString(namesList),
                                     Kappa = results$value,
                                     z = results$statistic,
                                     pValue = results$p.value,
                                     group = group)
          tableResults <- dplyr::tbl_df(tableResults)
        }

        # more than two coders
        # and results for each pair
        if (length(wearableCamImagesList) > 2 & oneToOne){

          pairs <- as.data.frame(t(combn(namesList, 2)))
          names(pairs) <- c("rater1", "rater2")

          tableResults <- NULL
          for (i in 1:nrow(pairs)){
            rater1 <- pairs$rater1[i]
            rater2 <- pairs$rater2[i]

            results <- kappa2(dat[, c(rater1, rater2)], "unweighted")
            temp <- data.frame(method = results$method,
                               pictures = results$subjects,
                               agreedOn = sum(dat[,rater1] ==
                                                dat[,rater2]),
                               rater1 = rater1,
                               rater2 = rater2,
                               Kappa = results$value,
                               z = results$statistic,
                               pValue = results$p.value,
                               group = group)
            tableResults <- rbind(tableResults, temp)
          }

          tableResults <- dplyr::tbl_df(tableResults)
        }


        listResults[[as.character(group)]] <- tableResults

      }
      listResults <- do.call("rbind", listResults)
    }

    if (byCode){

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
                                     pValue=results$p.value,
                                     code = code)
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
                                     pValue=results$p.value,
                                     code = code)
          tableResults <- dplyr::tbl_df(tableResults)
        }

        if (length(wearableCamImagesList) > 2 & oneToOne){

          pairs <- as.data.frame(t(combn(namesList, 2)))
          names(pairs) <- c("rater1", "rater2")
          pairs$"rater1" <- as.character(pairs$"rater1")
          pairs$"rater2" <- as.character(pairs$"rater2")
          tableResults <- NULL
          for (i in 1:nrow(pairs)){
            rater1 <- pairs$rater1[i]
            rater2 <- pairs$rater2[i]
            results <- kappa2(dat[, c(rater1, rater2)], "unweighted")
            temp <- data.frame(method=results$method,
                               pictures=results$subjects,
                               agreedOn=sum(dat[,rater1] == dat[,rater2]),
                               rater1YesRater2No=
                                 sum(dat[,rater1] == TRUE &
                                       dat[,rater2] == FALSE),
                               rater1NoRater2Yes=
                                 sum(dat[,rater1] == FALSE &
                                       dat[,rater2] == TRUE),
                               rater1=rater1,
                               rater2=rater2,
                               Kappa=results$value,
                               z=results$statistic,
                               pValue=results$p.value,
                               code = code)
            tableResults <- rbind(tableResults, temp)
          }

          tableResults <- dplyr::tbl_df(tableResults)
        }


        listResults[[code]] <- tableResults

      }
      listResults <- dplyr::tbl_df(do.call("rbind", listResults))
    }

    tableResults <- listResults

  }

  return(tableResults)

}
