library("watchme")
library("lubridate")
library("dplyr")
#################################################################################################
context("utils")
#################################################################################################

test_that("utils want at least two coders",{
  data("IO1")
  expect_error(bindCoders(list(IO1)),
               "Do not bother using this function if you only have one wearableCamImages object.")
})

test_that("utils uses namesList well", {
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


test_that("utils checks comparability",{
  data("dummyWearableCamImages")
  dummyWearableCamImages2 <- dummyWearableCamImages
  dummyWearableCamImages2@codes <- dummyWearableCamImages@codes[1:10]
  expect_error(iraWatchme(list(dummyWearableCamImages, dummyWearableCamImages2)),
               "There should be the same number of pictures in each wearableCamImages object!")

  dummyWearableCamImages2 <- dummyWearableCamImages
  dummyWearableCamImages2@dicoCoding <- dummyWearableCamImages@dicoCoding[1:6,]
  expect_error(iraWatchme(list(dummyWearableCamImages, dummyWearableCamImages2)),
               "All wearableCamImages objects should have the same dicoCoding!")
})
