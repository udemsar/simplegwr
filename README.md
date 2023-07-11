
<!-- README.md is generated from README.Rmd. Please edit that file -->

# simplegwr

<!-- badges: start -->
<!-- badges: end -->

simplegwr is an R package with functions for a basic geographically
weighted regression analysis. It was developed for the purpose of
introductory undergraduate teaching, as other gwr packages are often too
complex for this level. It is also free of any dependencies on various
spatial packages that seem to come and go and only uses basic R
functions. As such the hope is that it does not have to be continuously
changed and that once students master this, they can use it throughout
their studies.

The package supports the following: - a linear and a Poisson GWR model -
using adaptive or fixed weighting - bi-square kernel - optimisation of
bandwidth for both linear and Poisson version using AICc

## Installation

You can install the latest (under development version) of simplegwr from
github with:

``` r
devtools::install_github("udemsar/simplegwr")
library(simplegwr)
```

## Example

We provide two data sets to test the package, one for linear (dataGWR)
and one for Poisson model (dataP).

Here is an example of a linear GWR model, using data on electoral
turnout in London. Specifically, we are modelling the relationship
between the turnout and two demographic characteristics, overcrowding
and population density. Note that input data have to have two geographic
coordinates, called x and y, which have to be in a projected coordinate
system (this won’t work for lon/lat coordinates!).

First run a global model

``` r
# Read test data 
data(dataGWR) 
head(dataGWR)
#>        CODE FID              BOROUGH           WARD  TURNOUT OVERCROWD
#> 1 E05000026 611 Barking and Dagenham          Abbey 25.68894 23.797025
#> 2 E05000027 617 Barking and Dagenham         Alibon 20.34793 13.246034
#> 3 E05000028 616 Barking and Dagenham      Becontree 22.53821 12.929624
#> 4 E05000029 622 Barking and Dagenham Chadwell Heath 25.31881  8.802638
#> 5 E05000030 621 Barking and Dagenham      Eastbrook 24.12147  7.100592
#> 6 E05000031 613 Barking and Dagenham       Eastbury 21.51488 14.840824
#>   POPDENSITY        x        y
#> 1  102.28800 544203.5 184358.4
#> 2   76.36029 549061.6 185152.9
#> 3   89.49612 547000.4 186088.3
#> 4   29.64793 548359.7 189490.8
#> 5   30.45217 550789.9 186100.8
#> 6   80.16552 546139.9 183989.2
plot(dataGWR$x,dataGWR$y)
```

<img src="man/figures/README-global linear model-1.png" width="100%" />

``` r

# Run a global linear model
globalmodel <- lm(dataGWR$TURNOUT ~ dataGWR$OVERCROWD + dataGWR$POPDENSITY)

# Explore results, which can later be compared to the local GWR model
summary(globalmodel)
#> 
#> Call:
#> lm(formula = dataGWR$TURNOUT ~ dataGWR$OVERCROWD + dataGWR$POPDENSITY)
#> 
#> Residuals:
#>      Min       1Q   Median       3Q      Max 
#> -14.4464  -2.6726   0.2904   3.0965  16.3113 
#> 
#> Coefficients:
#>                     Estimate Std. Error t value Pr(>|t|)    
#> (Intercept)        36.690793   0.446648  82.147  < 2e-16 ***
#> dataGWR$OVERCROWD  -0.404290   0.036691 -11.019  < 2e-16 ***
#> dataGWR$POPDENSITY  0.024482   0.004703   5.206 2.63e-07 ***
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> Residual standard error: 4.888 on 622 degrees of freedom
#> Multiple R-squared:  0.1634, Adjusted R-squared:  0.1607 
#> F-statistic: 60.73 on 2 and 622 DF,  p-value: < 2.2e-16
```

Now let’s test GWR modelling with fixed weighting.

``` r
## Test gwr functions
##-----------------------

## 1. fixed weighting

# Calculate Optimal bandwidth - because this is fixed weighting, this is given as geographic distance.
bwOptimisation <- gwr_bandwidth(TURNOUT ~ OVERCROWD + POPDENSITY, dataGWR, kernel="bisquare", weighting='fixed')
#> [1] "I am running 46 models, so this may take a while."
#> [1] 1
#> [1] 2
#> [1] 3
#> [1] 4
#> [1] 5
#> [1] 6
#> [1] 7
#> [1] 8
#> [1] 9
#> [1] 10
#> [1] 11
#> [1] 12
#> [1] 13
#> [1] 14
#> [1] 15
#> [1] 16
#> [1] 17
#> [1] 18
#> [1] 19
#> [1] 20
#> [1] 21
#> [1] 22
#> [1] 23
#> [1] 24
#> [1] 25
#> [1] 26
#> [1] 27
#> [1] 28
#> [1] 29
#> [1] 30
#> [1] 31
#> [1] 32
#> [1] 33
#> [1] 34
#> [1] 35
#> [1] 36
#> [1] 37
#> [1] 38
#> [1] 39
#> [1] 40
#> [1] 41
#> [1] 42
#> [1] 43
#> [1] 44
#> [1] 45
#> [1] 46
#> [1] "Done!"
bwOpt <- bwOptimisation[[1]] # This is the bandwidth where AICc is the lowest.
plot(bwOptimisation[[2]]) # This is a plot of all AICc values, to show how bwOpt was selected.
```

<img src="man/figures/README-fixed weighting GWR model-1.png" width="100%" />

``` r

# Run GWR with optimal bandwidth
localResults <- gwr_basic(TURNOUT ~ OVERCROWD + POPDENSITY, dataGWR, bwOpt, kernel="bisquare",
                          weighting='fixed')
# Results are a list with two elements: 1) summary statistics (R2, AICc), 2) a data frame with
# parameter estimates and related values (standard error, t-values, local residuals, predicted value)
# Explore results
localStats <- localResults[[1]]
localParams <- localResults[[2]]
localAIC <- localStats$AICc[1]
localStats
#>          R2     AdjR2     AICc
#> 1 0.6819003 0.6767244 3766.497
head(localParams)
#>        CODE FID              BOROUGH           WARD  TURNOUT OVERCROWD
#> 1 E05000026 611 Barking and Dagenham          Abbey 25.68894 23.797025
#> 2 E05000027 617 Barking and Dagenham         Alibon 20.34793 13.246034
#> 3 E05000028 616 Barking and Dagenham      Becontree 22.53821 12.929624
#> 4 E05000029 622 Barking and Dagenham Chadwell Heath 25.31881  8.802638
#> 5 E05000030 621 Barking and Dagenham      Eastbrook 24.12147  7.100592
#> 6 E05000031 613 Barking and Dagenham       Eastbury 21.51488 14.840824
#>   POPDENSITY        x        y Intercept_coeff Intercept_StErr Intercept_tvalue
#> 1  102.28800 544203.5 184358.4        4.167870       0.4537991         9.184394
#> 2   76.36029 549061.6 185152.9        5.055501       0.8081750         6.255454
#> 3   89.49612 547000.4 186088.3        4.871094       0.6984728         6.973921
#> 4   29.64793 548359.7 189490.8        4.518444       1.0247591         4.409274
#> 5   30.45217 550789.9 186100.8        4.952764       1.0355839         4.782581
#> 6   80.16552 546139.9 183989.2        4.720911       0.5166554         9.137447
#>   OVERCROWD_coeff OVERCROWD_StErr OVERCROWD_tvalue POPDENSITY_coeff
#> 1      0.80489600       0.1272348       6.32606706       0.05861034
#> 2      0.19219611       0.2404321       0.79937776       0.20413935
#> 3      0.45902460       0.2045545       2.24402048       0.13892294
#> 4      0.02303538       0.3455774       0.06665767       0.27756008
#> 5     -0.45524642       0.3472410      -1.31103891       0.36152454
#> 6      0.73231969       0.1452000       5.04352404       0.07149436
#>   POPDENSITY_StErr POPDENSITY_tvalue     LocRes   StLocRes        R2     AdjR2
#> 1       0.02558751          2.290584 -106.52849 -0.4287442 0.7704252 0.7676758
#> 2       0.04730453          4.315429 -100.65501 -0.2349515 0.5212906 0.5124256
#> 3       0.04045069          3.434378 -105.61562 -0.3986247 0.6175490 0.6113303
#> 4       0.06346677          4.373313  -97.51469 -0.1313380 0.4809050 0.4697416
#> 5       0.06211740          5.820020 -103.12316 -0.3163870 0.4762267 0.4647152
#> 6       0.02970013          2.407207  -96.65455 -0.1029580 0.7201780 0.7162089
#>         yP
#> 1 132.2174
#> 2 121.0029
#> 3 128.1538
#> 4 122.8335
#> 5 127.2446
#> 6 118.1694
```

And with adaptive weighting:

``` r
##-----------------------
## 2. adaptive weighting
# Here the bandwidth is number of nearest neighbours
bwOptimisation <- gwr_bandwidth(TURNOUT ~ POPDENSITY + OVERCROWD, dataGWR, kernel="bisquare", weighting='adaptive')
#> [1] "I am running 51 models, so this may take a while."
#> [1] 1
#> [1] 2
#> [1] 3
#> [1] 4
#> [1] 5
#> [1] 6
#> [1] 7
#> [1] 8
#> [1] 9
#> [1] 10
#> [1] 11
#> [1] 12
#> [1] 13
#> [1] 14
#> [1] 15
#> [1] 16
#> [1] 17
#> [1] 18
#> [1] 19
#> [1] 20
#> [1] 21
#> [1] 22
#> [1] 23
#> [1] 24
#> [1] 25
#> [1] 26
#> [1] 27
#> [1] 28
#> [1] 29
#> [1] 30
#> [1] 31
#> [1] 32
#> [1] 33
#> [1] 34
#> [1] 35
#> [1] 36
#> [1] 37
#> [1] 38
#> [1] 39
#> [1] 40
#> [1] 41
#> [1] 42
#> [1] 43
#> [1] 44
#> [1] 45
#> [1] 46
#> [1] 47
#> [1] 48
#> [1] 49
#> [1] 50
#> [1] 51
#> [1] "Done!"
bwOpt <- bwOptimisation[[1]]
plot(bwOptimisation[[2]])
```

<img src="man/figures/README-adaptive weighting gwr model-1.png" width="100%" />

``` r

# GWR with optimal bandwidth
localResults <- gwr_basic(TURNOUT ~ POPDENSITY + OVERCROWD, dataGWR, bwOpt, kernel="bisquare",
                          weighting='adaptive')
localStats <- localResults[[1]]
localParams <- localResults[[2]]
localAIC <- localStats$AICc[1]
localStats
#>          R2    AdjR2     AICc
#> 1 0.8248719 0.808193 3768.215
head(localParams)
#>        CODE FID              BOROUGH           WARD  TURNOUT OVERCROWD
#> 1 E05000026 611 Barking and Dagenham          Abbey 25.68894 23.797025
#> 2 E05000027 617 Barking and Dagenham         Alibon 20.34793 13.246034
#> 3 E05000028 616 Barking and Dagenham      Becontree 22.53821 12.929624
#> 4 E05000029 622 Barking and Dagenham Chadwell Heath 25.31881  8.802638
#> 5 E05000030 621 Barking and Dagenham      Eastbrook 24.12147  7.100592
#> 6 E05000031 613 Barking and Dagenham       Eastbury 21.51488 14.840824
#>   POPDENSITY        x        y Intercept_coeff Intercept_StErr Intercept_tvalue
#> 1  102.28800 544203.5 184358.4       1.1764165       0.9681603        1.2151050
#> 2   76.36029 549061.6 185152.9       3.0042353       0.8647976        3.4739173
#> 3   89.49612 547000.4 186088.3       0.2955561       0.8301199        0.3560402
#> 4   29.64793 548359.7 189490.8       1.8946512       1.5771504        1.2013130
#> 5   30.45217 550789.9 186100.8       1.9816339       1.7393597        1.1392893
#> 6   80.16552 546139.9 183989.2       0.5199702       0.9532162        0.5454904
#>   POPDENSITY_coeff POPDENSITY_StErr POPDENSITY_tvalue OVERCROWD_coeff
#> 1        0.6719704        0.3261443         2.0603467     0.101750901
#> 2        1.4482403        0.3707576         3.9061649    -0.007418669
#> 3        1.1895056        0.4428013         2.6863190     0.103961710
#> 4        1.7830846        0.6188862         2.8811186     0.110943653
#> 5       -0.6149334        0.8936432        -0.6881196     0.489759747
#> 6        0.9715127        0.3152319         3.0818982     0.095240788
#>   OVERCROWD_StErr OVERCROWD_tvalue     LocRes   StLocRes        R2     AdjR2
#> 1      0.07010373        1.4514335 -30.930745  0.4068518 0.8979738 0.8882570
#> 2      0.06205066       -0.1195583 -59.398979 -0.1988985 0.8408239 0.8256642
#> 3      0.07503520        1.3855059  -8.807124  0.8776006 0.9059735 0.8970186
#> 4      0.09612137        1.1542038 -41.636606  0.1790513 0.6750535 0.6441063
#> 5      0.17606169        2.7817508 -34.226310  0.3367284 0.5752463 0.5347936
#> 6      0.06109192        1.5589752 -11.725295  0.8155075 0.8457873 0.8311004
#>         yP
#> 1 56.61969
#> 2 79.74690
#> 3 31.34533
#> 4 66.95542
#> 5 58.34778
#> 6 33.24017
```

Example for Poisson model, here we model how count of deer on camera
traps is related to vegetation height and elevation. Note that input
data have to have two geographic coordinates, called x and y, which have
to be in a projected coordinate system (this won’t work for lon/lat
coordinates!).

As before, first build a global model:

``` r
# Test on camera trap data
data(dataP) 
head(dataP)
#>   Camera       Lon      Lat Heigh_vege Deer Elevation        x        y
#> 1   shp1 -4.169806 56.62001     30.450  170       585 266955.3 749679.4
#> 2  shp10 -4.213999 56.61598     21.450   83       762 264229.6 749317.5
#> 3  shp11 -4.203300 56.61360     25.275  127       644 264877.5 749032.3
#> 4  shp12 -4.187722 56.62476     24.825   42       649 265873.0 750243.2
#> 5  shp13 -4.226357 56.61016     32.275    7       614 263450.3 748694.8
#> 6  shp14 -4.225610 56.62131     11.000    2       995 263536.4 749934.3
formula <- Deer ~ Elevation + Heigh_vege

# Global Poisson regression
globalPM <- glm(formula, family = poisson(link = log), data = dataP)
summary(globalPM)
#> 
#> Call:
#> glm(formula = formula, family = poisson(link = log), data = dataP)
#> 
#> Coefficients:
#>               Estimate Std. Error z value Pr(>|z|)    
#> (Intercept)  5.2207200  0.0994715  52.485  < 2e-16 ***
#> Elevation   -0.0009563  0.0001106  -8.648  < 2e-16 ***
#> Heigh_vege  -0.0169619  0.0024099  -7.038 1.94e-12 ***
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> (Dispersion parameter for poisson family taken to be 1)
#> 
#>     Null deviance: 1723.8  on 38  degrees of freedom
#> Residual deviance: 1637.2  on 36  degrees of freedom
#> AIC: 1862.7
#> 
#> Number of Fisher Scoring iterations: 5
globalPM$coefficients[[1]]
#> [1] 5.22072
globalPM$coefficients[[2]]
#> [1] -0.0009563084
globalPM$coefficients[[3]]
#> [1] -0.01696189
summary(globalPM)
#> 
#> Call:
#> glm(formula = formula, family = poisson(link = log), data = dataP)
#> 
#> Coefficients:
#>               Estimate Std. Error z value Pr(>|z|)    
#> (Intercept)  5.2207200  0.0994715  52.485  < 2e-16 ***
#> Elevation   -0.0009563  0.0001106  -8.648  < 2e-16 ***
#> Heigh_vege  -0.0169619  0.0024099  -7.038 1.94e-12 ***
#> ---
#> Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
#> 
#> (Dispersion parameter for poisson family taken to be 1)
#> 
#>     Null deviance: 1723.8  on 38  degrees of freedom
#> Residual deviance: 1637.2  on 36  degrees of freedom
#> AIC: 1862.7
#> 
#> Number of Fisher Scoring iterations: 5
summary(globalPM)$coefficients[,1] # param estimates 
#>   (Intercept)     Elevation    Heigh_vege 
#>  5.2207200074 -0.0009563084 -0.0169618894
summary(globalPM)$coefficients[1,1]  
#> [1] 5.22072
summary(globalPM)$coefficients[,2] # st errors
#>  (Intercept)    Elevation   Heigh_vege 
#> 0.0994714906 0.0001105811 0.0024099098
summary(globalPM)$coefficients[,3] # t-values
#> (Intercept)   Elevation  Heigh_vege 
#>   52.484586   -8.648029   -7.038392
summary(globalPM)$coefficients[,4] # p-values
#>  (Intercept)    Elevation   Heigh_vege 
#> 0.000000e+00 5.239664e-18 1.944711e-12
#str(summary(globalPM))
globalPM$deviance[[1]] #deviance
#> [1] 1637.205
globalAIC <- globalPM$aic[[1]] #aic
```

And then we can test Poisson GWR, this time just adaptive weighting
(although fixed also works).

``` r

## 1. adaptive weighting
bwOptimisation <- gwr_poisson_bandwidth(formula, dataP, kernel="bisquare", weighting='adaptive')
#> [1] "I am running 35 models, so this may take a while."
#> [1] 1
#> Warning in log(yy/yyP): NaNs produced
#> [1] 2
#> Warning in log(yy/yyP): NaNs produced
#> [1] 3
#> Warning in log(yy/yyP): NaNs produced
#> [1] 4
#> Warning in log(yy/yyP): NaNs produced
#> [1] 5
#> Warning in log(yy/yyP): NaNs produced
#> [1] 6
#> Warning in log(yy/yyP): NaNs produced
#> [1] 7
#> Warning in log(yy/yyP): NaNs produced
#> [1] 8
#> Warning in log(yy/yyP): NaNs produced
#> [1] 9
#> Warning in log(yy/yyP): NaNs produced
#> [1] 10
#> [1] 11
#> [1] 12
#> [1] 13
#> [1] 14
#> [1] 15
#> [1] 16
#> [1] 17
#> [1] 18
#> [1] 19
#> [1] 20
#> [1] 21
#> [1] 22
#> [1] 23
#> [1] 24
#> [1] 25
#> [1] 26
#> [1] 27
#> [1] 28
#> [1] 29
#> [1] 30
#> [1] 31
#> [1] 32
#> [1] 33
#> [1] 34
#> [1] 35
#> [1] "Done!"
bwOpt <- bwOptimisation[[1]]
plot(bwOptimisation[[2]])
```

<img src="man/figures/README-adaptive weighting Poisson model-1.png" width="100%" />

``` r
# GWR with optimal bandwidth
localResultsP <- gwr_poisson(formula, dataP, bwOpt, kernel="bisquare",
                             weighting='adaptive')
#> Warning in log(yy/yyP): NaNs produced
localStats <- localResultsP[[1]]
localParams <- localResultsP[[2]]
localAIC <- localStats$AIC[1]
localStats
#>   Deviance     AICc
#> 1      NaN 278.2093
head(localParams)
#>   Camera       Lon      Lat Heigh_vege Deer Elevation        x        y
#> 1   shp1 -4.169806 56.62001     30.450  170       585 266955.3 749679.4
#> 2  shp10 -4.213999 56.61598     21.450   83       762 264229.6 749317.5
#> 3  shp11 -4.203300 56.61360     25.275  127       644 264877.5 749032.3
#> 4  shp12 -4.187722 56.62476     24.825   42       649 265873.0 750243.2
#> 5  shp13 -4.226357 56.61016     32.275    7       614 263450.3 748694.8
#> 6  shp14 -4.225610 56.62131     11.000    2       995 263536.4 749934.3
#>   Intercept_coeff Intercept_StErr Intercept_tvalue Elevation_coeff
#> 1      1.07584863       0.2236789        4.8097903     0.012320073
#> 2      0.94884624       0.2331599        4.0695094     0.002412939
#> 3      0.03938834       0.3055684        0.1289019    -0.002174586
#> 4     -0.65529987       0.4655810       -1.4074883     0.035678969
#> 5      0.35221465       0.2725089        1.2924886     0.004949817
#> 6      0.79912589       0.2457985        3.2511425     0.015940331
#>   Elevation_StErr Elevation_tvalue Heigh_vege_coeff Heigh_vege_StErr
#> 1     0.003476259        3.5440611     0.0004040098     0.0011602173
#> 2     0.002388831        1.0100922     0.0027772823     0.0005042061
#> 3     0.003836942       -0.5667497     0.0055554355     0.0009857644
#> 4     0.014469833        2.4657486     0.0034116978     0.0008117339
#> 5     0.005228928        0.9466219     0.0047163335     0.0005586649
#> 6     0.006527755        2.4419315     0.0019015389     0.0003660687
#>   Heigh_vege_tvalue     LocRes      StLocRes deviance      AIC         yP
#> 1          0.348219 134.909651  1.4190218717 27.86521 72.28337  35.090349
#> 2          5.508229  60.330685  0.1027807127 38.13493 85.96121  22.669315
#> 3          5.635662 122.702932  1.2035859724  9.95289 51.54466   4.297068
#> 4          4.202976  54.555111  0.0008478333 11.77948 51.98517 -12.555111
#> 5          8.442151  -7.298205 -1.0907988422 23.60691 67.36339  14.298205
#> 6          5.194487  -8.714297 -1.1157913792 26.63396 70.18569  10.714297
plot(sort(localParams$Intercept_coeff))
```

<img src="man/figures/README-adaptive weighting Poisson model-2.png" width="100%" />

``` r
plot(sort(localParams$Intercept_tvalue))
```

<img src="man/figures/README-adaptive weighting Poisson model-3.png" width="100%" />

``` r
plot(sort(localParams$Elevation_coeff))
```

<img src="man/figures/README-adaptive weighting Poisson model-4.png" width="100%" />

``` r
plot(sort(localParams$Elevation_tvalue))
```

<img src="man/figures/README-adaptive weighting Poisson model-5.png" width="100%" />

``` r
plot(sort(localParams$Heigh_vege_coeff))
```

<img src="man/figures/README-adaptive weighting Poisson model-6.png" width="100%" />

``` r
plot(sort(localParams$Heigh_vege_tvalue))
```

<img src="man/figures/README-adaptive weighting Poisson model-7.png" width="100%" />
