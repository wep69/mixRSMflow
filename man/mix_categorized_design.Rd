\name{mix_categorized_design}
\alias{mix_categorized_design}
\title{Construct categorized-component or mixture-of-mixtures designs}
\usage{
mix_categorized_design(spec, categories, between_degree = 2L, within_degree = 2L,
                                   category_totals = NULL, max_runs = 100000L, seed = 1L)
}
\arguments{
  \item{spec}{A `mix_spec` object.}
  \item{categories}{Named list of non-overlapping component vectors covering all components.}
  \item{between_degree}{Simplex-lattice degree for category totals.}
  \item{within_degree}{Scalar or named degrees used inside categories.}
  \item{category_totals}{Optional data frame/matrix of pre-specified category totals.}
  \item{max_runs}{Safety cap on expanded combinations.}
  \item{seed}{Random seed recorded in metadata.}
}
\description{
Components are grouped into named categories. A between-category simplex lattice allocates the total among categories; within each positive category, another lattice allocates that category total among its components. The same
}
\details{
This help page is a prebuilt source-snapshot reference. The roxygen2 comments in the R source are authoritative and should be regenerated with roxygen2 during the local release gate.
}
\value{
A `mix_design` object.
}
\seealso{\code{mix_capabilities()}, the package vignettes, and \code{mix_report()}.}
\examples{
sp <- mix_spec(c("A", "B", "C", "D"))
cats <- list(base = c("A", "B"), additive = c("C", "D"))
d <- mix_categorized_design(sp, cats, between_degree = 2, within_degree = 1)
head(d$data)
d2 <- mix_categorized_design(sp, cats, between_degree = 2, within_degree = 2)
d3 <- mix_categorized_design(sp, cats, between_degree = 1, within_degree = 1)
head(d3$data)
}
