# coding_example
###################################################
path_results <- system.file("extdata", "image_level_pinocchio.csv", package  =  "watchme")
sep_results <- ","
path_dico <-  system.file("extdata", "dicoCoding_pinocchio.csv", package  =  "watchme")
sep_dico <- ";"
coding_example <- watchme_prepare_data(path_results = path_results, sep_results = sep_results,
                                        path_dico = path_dico, sep_dico = sep_dico)
save(coding_example, file  =  "data/coding_example.RData", compress = 'xz')

###################################################
# coding1
###################################################
path_results <- system.file("extdata", "sample_coding1.csv", package  =  "watchme")
sep_results <- "\t"
path_dico <-  system.file("extdata", "dico_coding_2016_01_IO.csv", package  =  "watchme")
sep_dico <- ";"
coding1 <- watchme_prepare_data(path_results = path_results, sep_results = sep_results,
                                       path_dico = path_dico, sep_dico = sep_dico,
                    quote_sign  =  "\'")
save(coding1, file  =  "data/coding1.RData", compress = 'xz')

###################################################
# coding2
###################################################
path_results <- system.file("extdata", "sample_coding2.csv", package  =  "watchme")
sep_results <- "\t"
path_dico <-  system.file("extdata", "dico_coding_2016_01_IO.csv", package  =  "watchme")
sep_dico <- ";"
coding2 <- watchme_prepare_data(path_results = path_results, sep_results = sep_results,
                                       path_dico = path_dico, sep_dico = sep_dico)
save(coding2, file  =  "data/coding2.RData", compress = 'xz')
