library("watchme")
library("lubridate")
library("dplyr")
library("ggplot2")

#################################################################################################
context("watchme_plot_sequence")
#################################################################################################
test_that("watchme_plot_sequence needs a dicoCoding",{
  data("coding_example")
  eventTable <- watchme_aggregate(df = coding_example)
  attr(eventTable, "dico") <- NULL
  expect_error(watchme_plot_sequence(eventTable),
               "Provide a dico.")
})

test_that("watchme_plot_sequence defines the x-axis as it should", {
  data("coding_example")
  eventTable <- watchme_aggregate(df = coding_example)
  p <- watchme_plot_sequence(eventTable)
  expect_that(grepl("time", toString(p$layers[[1]]$mapping)), equals(TRUE))
  p <- watchme_plot_sequence(eventTable, x_axis = "picture")
  expect_that(grepl("picture", toString(p$layers[[1]]$mapping)), equals(TRUE))

})

