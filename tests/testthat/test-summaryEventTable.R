library("watchme")
library("lubridate")
library("dplyr")

#################################################################################################
context("summaryEventTable")
#################################################################################################

test_that("summaryEventTable outputs a data table", {
  data("coding_example")
  eventTable <- watchme_aggregate(df = coding_example)
  summaryTable <- watchme_summarize_events(eventTable)
  expect_that(summaryTable, is_a("tbl_df"))

})

test_that("summaryEventTable outputs columns with the right classes", {
  data("coding_example")
  eventTable <- watchme_aggregate(df = coding_example)
  summaryTable <- watchme_summarize_events(eventTable)
  expect_that(summaryTable$meaning, is_a("factor"))
  expect_that(summaryTable$noOfEvents, is_a("integer"))
  expect_that(summaryTable$meanNoOfPictures, is_a("numeric"))
  expect_that(summaryTable$meanDuration, is_a("difftime"))

})
