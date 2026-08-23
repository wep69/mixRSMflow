\name{mix_anova}
\alias{mix_anova}
\title{ANOVA and pure-error/lack-of-fit decomposition for mixture models}
\usage{
mix_anova(object, replicate_by = NULL)
}
\arguments{
  \item{object}{A `mix_fit` object.}
  \item{replicate_by}{Optional columns defining replicated design points. By default, mixture components plus process variables are used.}
}
\description{
ANOVA and pure-error/lack-of-fit decomposition for mixture models
}
\details{
This help page is a prebuilt source-snapshot reference. The roxygen2 comments in the R source are authoritative and should be regenerated with roxygen2 during the local release gate.
}
\value{
Data frame containing regression, residual, lack-of-fit, pure-error, and total components.
}
\seealso{\code{mix_capabilities()}, the package vignettes, and \code{mix_report()}.}
\examples{
sp <- mix_spec(c("A", "B", "C"))
d <- mix_demo_data("mixture", n_rep = 3, seed = 8)
fit <- mix_fit("response", d, sp, model = "scheffe_quadratic")
mix_anova(fit)
mix_anova(fit, replicate_by = c("A", "B", "C"))
fit2 <- mix_fit("response", d, sp, model = "scheffe_linear")
mix_anova(fit2)
}
