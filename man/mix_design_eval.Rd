\name{mix_design_eval}
\alias{mix_design_eval}
\title{Evaluate information and prediction-variance properties of a mixture design}
\usage{
mix_design_eval(design,spec=NULL,model="scheffe_quadratic",evaluation=NULL,resolution=15L,
                process=NULL,process_order=2L,mixture_process=FALSE,
                reference=NULL)
}
\arguments{
  \item{design}{A `mix_design` or data frame.}
  \item{spec}{Mixture specification when `design` is a data frame.}
  \item{model}{Model basis.}
  \item{evaluation}{Optional prediction-evaluation set.}
  \item{resolution}{Evaluation-grid resolution.}
  \item{process}{Optional process-variable names.}
  \item{process_order}{Process polynomial order.}
  \item{mixture_process}{Include mixture-process interactions.}
  \item{reference}{Optional reference design for relative efficiency calculations.}
}
\description{
Evaluate information and prediction-variance properties of a mixture design
}
\details{
This help page is a prebuilt source-snapshot reference. The roxygen2 comments in the R source are authoritative and should be regenerated with roxygen2 during the local release gate.
}
\value{
A `mix_design_evaluation` object containing information criteria, FDS, and VDG
data, and a numeric vector `prediction_variance` of evaluation-grid variances.
}
\seealso{\code{mix_capabilities()}, the package vignettes, and \code{mix_report()}.}
\examples{
sp <- mix_spec(c("A", "B", "C"))
d <- mix_design(sp, "simplex_lattice", degree = 3)
ev <- mix_design_eval(d, model = "scheffe_quadratic", resolution = 8)
head(ev$fds)
ev2 <- mix_design_eval(d, model = "scheffe_special_cubic", resolution = 8)
ev3 <- mix_design_eval(d, model = "scheffe_linear", resolution = 8)
head(ev3$vdg)
}
