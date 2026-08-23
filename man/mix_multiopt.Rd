\name{mix_multiopt}
\alias{mix_multiopt}
\title{Multiresponse desirability, constraints, and Pareto optimization}
\usage{
mix_multiopt(object,goals,settings,response_weights=NULL,constraints=NULL,
                         resolution=25L,random_candidates=5000L,seed=1L)
}
\arguments{
  \item{object}{A `mix_multi_fit` object or named list of `mix_fit` objects.}
  \item{goals}{Named character vector (`maximize`, `minimize`, `target`).}
  \item{settings}{Named list; each response entry may contain `low`, `high`, `target`, and `weight`.}
  \item{response_weights}{Relative weights in the geometric mean of desirabilities.}
  \item{constraints}{Optional named list of response bounds such as `list(y1=c(min=5,max=10))`.}
  \item{resolution}{Feasible-grid resolution.}
  \item{random_candidates}{Number of random feasible points.}
  \item{seed}{Random seed.}
}
\description{
Multiresponse desirability, constraints, and Pareto optimization
}
\details{
This help page is a prebuilt source-snapshot reference. The roxygen2 comments in the R source are authoritative and should be regenerated with roxygen2 during the local release gate.
}
\value{
A `mix_multiopt` object with best compromise and Pareto set.
}
\seealso{\code{mix_capabilities()}, the package vignettes, and \code{mix_report()}.}
\examples{
sp <- mix_spec(c("A", "B", "C"))
d <- mix_demo_data("multiresponse", n_rep = 2, seed = 23)
mf <- mix_multi_fit(c("quality", "stability"), d, sp, model = "scheffe_quadratic")
goals <- c(quality = "maximize", stability = "maximize")
settings <- list(quality = list(low = min(d$quality), high = max(d$quality)),
                 stability = list(low = min(d$stability), high = max(d$stability)))
mo <- mix_multiopt(mf, goals, settings, resolution = 8, random_candidates = 50)
mo$composition
mo2 <- mix_multiopt(mf, goals, settings, response_weights = c(quality = 2, stability = 1),
                    resolution = 8, random_candidates = 50)
mo2$composition
mo3 <- mix_multiopt(mf, goals, settings, constraints = list(quality = c(min = 4, max = 10)),
                    resolution = 8, random_candidates = 50)
mo3$overall
}
