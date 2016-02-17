#' An R6 class to store information about images and their code.
#'
#' @docType class
#' @importFrom R6 R6Class
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
                          booleanCodes = "data.frame",
                          dicoCoding = "data.frame",
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
                          }


                        )
)
