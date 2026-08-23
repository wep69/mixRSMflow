\name{mix_block_design}
\alias{mix_block_design}
\title{Allocate a mixture design to approximately orthogonal balanced blocks}
\usage{
mix_block_design(design, n_blocks, model = "scheffe_quadratic", iterations = 50000L, seed
= 1L)
}
\arguments{
  \item{design}{A `mix_design` object.}
  \item{n_blocks}{Number of blocks.}
  \item{model}{Model basis whose estimability should be balanced over blocks.}
  \item{iterations}{Maximum pair-swap attempts.}
  \item{seed}{Random seed.}
}
\description{
A balanced swap-search minimizes squared differences among block totals of standardized model columns. Exact orthogonality is reported when achieved numerically; otherwise the result is explicitly labelled near-orthogonal.
}
\details{
This help page is a prebuilt source-snapshot reference. The roxygen2 comments in the R source are authoritative and should be regenerated with roxygen2 during the local release gate.
}
\value{
A new `mix_design` with `.block` and block-balance diagnostics.
}
\seealso{\code{mix_capabilities()}, the package vignettes, and \code{mix_report()}.}
\examples{
sp <- mix_spec(c("A", "B", "C"))
d <- mix_design(sp, "simplex_lattice", degree = 3)
bd <- mix_block_design(d, n_blocks = 2, iterations = 100, seed = 2)
table(bd$data$.block)
bd2 <- mix_block_design(d, n_blocks = 3, iterations = 100, seed = 4)
table(bd2$data$.block)
mix_block_design(d, n_blocks = 2, model = "scheffe_linear", iterations = 100, seed = 5)
}
