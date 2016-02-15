library("watchme")
library("lubridate")
library("dplyr")

#################################################################################################
context("combineObjects")
#################################################################################################
test_that("combineObjects wants the same dicoCoding", {
  data("dummyWearableCamImages")
  dummyWearableCamImages2 <- dummyWearableCamImages
  dummyWearableCamImages2@dicoCoding <- dummyWearableCamImages@dicoCoding[1:6,]
  wearableCamImagesList <- list(dummyWearableCamImages, dummyWearableCamImages2)
  expect_error(combineObjects(wearableCamImagesList),
               "All wearableCamImages objects should have the same dicoCoding!")
})

test_that("combineObjects outputs a wearableCameraImages object", {
  data("dummyWearableCamImages")
  wearableCamImagesList <- list(dummyWearableCamImages, dummyWearableCamImages)
  wearableCamImagesObject <- combineObjects(wearableCamImagesList)
  expect_that(wearableCamImagesObject, is_a("wearableCamImages"))
})
