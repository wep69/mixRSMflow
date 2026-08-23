\name{mix_fit}
\alias{mix_fit}
\title{Fit classical and generalized mixture response-surface models}
\usage{
mix_fit(response, data, spec = NULL,
                    model = "scheffe_quadratic", family = stats::gaussian(),
                    weights = NULL, offset = NULL, process = NULL,
                    process_order = 2L, mixture_process = FALSE, terms = NULL, ...)
}
\arguments{
  \item{response}{Response column name.}
  \item{data}{Data frame or `mix_design` containing observed responses.}
  \item{spec}{Mixture specification. If `data` is a `mix_design`, its specification is used by default.}
  \item{model}{Mixture basis passed to [mix_basis()].}
  \item{family}{A GLM family; Gaussian identity is the classical default.}
  \item{weights}{Optional observation weights or column name.}
  \item{offset}{Optional offset vector or column name.}
  \item{process}{Optional process-variable names.}
  \item{process_order}{Polynomial order for process variables.}
  \item{mixture_process}{Include mixture by process interactions.}
  \item{terms}{Optional basis-column names or indices to retain. This supports audited model reduction while preserving the original model family.}
  \item{...}{Additional arguments passed to or from other methods.}
}
\description{
Fit classical and generalized mixture response-surface models
}
\details{
This help page is a prebuilt source-snapshot reference. The roxygen2 comments in the R source are authoritative and should be regenerated with roxygen2 during the local release gate.
}
\value{
A `mix_fit` object.
}
\seealso{\code{mix_capabilities()}, the package vignettes, and \code{mix_report()}.}
\examples{
sp <- mix_spec(c("A", "B", "C"))
d <- mix_demo_data("mixture", n_rep = 2, seed = 4)
fit <- mix_fit("response", d, sp, model = "scheffe_quadratic")
coef(fit)
fit2 <- mix_fit("response", d, sp, model = "scheffe_linear")
fit3 <- mix_fit("response", d, sp, model = "scheffe_special_cubic")
coef(fit3)
}
