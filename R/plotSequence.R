#' Creates a table with events from the image level annotation information.
#'
#' @import ggplot2
#' @param eventTable a table of events created with the\code{toEventLevel} function (or having the same structure).
#' @param doNotUseCode a vector of codes that you do not want to see on the graph, e.g. if you have both codes
#' for categories and subcategories you may want to not plot categories.
#' @param xAxis either "time" or "picture" index as x axis variable.
#' @param facettingGroup boolean indicating whether there should be one plot per group of activities
#'  (as defined in the dicoCoding)
#' @param facettingCoder boolean indicating whether there should be one plot per coder
#'  (use only if you have a coder column!)
#' @param dicoCoding (optional) if you want consistent color definitons across several event tables, please provide the dicoCoding.
#' @param cbbPaletteYes boolean if dicoCoding provided and >=7 different activities, you can opt for a colorblind-friendly palette.
#' @return A \code{ggplot2} graph.
#' @examples
#' data("dummyWearableCamImages")
#' library("ggplot2")
#' eventTable <- toEventLevel(wearableCamImagesObject=dummyWearableCamImages)
#' plotSequence(eventTable)
#' plotSequence(eventTable, xAxis="picture", facettingGroup=TRUE)
#' eventTableCoders <- bindCoders(list(dummyWearableCamImages, dummyWearableCamImages), minDuration = 1)
#' plotSequence(eventTableCoders, facettingGroup = TRUE, facettingCoder = TRUE,
#' dicoCoding=dummyWearableCamImages@dicoCoding)
#' @export
plotSequence <- function(eventTable, doNotUseCode = NULL,
                         xAxis="time", facettingGroup=FALSE,
                         facettingCoder=FALSE, dicoCoding=NULL,
                         cbbPaletteYes=TRUE){

  if (!"coder" %in% names(eventTable) & facettingCoder == TRUE){
    stop("You can't facet by coder if you do not have several coders")
    }

  # The palette with black:
  cbbPalette <- c("#000000", "#E69F00", "#56B4E9", "#009E73",
                  "#0072B2", "#D55E00", "#CC79A7")


  p <- ggplot(eventTable[!eventTable$eventCode %in% doNotUseCode,])

  if (xAxis == "time"){
   p <- p + geom_rect(aes(xmin = startTime, xmax = endTime,
                  ymin = 0, ymax = 2, fill=activity, colour=activity),
              alpha = 1)
  }

  if (xAxis == "picture"){
    p <- p + geom_rect(aes(xmin = startPicture, xmax = endPicture,
                           ymin = 0, ymax = 2, fill=activity, colour=activity),
                       alpha = 1)
  }

  if(!is.null(dicoCoding)){
    if(cbbPaletteYes){
      p <- p + scale_fill_manual(drop=TRUE,
                                 limits = levels(dicoCoding$Meaning),
                                 values=cbbPalette) +
        scale_colour_manual(drop=TRUE,
                            limits = levels(dicoCoding$Meaning),
                            values=cbbPalette)
    }
   else{
     p <- p + scale_fill_manual(drop=TRUE,
                                limits = levels(dicoCoding$Meaning)) +
       scale_colour_manual(drop=TRUE,
                           limits = levels(dicoCoding$Meaning))
   }
  }


  p <- p +  theme(axis.line.y=element_blank(),axis.ticks.y=element_blank(),
          axis.text.y=element_blank(),
          panel.grid.minor.y=element_blank(),
          panel.grid.major.y=element_blank())

  if(facettingGroup & !facettingCoder){
    p <- p + facet_grid(group ~ .)
  }

  if(!facettingGroup & facettingCoder){
    p <- p + facet_grid(coder ~ .)
  }

  if(facettingGroup & facettingCoder){
    p <- p + facet_grid(coder ~ group)
    }

  return(p)

}
