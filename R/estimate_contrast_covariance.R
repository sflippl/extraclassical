#' Estimate covariance within a picture
#'
#' This function estimates the covariance within a picture under the assumption
#' that the covariance does not depend on the location of the pixel. We are
#' interested into the covariance along a certain dominant direction, since we
#' are concerned with contrast-filtered images.
#'
#' @param images Image or images. Might be a matrix or a list of matrices
#' @param orientation Orientation. Can be horizontal, vertical, diagonal or
#' antidiagonal
#' @param contrast_orientation If you do not supply orientation, you may also
#' specify the contrast you applied and the function computes the correct
#' orientation.
#'
#' @export

estimate_contrast_covariance <- function(
    images,
    orientation = NULL,
    contrast_orientation
) {
    UseMethod("estimate_contrast_covariance")
}

#' @export

estimate_contrast_covariance.list <- function(
    images,
    orientation = NULL,
    contrast_orientation
) {
    images %>%
        purrr::map(estimate_contrast_covariance,
                   orientation = orientation,
                   contrast_orientation = contrast_orientation) %>%
        purrr::reduce(`+`) %>%
        magrittr::divide_by(length(images))
}

#' @export

estimate_contrast_covariance.matrix <- function(
    images,
    orientation = NULL,
    contrast_orientation
) {
    if(!is.null(orientation)) {
        match.arg(
            orientation,
            c("horizontal", "vertical", "diagonal", "antidiagonal")
        )
    }
    else {
        orientation <- dplyr::case_when(
            contrast_orientation %in% c("n", "s") ~ "horizontal",
            contrast_orientation %in% c("w", "e") ~ "vertical",
            contrast_orientation %in% c("ne", "sw") ~ "diagonal",
            contrast_orientation %in% c("nw", "se") ~ "antidiagonal"
        )
    }
    if(orientation == "horizontal") {
        cov <- t(images) %*%
            images %>%
            magrittr::divide_by(nrow(images)) %>%
            average_covariance()
    }
    if(orientation == "vertical") {
        cov <- images %*%
            t(images) %>%
            magrittr::divide_by(nrow(images)) %>%
            average_covariance()
    }
    if(orientation == "diagonal") {
        cov <-
            images %>%
            # Extract different 'samples' (diagonals)
            {
                purrr::map(
                    seq_len(ncol(images)) - 1,
                    function(k) {
                        pracma::Diag(., k)
                    }
                )
            } %>%
            purrr::map(
                ~ . %*% t(.) %>%
                average_covariance()
            ) %>%
            purrr::reduce(
                function(x, y) {
                    if(length(x) < length(y)) {
                        x <- c(x, rep(0, length(y)-length(x)))
                    }
                    if(length(y) < length(x)) {
                        y <- c(y, rep(0, length(x)-length(y)))
                    }
                    x+y
                }
            ) %>%
            magrittr::divide_by(ncol(images):1)
    }
    if(orientation == "antidiagonal") {
        cov <-
            images %>%
            magrittr::extract(, ncol(.):1) %>%
            # Extract different 'samples' (diagonals)
            {
                purrr::map(
                    seq_len(ncol(images)) - 1,
                    function(k) {
                        pracma::Diag(., k)
                    }
                )
            } %>%
            purrr::map(
                ~ . %*% t(.) %>%
                    average_covariance()
            ) %>%
            purrr::reduce(
                function(x, y) {
                    if(length(x) < length(y)) {
                        x <- c(x, rep(0, length(y)-length(x)))
                    }
                    if(length(y) < length(x)) {
                        y <- c(y, rep(0, length(x)-length(y)))
                    }
                    x+y
                }
            ) %>%
            magrittr::divide_by(ncol(images):1)
    }
    cov
}

average_covariance <- function(covariance) {
    purrr::map_dbl(
        seq_len(ncol(covariance)),
        ~ pracma::Diag(covariance, . - 1) %>%
            sum() %>%
            magrittr::divide_by(ncol(covariance) + 1 - .)
    )
}
