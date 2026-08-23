\name{mix_moments}
\alias{mix_moments}
\title{Compute moments over a simplex or approximate moments over a constrained region}
\usage{
mix_moments(spec, powers, method = c("auto", "exact", "monte_carlo"), n = 100000L, seed =
1L)
}
\arguments{
  \item{spec}{Mixture specification.}
  \item{powers}{Non-negative exponent vector or matrix; one column per component.}
  \item{method}{`auto`, `exact`, or `monte_carlo`. Exact moments are available for the unrestricted simplex.}
  \item{n}{Number of Monte Carlo feasible points.}
  \item{seed}{Random seed.}
}
\description{
Compute moments over a simplex or approximate moments over a constrained region
}
\details{
This help page is a prebuilt source-snapshot reference. The roxygen2 comments in the R source are authoritative and should be regenerated with roxygen2 during the local release gate.
}
\value{
Data frame containing one moment for each row of `powers`.
}
\seealso{\code{mix_capabilities()}, the package vignettes, and \code{mix_report()}.}
\examples{
sp <- mix_spec(c("A", "B", "C"))
mix_moments(sp, powers = c(1, 1, 0), method = "exact")
mix_moments(sp, powers = c(2, 0, 0), method = "exact")
mix_moments(sp, powers = c(1, 1, 1), method = "monte_carlo", n = 20000, seed = 2)
}
