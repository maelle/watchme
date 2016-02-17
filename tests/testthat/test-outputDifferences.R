library("watchme")
library("lubridate")
library("dplyr")


#################################################################################################
context("outputDifferences")
#################################################################################################


test_that("outputDifferences gives no difference if equal",{
  expect_null(outputDifferences(list(IO1, IO1)))
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
