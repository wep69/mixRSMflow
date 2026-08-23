\name{mix_collinearity}
\alias{mix_collinearity}
\title{Diagnose collinearity and estimability in mixture model matrices}
\usage{
mix_collinearity(object, spec = NULL, model = "scheffe_quadratic", tol = 1e-10)
}
\arguments{
  \item{object}{A `mix_fit`, `mix_design`, numeric matrix, or data frame.}
  \item{spec}{Mixture specification when `object` is a design/data frame.}
  \item{model}{Model basis for a design/data frame.}
  \item{tol}{Numerical rank tolerance.}
}
\description{
Diagnose collinearity and estimability in mixture model matrices
}
\details{
This help page is a prebuilt source-snapshot reference. The roxygen2 comments in the R source are authoritative and should be regenerated with roxygen2 during the local release gate.
}
\value{
A `mix_collinearity` object with singular values, condition indices, coefficient-correlation matrix, variance-decomposition proportions, and recommendations.
}
\seealso{\code{mix_capabilities()}, the package vignettes, and \code{mix_report()}.}
\examples{
sp <- mix_spec(c("A", "B", "C"))
d <- mix_design(sp, "simplex_lattice", degree = 3)
mix_collinearity(d, model = "scheffe_quadratic")
mix_collinearity(d, model = "scheffe_special_cubic")
fit <- mix_fit("response", mix_demo_data("mixture", n_rep = 2, seed = 8), sp)
mix_collinearity(fit)
}
