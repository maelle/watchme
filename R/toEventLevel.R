#' Creates a table with events from the image level annotation information.
#'
#' @importFrom  dplyr tbl_df filter_ mutate_ select_ arrange_ left_join
#' @importFrom lazyeval interp
#' @importFrom lubridate ymd_hms
#' @importFrom tidyr gather
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
#' } event index, , ,  and event_code (character).
#' @examples
#' data('coding_example')
#' event_table <- watchme_aggregate(df = coding_example)
#' event_table
#' event_table2 <- watchme_aggregate(df = coding_example, min_no_pictures = 2)
#' event_table2

#' @export
watchme_aggregate <- function(df, min_no_pictures = 1) {
    # Extract dicoCoding
    dicoCoding <- attr(df, "dico")

    nCodes <- nrow(dicoCoding)

    # Transformation
    df %>%
      mutate_(index = interp(~1:nrow(df))) %>%
      select_(~ image_time,  ~ index, ~ everything()) %>%
      select_(quote(- image_path), quote(- participant_id)) %>%
      gather(event_code, boolean,
             3:(nCodes + 2)) %>%
      filter_(~ boolean) %>%
      mutate_(group = interp(~ c(0, cumsum(diff(index) != 1)) )) %>%
      group_by_(~ event_code,
                ~ group) %>%
      summarize_(start_time = interp(~ min(image_time)),
                 end_time = interp(~ max(image_time)),
                 no_pictures = interp(~ length(image_time)),
                 start_picture = interp(~ min(index)),
                 end_picture = interp(~ max(index))) %>%
      dplyr::left_join(dicoCoding,
                       by = c("event_code" = "Code")) %>%
      select_(~ (- group)) %>%
      mutate_(group = interp(~ Group)) %>%
      select_(~ (- Group)) %>%
      mutate_(meaning = interp(~ as.factor(Meaning))) %>%
      select_(~ (- Meaning)) %>%
      arrange_(~ event_code) %>%
      filter_(interp(~ no_pictures >= min_no_pictures)) %>%
      ungroup()
}
