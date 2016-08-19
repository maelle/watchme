library("watchme")
library("lubridate")
library("dplyr")
#################################################################################################
context("convertInput")
#################################################################################################

test_that("watchme_prepare_data outputs a tibble", {

  path_results <- system.file("extdata", "image_level_pinocchio.csv", package  =  "watchme")
  sep_results <- ","
  path_dico <-  system.file("extdata", "dicoCoding_pinocchio.csv", package  =  "watchme")
  sep_dico <- ";"
  wearableCamImagesObject <- watchme_prepare_data(path_results = path_results, sep_results = sep_results,
                                          path_dico = path_dico, sep_dico = sep_dico)

  expect_that(wearableCamImagesObject, is_a("tbl_df"))

})

test_that("watchme_prepare_data works with XnView outputs as well", {

  path_results <- system.file("extdata", "sample_coding2.csv", package  =  "watchme")
  sep_results <- "\t"
  path_dico <-  system.file("extdata", "dico_coding_2016_01_IO.csv", package  =  "watchme")
  sep_dico <- ";"
  coding2 <- watchme_prepare_data(path_results = path_results, sep_results = sep_results,
                      path_dico = path_dico, sep_dico = sep_dico)
  expect_that(coding2, is_a("tbl_df"))

})

