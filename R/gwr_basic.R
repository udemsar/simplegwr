#' GWR basic function
#'
#' This function calculates a linear gwr model
#' @param formula regression formula
#' @param data data frame of points with columns for regression formula, including x and y coordinates of all points - these need to be projected coordinates!
#' @param bw bandwidth, fixed (geog dist) or adaptive (number of neighbours)
#' @param kernel kernel type: currently only 'bisquare' 
#' @param weighting if "adaptive", calculate an adaptive kernel where the bandwidth (bw) corresponds to the number of nearest neighbours (i.e. adaptive distance); if "fixed", a fixed kernel is found (bandwidth is a fixed distance)
#' @return Returns a list with two elements: the first element is a data frame with summary statistics, the second element is a data frame with original data and parameter estimates
#' @export

gwr_basic <- function(formula, data, bw, kernel, weighting) {
  
  #-------  
  ## Step 1: weights 
  #------- 
  # Calculate distance matrix
  dM <- DistMatrix(data$x,data$y)
  #dM
  
  # Calculate weights matrix
  # Separate fixed vs adaptive weighting 
  if (weighting=='adaptive') { 
    
    #print('adaptive')
    
    # Step 1: For adaptive weighting we need to sort each row of the distance matrix
    # from nearest to furthest neighbour, and then only take the first bw
    # points and assign zeros to every other neighbour. This is done by the adaptive
    # matrix having Inf for all the neighbours further away than bw, so the bisquare
    # weight returns zero for all these points.
    # Then we have to sort it back to the original positions
    # This is done in a separate function
    dM_resorted <- createAdaptiveMatrix(dM,bw)
    #dM_resorted
    
    # Step 2: We apply the correct weight function to the distance matrix,
    # while separating for the type of weights.
    # As this is adaptive weighting, bwd for bisquare weights changes for each point.
    # I.e. for each point bwd should be the distance to the furthest n neighbour. 
    if (kernel=='bisquare') {
      
      # setup dW with zeros everywhere
      dW <- matrix(0, nrow = dim(dM_resorted)[1], ncol = dim(dM_resorted)[2])
      
      # For each row/point, assign bisquare weights with adaptive bandwidth, i.e.
      # use maxdist in each row as bwd for w_bisquare function
      for (i in 1:dim(dM_resorted)[1]) {
        
        # Find the max dist that is smaller than Inf, which is what the dM_resorted has
        # to separate those that are not nearest neighbours out 
        maxdist <- max(dM_resorted[i,which(dM_resorted[i,]<Inf)])
        dW[i,] <- structure(vapply(dM_resorted[i,], w_bisquare, bwd=maxdist, numeric(1)), dim=dim(dM_resorted[i,]))
        #plot(dW[i,]) #OK!
        
      } #for
      
    } else { 
      stop('Wrong or missing kernel specification')
    } # if kernel
    
  } else if (weighting=='fixed') {
    
    #print('fixed')
    
    # For fixed weighting we don't have to sort anything, we calculate weights with 
    # given distance matrix dM and bw.
    # For this, apply the correct weight function to the matrix, while separating 
    # for the type of weights.   
    if (kernel=='bisquare') {
      dW <- structure(vapply(dM, w_bisquare, bwd=bw, numeric(1)), dim=dim(dM))
    } else { 
      stop('Wrong or missing kernel specification')
    } # if kernel
    
  } else {
    stop('Wrong or missing specification of weighting')
  } #if weighting
  
  
  #-------  
  ## Step 2: calculate local models, one in each point 
  #------- 
  
  ## Select columns with regression variables from data
  # Read variables from formula
  variables <- all.vars(formula)
  # Column indices in the data set of these variables
  colInd <- which(names(data)%in% variables)
  # Regression data
  dataReg <- data[,colInd]  
  names(dataReg) <- variables
  #head(dataReg)
  
  ## Create output columns in the original data
  # For each independent variable create coeff, StError, t value columns
  # First generate names of new columns
  # First three columns are for intercept
  newNames <- list('Intercept_coeff','Intercept_StErr','Intercept_tvalue')
  #head(data)
  # For each independent variable create three columns
  for (v in 2:length(variables)) {
    coeff <- paste(variables[v],"_coeff",sep = "")
    StE <- paste(variables[v],"_StErr",sep = "")
    tVal <- paste(variables[v],"_tvalue",sep = "")
    newNames <- c(newNames, coeff, StE, tVal)
  }
  # Then add some statistics columns
  newNames <- c(newNames, 'LocRes', 'StLocRes', 'R2', 'AdjR2', 'yP')
  #newNames
  # Add all these new columns to data with zero values, so they can be filled in in the loop below
  for (nn in newNames){
    data[[nn]] <- 0
  }

  ## Calculate local models for each point in the data
  # How many points in this dataset?
  noPoints <- length(data$x)
  # For each point get data, weigh them, calculate lm, extract values, add to data frame
  for (i in 1:noPoints) {
    # Select weights for this point from dW
    weights <- dW[i,]
    # Which weights are non-zero, we will only use these data for regression
    subsetW <- which(weights>0)
    #subsetW
    # Get these weights
    nonzeroW <- weights[subsetW]
    #nonzeroW
    # Get original data from non-zero weight indices
    origData <- dataReg[subsetW,]
    #origData
    # Weigh these with weights
    weightedData <- origData * nonzeroW
    #weightedData
    # Run linear regression on these weighted data to get the local model
    localM <- lm(formula,weightedData)
    #summary(localM)
    
    # Get results out of localM
    # 1. parameter estimates, standard error, t-value
    results <- t(rbind( summary(localM)$coefficients[,1], # param estimates 
                        summary(localM)$coefficients[,2], # st errors
                        summary(localM)$coefficients[,3])) # t-values
    # Decompose this table of results into a row
    resultsRow <- results[1,]
    for (j in 2:length(variables)) 
    {resultsRow <- c(resultsRow,results[j,])}
    # Set back into data table
    # Find right position
    setHere <- which(names(data)== "Intercept_coeff")
    data[i,setHere:(setHere+length(resultsRow)-1)] <- resultsRow
    
    # 2. write statistics
    data$R2[i] <- summary(localM)$r.squared  
    data$AdjR2[i] <- summary(localM)$adj.r.squared 
    
    # 3. Calculate local residual (observed minus predicted)
    # Find observed value
    y <- data[i,which(names(data)== variables[1])]
    # Calculate predicted value
    yP <- as.matrix(dataReg[i,]) %*% as.matrix(results[,1]) # dot product
    data$LocRes[i] <- y-yP
    # Add predicted value to the table, for summary calculation later
    data$yP[i] <- yP
    
  } # End for loop for calculating individual models
  
  #-------  
  ## Step 3: Local residuals
  #------- 
  
  # Standardise local residuals
  mRes <- mean(data$LocRes)
  stRes <- sd(data$LocRes)
  data$StLocRes <- (data$LocRes-mRes)/stRes
  #head(data)
  
  #-------  
  ## Step 4: summary statistics 
  #------- 
  
  # Calculate AICc (GWR book, p. 61, eq. 2.33)
  # AICc = 2*n*ln(sigma2)+n*ln(2*pi)+ n*( (n+tr(H))/(n-2-tr(H))
  
  # n - sample size
  n <- noPoints
  
  # H - hat matrix = X (t(X) W X)^(-1) * t(X) * dW (GWR book, p. 55, eq. 2.20)
  # X - data matrix without dependent variable but with a column for intercept, used to calculate H
  # dW - weights matrix
  X <- as.data.frame(rep(1,n)) # add 1s for intercept
  X <- cbind.data.frame(X,dataReg[,2:ncol(dataReg)]) # exclude first column in dataReg, which is the dependant variable 
  XM <- as.matrix(X)
  WM <- as.matrix(dW)
  middle <- t(XM) %*% WM %*% XM 
  invX <- solve(middle) # calculate inverse of middle matrix
  H <- XM %*% invX %*% t(XM) %*% WM
  trH <- sum(diag(H)) # calculate trace of hat matrix, needed for AICc
  
  # sigma 2 - estimated st.dev of the error term
  # calculation taken from spgwr package, which follows GWR book
  B1 <- t(diag(n)-H)%*%(diag(n)-H)
  rss <- c(t(dataReg[,1])%*%B1%*%dataReg[,1])
  sigma2 <- rss/n
  
  # calculate AICc
  localAICc <- 2*n*log(sqrt(sigma2))+n*log(2*pi)+ n*((n+trH)/(n-2-trH))
  
  # Calculate average R2 and AdjR2
  summaryGWR <- c(mean(data$R2),mean(data$AdjR2),localAICc,bwOpt)
  names(summaryGWR) <- c('R2','AdjR2','AICc','bw')  
  
  #-------  
  ## Step 5: output 
  #------- 
  
  # Return the list with two elements:
  # 1. summary stats
  # 2. data table with all the results
  return(list(as.data.frame(t(summaryGWR)), data))
  
} # function
