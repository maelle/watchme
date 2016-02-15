library("watchme")
library("lubridate")
library("dplyr")
#################################################################################################
context("bindCoders")
#################################################################################################
test_that("bindCoders want at least two coders",{
  data("IO1")
  expect_error(bindCoders(list(IO1)),
               "Do not bother using this function if you only have one wearableCamImages object.")
})

test_that("bindCoders outputs a data table", {
  data("IO1")
  data("IO2")
  output <- bindCoders(list(IO1, IO2), minDuration = 1)
  expect_that(output, is_a("tbl_df"))

})

test_that("bindCoders uses namesList well", {
  data("dummyWearableCamImages")

  expect_that(bindCoders(list(dummyWearableCamImages, dummyWearableCamImages), namesList="theOnlyOne"),
              throws_error("Not as many names as wearableCamImages objects"))

  expect_that(bindCoders(list(dummyWearableCamImages, dummyWearableCamImages),
                         namesList=c("theOnlyOne", "theOnlyOne")),
              throws_error("Please provide unique names for the coders"))

  output <- bindCoders(list(dummyWearableCamImages, dummyWearableCamImages),
                       namesList=c("Cain", "Abel"))
  expect_that(levels(output$coder), equals(c("Cain", "Abel")))

})
