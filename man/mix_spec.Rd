\name{mix_spec}
\alias{mix_spec}
\title{Define a mixture specification}
\usage{
mix_spec(components, total = 1, lower = 0, upper = total,
                     A = NULL, b = NULL, dir = "<=", units = "proportion",
                     tol = 1e-8)
}
\arguments{
  \item{components}{Character vector of component names.}
  \item{total}{Mixture total, usually 1 or 100.}
  \item{lower}{Lower bounds for each component.}
  \item{upper}{Upper bounds for each component.}
  \item{A}{Optional linear-constraint matrix with one column per component.}
  \item{b}{Right-hand side vector for `A`.}
  \item{dir}{Direction(s) for the linear restrictions: `<=`, `>=`, or `==`.}
  \item{units}{Optional text describing component units.}
  \item{tol}{Numerical feasibility tolerance.}
}
\description{
Creates the central specification object used by all mixRSMflow workflows. Components are constrained to sum to `total`, while optional lower, upper, and linear restrictions define the feasible composition region.
}
\details{
This help page is a prebuilt source-snapshot reference. The roxygen2 comments in the R source are authoritative and should be regenerated with roxygen2 during the local release gate.
}
\value{
An object of class `mix_spec`.
}
\seealso{\code{mix_capabilities()}, the package vignettes, and \code{mix_report()}.}
\examples{
sp <- mix_spec(c("A", "B", "C"))
sp
sp2 <- mix_spec(c("A", "B", "C"), lower = c(.1, .1, .1), upper = c(.7, .8, .8))
sp2
rg <- mix_region(sp, type = "sphere", radius = 0.2)
rg$region
sp3 <- mix_spec(c("A", "B", "C"), A = matrix(c(1, 0, 0), nrow = 1), b = 0.5)
sp3
}
