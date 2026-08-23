\name{mix_imse}
\alias{mix_imse}
\title{Integrated mean-square prediction error under an explicit larger model}
\usage{
mix_imse(design, spec = NULL, fitted_model = "scheffe_quadratic",
                     true_model = "scheffe_special_cubic", evaluation = NULL,
                     beta_omitted = NULL, beta_cov = NULL, sigma2 = 1,
                     resolution = 18L, fitted_args = list(), true_args = list())
}
\arguments{
  \item{design}{A `mix_design` or design data frame.}
  \item{spec}{A `mix_spec` when `design` is a data frame.}
  \item{fitted_model}{Basis name used for the fitted model.}
  \item{true_model}{Larger basis name defining possible omitted terms.}
  \item{evaluation}{Optional feasible evaluation data. If `NULL`, a grid is generated.}
  \item{beta_omitted}{Optional named or ordered coefficient vector for omitted terms.}
  \item{beta_cov}{Optional covariance matrix for zero-mean omitted coefficients. This yields expected integrated squared bias.}
  \item{sigma2}{Error variance multiplying the integrated prediction variance.}
  \item{resolution}{Evaluation-grid resolution.}
  \item{fitted_args}{Named lists passed to [mix_basis()] for each model.}
  \item{true_args}{Named lists passed to [mix_basis()] for each model.}
}
\description{
Evaluates the Box-Draper variance-plus-bias decomposition for a fitted model relative to an explicitly specified larger model. It does not silently guess omitted-term coefficients. Bias can be evaluated at supplied coefficients or
}
\details{
This help page is a prebuilt source-snapshot reference. The roxygen2 comments in the R source are authoritative and should be regenerated with roxygen2 during the local release gate.
}
\value{
A `mix_imse` object with variance, bias and total IMSE components.
}
\seealso{\code{mix_capabilities()}, the package vignettes, and \code{mix_report()}.}
\examples{
sp <- mix_spec(c("A", "B", "C"))
d <- mix_design(sp, "simplex_lattice", degree = 3)
im <- mix_imse(d, fitted_model = "scheffe_quadratic",
               true_model = "scheffe_special_cubic", beta_omitted = c(`A:B:C` = 2),
               sigma2 = .25, resolution = 8)
im
im2 <- mix_imse(d, fitted_model = "scheffe_linear", true_model = "scheffe_quadratic",
                beta_omitted = c(`A:B` = 1, `A:C` = 1, `B:C` = 1), resolution = 8)
im2
mix_imse(d, fitted_model = "scheffe_quadratic", true_model = "scheffe_special_cubic",
         beta_cov = matrix(1), sigma2 = 1, resolution = 8)
}
