library("watchme")
library("lubridate")
library("dplyr")


#################################################################################################
context("outputDifferences")
#################################################################################################


test_that("outputDifferences gives no difference if equal",{
  data("coding1")
  expect_equal(nrow(watchme_output_differences(list(coding1, coding1))), 0)
})

test_that("outputDifferences gives differences if there are some",{
  data(coding1)
  data(coding2)
  results_list <- list(coding1, coding2)
  names_list <- c("coder1", "coder2")

  expect_that(watchme_output_differences(results_list, names_list),
              is_a("tbl_df"))
})
