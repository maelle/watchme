#' An R6 class to store information about images and their code.
#'
#' @docType class
#' @importFrom R6 R6Class
#' @importFrom vegalite vegalite cell_size add_data encode_y encode_color encode_x timeunit_x axis_x axis_y mark_tick "%>%"
#' @importFrom dplyr tbl_df mutate_ group_by_ summarize_ ungroup left_join
#' @importFrom tidyr gather
#' @importFrom lazyeval interp
#' @export
#' @keywords data
#' @return Object of \code{\link{R6Class}}.
#' @format \code{\link{R6Class}} object.
#' @examples
#' pathResults <- system.file("extdata", "image_level_pinocchio.csv", package = "watchme")
#' sepResults <- ","
#' pathDicoCoding <-  system.file("extdata", "dicoCoding_pinocchio.csv", package = "watchme")
#' sepDicoCoding <- ";"
#' wearableCamImagesObject <- convertInput(pathResults=pathResults, sepResults=sepResults,
#'                                         pathDicoCoding=pathDicoCoding, sepDicoCoding=sepDicoCoding)
#' class(wearableCamImagesObject)
#' @field participantID Name or ID number of the participant (character)
#' @field imagePath Path or name of the image in order to be able to identify duplicates (character)
#' @field timeDate Time and date of each image (POSIXt)
#' @field codes annotation(s) given to this image (character), e.g. separated by ','.
#' @field booleanCodes table of boolean, indicating if a given code was given to a given picture. codes is a condensed form of this slot.
#' @field dicoCoding table for defining the codes with at least Code and Meaning column, possibly Group column for having groups of codes (e.g. sport encompasses running and swimming)

wearableCamImages <- R6::R6Class("wearableCamImages",
                        public = list(
                          participantID = "character",
                          imagePath = "character",
                          timeDate = "POSIXt",
                          codes = "character",
                          booleanCodes = "tbl_df",
                          dicoCoding = "tbl_df",
                          initialize = function(participantID,
                                                imagePath,
                                                timeDate,
                                                codes,
                                                booleanCodes,
                                                dicoCoding) {
                            if(any(is.na(c(participantID,
                                             imagePath,
                                             timeDate,
                                             codes,
                                             booleanCodes,
                                             dicoCoding)))){
                              stop("all fields must be known")
                            }
                            self$participantID <- participantID
                            self$imagePath <- imagePath
                            self$timeDate <- timeDate
                            self$codes <- codes
                            self$booleanCodes <- booleanCodes
                            self$dicoCoding <- dicoCoding
                          },
                          plot = function(){
                            plotVegalite(booleanCodes = self$booleanCodes,
                                         timeDate = self$timeDate,
                                         dico = self$dicoCoding)
                          }



                        )
)

##########################################################################
# PLOT METHOD
##########################################################################
# nocov start
plotVegalite <- function(booleanCodes,
                         timeDate,
                         dico){# nolint start
  dataPlot <- cbind(timeDate,
                    booleanCodes)
  dataPlot <- tbl_df(dataPlot) %>%
    gather("code", "value", 2:ncol(dataPlot)) %>%
    filter_(~ value == TRUE) %>%
    mutate_(code = interp(~factor(code, levels = dico$Code,
                         ordered = TRUE))) %>%
    arrange_(~ code) %>%
    left_join(dico, by = c("code" = "Code"))

  p <- vegalite(renderer = "canvas",
                 export = TRUE,
                background = "white") %>%
          cell_size(1000, 800) %>%
          add_data(dataPlot) %>%
          encode_y("code", "nominal",
                   sort = "none") %>%
          encode_color("Group", "nominal") %>%
          encode_x("timeDate", "temporal") %>%
          timeunit_x("yearmonthdayhoursminutesseconds")%>%
          axis_x(title = "Time of day",
                 format="%a, %H:%M",
                 labelAngle=0)  %>%
          axis_y(axisWidth=0,
                 title = "Activity", grid = TRUE)  %>%
          mark_tick(size = 1,
                    thickness = 10, opacity = 1)

 return(p)
}
# nolint end
# nocov end
