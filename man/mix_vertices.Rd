\name{mix_vertices}
\alias{mix_vertices}
\title{Enumerate extreme vertices of a linearly constrained mixture region}
\usage{
mix_vertices(spec, max_combinations = 250000L, tol = spec$tol \%||\% 1e-8)
}
\arguments{
  \item{spec}{A `mix_spec` or polytope `mix_region` object.}
  \item{max_combinations}{Safety limit for active-set combinations.}
  \item{tol}{Numerical tolerance.}
}
\description{
Uses active-set enumeration for the equality `sum(x)=total` plus bound and general linear inequalities. Intended for moderate-dimensional constrained mixture problems.
}
\details{
This help page is a prebuilt source-snapshot reference. The roxygen2 comments in the R source are authoritative and should be regenerated with roxygen2 during the local release gate.
}
\value{
Data frame of unique feasible extreme vertices.
}
\seealso{\code{mix_capabilities()}, the package vignettes, and \code{mix_report()}.}
\examples{
sp <- mix_spec(c("A", "B", "C"), lower = c(.1, .1, .1), upper = c(.7, .8, .8))
mix_vertices(sp)
nrow(mix_vertices(sp))
sp2 <- mix_spec(c("A", "B", "C"), lower = c(.1, .1, .1), upper = c(.7, .8, .8),
                A = matrix(c(1, 1, 0), 1), b = .75)
mix_vertices(sp2)
}
