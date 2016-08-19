# coding_example
###################################################
pathResults <- system.file("extdata", "image_level_pinocchio.csv", package = "watchme")
sepResults <- ","
pathDicoCoding <-  system.file("extdata", "dicoCoding_pinocchio.csv", package = "watchme")
sepDicoCoding <- ";"
coding_example <- watchme_prepare_data(pathResults=pathResults, sepResults=sepResults,
                                        pathDicoCoding=pathDicoCoding, sepDicoCoding=sepDicoCoding)
save(coding_example, file = "data/coding_example.RData", compress='xz')

###################################################
# coding1
###################################################
pathResults <- system.file("extdata", "sample_coding1.csv", package = "watchme")
sepResults <- "\t"
pathDicoCoding <-  system.file("extdata", "dico_coding_2016_01_IO.csv", package = "watchme")
sepDicoCoding <- ";"
coding1 <- watchme_prepare_data(pathResults=pathResults, sepResults=sepResults,
                                       pathDicoCoding=pathDicoCoding, sepDicoCoding=sepDicoCoding,
                    quoteSign = "\'")
save(coding1, file = "data/coding1.RData", compress='xz')

###################################################
# coding2
###################################################
pathResults <- system.file("extdata", "sample_coding2.csv", package = "watchme")
sepResults <- "\t"
pathDicoCoding <-  system.file("extdata", "dico_coding_2016_01_IO.csv", package = "watchme")
sepDicoCoding <- ";"
coding2 <- watchme_prepare_data(pathResults=pathResults, sepResults=sepResults,
                                       pathDicoCoding=pathDicoCoding, sepDicoCoding=sepDicoCoding)
save(coding2, file = "data/coding2.RData", compress='xz')
