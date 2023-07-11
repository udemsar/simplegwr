#' Optimal bandwidth for Poisson GWR
#'
#' This function optimised bandwidth for a Poisson gwr model using AICc optimisation (i.e. optimal
#' bandwidth is the one where AICc is minimal).
#' @param formula regression formula
#' @param data data frame of points with columns for regression formula, including x and y coordinates of all points
#' @param kernel kernel type (default is bisquare for now)
#' @param weighting weighting if "adaptive", calculate an adaptive kernel where the bandwidth (bw) corresponds to the number of nearest neighbours (i.e. adaptive distance); if "fixed", a fixed kernel is found (bandwidth is a fixed distance)
#' @return Returns a list with two elements: the first element is a data frame with summary statistics, the second element is a data frame with original data and parameter estimates
#' @export

gwr_poisson_bandwidth <- function(formula, data, kernel, weighting) {
  
  # No. of points
  n <- length(data$x)
  
  # If adaptive kernel, bw is number of neighbouring points
  # if fixed, we need to calculate the distance matrix and take the longest distance
  # Also if less than 50 points, then we check all the points.
  if (weighting=='adaptive') {
    if (n<51) {
      intervalStep <- 1
      bw <- as.vector(seq(from=5*intervalStep, to=n, by=intervalStep))
    } else {
      intervalStep <- floor(n/50)
      # we start at 2* interval step and go to the max no. of neighbours
      bw <- as.vector(seq(from=2*intervalStep, to=n, by=intervalStep))
    }
  } else {
    # dist matrix
    dM <- DistMatrix(data$x,data$y)
    maxDist <- max(dM)
    if (maxDist<51) {intervalStep <- 1} else {intervalStep <- floor(maxDist/50)}
    # we start at about 5x interval step and go to the max dist
    bw <- as.vector(seq(from=5*intervalStep, to=maxDist, by=intervalStep))
  }
  
  # A simple way to find min AICc: we run GWR 50x or a thereabouts 
  localAICc <- as.vector(rep(0,length(bw)))
  
  # Run for all bandwidths
  #i <- 1
  print(paste('I am running',as.character(length(bw)),'models, so this may take a while.'))
  for (i in 1:length(bw)) {
    
    # print counter
    print(i)
    
    # set parameter
    bandw <- bw[i]
    
    # which model to run, adaptive or fixed
    if (weighting=='adaptive') {
      localM <- gwr_poisson(formula, data, bandw, kernel='bisquare', weighting='adaptive')
    } else {
      localM <- gwr_poisson(formula, data, bandw, kernel="bisquare", weighting='fixed')  
    } # end else not adaptive
    
    # get local AICc
    localAICc[i] <- localM[[1]]$AICc[1]
    
  } # for
  
  # Find bandwidth with the lowest AICc
  results <- data.frame(bw,localAICc)
  minAICc <- min(results$localAICc)
  where <- which(results$localAICc==minAICc)  
  if (length(where)==1) { # if there is only one minimum
    optBandw <- results$bw[where[1]]   
  } else { # if there are more than one minima, we take the central one
    medianWhere <- median(where)
    optBandw <- results$bw[medianWhere]
  }
  #plot(results)
  
  print('Done!')
  
  # Return the lowest AICc and a table with all bandwidths and AICcs  
  return(list(optBandw, results))
  
} # function 