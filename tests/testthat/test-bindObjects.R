library("watchme")
library("lubridate")
library("dplyr")
#################################################################################################
context("bindObjects")
#################################################################################################


test_that("bindObjects return a tibble-object", {
  passes <- c("CK", "IO", "OP", "PM", "TP")

  create_pass_results <- function(pass){
    path_results <- system.file('extdata', paste0("oneday_", pass, ".csv"), package = 'watchme')
    sep_results <- '\t'
    path_dico <-  system.file('extdata', paste0("dico_coding_2016_01_", pass, ".csv"), package = 'watchme')
    sep_dico <- ';'

    results <- watchme_prepare_data(path_results = path_results, sep_results = sep_results,
                                    path_dico = path_dico, sep_dico = sep_dico)
    results$image_path <- gsub("\"", "", results$image_path)
    results
  }

  results_list <- passes %>% purrr::map(create_pass_results)
  oneday_results <- watchme_combine_results(results_list, common_codes = "non_codable")
  expect_is(oneday_results, "tbl_df")
  expect_is(attr(oneday_results, "dico"), "data.frame")
  })
