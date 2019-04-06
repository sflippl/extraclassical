#' Real Discrete Fourier Transform Matrix
#'
#' Instantiates a Real Discrete Fourier Transform Matrix.
#'
#' @param n What dimensions should the matrix have?
#'
#' @export

real_dft_matrix <- function(n) {
    h <- floor(n/2)
    dft <- matrix(nrow = n, ncol = n)
    dft[, 1] <- 1 / sqrt(n)
    for(k in seq_len(h)) {
        if(2*k+1 <= n) {
            dft[, 2*k] <- sqrt(2)/sqrt(n)*cos(-2*pi*(0:(n-1))*k/n)
            dft[, 2*k+1] <- sqrt(2)/sqrt(n)*sin(-2*pi*(0:(n-1))*k/n)
        }
        else {
            dft[, 2*k] <- 1/sqrt(n)*cos(-2*pi*(0:(n-1))*k/n)
        }
    }
    dft
}

#' Frequency Decomposition
#'
#' Yields the frequency decomposition of an extraclassical process.
#'
#' @param process An extraclassical process
#'
#' @export

frequency_decomposition <- function(process) {
    n <- n_receptors(process)
    h <- floor((n+1)/2)
    sigma <- covariance(process, 0:h)
    lambda <- numeric(h)
    for(k in 1:h) {
        if(n %% 2 == 0) w <- c(1, rep(2, h-1), 1)
        else w <- c(1, rep(2, h))
        lambda[k] <- sum(w * sigma * cos(2*pi*(0:h)*(k-1)/n))
    }
    lambda
}
