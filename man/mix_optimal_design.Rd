\name{mix_optimal_design}
\alias{mix_optimal_design}
\title{Construct exact optimal mixture designs}
\usage{
mix_optimal_design(spec,model="scheffe_quadratic",runs,
                               criterion=c("D","A","I","G","E","T","Alias","BayesD",
                               "BayesI"),
                               algorithm=c("hybrid","exchange","ga"),candidates=NULL,
                               evaluation=NULL,
                               resolution=12L,random_candidates=1000L,process=NULL,
                               process_order=2L,
                               mixture_process=FALSE,allow_replicates=TRUE,
                               robust=c("mean","worst"),
                               prior_precision=NULL,alternative_model=NULL,
                               alias_model=NULL,
                               starts=3L,max_iter=20L,population=40L,generations=50L,
                               seed=1L)
}
\arguments{
  \item{spec}{Mixture specification.}
  \item{model}{Primary model basis or vector of model names for model-robust design.}
  \item{runs}{Number of exact design runs.}
  \item{criterion}{Optimality criterion: D, A, I, G, E, T, Alias, BayesD, or BayesI.}
  \item{algorithm}{`exchange`, `ga`, or `hybrid`.}
  \item{candidates}{Optional candidate data frame. If omitted, a feasible grid plus random points is generated.}
  \item{evaluation}{Optional prediction-evaluation grid for I/G criteria.}
  \item{resolution}{Simplex grid resolution.}
  \item{random_candidates}{Additional random feasible candidates.}
  \item{process}{Optional named list of process levels to cross with mixture candidates.}
  \item{process_order}{Process polynomial order.}
  \item{mixture_process}{Include mixture-process interactions.}
  \item{allow_replicates}{Allow replicated exact design points.}
  \item{robust}{`mean` or `worst` aggregation across multiple candidate models.}
  \item{prior_precision}{Prior precision matrix/scalar for BayesD/BayesI linear-normal criteria.}
  \item{alternative_model}{Alternative model for T-optimal discrimination.}
  \item{alias_model}{Higher-order model supplying omitted columns for Alias criterion.}
  \item{starts}{Number of independent starts.}
  \item{max_iter}{Exchange iterations.}
  \item{population}{GA population size.}
  \item{generations}{GA generations.}
  \item{seed}{Random seed.}
}
\description{
Construct exact optimal mixture designs
}
\details{
This help page is a prebuilt source-snapshot reference. The roxygen2 comments in the R source are authoritative and should be regenerated with roxygen2 during the local release gate.
}
\value{
A `mix_design` with optimality metadata.
}
\seealso{\code{mix_capabilities()}, the package vignettes, and \code{mix_report()}.}
\examples{
sp <- mix_spec(c("A", "B", "C"))
od <- mix_optimal_design(sp, model = "scheffe_quadratic", runs = 8, criterion = "D",
                         algorithm = "exchange", resolution = 5, random_candidates = 20,
                         starts = 1, max_iter = 2, seed = 19)
od
od2 <- mix_optimal_design(sp, model = "scheffe_quadratic", runs = 8, criterion = "A",
                          algorithm = "exchange", resolution = 5, random_candidates = 20,
                          starts = 1, max_iter = 2, seed = 11)
od2
od3 <- mix_optimal_design(sp, model = "scheffe_quadratic", runs = 8, criterion = "D",
                          algorithm = "ga", resolution = 5, random_candidates = 20,
                          population = 8, generations = 3, seed = 7)
od3
}
