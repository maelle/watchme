library("watchme")
library("lubridate")
library("dplyr")
#################################################################################################
context("utils")
#################################################################################################

test_that("utils want at least two coders",{
  data("coding1")
  expect_error(watchme_ira(list(coding1)),
               "Do not bother using this function if you only have one.")
})

test_that("utils uses namesList well", {
  data("coding1")

  expect_that(watchme_ira(list(coding1, coding1), names_list = "theOnlyOne"),
              throws_error("Not as many names as"))

  expect_that(watchme_ira(list(coding1, coding1),
                          names_list = c("theOnlyOne", "theOnlyOne")),
              throws_error("Please provide unique names for the coders"))

  output <- watchme_ira(list(coding1, coding1),
                        names_list = c("Cain", "Abel"))
  expect_that(levels(output$raters), equals("Cain, Abel"))

})


test_that("utils checks comparability",{
  data("coding1")
  expect_error(watchme_ira(list(coding1,coding1[1:100,])),
               "There should be the same number of pictures in each")
  data("coding1")
  data("coding2")
  attr(coding2, "dico")<- attr(coding1, "dico")[1:6,]
  expect_error(watchme_ira(list(coding1, coding2)),
               "All tibbles should have the same dico!")
})
