\name{mix_gbm_term}
\alias{mix_gbm_term}
\title{Define one general blending model term}
\usage{
mix_gbm_term(components, g = 1, h = NULL, s = 1, label = NULL)
}
\arguments{
  \item{components}{Two or three component names (or positions).}
  \item{g}{Component-specific non-negative/flexible power parameters.}
  \item{h}{For a binary term, one allocation parameter. For a ternary term, two allocation parameters whose sum is at most one.}
  \item{s}{Homogeneity/order exponent applied to the component subtotal.}
  \item{label}{Optional basis-column label.}
}
\description{
Creates a validated term specification for the general blending model (GBM) parameterization of Brown, Donev and Bissett. The nonlinear exponents are fixed by this specification; the associated regression coefficient is then
}
\details{
This help page is a prebuilt source-snapshot reference. The roxygen2 comments in the R source are authoritative and should be regenerated with roxygen2 during the local release gate.
}
\value{
A list suitable for the `gbm_terms` argument of [mix_basis()] or [mix_fit()].
}
\references{
Brown, L., Donev, A. N., & Bissett, A. C. (2015). General Blending Models for Data From Mixture Experiments. Technometrics, 57, 449-456. doi:10.1080/00401706.2014.947003.
}
\seealso{\code{mix_capabilities()}, the package vignettes, and \code{mix_report()}.}
\examples{
term <- mix_gbm_term(c("A", "B"), g = c(1, 1), h = 0.5, s = 1)
term
sp <- mix_spec(c("A", "B", "C"))
X <- mix_basis(data.frame(A = .2, B = .3, C = .5), sp, "gbm", gbm_terms = list(term))
X
mix_gbm_term(c("A", "B", "C"), g = c(1, 1, 1), h = 1/3, s = 1)
mix_gbm_term(c("A", "B", "C"), g = c(1, 2, 1), h = c(0.25, 0.25), s = 1)
}
