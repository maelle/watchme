library("watchme")
library("lubridate")
library("dplyr")


#################################################################################################
context("outputDifferences")
#################################################################################################
test_that("outputDifferences uses namesList well", {
  data("dummyWearableCamImages")

  expect_that(outputDifferences(list(dummyWearableCamImages, dummyWearableCamImages), namesList="theOnlyOne"),
              throws_error("Not as many names as wearableCamImages objects"))

  expect_that(outputDifferences(list(dummyWearableCamImages, dummyWearableCamImages),
                         namesList=c("theOnlyOne", "theOnlyOne")),
              throws_error("Please provide unique names for the coders"))



})

test_that("outputDifferences wants at least two objects", {
  data("IO1")
  expect_error(outputDifferences(list(IO1)),
               "Do not bother using this function if you only have one wearableCamImages object.")
})

test_that("outputDifferences checks comparability",{
  data("dummyWearableCamImages")
  dummyWearableCamImages2 <- dummyWearableCamImages
  dummyWearableCamImages2@codes <- dummyWearableCamImages@codes[1:10]
  expect_error(outputDifferences(list(dummyWearableCamImages, dummyWearableCamImages2)),
               "There should be the same number of pictures in each wearableCamImages object!")

  dummyWearableCamImages2 <- dummyWearableCamImages
  dummyWearableCamImages2@dicoCoding <- dummyWearableCamImages@dicoCoding[1:6,]
  expect_error(outputDifferences(list(dummyWearableCamImages, dummyWearableCamImages2)),
               "All wearableCamImages objects should have the same dicoCoding!")
})

test_that("outputDifferences gives no difference if equal",{
  expect_null(outputDifferences(list(dummyWearableCamImages, dummyWearableCamImages)))
})

test_that("outputDifferences gives differences if there are some",{
  data(IO1)
  data(IO2)
  listObjects <- list(IO1, IO2)
  namesList <- c("coder1", "coder2")
  skip_on_appveyor()
  expect_that(outputDifferences(listObjects, namesList),
              is_a("tbl_df"))
})
