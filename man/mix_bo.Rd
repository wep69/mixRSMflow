\name{mix_bo}
\alias{mix_bo}
\title{Gaussian-process Bayesian optimization over a mixture region}
\usage{
mix_bo(data,response,spec,goal=c("maximize","minimize"),iterations=1L,
                   objective=NULL,candidate_n=5000L,nugget=1e-8,seed=1L)
}
\arguments{
  \item{data}{Existing mixture data.}
  \item{response}{Response column name.}
  \item{spec}{Mixture specification.}
  \item{goal}{`maximize` or `minimize`.}
  \item{iterations}{Number of sequential recommendations/evaluations.}
  \item{objective}{Optional function accepting a numeric composition vector and returning a scalar response.}
  \item{candidate_n}{Number of random feasible candidates per iteration.}
  \item{nugget}{GP nugget parameter.}
  \item{seed}{Random seed.}
}
\description{
This advanced adapter uses `DiceKriging` when available. It can either recommend the next feasible composition from existing observations or, when an explicit deterministic `objective` function is supplied, conduct
}
\details{
This help page is a prebuilt source-snapshot reference. The roxygen2 comments in the R source are authoritative and should be regenerated with roxygen2 during the local release gate.
}
\value{
A `mix_bo` object containing GP history and recommended point(s).
}
\seealso{\code{mix_capabilities()}, the package vignettes, and \code{mix_report()}.}
\examples{
if (requireNamespace("DiceKriging", quietly = TRUE)) {
  sp <- mix_spec(c("A", "B", "C"))
  d <- mix_demo_data("mixture", n_rep = 1, seed = 24)
  bo <- mix_bo(d, "response", sp, iterations = 1, candidate_n = 100, seed = 2)
  bo$recommendation
  bo2 <- mix_bo(d, "response", sp, goal = "minimize", iterations = 1, candidate_n = 100, seed = 3)
  bo2$recommendation
  d2 <- d
  d2$.run <- NULL
  bo3 <- mix_bo(d2, "response", sp, iterations = 1, candidate_n = 100, seed = 4,
                objective = function(x) x[1] + 2 * x[2])
  bo3$status
}
}
