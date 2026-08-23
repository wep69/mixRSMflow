\name{mix_optimize}
\alias{mix_optimize}
\title{Optimize a fitted mixture response surface under exact mixture constraints}
\usage{
mix_optimize(object,goal=c("maximize","minimize","target"),target=NULL,
                         method=c("hybrid","grid","ga"),grid_resolution=30L,
                         random_candidates=5000L,near_tolerance=0.01,seed=1L)
}
\arguments{
  \item{object}{A `mix_fit` object.}
  \item{goal}{`maximize`, `minimize`, or `target`.}
  \item{target}{Target response for `goal="target"`.}
  \item{method}{`hybrid`, `grid`, or `ga`.}
  \item{grid_resolution}{Feasible-grid resolution.}
  \item{random_candidates}{Number of random feasible candidates added to the grid.}
  \item{near_tolerance}{Relative tolerance defining the near-optimal region.}
  \item{seed}{Random seed.}
}
\description{
Optimize a fitted mixture response surface under exact mixture constraints
}
\details{
This help page is a prebuilt source-snapshot reference. The roxygen2 comments in the R source are authoritative and should be regenerated with roxygen2 during the local release gate.
}
\value{
A `mix_optimum` object containing the best composition, response, and near-optimal region.
}
\seealso{\code{mix_capabilities()}, the package vignettes, and \code{mix_report()}.}
\examples{
sp <- mix_spec(c("A", "B", "C"))
d <- mix_demo_data("mixture", n_rep = 2, seed = 20)
fit <- mix_fit("response", d, sp)
opt <- mix_optimize(fit, goal = "maximize", method = "grid", grid_resolution = 7,
                    random_candidates = 0)
opt$composition
opt2 <- mix_optimize(fit, goal = "minimize", method = "grid", grid_resolution = 7,
                     random_candidates = 0)
opt2$composition
opt3 <- mix_optimize(fit, goal = "target", target = 6, method = "grid",
                     grid_resolution = 7, random_candidates = 0)
}
