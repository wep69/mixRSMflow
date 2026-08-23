\name{mix_capabilities}
\alias{mix_capabilities}
\title{Inspect the package capability registry}
\usage{
mix_capabilities(module = NULL, tier = NULL)
}
\arguments{
  \item{module}{Optional module filter.}
  \item{tier}{Optional validation-tier filter.}
}
\description{
Inspect the package capability registry
}
\details{
This help page is a prebuilt source-snapshot reference. The roxygen2 comments in the R source are authoritative and should be regenerated with roxygen2 during the local release gate.
}
\value{
A data frame describing source-implemented capabilities, optional backends, target validation tiers, and current runtime-certification status.
}
\seealso{\code{mix_capabilities()}, the package vignettes, and \code{mix_report()}.}
\examples{
head(mix_capabilities())
mix_capabilities(module = "optimal_design")
mix_capabilities(module = "design")
nrow(mix_capabilities())
}
