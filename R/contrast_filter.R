#' Contrast filter
#'
#' This function computes the contrast of a filter.
#'
#' @param matrix The matrix input
#' @param orientation Which orientation should the filter have, i. e. where is
#' the maximum excitability? Is coded as follows: One letter stands for west,
#' south, east, north, two letters stand for northwest, southwest, northeast,
#' southeast
#' @param thickness How thick should the edges be? Positive integer.
#'
#' @export

contrast_filter <- function(
    matrix,
    orientation = c("w", "s", "e", "n", "nw", "sw", "se", "ne"),
    thickness = 1L
) {
    kernel <-
        contrast_filter_matrix(orientation = orientation, thickness = thickness)
    new_ncol <- ncol(matrix) - 2*thickness
    new_nrow <- nrow(matrix) - 2*thickness
    assertthat::assert_that(new_ncol > 0, new_nrow > 0)
    filtered <- matrix(ncol = new_ncol, nrow = new_nrow)
    for(icol in 1:new_ncol) {
        for(irow in 1:new_nrow) {
            tmp_mat <- matrix[irow:(irow+2*thickness),
                              icol:(icol+2*thickness)]
            new_val <- sum(tmp_mat*kernel)
            filtered[irow, icol] <- new_val
        }
    }
    filtered
}

#' @describeIn contrast_filter Provides the contrast filtering matrix.
#'
#' @export

contrast_filter_matrix <- function(
    orientation = c("w", "s", "e", "n", "nw", "sw", "se", "ne"),
    thickness = 1L
) {
    match.arg(orientation)
    # If the orientation is western or directly northern, first comes
    # excitability, then inhibition. In the other case, it is visa versa
    if(orientation %in% c("sw", "w", "nw", "n")) {
        filter_vec <- c(rep(1, thickness), 0, rep(-1, thickness))/(2*thickness)
    }
    else {
        filter_vec <- c(rep(-1, thickness), 0, rep(1, thickness))/(2*thickness)
    }
    n <- 2*thickness+1
    filter_mat <- matrix(0, nrow = n, ncol = n)
    if(orientation %in% c("w", "e")) {
        filter_mat[thickness+1,] <- filter_vec
    }
    if(orientation %in% c("n", "s")) {
        filter_mat[,thickness+1] <- filter_vec
    }
    if(orientation %in% c("nw", "se")) {
        diag(filter_mat) <- filter_vec
    }
    if(orientation %in% c("sw", "ne")) {
        diag(filter_mat) <- filter_vec
        filter_mat <- filter_mat[n:1,]
    }
    filter_mat
}
