#' Calculates interrater agreement using the irr package. The unit of comparison is one picture.
#' @importFrom irr kappa2 kappam.fleiss
#' @importFrom dplyr tbl_df filter_
#' @param results_list a list of \code{tibble}  created by \code{watchme_prepare_data}.
#' @param names_list (optional) a vector of names for the coders. It must be the same length as results_list
#' and contains different names.
#' @param one_to_one a boolean indicating whether Cohen's kappa should be calculated for each possible
#' pair of coders in case of more than 2 coders,
#' instead of Fleiss's Kappa for all coders at the same time.
#' @param byGroup boolean indicating whether the IRR should be calculated for each group of codes separately. The meaning is, agreement = giving a code of the same group.
#' @param by_code boolean indicating whether the IRR should be calculated for each code separately. If both
#' byGroup and by_code are FALSE annotations are compared as they are.
#' @return  A \code{tbl_df} presenting the results of a call to the \code{irr} function.
#' If there are only two raters the called function is \code{kappa2}, unweighted.
#'  If there are more than two raters and \code{one_to_one} is \code{FALSE}, the called function is \code{kappam.fleiss}.
#' @examples
#' data('IO1')
#' data('IO2')
#' results_list <- list(IO1, IO2)
#' names_list <- c('Cain', 'Abel')
#' watchme_ira(results_list, names_list=names_list)
#' results_list2 <- list(IO1, IO1, IO2)
#' names_list <- c('Riri', 'Fifi', 'Loulou')
#' watchme_ira(results_list2, names_list=names_list)
#' watchme_ira(results_list2, names_list=names_list, one_to_one=TRUE)
#' watchme_ira(results_list, names_list=c('Cain', 'Abel'), one_to_one=TRUE, by_code=TRUE)
#' watchme_ira(results_list, names_list=c('Cain', 'Abel'), one_to_one=TRUE, byGroup=TRUE)

#' @export
watchme_ira <- function(results_list, names_list=NULL,
                       one_to_one=FALSE, byGroup=FALSE,
                       by_code=FALSE){
  # some checks, see utils.R
  # and take one dicoCoding (they're all the same)
  watchme_check_list(results_list,
                     names_list = names_list)

  dico_ref <- watchme_check_dicos(results_list)
  # give a default names_list is there is none
  if (is.null(names_list)){
    names_list <- as.character(1:length(results_list))
  }


  # Easy, simply compares the equality of annotations
    if ( !byGroup & !by_code){
    # create the table for comparing
    dat <- purrr::map(results_list, create_string_for_comparison,
                      dico_ref) %>%
      dplyr::bind_cols()

     # make sure the levels are the same
    # even if one coder has not used one code
    names(dat) <- names_list


    if (length(results_list) == 2){
      results <- irr::kappa2(dat, "unweighted")
      tableResults <- data.frame(method = results$method,
                                 pictures = results$subjects,
                                 agreedOn = sum(dat[,1] == dat[,2]),
                                 raters = results$raters,
                                 ratersNames =
                                   paste(names_list[[1]], "and",
                                         names_list[[2]], sep=" "),
                                 Kappa = results$value,
                                 z = results$statistic,
                                 pValue = results$p.value)
      tableResults <- dplyr::tbl_df(tableResults)
    }

    if (length(results_list) > 2 & !one_to_one){

      results <- irr::kappam.fleiss(dat)

      lengthOfUnique <- function(x){
        return(length(unique(x)))
      }

      agreedOn <- sum(apply(dat, 1, lengthOfUnique) == 1)


      tableResults <- data.frame(method = results$method,
                                 pictures = results$subjects,
                                 agreedOn = agreedOn,
                                 raters = results$raters,
                                 ratersNames = toString(names_list),
                                 Kappa = results$value,
                                 z = results$statistic,
                                 pValue = results$p.value)
      tableResults <- dplyr::tbl_df(tableResults)
    }

    if (length(results_list) > 2 & one_to_one){

      pairs <- as.data.frame(t(combn(names_list, 2)))
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

    if (byGroup & !by_code){
      for (group in unique(dico_ref$Group)){
        dat <- NULL
        namesDat <- NULL
        for (object in 1:length(results_list)){
          # filter only for the group
          # and then look whether any code for this group
          temp <- results_list[[object]]$booleanCodes
          temp <- temp[, filter_(dico_ref,
                                interp( ~Group == group))$
                         Code]
          temp <- as.data.frame(temp)
          temp <- (apply(temp, 1, sum) >= 1)

         # bind, one column per coder
         dat <- cbind(dat, as.factor(temp))
         namesDat <- c(namesDat, names_list[object])
        }
        dat <- as.data.frame(dat)
        names(dat) <- namesDat
        dat <- tbl_df(dat)

        if (length(results_list) == 2){
          results <- irr::kappa2(dat, "unweighted")
          tableResults <- data.frame(method = results$method,
                                     pictures = results$subjects,
                                     agreedOn = sum(dat[,1] == dat[,2]),
                                     raters = results$raters,
                                     ratersNames =
                                       paste(names_list[[1]], "and",
                                             names_list[[2]],
                                             sep = " "),
                                     Kappa = results$value,
                                     z = results$statistic,
                                     pValue = results$p.value,
                                     group = group)
          tableResults <- dplyr::tbl_df(tableResults)
        }

        # more than two coders, but kappam.fleiss
        # (global measure of agreement)
        if (length(results_list) > 2 & !one_to_one){

          results <- irr::kappam.fleiss(dat)

          lengthOfUnique <- function(x){
            return(length(unique(x)))
          }

          agreedOn <- sum(apply(dat, 1, lengthOfUnique) == 1)


          tableResults <- data.frame(method = results$method,
                                     pictures = results$subjects,
                                     agreedOn = agreedOn,
                                     raters = results$raters,
                                     ratersNames = toString(names_list),
                                     Kappa = results$value,
                                     z = results$statistic,
                                     pValue = results$p.value,
                                     group = group)
          tableResults <- dplyr::tbl_df(tableResults)
        }

        # more than two coders
        # and results for each pair
        if (length(results_list) > 2 & one_to_one){

          pairs <- as.data.frame(t(combn(names_list, 2)))
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

    if (by_code){

      for (j in 1:ncol(results_list[[1]]$booleanCodes)){
        code <- names(results_list[[1]]$booleanCodes)[j]
        dat <- data.frame(rep(NA,
                              length(results_list[[1]]$
                                       booleanCodes[,code])))
        for (i in 1:length(results_list)){
          dat <- cbind(dat,
                       results_list[[i]]$booleanCodes[,code])
        }
        dat <- as.data.frame(dat[,2:ncol(dat)])
        names(dat) <- names_list
        if (length(results_list)  ==  2){
          results <- kappa2(dat, "unweighted")
          tableResults <- data.frame(method = results$method,
                                     pictures = results$subjects,
                                     agreedOn = sum(dat[,1] == dat[,2]),
                                     rater1YesRater2No=sum(
                                       dat[,1] == TRUE & dat[,2] == FALSE),
                                     rater1NoRater2Yes=sum(
                                       dat[,1] == FALSE & dat[,2] == TRUE),
                                     raters = results$raters,
                                     ratersNames = paste(
                                       names_list[[1]], "and",
                                       names_list[[2]], sep=" "),
                                     Kappa = results$value,
                                     z = results$statistic,
                                     pValue = results$p.value,
                                     code = code)
          tableResults <- dplyr::tbl_df(tableResults)
        }

        if (length(results_list) > 2 & !one_to_one){

          results <- kappam.fleiss(dat)

          lengthOfUnique <- function(x){
            return(length(unique(x)))
          }

          agreedOn <- sum(apply(dat, 1, lengthOfUnique) == 1)


          tableResults <- data.frame(method = results$method,
                                     pictures = results$subjects,
                                     agreedOn = agreedOn,
                                     raters = results$raters,
                                     ratersNames = toString(names_list),
                                     Kappa = results$value,
                                     z = results$statistic,
                                     pValue = results$p.value,
                                     code = code)
          tableResults <- dplyr::tbl_df(tableResults)
        }

        if (length(results_list) > 2 & one_to_one){

          pairs <- as.data.frame(t(combn(names_list, 2)))
          names(pairs) <- c("rater1", "rater2")
          pairs$"rater1" <- as.character(pairs$"rater1")
          pairs$"rater2" <- as.character(pairs$"rater2")
          tableResults <- NULL
          for (i in 1:nrow(pairs)){
            rater1 <- pairs$rater1[i]
            rater2 <- pairs$rater2[i]
            results <- kappa2(dat[, c(rater1, rater2)], "unweighted")
            temp <- data.frame(method = results$method,
                               pictures = results$subjects,
                               agreedOn = sum(dat[,rater1] == dat[,rater2]),
                               rater1YesRater2No =
                                 sum(dat[,rater1] == TRUE &
                                       dat[,rater2] == FALSE),
                               rater1NoRater2Yes =
                                 sum(dat[,rater1] == FALSE &
                                       dat[,rater2] == TRUE),
                               rater1 = rater1,
                               rater2 = rater2,
                               Kappa = results$value,
                               z = results$statistic,
                               pValue = results$p.value,
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

create_string_for_comparison <- function(df, dico_ref){
df[, dico_ref$Code] %>%
  purrr::by_row(toString, .to = "codes",
                .collate = "cols") %>%
  select_(quote(codes))
}
