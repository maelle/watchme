library("watchme")
library("lubridate")
library("dplyr")
library("irr")

#################################################################################################
context("irrWatchme")
#################################################################################################
test_that("irrWatchme uses namesList well", {
  data("IO1")
  data("IO2")

  expect_that(irrWatchme(list(IO1, IO2), namesList="theOnlyOne"),
              throws_error("Not as many names as wearableCamImages objects"))

  expect_that(irrWatchme(list(IO1, IO2),
                         namesList=c("theOnlyOne", "theOnlyOne")),
              throws_error("Please provide unique names for the coders"))

  expect_that(irrWatchme(list(IO1, IO2)),
                         is_a("tbl_df"))

})

test_that("irrWatchme checks comparability",{
  data("dummyWearableCamImages")
  dummyWearableCamImages2 <- dummyWearableCamImages
  dummyWearableCamImages2@codes <- dummyWearableCamImages@codes[1:10]
  expect_error(irrWatchme(list(dummyWearableCamImages, dummyWearableCamImages2)),
               "There should be the same number of pictures in each wearableCamImages object!")

  dummyWearableCamImages2 <- dummyWearableCamImages
  dummyWearableCamImages2@dicoCoding <- dummyWearableCamImages@dicoCoding[1:6,]
  expect_error(irrWatchme(list(dummyWearableCamImages, dummyWearableCamImages2)),
               "All wearableCamImages objects should have the same dicoCoding!")
})

test_that("irrWatchme outputs the right type of results depending on the options",{
  data("IO1")
  data("IO2")

  listWC <- list(IO1, IO2)
  namesList <- c("Cain", "Abel")

  output <- irrWatchme(listWC, namesList=namesList)

  expect_that(output, is_a("tbl_df"))
  expect_that(dim(output), equals(c(1,8)))
  expect_that(names(output), equals(c( "method", "pictures", "agreedOn", "raters", "ratersNames", "Kappa",
                                       "z" , "pValue"  )))
  expect_that(as.character(output$method), equals("Cohen's Kappa for 2 Raters (Weights: unweighted)"))

  listWC2 <- list(IO1, IO2, IO2)
  namesList <- c("Riri", "Fifi", "Loulou")
  output <- irrWatchme(listWC2, namesList=namesList)
  expect_that(output, is_a("tbl_df"))
  expect_that(dim(output), equals(c(1,8)))
  expect_that(names(output), equals(c( "method", "pictures", "agreedOn", "raters", "ratersNames", "Kappa",
                                       "z" , "pValue"  )))
  expect_that(as.character(output$method), equals("Fleiss' Kappa for m Raters"))

  output <- irrWatchme(listWC2, namesList=namesList, oneToOne=TRUE)
  expect_that(output, is_a("tbl_df"))
  expect_that(names(output), equals(c( "method", "pictures", "agreedOn", "rater1", "rater2",
                                       "Kappa",
                                       "z" , "pValue"  )))
  expect_that(as.character(output$method[1]), equals("Cohen's Kappa for 2 Raters (Weights: unweighted)"))

  output <- irrWatchme(listWC, namesList=c("Cain", "Abel"), byCode=TRUE)
  expect_that(output, is_a("list"))
  expect_that(length(output), equals(ncol(IO1@codesBinaryVariables)))
  expect_that(dim(output[[1]]), equals(c(1,10)))
#   expect_that(names(output[[1]]), equals(c( "method", "pictures", "agreedOn", "raters", "ratersNames", "Kappa",
#                                        "z" , "pValue"  )))
  expect_that(as.character(output[[1]]$method), equals("Cohen's Kappa for 2 Raters (Weights: unweighted)"))

  output <- irrWatchme(listWC, namesList=c("Cain", "Abel"), byGroup=TRUE)
  expect_that(output, is_a("list"))
  expect_that(length(output), equals(length(levels(factor(IO1@dicoCoding$Group)))))
  expect_that(dim(output[[1]]), equals(c(1,8)))
  expect_that(names(output[[1]]), equals(c( "method", "pictures", "agreedOn", "raters", "ratersNames", "Kappa",
                                            "z" , "pValue"  )))
  expect_that(as.character(output[[1]]$method), equals("Cohen's Kappa for 2 Raters (Weights: unweighted)"))
})

test_that("irrWachme outputs an error if there is only one file",{
  expect_error(irrWatchme(list(dummyWearableCamImages)), "Do not bother using this function if you only have one wearableCamImages object.")
})
