\name{mix_diagnose}
\alias{mix_diagnose}
\title{Diagnose a fitted mixture model}
\usage{
mix_diagnose(object)
}
\arguments{
  \item{object}{A `mix_fit` object.}
}
\description{
Diagnose a fitted mixture model
}
\details{
This help page is a prebuilt source-snapshot reference. The roxygen2 comments in the R source are authoritative and should be regenerated with roxygen2 during the local release gate.
}
\value{
A `mix_diagnostics` object with observation-level and matrix diagnostics.
}
\seealso{\code{mix_capabilities()}, the package vignettes, and \code{mix_report()}.}
\examples{
sp <- mix_spec(c("A", "B", "C"))
d <- mix_demo_data("mixture", n_rep = 2, seed = 9)
fit <- mix_fit("response", d, sp)
mix_diagnose(fit)
dg <- mix_diagnose(fit)
names(dg)
fit2 <- mix_fit("response", d, sp, model = "scheffe_linear")
mix_diagnose(fit2)
}
