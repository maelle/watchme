#' Outputs images for which codes are different among coders
#'
#' @importFrom dplyr tbl_df mutate_ arrange_ group_by_ left_join filter_ summarize_
#' @importFrom tidyr gather spread
#' @param wearableCamImagesList a list of \code{wearableCamImages} objects.
#' @param namesList (optional) a vector of names for the coders. It must be the same length as wearableCamImagesList
#' and contains different names.
#'
#' @return A \code{tbl_df} with image name, image time, and one column for each coder.
#' @examples
#' \dontrun{
#' data(IO1)
#' data(IO2)
#' listObjects <- list(IO1, IO2)
#' namesList <- c("coder1", "coder2")
#' outputDifferences(listObjects, namesList)
#' }
#' @export
#'
outputDifferences <- function(wearableCamImagesList, namesList=NULL){
  # some sanity checks, see utils.R
  checkList(wearableCamImagesList = wearableCamImagesList,
            namesList = namesList)
  # give a default namesList is there is none
  if (is.null(namesList)){
    namesList <- as.character(1:length(wearableCamImagesList))
  }

  # binary variables
  codes <- do.call("c", lapply(wearableCamImagesList,
                                   "[[", "codes"))
  # times
  imageTime <- do.call("c", lapply(wearableCamImagesList,
                      "[[", "timeDate"))
  # coders names
  coders <- do.call("c",lapply(namesList,
                               rep,
                 nrow(wearableCamImagesList[[1]]$booleanCodes)))

  bigTable <- data.frame(codes,
                         imageTime,
                         coders)
  bigTable <- tbl_df(bigTable)
  # find lines with differences
  tableImages <- bigTable %>%
    arrange_(~ imageTime) %>%
    group_by_(~ imageTime) %>%
    summarize_(unique = interp(~ length(unique(codes)))) %>%
    filter_(interp(~unique > 1)) %>%
  # now get one line with codes from each coder
    left_join(bigTable, by = "imageTime") %>%
    mutate_(codes = interp(~ gsub("\\, ", "", codes))) %>%
    spread(coders, codes)

return(tableImages)
}
