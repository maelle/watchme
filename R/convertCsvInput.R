#' Creates a wearableCamImages object from information read in a csv file.
#'
#' @importFrom lubridate ymd_hms mdy_hms
#' @importFrom dplyr tbl_df mutate_ group_by_ summarize_ ungroup
#' @importFrom tidyr gather
#' @importFrom lazyeval interp
#' @param path_results the path to the file with coding results
#' @param sep_results the separator in the file with coding results
#' @param path_dico the path to the file with the list of annotations
#' @param sep_dico the separator in the file with the list of annotations
#' @param tz timezone
#' @param quote_sign the quote argument of read.table for the results, default is "\'"
#' @param participant_id participant ID, if available.
#' @return A \code{tibble} with
#' \itemize{
#' \item participant_id Name or ID number of the participant (character)
#' \item image_time Path or name of the image in order to be able to identify duplicates (character)
#' \item image_time Time and date of each image (POSIXt)
#' \item booleanCodes columns of boolean, indicating if a given code was given to a given picture. codes is a condensed form of this.
#' \item the attribute \code{dico} \code{tibble} for defining the codes with at least Code and Meaning column, possibly Group column for having groups of codes (e.g. sport encompasses running and swimming)
#' }
#' @details
#' Please check the format that both files should have by looking at the provided
#' example data.
#' However you could consider write your own function for converting the input
#' instead of having to re-format all your existing data,
#' which we could even add to the package.
#' @examples
#' path_results <- system.file('extdata', 'image_level_pinocchio.csv', package = 'watchme')
#' sep_results <- ','
#' path_dico <-  system.file('extdata', 'dicoCoding_pinocchio.csv', package = 'watchme')
#' sep_dico <- ';'
#' data_pictures <- watchme_prepare_data(path_results=path_results, sep_results=sep_results,
#'               path_dico=path_dico, sep_dico=sep_dico)
#' data_pictures
#' attr(data_pictures, "dico")

#' @export
watchme_prepare_data <- function(path_results, sep_results,
                                 quote_sign = "\'",
                                 participant_id = "no_id",
                                 path_dico, sep_dico,
                                 tz = "Asia/Kolkata") {

    ########################################################
    # Get dico coding
    ########################################################
    dico <- read.csv(path_dico, sep = sep_dico, header = TRUE)
    dico <- dplyr::mutate_each_(dico, dplyr::funs_("tolower"),
                                      c("Code", "Meaning", "Group"))

    dico <- dplyr::mutate_each_(dico, dplyr::funs_("gsub", args = list(pattern = " ",
                                                                       replacement = "_")),
                                c("Code", "Meaning", "Group"))

    ########################################################
    # open results
    ########################################################

    resultsCoding <- read.table(path_results, sep = sep_results,
                                header = TRUE, quote = quote_sign)



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

    # replace spaces by "_"
    resultsCoding <- dplyr::mutate_(resultsCoding,
                                    annotation = lazyeval::interp(~gsub(" ", "_", annotation)))
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

    codes <- dico$Code

    resultsCoding <- resultsCoding %>%
      dplyr::bind_cols(purrr::invoke_map(grep_code, codes,
                                         df = resultsCoding) %>%
                         dplyr::bind_cols()) %>%
      dplyr::select_(quote(- annotation)) %>%
      dplyr::arrange_(~image_time)

    ########################################################
    # Done!
    ########################################################

    attr(resultsCoding, "dico") <- dico
    return(resultsCoding)
}



grep_code <- function(df, code){
  mutateCall <- lazyeval::interp( ~ grepl(pattern = code, annotation))
  df %>% dplyr::mutate_(.dots = setNames(list(mutateCall),
                                         code)) %>%
    dplyr::select_(~dplyr::matches(code))
}

eliminate_spaces <- function(x){
  gsub(" ", "_", x)
}
