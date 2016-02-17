library("watchme")
library("lubridate")
library("dplyr")


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

  expect_that(sum(eventTable$startTime%in%dummyWearableCamImages$timeDate), equals(nrow(eventTable)))
  expect_that(sum(eventTable$endTime%in%dummyWearableCamImages$timeDate), equals(nrow(eventTable)))
})


test_that("toEventLevel outputs a data table with the right variables", {
  data("dummyWearableCamImages")
  eventTable <- toEventLevel(wearableCamImagesObject=dummyWearableCamImages)

  expect_that(names(eventTable), equals(c("eventIndex", "startTime", "endTime",
                                          "eventCode",  "noOfPictures", "activity",
                                          "group", "startPicture", "endPicture")))

})
