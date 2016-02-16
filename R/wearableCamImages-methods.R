#############################################
# participantID
#############################################
#' Accesses participantID
#' @rdname participantID-methods
#' @aliases participantID,participantID-method
#' @param wearableCamImages the wearableCamImages object
#' @exportMethod participantID
setGeneric("participantID", function(wearableCamImages) standardGeneric("participantID"))

#' @rdname participantID-methods
setMethod("participantID", "wearableCamImages", function(wearableCamImages) wearableCamImages@participantID)

##########################################################################################

#############################################
# imagePath
#############################################
#' Accesses imagePath
#' @rdname imagePath-methods
#' @aliases imagePath,imagePath-method
#' @param wearableCamImages the wearableCamImages object
#' @exportMethod imagePath
setGeneric("imagePath", function(wearableCamImages) standardGeneric("imagePath"))

#' @rdname imagePath-methods
setMethod("imagePath", "wearableCamImages", function(wearableCamImages) wearableCamImages@imagePath)

##########################################################################################

#############################################
# timeDate
#############################################
#' Accesses timeDate
#' @rdname timeDate-methods
#' @aliases timeDate,timeDate-method
#' @param wearableCamImages the wearableCamImages object
#' @exportMethod timeDate
setGeneric("timeDate", function(wearableCamImages) standardGeneric("timeDate"))

#' @rdname timeDate-methods
setMethod("timeDate", "wearableCamImages", function(wearableCamImages) wearableCamImages@timeDate)

##########################################################################################

#############################################
# codes
#############################################
#' Accesses codes
#' @rdname codes-methods
#' @aliases codes,codes-method
#' @param wearableCamImages the wearableCamImages object
#' @exportMethod codes
setGeneric("codes", function(wearableCamImages) standardGeneric("codes"))

#' @rdname codes-methods
setMethod("codes", "wearableCamImages", function(wearableCamImages) wearableCamImages@codes)

##########################################################################################

#############################################
# codesBinaryVariables
#############################################
#' Accesses codesBinaryVariables
#' @rdname codesBinaryVariables-methods
#' @aliases codesBinaryVariables,codesBinaryVariables-method
#' @param wearableCamImages the wearableCamImages object
#' @exportMethod codesBinaryVariables
setGeneric("codesBinaryVariables", function(wearableCamImages) standardGeneric("codesBinaryVariables"))

#' @rdname codesBinaryVariables-methods
setMethod("codesBinaryVariables", "wearableCamImages", function(wearableCamImages) wearableCamImages@codesBinaryVariables)

##########################################################################################

#############################################
# dicoCoding
#############################################
#' Accesses dicoCoding
#' @rdname dicoCoding-methods
#' @aliases dicoCoding,dicoCoding-method
#' @param wearableCamImages the wearableCamImages object
#' @exportMethod dicoCoding
setGeneric("dicoCoding", function(wearableCamImages) standardGeneric("dicoCoding"))

#' @rdname dicoCoding-methods
setMethod("dicoCoding", "wearableCamImages", function(wearableCamImages) wearableCamImages@dicoCoding)

##########################################################################################
