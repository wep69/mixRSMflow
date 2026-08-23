\name{mix_multiple_lattice}
\alias{mix_multiple_lattice}
\title{Construct multiple-lattice designs for major and minor component groups}
\usage{
mix_multiple_lattice(spec, major, minor = setdiff(spec$components, major),
                                 major_totals, major_degree = 3L, minor_degree = 2L,
                                 max_runs = 100000L, randomize = FALSE, seed = 1L)
}
\arguments{
  \item{spec}{A `mix_spec` object.}
  \item{major}{Character vector of major components.}
  \item{minor}{Character vector of minor components. Defaults to all remaining components.}
  \item{major_totals}{Feasible totals assigned to the major-component group.}
  \item{major_degree}{Simplex-lattice degrees within the groups.}
  \item{minor_degree}{Simplex-lattice degrees within the groups.}
  \item{max_runs}{Safety cap before feasibility filtering.}
  \item{randomize}{Randomize run order.}
  \item{seed}{Random seed.}
}
\description{
The design crosses simplex lattices within major and minor component groups at user-specified totals allocated to the major group. This provides a transparent construction for mixture systems in which components are
}
\details{
This help page is a prebuilt source-snapshot reference. The roxygen2 comments in the R source are authoritative and should be regenerated with roxygen2 during the local release gate.
}
\value{
A `mix_design` object.
}
\seealso{\code{mix_capabilities()}, the package vignettes, and \code{mix_report()}.}
\examples{
sp <- mix_spec(c("A", "B", "C"))
d <- mix_multiple_lattice(sp, major = c("A", "B"), minor = "C",
                          major_totals = c(.6, .8), major_degree = 2, minor_degree = 1)
head(d$data)
d2 <- mix_multiple_lattice(sp, major = c("A", "B"), minor = "C",
                           major_totals = .7, major_degree = 2, minor_degree = 2)
nrow(d2$data)
d3 <- mix_multiple_lattice(sp, major = c("A", "B"), minor = "C",
                           major_totals = c(.6, .8), major_degree = 1, minor_degree = 1,
                           randomize = TRUE, seed = 6)
head(d3$data)
}
