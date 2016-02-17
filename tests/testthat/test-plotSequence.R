library("watchme")
library("lubridate")
library("dplyr")
library("ggplot2")

#################################################################################################
context("plotSequence")
#################################################################################################
test_that("plotSequence needs a dicoCoding",{
  data("dummyWearableCamImages")
  eventTable <- toEventLevel(wearableCamImagesObject=dummyWearableCamImages)
  expect_error(plotSequence(eventTable),
               "Provide a dicoCoding.")
})

test_that("plotSequence defines the x-axis as it should", {
  data("dummyWearableCamImages")
  eventTable <- toEventLevel(wearableCamImagesObject=dummyWearableCamImages)
  p <- plotSequence(eventTable, dicoCoding=dummyWearableCamImages$dicoCoding)
  expect_that(grepl("Time", toString(p$layers[[1]]$mapping)), equals(TRUE))
  p <- plotSequence(eventTable, xAxis="picture",
                    dicoCoding=dummyWearableCamImages$dicoCoding)
  expect_that(grepl("Picture", toString(p$layers[[1]]$mapping)), equals(TRUE))
  p <- plotSequence(eventTable, xAxis="time",
                    dicoCoding=dummyWearableCamImages$dicoCoding)
  expect_that(grepl("Time", toString(p$layers[[1]]$mapping)), equals(TRUE))
})


test_that("plotSequence does facetting as it should", {
  data("IO1")
  data("IO2")

  # no facetting
  eventTable <- toEventLevel(wearableCamImagesObject=IO1)
  p <- plotSequence(eventTable,
                    dicoCoding=IO1$dicoCoding)
  expect_that(p$facet, is_a("null"))

  # facetting only for the group
  p <- plotSequence(eventTable, facettingGroup=TRUE,
                    dicoCoding=IO1$dicoCoding)
  expect_that(names(p$facet$rows), equals("group"))
  expect_that(toString(names(p$facet$cols)), equals(""))

  eventTableCoders <- bindCoders(list(IO1, IO2), minDuration = 1)
  # facetting only for the coder
  p <- plotSequence(eventTableCoders, facettingGroup = FALSE, facettingCoder = TRUE,
                    dicoCoding=IO1$dicoCoding)
  expect_that(names(p$facet$rows), equals("coder"))
  expect_that(toString(names(p$facet$cols)), equals(""))

  # facetting for both group and coder
  p <- plotSequence(eventTableCoders, facettingGroup = TRUE, facettingCoder = TRUE,
                    dicoCoding=IO1$dicoCoding)
  expect_that(names(p$facet$rows), equals("coder"))
  expect_that(names(p$facet$cols), equals("group"))

  # facetting for coders when no coder
  expect_that(plotSequence(eventTable, facettingCoder=TRUE,
                           dicoCoding=IO1$dicoCoding),
              throws_error("You can't facet by coder if you do not have several coders"))

})
