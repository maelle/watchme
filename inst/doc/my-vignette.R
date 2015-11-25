## ------------------------------------------------------------------------
pathDicoCoding <-  system.file("extdata", "dicoCoding_pinocchio.csv", package = "watchme")
sepDicoCoding <- ";"
dicoCoding <- read.table(pathDicoCoding, sep=sepDicoCoding, header=TRUE)
head(dicoCoding)

## ---- warning=FALSE, message=FALSE---------------------------------------
library("dplyr")
pathResults <- system.file("extdata", "image_level_pinocchio.csv", package = "watchme")
sepResults <- ","
codingResults <- read.table(pathResults, sep=sepResults, header=TRUE)
codingResults <- dplyr::tbl_df(codingResults)
print(codingResults)

## ---- warning=FALSE, message=FALSE---------------------------------------
library("watchme")
pathResults <- system.file("extdata", "image_level_pinocchio.csv", package = "watchme")
sepResults <- ","
pathDicoCoding <-  system.file("extdata", "dicoCoding_pinocchio.csv", package = "watchme")
sepDicoCoding <- ";"
wearableCamImagesObject <- convertInput(pathResults=pathResults, sepResults=sepResults,
              pathDicoCoding=pathDicoCoding, sepDicoCoding=sepDicoCoding)
class(wearableCamImagesObject)

## ---- warning=FALSE, message=FALSE---------------------------------------
data("dummyWearableCamImages")
eventTable <- toEventLevel(wearableCamImagesObject=dummyWearableCamImages)
eventTable
eventTable2 <- toEventLevel(wearableCamImagesObject=dummyWearableCamImages, minDuration = 2)
eventTable2

## ---- warning=FALSE, message=FALSE, fig.width=10-------------------------
data("dummyWearableCamImages")
library("ggplot2")
eventTable <- toEventLevel(wearableCamImagesObject=dummyWearableCamImages)
plotSequence(eventTable)
plotSequence(eventTable, xAxis="picture", facettingGroup=TRUE)




## ---- warning=FALSE, message=FALSE, fig.width=10-------------------------
eventTableCoders <- bindCoders(list(dummyWearableCamImages, dummyWearableCamImages), minDuration = 1)
plotSequence(eventTableCoders, facettingGroup = TRUE, facettingCoder = TRUE,
dicoCoding=dummyWearableCamImages@dicoCoding)

## ---- warning=FALSE, message=FALSE, fig.width=10-------------------------
library("xtable")
data("dummyWearableCamImages")
listWC <- list(dummyWearableCamImages, dummyWearableCamImages)
namesList <- c("Cain", "Abel")
irrWatchme(listWC, namesList=namesList)

## ---- warning=FALSE, message=FALSE, fig.width=10-------------------------
irrWatchme(listWC, namesList=c("Cain", "Abel"), oneToOne=TRUE, byGroup=TRUE)

## ---- warning=FALSE, message=FALSE, fig.width=10-------------------------
irrWatchme(listWC, namesList=c("Cain", "Abel"), oneToOne=TRUE, byCode=TRUE)

## ---- warning=FALSE, message=FALSE, fig.width=10-------------------------
listWC2 <- list(dummyWearableCamImages, dummyWearableCamImages, dummyWearableCamImages)
namesList <- c("Riri", "Fifi", "Loulou")
irrWatchme(listWC2, namesList=namesList)
irrWatchme(listWC2, namesList=namesList, oneToOne=TRUE)


