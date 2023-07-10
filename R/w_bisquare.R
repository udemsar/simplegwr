#--------------------
#' Bi-square weight
#'
#' This function returns a bi-square inverse distance weight.
#' @param dd distance from regression point in metres
#' @param bwd bandwidth distance in metres, either exact value (fixed kernel) or geog distance to furthest neighbour (adaptive kernel)
#' @return A bi-square inverse distance weight
#' @export
#' @examples
#' w_bisquare(2,5)
#' w_bisquare(5,2)
#' w_bisquare(2,2)

w_bisquare <- function(dd,bwd){
  if (dd<bwd) {
    w <- (1-(dd/bwd)^2)^2
  }
  else {
    w <- 0
  }
  return(w)
} # function