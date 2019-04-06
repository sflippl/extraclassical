#' Compute the expected value
#'
#' This function computes the expected value of the model's input.
#'
#' @param model A model.
#'
#' @export

expected_value <- function(model) {
    UseMethod("expected_value")
}

#' @export

expected_value.single_bar_process <- function(model) {
    n <- n_receptors(model)
    if(n == 0) return(0)
    n^(-1) * sum((1:n) * length_distribution(model))
}

#' Compute the covariance between two receptors
#'
#' This function computes the covariance between two receptors given their
#' distance.
#'
#' @param model A model.
#' @param distance Distance between the two receptors. If NULL (default value),
#' returns the covariance matrix of the model. Distance may be above the number
#' of receptors, but assumes a circular input. The value is vectorized.
#'
#' @export

covariance <- function(model, distance = NULL) {
    checkmate::assert_integer(distance, lower = 0, any.missing = FALSE,
                             null.ok = TRUE)
    if(!is.null(distance)) {
        distance <- distance %% n_receptors(model)
    }
    UseMethod("covariance")
}

#' @export

covariance.single_bar_process <- function(model, distance = NULL) {
    if(is.null(distance)) {
        cov <- toeplitz(covariance(model, 0:(n_receptors(model) - 1)))
        return(cov)
    }
    n <- n_receptors(model)
    p <- length_distribution(model)
    mu_sqrd <- expected_value(model)^2
    purrr::map_dbl(
        distance,
        function(x) {
            id_1 <- (x + 1):n
            if(x == 0) id_2 <- integer(0)
            else id_2 <- (n - x + 1):n
            tmp_1 <- single_bar_process(n - x, p[id_1])
            tmp_2 <- single_bar_process(x, p[id_2])
            (n - x)/n * expected_value(tmp_1) + x/n * expected_value(tmp_2) -
                mu_sqrd
        }
    )
}
