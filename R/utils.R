# function for checking the objects to be combined have the same length and times
watchme_check_list <- function(results_list, names_list = NULL){

  lengthRef <- nrow(results_list[[1]])
  lengthsCodes <- vapply(results_list, nrow, 1)
  if (any(lengthsCodes != lengthRef)){
    stop(call. = FALSE,
         "There should be the same number of pictures in each tibble!")# nolint
  }

  times <- do.call("cbind", lapply(results_list,
                                   "[[", "image_time"))
  if(any(vapply(apply(times,1, unique), length, FUN.VALUE = 1) > 1)){
    stop(call. = FALSE,
         "All objects should have the same imageTime field, at least one difference here!")# nolint
  }

  if (length(results_list) == 1){
    stop(call. = FALSE,
         "Do not bother using this function if you only have one tibble.")# nolint
  }

  if (!is.null(names_list)){
    if (length(names_list) != length(results_list)){
      stop(call. = FALSE,
           "Not as many names as tibbles")
    }
    if (length(levels(factor(names_list))) != length(names_list)){
      stop(call. = FALSE,
           "Please provide unique names for the coders")
    }
  }

}

watchme_check_dicos <- function(results_list){

  # check that all objects used the same dico

  dico_ref <- attr(results_list[[1]], "dico")

  if (any(vapply(results_list, compare_dicos, dico_ref = dico_ref,
                 FUN.VALUE = TRUE) == FALSE)){
    stop(call. = FALSE,
         "All tibbles should have the same dico!")# nolint
  }

  dico_ref
}

compare_dicos <- function(df, dico_ref){
  val1 <- nrow(attr(df, "dico")) == nrow(dico_ref)
  if(val1){
    all(attr(df, "dico") == dico_ref)
  }else{
    FALSE
  }

}


# create a column with all TRUE/FALSE pasted,
# if the same codes were given to a picture
# then they are the same for the coders
create_string_for_comparison <- function(df, dico_ref){

  df[, dico_ref$Code] %>%
    purrr::by_row(toString, .to = "codes",
                  .collate = "cols") %>%
    select_(quote(codes))
}

count_unique_elements <- function(x){
  length(unique(x))
}

count_unique_elements2 <- function(x){
  length(unique(t(x)))
}

count_agreed_on <- function(dat){
  sum(apply(dat, 1, count_unique_elements) == 1)
}
