library("watchme")
library("lubridate")
library("dplyr")


#################################################################################################
context("toEventLevel")
#################################################################################################

test_that("toEventLevel outputs a data table", {
  data("coding_example")
  eventTable <- watchme_aggregate(df = coding_example)

  expect_that(eventTable, is_a("tbl_df"))

})

test_that("the dates in toEventLevel are not invented or shifted", {
  data("coding_example")
  eventTable <- watchme_aggregate(df = coding_example)

  expect_true(all(eventTable$start_time %in% coding_example$image_time))
  expect_true(all(eventTable$end_time %in% coding_example$image_time))
})


test_that("toEventLevel outputs a data table with the right variables", {
  data("dummyWearableCamImages")
  eventTable <- watchme_aggregate(df=coding_example)

  expect_that(names(eventTable), equals(c("event_code", "start_time", "end_time",
                                          "no_pictures", "start_picture", "end_picture",
                                          "group",
                                          "activity")))

})
