\name{mix_optimum_ci}
\alias{mix_optimum_ci}
\title{Quantify uncertainty in the location of the optimum}
\usage{
mix_optimum_ci(object,method=c("parametric","residual_bootstrap"),B=500L,level=0.95,
                           grid_resolution=20L,seed=1L)
}
\arguments{
  \item{object}{A `mix_optimum` or `mix_fit` object.}
  \item{method}{`parametric` coefficient simulation or `residual_bootstrap`.}
  \item{B}{Number of draws/bootstrap replicates.}
  \item{level}{Confidence level.}
  \item{grid_resolution}{Optimization grid used for each replicate.}
  \item{seed}{Random seed.}
}
\description{
Quantify uncertainty in the location of the optimum
}
\details{
This help page is a prebuilt source-snapshot reference. The roxygen2 comments in the R source are authoritative and should be regenerated with roxygen2 during the local release gate.
}
\value{
A `mix_optimum_ci` object with marginal intervals and a joint cloud of optimal compositions.
}
\seealso{\code{mix_capabilities()}, the package vignettes, and \code{mix_report()}.}
\examples{
sp <- mix_spec(c("A", "B", "C"))
d <- mix_design(sp, "simplex_lattice", degree = 4)$data
set.seed(5)
d$response <- with(d, 6*A + 5*B + 5.5*C + 3*A*B + 2*A*C + 2*B*C) + rnorm(nrow(d), 0, 0.5)
fit <- mix_fit("response", d, sp)
ci <- mix_optimum_ci(fit, method = "parametric", B = 10, grid_resolution = 6, seed = 2)
ci$intervals
ci2 <- mix_optimum_ci(fit, method = "residual_bootstrap", B = 10, grid_resolution = 6, seed = 3)
ci2$intervals
mix_optimum_ci(fit, method = "parametric", B = 10, level = .9, grid_resolution = 6, seed = 4)
}
