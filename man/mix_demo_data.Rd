\name{mix_demo_data}
\alias{mix_demo_data}
\title{Generate reproducible pedagogical mixture datasets}
\usage{
mix_demo_data(kind=c("mixture","mixture_process","multiresponse"),n_rep=3L,seed=20260813L)
}
\arguments{
  \item{kind}{`mixture`, `mixture_process`, or `multiresponse`.}
  \item{n_rep}{Number of replicates per base blend for `mixture` and `multiresponse`.}
  \item{seed}{Random seed.}
}
\description{
The datasets are simulated and carry known response-generating mechanisms, avoiding licensing problems associated with textbook datasets.
}
\details{
This help page is a prebuilt source-snapshot reference. The roxygen2 comments in the R source are authoritative and should be regenerated with roxygen2 during the local release gate.
}
\value{
A data frame with mixture components and simulated response(s).
}
\seealso{\code{mix_capabilities()}, the package vignettes, and \code{mix_report()}.}
\examples{
d <- mix_demo_data("mixture", n_rep = 2, seed = 27)
head(d)
head(mix_demo_data("mixture_process", n_rep = 1, seed = 2))
head(mix_demo_data("multiresponse", n_rep = 1, seed = 3))
}
