\name{mix_biplot}
\alias{mix_biplot}
\title{Multiresponse prediction biplot over the feasible mixture region}
\usage{
mix_biplot(object, resolution = 20L, scale = TRUE, plot = TRUE)
}
\arguments{
  \item{object}{A `mix_multi_fit` object.}
  \item{resolution}{Candidate-grid resolution.}
  \item{scale}{Standardize responses before PCA.}
  \item{plot}{If `TRUE`, return a ggplot biplot as well.}
}
\description{
Multiresponse prediction biplot over the feasible mixture region
}
\details{
This help page is a prebuilt source-snapshot reference. The roxygen2 comments in the R source are authoritative and should be regenerated with roxygen2 during the local release gate.
}
\value{
A `mix_biplot` object containing PCA scores, loadings, candidate compositions, and optional plot.
}
\seealso{\code{mix_capabilities()}, the package vignettes, and \code{mix_report()}.}
\examples{
sp <- mix_spec(c("A", "B", "C"))
d <- mix_demo_data("multiresponse", n_rep = 2, seed = 16)
mf <- mix_multi_fit(c("quality", "stability"), d, sp, model = "scheffe_quadratic")
bp <- mix_biplot(mf, resolution = 8, plot = FALSE)
bp$loadings
bp2 <- mix_biplot(mf, resolution = 8, scale = FALSE, plot = FALSE)
bp2$loadings
mf2 <- mix_multi_fit(c("quality", "stability"), d, sp, model = "scheffe_linear")
bp3 <- mix_biplot(mf2, resolution = 6, plot = FALSE)
}
