\name{mix_fit_bayes}
\alias{mix_fit_bayes}
\title{Fit a Bayesian mixture model through brms}
\usage{
mix_fit_bayes(response, data, spec = NULL, model="scheffe_quadratic",
                          family = NULL, random = NULL, prior = NULL,
                          process = NULL, mixture_process = FALSE, terms = NULL, ...,
                          brms_args = list())
}
\arguments{
  \item{response}{Response column name.}
  \item{data}{Data frame or `mix_design`.}
  \item{spec}{Mixture specification.}
  \item{model}{Mixture basis.}
  \item{family}{A `brms` family.}
  \item{random}{Optional brms-compatible random-effects expression without the response.}
  \item{prior}{Optional brms prior specification.}
  \item{process}{Optional process variables.}
  \item{mixture_process}{Include mixture-process interactions.}
  \item{terms}{Optional mixture-basis terms to retain.}
  \item{brms_args}{Named list of additional arguments passed to `brms::brm`.}
  \item{...}{Additional arguments passed to or from other methods.}
}
\description{
Fit a Bayesian mixture model through brms
}
\details{
This help page is a prebuilt source-snapshot reference. The roxygen2 comments in the R source are authoritative and should be regenerated with roxygen2 during the local release gate.
}
\value{
A `mix_fit_bayes` object.
}
\seealso{\code{mix_capabilities()}, the package vignettes, and \code{mix_report()}.}
\examples{
if (FALSE) { # Requires brms and a configured Stan toolchain
  sp <- mix_spec(c("A", "B", "C"))
  d <- mix_demo_data("mixture", n_rep = 2, seed = 6)
  bf <- mix_fit_bayes("response", d, sp, model = "scheffe_quadratic")
  bf2 <- mix_fit_bayes("response", d, sp, model = "scheffe_linear")
  bf3 <- mix_fit_bayes("response", d, sp, model = "scheffe_special_cubic",
                       brms_args = list(iter = 500))
}
}
