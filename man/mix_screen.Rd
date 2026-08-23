\name{mix_screen}
\alias{mix_screen}
\title{Screen component directional effects with uncertainty}
\usage{
mix_screen(object, direction = c("cox", "piepel"), reference = NULL,
                       level = 0.95, delta = 1e-5)
}
\arguments{
  \item{object}{A `mix_fit` object.}
  \item{direction}{`cox` or `piepel`.}
  \item{reference}{Feasible reference composition; defaults to `spec$center`.}
  \item{level}{Confidence level.}
  \item{delta}{Finite-difference step in path coordinates.}
}
\description{
Screen component directional effects with uncertainty
}
\details{
This help page is a prebuilt source-snapshot reference. The roxygen2 comments in the R source are authoritative and should be regenerated with roxygen2 during the local release gate.
}
\value{
Data frame of local directional slopes, standard errors, confidence intervals, and p-values.
}
\seealso{\code{mix_capabilities()}, the package vignettes, and \code{mix_report()}.}
\examples{
sp <- mix_spec(c("A", "B", "C"))
d <- mix_demo_data("mixture", n_rep = 2, seed = 13)
fit <- mix_fit("response", d, sp)
mix_screen(fit, direction = "cox")
mix_screen(fit, direction = "piepel")
mix_screen(fit, direction = "cox", reference = c(A = .4, B = .3, C = .3), level = .9)
}
