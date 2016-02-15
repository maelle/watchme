library("watchme")
library("lubridate")
library("dplyr")
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

test_that("convertInput works with XnView outputs as well", {
  pathResults <- system.file("extdata", "sample_IO_02.csv", package = "watchme")
  sepResults <- "\t"
  pathDicoCoding <-  system.file("extdata", "dico_coding_2016_01_IO.csv", package = "watchme")
  sepDicoCoding <- ";"
  wearableCamImagesObject <- convertInput(pathResults=pathResults, sepResults=sepResults,
                                          pathDicoCoding=pathDicoCoding, sepDicoCoding=sepDicoCoding)
  expect_that(wearableCamImagesObject, is_a("wearableCamImages"))
})

