\name{mix_reduce}
\alias{mix_reduce}
\title{Audited hierarchical model reduction for mixture response surfaces}
\usage{
mix_reduce(object, criterion = c("hybrid", "press", "aic", "bic"),
                       min_terms = NULL, max_steps = 50L, protect = NULL, tolerance =
                       1e-4)
}
\arguments{
  \item{object}{A `mix_fit` object.}
  \item{criterion}{`hybrid`, `press`, `aic`, or `bic`.}
  \item{min_terms}{Minimum number of retained basis columns.}
  \item{max_steps}{Maximum backward-removal steps.}
  \item{protect}{Terms that may not be removed; component main terms are protected by default.}
  \item{tolerance}{Required fractional score improvement for a removal.}
}
\description{
The default hybrid score combines prediction error, numerical conditioning, and parsimony. Term removal is considered only when hierarchy is preserved. No term is removed solely because of a p-value.
}
\details{
This help page is a prebuilt source-snapshot reference. The roxygen2 comments in the R source are authoritative and should be regenerated with roxygen2 during the local release gate.
}
\value{
A `mix_reduction` object containing the selected fit and complete audit path.
}
\seealso{\code{mix_capabilities()}, the package vignettes, and \code{mix_report()}.}
\examples{
sp <- mix_spec(c("A", "B", "C"))
d <- mix_demo_data("mixture", n_rep = 3, seed = 12)
fit <- mix_fit("response", d, sp, model = "scheffe_special_cubic")
red <- mix_reduce(fit, criterion = "press", max_steps = 2)
red$retained_terms
red2 <- mix_reduce(fit, criterion = "aic", max_steps = 2)
red2$retained_terms
mix_reduce(fit, criterion = "bic", max_steps = 2)
}
