\name{mix_basis}
\alias{mix_basis}
\title{Build a mixture-model basis matrix}
\usage{
mix_basis(data, spec,
                      model = c("scheffe_linear", "scheffe_quadratic",
                                "scheffe_special_cubic", "scheffe_cubic",
                                "scheffe_special_quartic", "scheffe_quartic",
                                "slack_linear", "slack_quadratic", "kronecker_quadratic",
                                "inverse_scheffe", "ratio", "cox_linear", "cox_quadratic",
                                "cox_cubic", "logcontrast",
                                "becker_h1", "becker_h2", "becker_h3", 
                                "additive_blending", "gbm"),
                      process = NULL, process_order = 2L, mixture_process = FALSE,
                      slack_component = NULL, reference = NULL, denominator = NULL,
                      inverse_components = NULL, additive_component = NULL, gbm_terms = 
                      NULL)
}
\arguments{
  \item{data}{Data frame containing the mixture components.}
  \item{spec}{A `mix_spec` object.}
  \item{model}{Model basis name.}
  \item{process}{Optional numeric process-variable names.}
  \item{process_order}{Polynomial order for process variables (1 or 2).}
  \item{mixture_process}{If `TRUE`, interact mixture terms with process terms.
  To keep the mixture-process model estimable, cross terms are generated for
  all mixture columns except constant/intercept columns and the last
  component's main effect (whose cross family is collinear with the process
  main effects because the components sum to one).}
  \item{slack_component}{Component designated as slack for slack-variable models.}
  \item{reference}{Reference composition for Cox parameterization.}
  \item{denominator}{Denominator component for ratio models.}
  \item{inverse_components}{Components receiving reciprocal terms.}
  \item{additive_component}{Component assumed to blend additively in the Becker-type reduced model.}
  \item{gbm_terms}{List of fixed-exponent general blending terms created by [mix_gbm_term()].}
}
\description{
Supports classical Scheffe polynomials and several alternative parameterizations discussed in the mixture-experiment literature. Higher-order special/full Scheffe forms follow the canonical term structures used in standard mixture DOE.
}
\details{
This help page is a prebuilt source-snapshot reference. The roxygen2 comments in the R source are authoritative and should be regenerated with roxygen2 during the local release gate.
}
\value{
Numeric design matrix with informative column names.
}
\seealso{\code{mix_capabilities()}, the package vignettes, and \code{mix_report()}.}
\examples{
sp <- mix_spec(c("A", "B", "C"))
d <- mix_design(sp, "simplex_centroid")
X <- mix_basis(d$data, sp, model = "scheffe_quadratic")
head(X)
X2 <- mix_basis(d$data, sp, model = "scheffe_special_cubic")
head(X2)
mix_basis(d$data, sp, model = "slack_linear", slack_component = "C")
}
