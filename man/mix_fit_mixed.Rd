\name{mix_fit_mixed}
\alias{mix_fit_mixed}
\title{Fit a mixed-effects mixture model through lme4}
\usage{
mix_fit_mixed(response, data, spec = NULL, random,
                          model = "scheffe_quadratic", family = NULL,
                          process = NULL, mixture_process = FALSE, terms = NULL, ...)
}
\arguments{
  \item{response}{Response column name.}
  \item{data}{Data frame or `mix_design`.}
  \item{spec}{Mixture specification.}
  \item{random}{Random-effects term such as `(1|block)`.}
  \item{model}{Mixture basis.}
  \item{family}{`NULL` for `lmer`, otherwise a GLM family for `glmer`.}
  \item{process}{Optional process variables.}
  \item{mixture_process}{Include mixture-process interactions.}
  \item{terms}{Optional mixture-basis terms to retain.}
  \item{...}{Additional arguments passed to or from other methods.}
}
\description{
This adapter preserves the mixture basis while delegating mixed-model estimation to `lme4::lmer` or `lme4::glmer`. It is intended for block, split-plot, and related hierarchical designs.
}
\details{
This help page is a prebuilt source-snapshot reference. The roxygen2 comments in the R source are authoritative and should be regenerated with roxygen2 during the local release gate.
}
\value{
A `mix_fit_mixed` object.
}
\seealso{\code{mix_capabilities()}, the package vignettes, and \code{mix_report()}.}
\examples{
if (requireNamespace("lme4", quietly = TRUE)) {
  sp <- mix_spec(c("A", "B", "C"))
  d <- mix_demo_data("mixture", n_rep = 3, seed = 5)
  d$block <- factor(rep(seq_len(3), length.out = nrow(d)))
  mm <- mix_fit_mixed("response", d, sp, random = "(1|block)", model = "scheffe_linear")
  mm
  d2 <- d
  d2$response <- d2$response + as.numeric(d2$block)
  mm2 <- mix_fit_mixed("response", d2, sp, random = "(1|block)", model = "scheffe_quadratic")
  mm3 <- mix_fit_mixed("response", d2, sp, random = "(1|block)", model = "scheffe_linear")
}
}
