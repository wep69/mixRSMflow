\name{mix_compare}
\alias{mix_compare}
\title{Compare fitted mixture models without selecting solely by one metric}
\usage{
mix_compare(..., criterion = NULL)
}
\arguments{
  \item{criterion}{Optional ordering criterion: `AIC`, `BIC`, `RMSE`, or `PRESS`.}
  \item{...}{Additional arguments passed to or from other methods.}
}
\description{
Compare fitted mixture models without selecting solely by one metric
}
\details{
This help page is a prebuilt source-snapshot reference. The roxygen2 comments in the R source are authoritative and should be regenerated with roxygen2 during the local release gate.
}
\value{
Comparison table with model size, fit, prediction, and conditioning metrics.
}
\seealso{\code{mix_capabilities()}, the package vignettes, and \code{mix_report()}.}
\examples{
sp <- mix_spec(c("A", "B", "C"))
d <- mix_demo_data("mixture", n_rep = 2, seed = 10)
f1 <- mix_fit("response", d, sp, model = "scheffe_linear")
f2 <- mix_fit("response", d, sp, model = "scheffe_quadratic")
mix_compare(f1, f2, criterion = "PRESS")
f3 <- mix_fit("response", d, sp, model = "scheffe_special_cubic")
mix_compare(f1, f2, f3, criterion = "AIC")
mix_compare(f1, f2)
}
