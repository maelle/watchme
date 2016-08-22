#' Outputs images for which codes are different among coders
#'
#' @importFrom dplyr tbl_df mutate_ arrange_ group_by_ left_join filter_ summarize_ select_
#' @importFrom tidyr gather spread
#' @param results_list a list of \code{tibble} created by \code{watchme_prepare_data}.
#' @param names_list (optional) a vector of names for the coders. It must be the same length as results_list
#' and contains different names.
#' @return A \code{tbl_df} with image name, image time, and one column for each coder.
#' @examples
#' \dontrun{
#' data('coding1')
#' data('coding2')
#' # With two coders
#' results_list <- list(coding1, coding2)
#' names_list <- c('Cain', 'Abel')
#' watchme_output_differences(results_list = results_list,
#'  names_list = names_list)
#' }
#' @export
#'
watchme_output_differences <- function(results_list, names_list = NULL){
  # some checks, see utils.R
  # and take one dicoCoding (they're all the same)
  watchme_check_list(results_list,
                     names_list = names_list)

  dico_ref <- watchme_check_dicos(results_list)
  # give a default names_list is there is none
  if (is.null(names_list)){
    names_list <- as.character(1:length(results_list))
  }

  for(i in 1:length(results_list)){

    for(code in dico_ref$Code){
      results_list[[i]][, code] <- ifelse(results_list[[i]][, code] == FALSE, "", code)
    }
  }

  # binary variables
  codes <- do.call("c", lapply(results_list,
                               create_string_for_comparison, dico_ref))
  codes <- dplyr::bind_cols(codes)
  names(codes) <- names_list

  # times
  imageTime <- results_list[[1]][,"image_time"]

  bigTable <- dplyr::bind_cols(codes,
                         imageTime)

  codes <- purrr::by_row(codes, count_unique_elements2,
                         .collate = "cols", .to = "unique_elements") %>%
    dplyr::select_(~ unique_elements)

  bigTable <- dplyr::bind_cols(bigTable, codes)

  dplyr::filter_(bigTable, lazyeval::interp(~unique_elements > 1)) %>%
    dplyr::select_(quote(- unique_elements))

}
