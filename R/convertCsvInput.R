#' Creates a wearableCamImages object from information read in a csv file.
#'
#' @importFrom lubridate ymd_hms mdy_hms
#' @importFrom dplyr tbl_df mutate_ group_by_ summarize_ ungroup
#' @importFrom tidyr gather
#' @importFrom lazyeval interp
#' @param pathResults the path to the file with coding results
#' @param sepResults the separator in the file with coding results
#' @param pathDicoCoding the path to the file with the list of annotations
#' @param sepDicoCoding the separator in the file with the list of annotations
#' @param tz timezone
#' @param quoteSign the quote argument of read.table for the results, default is "\'"
#' @return A \code{tibble} with
#' \itemize{
#' \item participantID Name or ID number of the participant (character)
#' \item image_time Path or name of the image in order to be able to identify duplicates (character)
#' \item image_time Time and date of each image (POSIXt)
#' \item booleanCodes columns of boolean, indicating if a given code was given to a given picture. codes is a condensed form of this.
#' \item the attribute \code{dicoCoding} \code{tibble} for defining the codes with at least Code and Meaning column, possibly Group column for having groups of codes (e.g. sport encompasses running and swimming)
#' }
#' @details
#' Please check the format that both files should have by looking at the provided
#' example data.
#' However you could consider write your own function for converting the input
#' instead of having to re-format all your existing data,
#' which we could even add to the package.
#' @examples
#' pathResults <- system.file('extdata', 'image_level_pinocchio.csv', package = 'watchme')
#' sepResults <- ','
#' pathDicoCoding <-  system.file('extdata', 'dicoCoding_pinocchio.csv', package = 'watchme')
#' sepDicoCoding <- ';'
#' data_pictures <- watchme_prepare_data(pathResults=pathResults, sepResults=sepResults,
#'               pathDicoCoding=pathDicoCoding, sepDicoCoding=sepDicoCoding)
#' class(wearableCamImagesObject)

#' @export
watchme_prepare_data <- function(pathResults, sepResults, quoteSign = "\'",
                         participant_id = "no_id",
                         pathDicoCoding, sepDicoCoding,
                         tz = "Asia/Kolkata") {
    ########################################################
    # Get dico coding
    ########################################################
    dicoCoding <- read.csv(pathDicoCoding, sep = sepDicoCoding, header = TRUE)
    dicoCoding <- dplyr::mutate_each_(dicoCoding, dplyr::funs_("tolower"),
                                      c("Code", "Meaning", "Group"))

    ########################################################
    # open results
    ########################################################
    resultsCoding <- read.table(pathResults, sep = sepResults,
                                header = TRUE, quote = quoteSign)


    # When it comes from XnView MP, wrong names
    if(grepl("Filename", names(resultsCoding)[1])){
      names(resultsCoding) <- c("image_path",
                                "image_time",
                                "annotation")
      resultsCoding <- resultsCoding[,1:3]
    }
    # keep only rows with image_path
    resultsCoding <- dplyr::filter(resultsCoding, image_path!= "")


    # if several rows for one image, merge annotation
    resultsCoding <- resultsCoding %>%
      group_by_(~ image_path,~ image_time) %>%  # nolint
      summarize_(annotation = interp(~ toString(annotation))) %>%
      ungroup()

    resultsCoding <- dplyr::mutate_(resultsCoding,
                             participant_id = ~participant_id)

    ########################################################
    # convert time date
    ########################################################

    resultsCoding <-mutate_(resultsCoding,
                            image_time = lazyeval::interp(~lubridate::parse_date_time(
                              as.character(image_time), tz = tz,
                              orders = c("ymd_hms", "mdy_hms"))))

    ########################################################
    # Find all codes
    ########################################################
    # create empty vector
    resultsCoding <- mutate_(resultsCoding,
                             annotation = lazyeval::interp(~tolower(annotation)))

    ########################################################
    # then first I create the table with binary variables
    ########################################################
    # one column for each possible code,
    # one line for each picture

    codes <- dicoCoding$Code

    resultsCoding <- resultsCoding %>%
      dplyr::bind_cols(purrr::invoke_map(grep_code, codes,
                                         df = resultsCoding) %>%
                         dplyr::bind_cols()) %>%
      dplyr::select_(quote(- annotation)) %>%
      dplyr::arrange_(~image_time)

    ########################################################
    # Done!
    ########################################################

    attr(resultsCoding, "dicoCoding") <- dicoCoding
    return(resultsCoding)
}



grep_code <- function(df, code){
  mutateCall <- lazyeval::interp( ~ grepl(pattern = code, annotation))
  df %>% dplyr::mutate_(.dots = setNames(list(mutateCall),
                                         code)) %>%
    dplyr::select_(~dplyr::matches(code))
}
