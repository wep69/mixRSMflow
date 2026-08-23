\name{mix_multi_fit}
\alias{mix_multi_fit}
\title{Fit several responses using a shared mixture specification}
\usage{
mix_multi_fit(responses,data,spec=NULL,...)
}
\arguments{
  \item{responses}{Character vector of response columns.}
  \item{data}{Data frame or `mix_design`.}
  \item{spec}{Mixture specification.}
  \item{...}{Additional arguments passed to or from other methods.}
}
\description{
Fit several responses using a shared mixture specification
}
\details{
This help page is a prebuilt source-snapshot reference. The roxygen2 comments in the R source are authoritative and should be regenerated with roxygen2 during the local release gate.
}
\value{
A `mix_multi_fit` object.
}
\seealso{\code{mix_capabilities()}, the package vignettes, and \code{mix_report()}.}
\examples{
sp <- mix_spec(c("A", "B", "C"))
d <- mix_demo_data("multiresponse", n_rep = 2, seed = 22)
mf <- mix_multi_fit(c("quality", "stability"), d, sp, model = "scheffe_quadratic")
mf
mf2 <- mix_multi_fit(c("quality", "stability"), d, sp, model = "scheffe_linear")
mf3 <- mix_multi_fit("quality", d, sp, model = "scheffe_special_cubic")
mf3
}
