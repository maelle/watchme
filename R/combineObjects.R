#' Combine objects with same pictures but different codes
#'
#' @importFrom dplyr tbl_df mutate_ group_by_ summarize_ ungroup
#' @importFrom lazyeval interp
#' @param results_list a list of \code{tibble}  created by \code{watchme_prepare_data}.
#' @param common_codes One or several codes that are common between the objects.
#'
#' @return A \code{tibble} with
#' \itemize{
#' \item participantID Name or ID number of the participant (character)
#' \item image_time Path or name of the image in order to be able to identify duplicates (character)
#' \item image_time Time and date of each image (POSIXt)
#' \item booleanCodes columns of boolean, indicating if a given code was given to a given picture. codes is a condensed form of this.
#' \item the attribute \code{dico} \code{tibble} for defining the codes with at least Code and Meaning column, possibly Group column for having groups of codes (e.g. sport encompasses running and swimming)
#' }
#' @details The motivation was to create a single object based on several coding files
#' in the CHAI project: each pass/group of codes such as cooking and travel resulted
#'  in one file,
#' and we want to combine them.
#'
#' For\code{common_codes} codes, the annotation are merged: if an image has such a code in an object
#' and not in the other, the code is assigned to the image in the resulting object.
#' The code does not look for conflicts.
#'
#' @examples
#' library("dplyr")
#' passes <- c("CK", "IO", "OP", "PM", "TP")
#'
#' create_pass_results <- function(pass){
#'   path_results <- system.file('extdata', paste0("oneday_", pass, ".csv"),
#'   package = 'watchme')
#'   sep_results <- "\t"
#'   path_dico <-  system.file('extdata', paste0("dico_coding_2016_01_", pass, ".csv"),
#'    package = 'watchme')
#'   sep_dico <- ';'
#'
#'   results <- watchme_prepare_data(path_results = path_results,
#'                                   sep_results = sep_results,
#'                                   path_dico = path_dico,
#'                                   sep_dico = sep_dico,
#'                                   tz = "Asia/Kolkata")
#'   results$image_path <- gsub('\"', "", results$image_path)
#'   results
#' }
#'
#' results_list <- passes %>% purrr::map(create_pass_results)
#' oneday_results <- watchme_combine_results(results_list,
#' common_codes = "non_codable")
#' oneday_results
#' @export
#'


watchme_combine_results <- function(results_list,
                           common_codes = c("non codable")){
  ########################################################
  # check they have the same length and times
  ########################################################

  watchme_check_list(results_list)


  ########################################################
  # create a dico
  ########################################################
  dico <- unique(do.call("rbind",
                        lapply(results_list,
                               get_dico)))

  ########################################################
  # join
  ########################################################
  df <-  Reduce(function(df1, df2){
      df <- dplyr::left_join(df1, df2, by = c("image_path", "image_time", "participant_id"))

      for(code in common_codes){
        df[, code] <- df1[, code]|df2[, code]
        df <- dplyr::select_(df, paste0("-", code, ".x"), paste0("-", code, ".y"))
      }
     df
    }, results_list)

  attr(df, "dico") <- dico
  return(df)
}

get_dico <- function(df){
  attr(df, "dico")
}
