#' Combine objects with same pictures but different codes
#'
#' @importFrom dplyr tbl_df mutate_ group_by_ summarize_ ungroup
#' @importFrom tidyr gather
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
#' @export
#'
#' @examples
#' data(listWM)
#' object <- watchme_combine_results(listWM, common_codes = c("non codable"))
watchme_combine_results <- function(results_list,
                           common_codes = c("non codable")){
  ########################################################
  # check they have the same length and times
  ########################################################

  lengthRef <- nrow(results_list[[1]])
  lengthsCodes <- vapply(results_list, nrow, 1)
  if (any(lengthsCodes != lengthRef)){
    stop("There should be the same number of pictures in each wearableCamImages object!")# nolint
  }

  times <- do.call("cbind", lapply(results_list,
                                   "[[", "image_time"))
  if(any(lapply(apply(times,1, unique), length) > 1)){
    stop("All objects should have the same imageTime field, at least one difference here!")# nolint
  }


  ########################################################
  # create a dico
  ########################################################
  dico <- unique(do.call("rbind",
                        lapply(results_list,
                               "[[", "dico")))

  ########################################################
  # join
  ########################################################
  df <- results_list %>%
    Reduce(function(df1, df2){
      left_join(dtf1, dtf2, by = c("image_path", "image_time", "participant_id"))
    }, .)

  attr(df, "dico") <- dico
  return(df)
}
