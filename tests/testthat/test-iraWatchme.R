library("watchme")
library("lubridate")
library("dplyr")
library("irr")

#################################################################################################
context("watchme_ira")
#################################################################################################
test_that("watchme_ira outputs the right type of results depending on the options",{
  data("IO1")
  data("IO2")

  listWC <- list(IO1, IO2)
  names_list <- c("Cain", "Abel")

  output <- watchme_ira(listWC, names_list = names_list)

  expect_that(output, is_a("tbl_df"))
  expect_that(dim(output), equals(c(1,8)))
  expect_that(names(output), equals(c( "method", "pictures", "agreedOn", "raters", "ratersNames", "Kappa",
                                       "z" , "pValue"  )))
  expect_that(as.character(output$method), equals("Cohen's Kappa for 2 Raters (Weights: unweighted)"))

  listWC2 <- list(IO1, IO2, IO2)
  names_list <- c("Riri", "Fifi", "Loulou")
  output <- watchme_ira(listWC2, names_list = names_list)
  expect_that(output, is_a("tbl_df"))
  expect_that(dim(output), equals(c(1,8)))
  expect_that(names(output), equals(c( "method", "pictures", "agreedOn", "raters", "ratersNames", "Kappa",
                                       "z" , "pValue"  )))
  expect_that(as.character(output$method), equals("Fleiss' Kappa for m Raters"))

  output <- watchme_ira(listWC2, names_list = names_list, oneToOne = TRUE)
  expect_that(output, is_a("tbl_df"))
  expect_that(names(output), equals(c( "method", "pictures", "agreedOn", "rater1", "rater2",
                                       "Kappa",
                                       "z" , "pValue"  )))
  expect_that(as.character(output$method[1]), equals("Cohen's Kappa for 2 Raters (Weights: unweighted)"))

  data("IO1")
  data("IO2")

  listWC <- list(IO1, IO2)
  output <- watchme_ira(listWC, names_list = c("Cain", "Abel"), byCode = TRUE)
  expect_that(output, is_a("tbl_df"))
  expect_that(nrow(output), equals(ncol(IO1$booleanCodes)))
  expect_that(ncol(output), equals(11))
  expect_that(as.character(output$method[1]), equals("Cohen's Kappa for 2 Raters (Weights: unweighted)"))

  output <- watchme_ira(listWC, names_list = c("Cain", "Abel"), byGroup = TRUE)
  expect_that(output, is_a("tbl_df"))
  expect_that(nrow(output), equals(length(levels(factor(IO1$dicoCoding$Group)))))
  expect_that(ncol(output), equals(9))
  expect_that(names(output), equals(c( "method", "pictures", "agreedOn", "raters", "ratersNames", "Kappa",
                                            "z" , "pValue", "group"  )))
  expect_that(as.character(output$method[1]), equals("Cohen's Kappa for 2 Raters (Weights: unweighted)"))
})

test_that("The function works if names_list is NULL", {
  data("IO1")
  data("IO2")
  listWC <- list(IO1, IO2)
  output <- watchme_ira(listWC, names_list = NULL, byGroup = TRUE)
  expect_that(output, is_a("tbl_df"))
})

test_that("It works for several combinations of arguments", {
  data("IO1")
  data("IO2")
  listWC3 <- list(IO1, IO2, IO2)
  output <- watchme_ira(listWC3, names_list = c("Riri", "Fifi", "Loulou"), byGroup = TRUE, byCode  =  FALSE, oneToOne  =  FALSE)
  expect_that(output, is_a("tbl_df"))

  output <- watchme_ira(listWC3, names_list = c("Riri", "Fifi", "Loulou"), byGroup = FALSE, byCode  =  TRUE, oneToOne  =  FALSE)
  expect_that(output, is_a("tbl_df"))

  output <- watchme_ira(listWC3, names_list = c("Riri", "Fifi", "Loulou"), byGroup = TRUE, byCode  =  FALSE, oneToOne  =  TRUE)
  expect_that(output, is_a("tbl_df"))

  output <- watchme_ira(listWC3, names_list = c("Riri", "Fifi", "Loulou"), byGroup = FALSE, byCode  =  TRUE, oneToOne  =  TRUE)
  expect_that(output, is_a("tbl_df"))


})
