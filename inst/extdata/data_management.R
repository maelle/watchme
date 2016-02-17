###################################################
# dummyWearableCamImages
###################################################
pathResults <- system.file("extdata", "image_level_pinocchio.csv", package = "watchme")
sepResults <- ","
pathDicoCoding <-  system.file("extdata", "dicoCoding_pinocchio.csv", package = "watchme")
sepDicoCoding <- ";"
dummyWearableCamImages <- convertInput(pathResults=pathResults, sepResults=sepResults,
                                        pathDicoCoding=pathDicoCoding, sepDicoCoding=sepDicoCoding)
save(dummyWearableCamImages, file = "data/dummyWearableCamImages.RData")

###################################################
# IO1
###################################################
pathResults <- system.file("extdata", "sample_IO1.csv", package = "watchme")
sepResults <- "\t"
pathDicoCoding <-  system.file("extdata", "dico_coding_2016_01_IO.csv", package = "watchme")
sepDicoCoding <- ";"
IO1 <- convertInput(pathResults=pathResults, sepResults=sepResults,
                                       pathDicoCoding=pathDicoCoding, sepDicoCoding=sepDicoCoding,
                    quoteSign = "\'")
save(IO1, file = "data/IO1.RData")

###################################################
# IO2
###################################################
pathResults <- system.file("extdata", "sample_IO2.csv", package = "watchme")
sepResults <- "\t"
pathDicoCoding <-  system.file("extdata", "dico_coding_2016_01_IO.csv", package = "watchme")
sepDicoCoding <- ";"
IO2 <- convertInput(pathResults=pathResults, sepResults=sepResults,
                                       pathDicoCoding=pathDicoCoding, sepDicoCoding=sepDicoCoding)
save(IO2, file = "data/IO2.RData")
