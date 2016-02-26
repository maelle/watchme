library("watchme")
library("lubridate")
library("dplyr")
#################################################################################################
context("bindCoders")
#################################################################################################

test_that("bindCoders outputs a data table", {
  data("IO1")
  data("IO2")
  output <- bindCoders(list(IO1, IO2), minDuration = 1)
  expect_that(output, is_a("tbl_df"))

})

test_that("bindCoders uses namesList well", {
  data("dummyWearableCamImages")
  output <- bindCoders(list(dummyWearableCamImages, dummyWearableCamImages),
                       namesList=c("Cain", "Abel"))
  expect_that(levels(output$coder), equals(c("Abel", "Cain")))

})
