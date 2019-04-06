#' Read in a CIFAR-10 batch
#'
#' This function reads in batches of the CIFAR-10 dataset.
#'
#' @param batch Which batches are read in?
#'
#' @export

read_cifar_10 <- function(batch = c("1", "2", "3", "4", "5", "test")) {
    match.arg(batch, several.ok = TRUE)
    reticulate::source_python("R/read_pickle_file.py")
    cifar <-
        purrr::map_df(
            batch,
            function(b) {
                if(b == "test") file <- "test_batch"
                else file <- paste0("data_batch_", b)
                file <-
                    paste0("inst/extdata/cifar-10-python/cifar-10-batches-py/", file)
                cifar <- file %>%
                    read_pickle_file()
                dat <- seq_len(nrow(cifar$data)) %>%
                    purrr::map_df(
                        ~ tibble::tibble(
                            filename = cifar$filenames[.],
                            batch = b,
                            label = cifar$labels[.],
                            red = cifar$data[., 1:1024] %>%
                                matrix(ncol = 32, nrow = 32, byrow = TRUE) %>%
                                list(),
                            green = cifar$data[., 1025:2048] %>%
                                matrix(ncol = 32, nrow = 32, byrow = TRUE) %>%
                                list(),
                            blue = cifar$data[., 2049:3072] %>%
                                matrix(ncol = 32, nrow = 32, byrow = TRUE) %>%
                                list()
                        ) %>%
                            dplyr::mutate_at(
                                dplyr::vars(red, green, blue),
                                ~ purrr::map(., ~./128-1)
                            ) %>%
                            dplyr::mutate(
                                bw = purrr::pmap(
                                    list(red, green, blue),
                                    ~ (..1 + ..2 + ..3)/3
                                )
                            )
                    )
                dat
            }
        )
    cifar
}
