#--------------------
#' Euclidean distance function
#'
#' This function returns Euclidean distance between points (x1,y1) and (x2,y2).
#' @param x1 x coordinate of point 1
#' @param y1 y coordinate of point 1
#' @param x2 x coordinate of point 2
#' @param y2 y coordinate of point 2
#' @return Euclidean distance between two points
#' @export
#' @examples
#' EuclDist(1,1,2,2)

EuclDist <- function(x1,y1,x2,y2){
  dist <- sqrt((x2-x1)^2+(y2-y1)^2)
  return(dist)
} # function
