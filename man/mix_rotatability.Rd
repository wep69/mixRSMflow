\name{mix_rotatability}
\alias{mix_rotatability}
\title{Assess approximate rotatability through radial prediction-variance dispersion}
\usage{
mix_rotatability(design, spec = NULL, model = "scheffe_quadratic", bins = 6L, resolution
= 18L)
}
\arguments{
  \item{design}{A `mix_design` or data frame.}
  \item{spec}{Mixture specification when `design` is a data frame.}
  \item{model}{Model basis.}
  \item{bins}{Number of radial bins in independent coordinates.}
  \item{resolution}{Evaluation-grid resolution.}
}
\description{
Assess approximate rotatability through radial prediction-variance dispersion
}
\details{
This help page is a prebuilt source-snapshot reference. The roxygen2 comments in the R source are authoritative and should be regenerated with roxygen2 during the local release gate.
}
\value{
A `mix_rotatability` object. A score near one indicates low within-radius variance dispersion.
}
\seealso{\code{mix_capabilities()}, the package vignettes, and \code{mix_report()}.}
\examples{
sp <- mix_spec(c("A", "B", "C"))
d <- mix_design(sp, "simplex_lattice", degree = 3)
mix_rotatability(d, model = "scheffe_quadratic", resolution = 8)
mix_rotatability(d, model = "scheffe_linear", resolution = 8)
mix_rotatability(d, model = "scheffe_quadratic", bins = 4, resolution = 8)
}
