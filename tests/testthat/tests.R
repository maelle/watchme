library("watchme")
library("lubridate")
library("dplyr")
library("ggplot2")
library("irr")
#################################################################################################
context("convertInput")
#################################################################################################

test_that("convertInput outputs a wearableCameraImages object", {
  pathResults <- system.file("extdata", "image_level_pinocchio.csv", package = "watchme")
  sepResults <- ","
  pathDicoCoding <-  system.file("extdata", "dicoCoding_pinocchio.csv", package = "watchme")
  sepDicoCoding <- ";"
  wearableCamImagesObject <- convertInput(pathResults=pathResults, sepResults=sepResults,
                                          pathDicoCoding=pathDicoCoding, sepDicoCoding=sepDicoCoding)
  expect_that(wearableCamImagesObject, is_a("wearableCamImages"))

})



#################################################################################################
context("toEventLevel")
#################################################################################################

test_that("toEventLevel outputs a data table", {
  data("dummyWearableCamImages")
  eventTable <- toEventLevel(wearableCamImagesObject=dummyWearableCamImages)

  expect_that(eventTable, is_a("tbl_df"))

})

test_that("the dates in toEventLevel are not invented or shifted", {
  data("dummyWearableCamImages")
  eventTable <- toEventLevel(wearableCamImagesObject=dummyWearableCamImages)

  expect_that(sum(eventTable$startTime%in%dummyWearableCamImages@timeDate), equals(nrow(eventTable)))
  expect_that(sum(eventTable$endTime%in%dummyWearableCamImages@timeDate), equals(nrow(eventTable)))
})


test_that("toEventLevel outputs a data table with the right variables", {
  data("dummyWearableCamImages")
  eventTable <- toEventLevel(wearableCamImagesObject=dummyWearableCamImages)

  expect_that(names(eventTable), equals(c("eventIndex", "startTime", "endTime",
                                          "eventCode",  "noOfPictures", "activity",
                                          "group", "startPicture", "endPicture")))

})

#################################################################################################
context("summaryEventTable")
#################################################################################################

test_that("summaryEventTable outputs a data table", {
  data("dummyWearableCamImages")
  eventTable <- toEventLevel(wearableCamImagesObject=dummyWearableCamImages)
  summaryTable <- summaryEventTable(eventTable)
  expect_that(summaryTable, is_a("tbl_df"))

})

test_that("summaryEventTable outputs columns with the right classes", {
  data("dummyWearableCamImages")
  eventTable <- toEventLevel(wearableCamImagesObject=dummyWearableCamImages)
  summaryTable <- summaryEventTable(eventTable)
  expect_that(summaryTable$activity, is_a("factor"))
  expect_that(summaryTable$noOfEvents, is_a("integer"))
  expect_that(summaryTable$meanNoOfPictures, is_a("numeric"))
  expect_that(summaryTable$meanDuration, is_a("numeric"))

})

#################################################################################################
context("bindCoders")
#################################################################################################
test_that("bindCoders outputs a data table", {
  data("dummyWearableCamImages")
  output <- bindCoders(list(dummyWearableCamImages, dummyWearableCamImages), minDuration = 1)
  expect_that(output, is_a("tbl_df"))

})

test_that("bindCoders uses namesList well", {
  data("dummyWearableCamImages")

  expect_that(bindCoders(list(dummyWearableCamImages, dummyWearableCamImages), namesList="theOnlyOne"),
              throws_error("Not as many names as wearableCamImages objects"))

  expect_that(bindCoders(list(dummyWearableCamImages, dummyWearableCamImages),
                         namesList=c("theOnlyOne", "theOnlyOne")),
              throws_error("Please provide unique names for the coders"))

  output <- bindCoders(list(dummyWearableCamImages, dummyWearableCamImages),
                       namesList=c("Cain", "Abel"))
  expect_that(levels(output$coder), equals(c("Cain", "Abel")))

})
#################################################################################################
context("plotSequence")
#################################################################################################
test_that("plotSequence defines the x-axis as it should", {
  data("dummyWearableCamImages")
  eventTable <- toEventLevel(wearableCamImagesObject=dummyWearableCamImages)
  p <- plotSequence(eventTable)
  expect_that(grepl("Time", toString(p$layers[[1]]$mapping)), equals(TRUE))
  p <- plotSequence(eventTable, xAxis="picture")
  expect_that(grepl("Picture", toString(p$layers[[1]]$mapping)), equals(TRUE))
  p <- plotSequence(eventTable, xAxis="time")
  expect_that(grepl("Time", toString(p$layers[[1]]$mapping)), equals(TRUE))
})


test_that("plotSequence does facetting as it should", {
  data("dummyWearableCamImages")

  # no facetting
  eventTable <- toEventLevel(wearableCamImagesObject=dummyWearableCamImages)
  p <- plotSequence(eventTable)
  expect_that(p$facet, is_a("null"))

  # facetting only for the group
  p <- plotSequence(eventTable, facettingGroup=TRUE)
  expect_that(names(p$facet$rows), equals("group"))
  expect_that(toString(names(p$facet$cols)), equals(""))

  eventTableCoders <- bindCoders(list(dummyWearableCamImages, dummyWearableCamImages), minDuration = 1)
  # facetting only for the coder
  p <- plotSequence(eventTableCoders, facettingGroup = FALSE, facettingCoder = TRUE)
  expect_that(names(p$facet$rows), equals("coder"))
  expect_that(toString(names(p$facet$cols)), equals(""))

  # facetting for both group and coder
  p <- plotSequence(eventTableCoders, facettingGroup = TRUE, facettingCoder = TRUE)
  expect_that(names(p$facet$rows), equals("coder"))
  expect_that(names(p$facet$cols), equals("group"))

  # facetting for coders when no coder
  expect_that(plotSequence(eventTable, facettingCoder=TRUE),
              throws_error("You can't facet by coder if you do not have several coders"))

})

#################################################################################################
context("irrWatchme")
#################################################################################################
test_that("irrWatchme uses namesList well", {
  data("dummyWearableCamImages")

  expect_that(irrWatchme(list(dummyWearableCamImages, dummyWearableCamImages), namesList="theOnlyOne"),
              throws_error("Not as many names as wearableCamImages objects"))

  expect_that(irrWatchme(list(dummyWearableCamImages, dummyWearableCamImages),
                         namesList=c("theOnlyOne", "theOnlyOne")),
              throws_error("Please provide unique names for the coders"))

  expect_that(irrWatchme(list(dummyWearableCamImages, dummyWearableCamImages)),
                         is_a("tbl_df"))

})

test_that("irrWatchme checks comparability",{
  data("dummyWearableCamImages")
  dummyWearableCamImages2 <- dummyWearableCamImages
  dummyWearableCamImages2@codes <- dummyWearableCamImages@codes[1:10]
  expect_error(irrWatchme(list(dummyWearableCamImages, dummyWearableCamImages2)),
               "There should be the same number of pictures in each wearableCamImages object!")

  dummyWearableCamImages2 <- dummyWearableCamImages
  dummyWearableCamImages2@dicoCoding <- dummyWearableCamImages@dicoCoding[1:6,]
  expect_error(irrWatchme(list(dummyWearableCamImages, dummyWearableCamImages2)),
               "All wearableCamImages objects should have the same dicoCoding!")
})

test_that("irrWatchme outputs the right type of results depending on the options",{
  data("dummyWearableCamImages")

  listWC <- list(dummyWearableCamImages, dummyWearableCamImages)
  namesList <- c("Cain", "Abel")

  output <- irrWatchme(listWC, namesList=namesList)

  expect_that(output, is_a("tbl_df"))
  expect_that(dim(output), equals(c(1,8)))
  expect_that(names(output), equals(c( "method", "pictures", "agreedOn", "raters", "ratersNames", "Kappa",
                                       "z" , "pValue"  )))
  expect_that(as.character(output$method), equals("Cohen's Kappa for 2 Raters (Weights: unweighted)"))

  listWC2 <- list(dummyWearableCamImages, dummyWearableCamImages, dummyWearableCamImages)
  namesList <- c("Riri", "Fifi", "Loulou")
  output <- irrWatchme(listWC2, namesList=namesList)
  expect_that(output, is_a("tbl_df"))
  expect_that(dim(output), equals(c(1,8)))
  expect_that(names(output), equals(c( "method", "pictures", "agreedOn", "raters", "ratersNames", "Kappa",
                                       "z" , "pValue"  )))
  expect_that(as.character(output$method), equals("Fleiss' Kappa for m Raters"))

  output <- irrWatchme(listWC2, namesList=namesList, oneToOne=TRUE)
  expect_that(output, is_a("tbl_df"))
  expect_that(names(output), equals(c( "method", "pictures", "agreedOn", "rater1", "rater2",
                                       "Kappa",
                                       "z" , "pValue"  )))
  expect_that(as.character(output$method[1]), equals("Cohen's Kappa for 2 Raters (Weights: unweighted)"))

  output <- irrWatchme(listWC, namesList=c("Cain", "Abel"), byCode=TRUE)
  expect_that(output, is_a("list"))
  expect_that(length(output), equals(ncol(dummyWearableCamImages@codesBinaryVariables)))
  expect_that(dim(output[[1]]), equals(c(1,10)))
#   expect_that(names(output[[1]]), equals(c( "method", "pictures", "agreedOn", "raters", "ratersNames", "Kappa",
#                                        "z" , "pValue"  )))
  expect_that(as.character(output[[1]]$method), equals("Cohen's Kappa for 2 Raters (Weights: unweighted)"))

  output <- irrWatchme(listWC, namesList=c("Cain", "Abel"), byGroup=TRUE)
  expect_that(output, is_a("list"))
  expect_that(length(output), equals(length(levels(factor(dummyWearableCamImages@dicoCoding$Group)))))
  expect_that(dim(output[[1]]), equals(c(1,8)))
  expect_that(names(output[[1]]), equals(c( "method", "pictures", "agreedOn", "raters", "ratersNames", "Kappa",
                                            "z" , "pValue"  )))
  expect_that(as.character(output[[1]]$method), equals("Cohen's Kappa for 2 Raters (Weights: unweighted)"))
})

test_that("irrWachme outputs an error if there is only one file",{
  expect_error(irrWatchme(list(dummyWearableCamImages)), "Do not bother using this function if you only have one wearableCamImages object.")
})
#################################################################################################
context("combineObjects")
#################################################################################################
test_that("combineObjects outputs a wearableCameraImages object", {
  data("dummyWearableCamImages")
  wearableCamImagesList <- list(dummyWearableCamImages, dummyWearableCamImages)
  wearableCamImagesObject <- combineObjects(wearableCamImagesList)
  expect_that(wearableCamImagesObject, is_a("wearableCamImages"))
})
