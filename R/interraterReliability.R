#' Calculates interrater agreement using the \code{irr} package. The unit of comparison is one picture.
#' @importFrom irr kappa2 kappam.fleiss
#' @importFrom dplyr tbl_df filter_
#' @param results_list a list of \code{tibble} created by \code{watchme_prepare_data}.
#' @param names_list (optional) a vector of names for the coders. It must be the same length as results_list
#' and contains different names.
#' @param one_to_one a boolean indicating whether Cohen's kappa should be calculated for each possible
#' pair of coders in case of more than 2 coders,
#' instead of Fleiss's Kappa for all coders at the same time.
#' @param by_code boolean indicating whether the IRR should be calculated for each code separately, or for annotations as a whole.
#' @return  A \code{tbl_df} presenting the results of a call to the \code{irr} function.
#' If there are only two raters the called function is \code{kappa2}, unweighted.
#' If there are more than two raters and \code{one_to_one} is \code{FALSE}, the called function is \code{kappam.fleiss}.
#' @examples
#' data('coding1')
#' data('coding2')
#' # With two coders
#' results_list <- list(coding1, coding2)
#' names_list <- c('Cain', 'Abel')
#' watchme_ira(results_list, names_list = names_list)
#' watchme_ira(results_list, names_list = names_list, by_code = TRUE)
#' # With three coders
#' results_list2 <- list(coding1, coding1, coding2)
#' names_list2 <- c('Riri', 'Fifi', 'Loulou')
#' watchme_ira(results_list2, names_list = names_list2, one_to_one = FALSE)
#' watchme_ira(results_list2, names_list = names_list2, one_to_one = TRUE)
#' watchme_ira(results_list2, names_list = names_list2, one_to_one = FALSE, by_code = TRUE)
#' watchme_ira(results_list2, names_list = names_list2, one_to_one = TRUE, by_code = TRUE)

#' @export
watchme_ira <- function(results_list, names_list = NULL,
                       one_to_one = TRUE,
                       by_code = FALSE){
  # some checks, see utils.R
  # and take one dicoCoding (they're all the same)
  watchme_check_list(results_list,
                     names_list = names_list)

  dico_ref <- watchme_check_dicos(results_list)
  # give a default names_list is there is none
  if (is.null(names_list)){
    names_list <- as.character(1:length(results_list))
  }


  # Compares the equality of annotations as a whole
    if (!by_code){
    # create the table for comparing
    dat <- purrr::map(results_list, create_string_for_comparison,
                      dico_ref) %>%
      dplyr::bind_cols()

    names(dat) <- names_list

    # one to one comparison
    if(one_to_one){
      dat_pairs <- combn(dat, 2, simplify = FALSE)

      tableResults <- dat_pairs %>%
        purrr::map(calculate_irr, irr_function = irr::kappa2,
                   arg_function_irr = "unweighted")
      tableResults <- quietly_bind_rows(tableResults)$"result"
    }else{
      # ira for the group
      tableResults <- list(dat) %>%
        purrr::map(calculate_irr, irr_function = irr::kappam.fleiss)
      tableResults <- quietly_bind_rows(tableResults)$"result"
    }


}


  # If the IRA is to be calculated by code
  else{
    tableResults <- list()
    for(code in dico_ref$Code){
      dat <- purrr::map(results_list, dplyr::select_,
                        code) %>%
        dplyr::bind_cols()
      names(dat) <- names_list
      dat_pairs <- combn(dat, 2, simplify = FALSE)

      if(one_to_one){
        tableResults[[code]] <- dat_pairs %>%
          purrr::map(calculate_irr, irr_function = irr::kappa2,
                     arg_function_irr = "unweighted")
      }else{
        tableResults[[code]] <- list(dat) %>%
          purrr::map(calculate_irr, irr_function = irr::kappam.fleiss,
                     arg_function_irr = NULL)
      }

      tableResults[[code]] <-   quietly_bind_rows(tableResults[[code]])$"result"
      tableResults[[code]] <- tableResults[[code]] %>%
        dplyr::mutate_(code = ~code) %>%
        dplyr::select_(~code, ~everything())
    }

    tableResults <- quietly_bind_rows(tableResults)$"result"
  }

  tableResults <- tibble::as_tibble(tableResults)
  return(tableResults)

}



quietly_bind_rows <- purrr::quietly(dplyr::bind_rows)



calculate_irr <- function(data_pairs, irr_function, arg_function_irr = NULL){

  if(is.null(arg_function_irr)){
    results <- irr_function(data_pairs)
  }else{
    results <- irr_function(data_pairs, arg_function_irr)
  }
  data.frame(method = results$method,
             pictures = results$subjects,
             agreed_on = count_agreed_on(data_pairs),
             raters = toString(names(data_pairs)),
             Kappa = results$value,
             z = results$statistic,
             p_value = results$p.value)
}
