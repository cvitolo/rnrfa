\name{stationSummary}
\alias{stationSummary}
\docType{data}
\title{
stationSummary
}
\description{
table containing details for 1537 stations.
}
\usage{data(stationSummary)}
\format{
  A data frame with 1537 observations on the following 20 variables.
  \describe{
    \item{\code{id}}{a list vector}
    \item{\code{name}}{a list vector}
    \item{\code{location}}{a list vector}
    \item{\code{river}}{a list vector}
    \item{\code{stationDescription}}{a list vector}
    \item{\code{catchmentDescription}}{a list vector}
    \item{\code{hydrometricArea}}{a list vector}
    \item{\code{operator}}{a list vector}
    \item{\code{haName}}{a list vector}
    \item{\code{gridReference}}{a list vector}
    \item{\code{stationType}}{a list vector}
    \item{\code{catchmentArea}}{a list vector}
    \item{\code{gdfStart}}{a list vector}
    \item{\code{gdfEnd}}{a list vector}
    \item{\code{farText}}{a list vector}
    \item{\code{categories}}{a list vector}
    \item{\code{altitude}}{a list vector}
    \item{\code{sensitivity}}{a list vector}
    \item{\code{Latitude}}{a numeric vector}
    \item{\code{Longitude}}{a numeric vector}
  }
}
\details{
This is the full set of river station that can be retrieved using UK NRFA APIs.
}
\source{
http://www.ceh.ac.uk/data/nrfa/
}
\examples{
data(stationSummary)
}
\keyword{datasets}
