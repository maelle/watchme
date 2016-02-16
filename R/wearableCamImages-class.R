#' An S4 class to store information about images and their code.
#' @importFrom methods setClass
#' @name wearableCamImages-class
#' @rdname wearableCamImages-class
#'
#' @slot participantID Name or ID number of the participant (character)
#' @slot imagePath Path or name of the image in order to be able to identify duplicates (character)
#' @slot timeDate Time and date of each image (POSIXt)
#' @slot codes annotation(s) given to this image (character), e.g. separated by ';'.
#' @slot codesBinaryVariables table of boolean, indicating if a given code was given to a given picture. \code{codes} is a condensed
#' form of this slot.
#' @slot dicoCoding table for defining the codes with at least Code and Meaning column, possibly Group column for having groups of codes (e.g. sport encompasses running and swimming)
#'
#' @exportClass wearableCamImages
#'
wearableCamImages <- setClass("wearableCamImages",
                              slots = c(participantID = "character",
                                        imagePath = "character",
                                        timeDate = "POSIXt",
                                        codes = "character",
                                        codesBinaryVariables = "data.frame",
                                        dicoCoding = "data.frame"))



