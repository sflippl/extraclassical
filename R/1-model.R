#' Single Bar Process
#'
#' Model 1 consists of one bar at a time that is distributed according to its
#' length and a set of horizontally distributed receptors.
#'
#' @param n_receptors Number of receptors
#' @param length_distribution The likelihood of bars with different length. A
#' vector with n components where the k-th component returns the likelihood of
#' a bar of length k.
#'
#' @export

single_bar_process <- function(n_receptors, length_distribution) {
    checkmate::assert_integer(n_receptors, lower = 0, len = 1)
    checkmate::assert_numeric(length_distribution, lower = 0, upper = 1,
                             len = n_receptors, any.missing = FALSE)
    assertthat::assert_that(sum(length_distribution) <= 1)
    model <- list(
        n_receptors = n_receptors,
        length_distribution = length_distribution
    )
    class(model) <- c("single_bar_process", "extraclassical_process",
                      class(model))
    model
}

#' @rdname single_bar_process
#'
#' @param model A Model 1 type model
#'
#' @export

n_receptors <- function(model) {
    model[["n_receptors"]]
}

#' @rdname single_bar_process
#'
#' @export

length_distribution <- function(model) {
    model[["length_distribution"]]
}

#' @rdname single_bar_process
#'
#' @export

print.single_bar_process <- function(x) {
    n <- n_receptors(x)
    if(n == 0) mean <- 0
    else mean <- sum(1:n * length_distribution(x))
    msg <- glue::glue(
        "Single Bar Process with {n} input receptors. ",
        "Mean length: {round(mean, 2)}"
    )
    print(msg)
    invisible(x)
}
