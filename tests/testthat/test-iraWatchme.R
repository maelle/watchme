library("watchme")
library("lubridate")
library("dplyr")
library("irr")

#################################################################################################
context("watchme_ira")
#################################################################################################
test_that("watchme_ira outputs the right type of results depending on the options",{
  data("coding1")
  data("coding2")

  listWC <- list(coding1, coding2)
  names_list <- c("Cain", "Abel")

  output <- watchme_ira(listWC, names_list = names_list)

  expect_that(output, is_a("tbl_df"))
  expect_that(dim(output), equals(c(1,7)))
  expect_that(names(output), equals(c( "method", "pictures", "agreed_on", "raters", "Kappa",
                                       "z" , "p_value"  )))
  expect_that(as.character(output$method), equals("Cohen's Kappa for 2 Raters (Weights: unweighted)"))

  listWC2 <- list(coding1, coding2, coding2)
  names_list <- c("Riri", "Fifi", "Loulou")
  output <- watchme_ira(listWC2, names_list = names_list, one_to_one = FALSE)
  expect_that(output, is_a("tbl_df"))
  expect_that(dim(output), equals(c(1,7)))
  expect_that(names(output), equals(c( "method", "pictures", "agreed_on", "raters", "Kappa",
                                       "z" , "p_value"  )))
  expect_that(as.character(output$method), equals("Fleiss' Kappa for m Raters"))

  output <- watchme_ira(listWC2, names_list = names_list, one_to_one = TRUE)
  expect_that(output, is_a("tbl_df"))
  expect_that(names(output), equals(c( "method", "pictures", "agreed_on", "raters",
                                       "Kappa",
                                       "z" , "p_value"  )))
  expect_that(as.character(output$method[1]), equals("Cohen's Kappa for 2 Raters (Weights: unweighted)"))

  data("coding1")
  data("coding2")

  listWC <- list(coding1, coding2)
  output <- watchme_ira(listWC, names_list = c("Cain", "Abel"), by_code = TRUE)
  expect_that(output, is_a("tbl_df"))
  expect_that(nrow(output), equals(nrow(attr(coding1, "dico"))))
  expect_equal(ncol(output), 8)
  expect_that(as.character(output$method[1]), equals("Cohen's Kappa for 2 Raters (Weights: unweighted)"))

})

test_that("The function works if names_list is NULL", {
  data("coding1")
  data("coding2")
  listWC <- list(coding1, coding2)
  output <- watchme_ira(listWC, names_list = NULL)
  expect_that(output, is_a("tbl_df"))
})
