#' Matrix Heatmap
#'
#' This function generates a simple matrix heatmap using [ggplot()].
#'
#' @param matrix
#'
#' @export

matrix_heatmap <- function(matrix) {
    .heatmap_helper(matrix) +
        ggplot2::scale_fill_viridis_c(option = "magma")
}

#' @describeIn matrix_heatmap creates a black-white picture.
#'
#' @export

matrix_picture <- function(matrix) {
    .heatmap_helper(matrix) +
        ggplot2::scale_fill_gradient(low = "white", high = "black") +
        theme(legend.position = "none")
}

.heatmap_helper <- function(matrix) {
    ncol <- ncol(matrix)
    nrow <- nrow(matrix)
    matrix %>%
        magrittr::set_colnames(1:ncol) %>%
        tibble::as_tibble(.name_repair = "minimal") %>%
        dplyr::mutate(row = 1:nrow) %>%
        tidyr::gather(key = "col", value = "value", -row) %>%
        dplyr::mutate(col = as.integer(col)) %>%
        ggplot2::ggplot(ggplot2::aes(col, row, fill = value)) +
        ggplot2::geom_tile() +
        ggplot2::scale_y_reverse() +
        theme_void()
}
