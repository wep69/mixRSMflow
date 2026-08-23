\name{mix_fit_gls}
\alias{mix_fit_gls}
\title{Fit weighted/generalized least-squares mixture models through nlme}
\usage{
mix_fit_gls(response, data, spec = NULL, model = "scheffe_quadratic",
                        process = NULL, mixture_process = FALSE,
                        correlation = NULL, variance = NULL, method = c("REML", "ML"),
                        terms = NULL, ...)
}
\arguments{
  \item{response}{Response column name.}
  \item{data}{Data frame or `mix_design`.}
  \item{spec}{Mixture specification.}
  \item{model}{Mixture basis.}
  \item{process}{Optional process-variable names.}
  \item{mixture_process}{Include mixture-process interactions.}
  \item{correlation}{Optional `nlme` correlation structure.}
  \item{variance}{Optional `nlme` variance function (e.g. `varIdent`, `varPower`).}
  \item{method}{`REML` or `ML`.}
  \item{terms}{Optional basis terms to retain.}
  \item{...}{Additional arguments passed to or from other methods.}
}
\description{
Fit weighted/generalized least-squares mixture models through nlme
}
\details{
This help page is a prebuilt source-snapshot reference. The roxygen2 comments in the R source are authoritative and should be regenerated with roxygen2 during the local release gate.
}
\value{
A `mix_fit_gls` object.
}
\seealso{\code{mix_capabilities()}, the package vignettes, and \code{mix_report()}.}
\examples{
if (requireNamespace("nlme", quietly = TRUE)) {
  sp <- mix_spec(c("A", "B", "C"))
  d <- mix_demo_data("mixture", n_rep = 2, seed = 7)
  gf <- mix_fit_gls("response", d, sp, model = "scheffe_quadratic", method = "ML")
  gf
  gf2 <- mix_fit_gls("response", d, sp, model = "scheffe_linear", method = "REML")
  gf3 <- mix_fit_gls("response", d, sp, model = "scheffe_quadratic", method = "ML",
                     terms = c("A", "B", "C", "A:B"))
  gf2
  gf3
}
}
