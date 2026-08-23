\name{mix_reparameterize}
\alias{mix_reparameterize}
\title{Reparameterize an equivalent Scheffe model with an intercept and slack component}
\usage{
mix_reparameterize(object, slack_component = NULL)
}
\arguments{
  \item{object}{A Gaussian or GLM `mix_fit` fitted with `scheffe_linear` or `scheffe_quadratic`.}
  \item{slack_component}{Component to eliminate through the mixture total constraint.}
}
\description{
For linear and quadratic Scheffe models this function refits the same response space using a slack-variable polynomial. The transformation is useful for teaching, numerical diagnostics, and comparison of coefficient interpretations.
}
\details{
This help page is a prebuilt source-snapshot reference. The roxygen2 comments in the R source are authoritative and should be regenerated with roxygen2 during the local release gate.
}
\value{
A new `mix_fit` object with model `slack_linear` or `slack_quadratic`.
}
\seealso{\code{mix_capabilities()}, the package vignettes, and \code{mix_report()}.}
\examples{
sp <- mix_spec(c("A", "B", "C"))
d <- mix_demo_data("mixture", n_rep = 2, seed = 11)
fit <- mix_fit("response", d, sp, model = "scheffe_quadratic")
slack <- mix_reparameterize(fit, slack_component = "C")
slack$reparameterization
slack2 <- mix_reparameterize(fit, slack_component = "A")
slack2$reparameterization
fit_lin <- mix_fit("response", d, sp, model = "scheffe_linear")
mix_reparameterize(fit_lin)
}
