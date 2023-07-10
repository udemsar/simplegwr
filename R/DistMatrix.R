#' Distance matrix
#'
#' This function returns a pairwise distance matrix between all points in the dataset.
#' @param x x coordinate of points
#' @param y y coordinate of points
#' @return A pairwise distance matrix
#' @export
#' @examples
#' DistMatrix(1:5,1:5)

DistMatrix <- function(x,y){
  # set up matrix with 0
  distm <- matrix(0,nrow=length(x),ncol=length(x))
  distm
  # calculate distances in the top triangle and mirror below
  n <- length(x)
  for (i in 1:(n-1)) {
    for (j in (i+1):n) {
      distm[i,j] <- EuclDist(x[i],y[i],x[j],y[j])
      distm[j,i] <- distm[i,j]
    }
  }
  # return matrix 
  return(distm)      
} # function

