#' Create adaptive matrix
#'
#' This function takes a full distance matrix and adaptive bandwidth and 
#' returns a distance matrix where only as many nearest neighbours are given for each
#' point as the value of bandwidth. All other neighbours are given the distance Inf,
#' so that in the next step, as we calculate weighting, their weights will be 0.
#' @param M distance matrix
#' @param n bandwidth - number of nearest neighbours
#' @return Distance matrix with finite distances only to n nearest neighbours
#' @export
#' @examples
#' createAdaptiveMatrix(matrix(c(0,1,2,3,4, 1,0,5,4,1, 9,7,0,2,1, 5,4,6,0,4, 4,3,2,1,0), nrow=5, ncol=5, byrow=TRUE),2)

createAdaptiveMatrix <- function(M,n){
  
  # We need to reorder each row in ascending order and then take
  # n+1 elements and assign Inf to all the others. n+1, because the first
  # element will be the point itself (as this is dist matrix, it will have
  # 0s on the diagonal), then n nearest neighbours.
  rows <- dim(M)[1]
  for (i in 1:rows) {
    indOrd <- order(M[i,])
    indOrd2 <- indOrd[(n+2):rows]
    M[i,indOrd2] <- Inf
  } # for
  
  return(M)    
} # function
