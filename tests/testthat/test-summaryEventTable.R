library("watchme")
library("lubridate")
library("dplyr")

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
  expect_that(summaryTable$meanDuration, is_a("difftime"))

})
