% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/gwr_poisson_bandwidth.R
\name{gwr_poisson_bandwidth}
\alias{gwr_poisson_bandwidth}
\title{Optimal bandwidth for Poisson GWR}
\usage{
gwr_poisson_bandwidth(formula, data, kernel, weighting)
}
\arguments{
\item{formula}{regression formula}

\item{data}{data frame of points with columns for regression formula, including x and y coordinates of all points}

\item{kernel}{kernel type (default is bisquare for now)}

\item{weighting}{weighting if "adaptive", calculate an adaptive kernel where the bandwidth (bw) corresponds to the number of nearest neighbours (i.e. adaptive distance); if "fixed", a fixed kernel is found (bandwidth is a fixed distance)}
}
\value{
Returns a list with two elements: the first element is a data frame with summary statistics, the second element is a data frame with original data and parameter estimates
}
\description{
This function optimised bandwidth for a Poisson gwr model using AICc optimisation (i.e. optimal
bandwidth is the one where AICc is minimal).
}
