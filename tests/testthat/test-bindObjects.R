library("watchme")
library("lubridate")
library("dplyr")
#################################################################################################
context("bindObjects")
#################################################################################################
test_that("bindObjects checks things",{
  data(IO1)
  data(dummyWearableCamImages)
  listWM <- list(IO1, dummyWearableCamImages)
  expect_error(combineObjects(listWM),
               "There should be the same number of pictures in each wearableCamImages object!") # nolint
  IO3 <- IO1$clone()
  IO3$timeDate[1] <- ymd_hms("2015-02-02 02:02:02")
  listWM <- list(IO1, IO3)
  expect_error(combineObjects(listWM),
               "All objects should have the same imageTime field, at least one difference here!") # nolint

})

test_that("bindObjects return a wearableCamImages-object", {
  data(listWM)
  object <- combineObjects(listWM, codeException = c("non codable"))
  expect_that(object, is_a("wearableCamImages"))
  })
