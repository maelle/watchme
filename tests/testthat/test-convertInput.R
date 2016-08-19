library("watchme")
library("lubridate")
library("dplyr")
#################################################################################################
context("convertInput")
#################################################################################################

test_that("watchme_prepare_data outputs a tibble", {
  pathResults <- system.file("extdata", "image_level_pinocchio.csv", package = "watchme")
  sepResults <- ","
  pathDicoCoding <-  system.file("extdata", "dicoCoding_pinocchio.csv", package = "watchme")
  sepDicoCoding <- ";"
  wearableCamImagesObject <- watchme_prepare_data(pathResults=pathResults, sepResults=sepResults,
                                          pathDicoCoding=pathDicoCoding, sepDicoCoding=sepDicoCoding)
  expect_that(wearableCamImagesObject, is_a("tbl_df"))

})

test_that("watchme_prepare_data works with XnView outputs as well", {
  pathResults <- system.file("extdata", "sample_IO2.csv", package = "watchme")
  sepResults <- "\t"
  pathDicoCoding <-  system.file("extdata", "dico_coding_2016_01_IO.csv", package = "watchme")
  sepDicoCoding <- ";"
  IO2 <- watchme_prepare_data(pathResults=pathResults, sepResults=sepResults,
                      pathDicoCoding=pathDicoCoding, sepDicoCoding=sepDicoCoding)
  expect_that(IO2, is_a("tbl_df"))
})

