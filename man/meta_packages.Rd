% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/meta_packages.R
\name{meta_packages}
\alias{meta_packages}
\title{List package metadata}
\usage{
meta_packages(repo = "https://community.r-multiverse.org")
}
\arguments{
\item{repo}{Character of length 1, URL of the package repository.
R-multiverse uses \code{"https://community.r-multiverse.org"}.}
}
\value{
A data frame with one row per package and columns with package
metadata.
}
\description{
List package metadata in an R universe.
}
\examples{
meta_packages(repo = "https://wlandau.r-universe.dev")
}
\seealso{
Other meta: 
\code{\link{meta_checks}()}
}
\concept{meta}
