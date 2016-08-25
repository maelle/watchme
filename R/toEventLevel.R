#' Creates a table with events from the image level annotation information.
#'
#' @importFrom  dplyr tbl_df filter_ mutate_ select_ arrange_ left_join %>%
#' @importFrom lazyeval interp
#' @importFrom lubridate ymd_hms
#' @param df the data created by using \code{watchme_prepare_data}
#' @param min_no_pictures the minimal number of images for defining an event. Default is 1.
#' @return A \code{tbl_df} with
#' \itemize{
#' \item event code
#' \item start time (POSIXt)
#' \item end time (POSIXt)
#' \item no of pictures in the event
#' \item index of the first picture in the event
#' \item index of the last picture in the event
#' \item group of the code
#' \item meaning of the code
#' \item duration of the event in seconds
#' \item the attribute \code{dico} \code{tibble} for defining the codes with at least Code and Meaning column, possibly Group column for having groups of codes (e.g. sport encompasses running and swimming)
#' } event index, , ,  and event_code (character).
#' @examples
#' data('coding_example')
#' event_table <- watchme_aggregate(df = coding_example)
#' event_table
#' event_table2 <- watchme_aggregate(df = coding_example, min_no_pictures = 2)
#' event_table2

#' @export
watchme_aggregate <- function(df, min_no_pictures = 1) {
    # Extract dico
  dico <- attr(df, "dico")

    nCodes <- nrow(dico)

    # Transformation
    df <- df %>%
      dplyr::mutate_(index = interp(~1:nrow(df))) %>%
      dplyr::select_(~ image_time,  ~ index, ~ dplyr::everything()) %>%
      dplyr::select_(quote(- image_path), quote(- participant_id))
    df <- suppressWarnings(tidyr::gather_(df, "event_code", "boolean",
                     dico$Code)) %>%
      dplyr::filter_(~ boolean) %>%
      dplyr::mutate_(group = interp(~ c(0, cumsum(diff(index) != 1)) )) %>%
      dplyr::group_by_(~ event_code,
                ~ group) %>%
      dplyr::summarize_(start_time = interp(~ min(image_time)),
                 end_time = interp(~ max(image_time)),
                 no_pictures = interp(~ length(image_time)),
                 start_picture = interp(~ min(index)),
                 end_picture = interp(~ max(index))) %>%
      dplyr::left_join(dico,
                       by = c("event_code" = "Code")) %>%
      dplyr::select_(~ (- group)) %>%
      dplyr::mutate_(group = interp(~ Group)) %>%
      dplyr::select_(~ (- Group)) %>%
      dplyr::mutate_(meaning = interp(~ as.factor(Meaning))) %>%
      dplyr::select_(~ (- Meaning)) %>%
      dplyr::arrange_(~ event_code) %>%
      dplyr::filter_(interp(~ no_pictures >= min_no_pictures)) %>%
      dplyr::ungroup()%>%
      dplyr::mutate_(duration = lazyeval::interp(~as.numeric(difftime(end_time,
                                                                     start_time,
                                                                     units = "secs"))))

    attr(df, "dico") <- dico

    df
}
