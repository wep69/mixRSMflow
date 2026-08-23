\name{mix_design}
\alias{mix_design}
\title{Generate classical and mixture-process designs}
\usage{
mix_design(spec,
                       type = c("simplex_lattice", "simplex_centroid", "axial",
                                "augmented_centroid", "symmetric_simplex",
                                "extreme_vertices", "rotatable", "multiple_lattice",
                                "categorized_components", "mixture_process",
                                "split_plot", "mixture_amount"),
                       degree = 3L, alpha = NULL, include_centroid = TRUE,
                       edge_midpoints = TRUE, base_type = "simplex_centroid",
                       process = NULL, amount = NULL, fraction = NULL,
                       hard_to_change = NULL, fraction_method = c("D", "random"),
                       fraction_model = "scheffe_quadratic",
                       fraction_process_order = 2L, fraction_mixture_process = TRUE,
                       major = NULL, minor = NULL, major_totals = NULL,
                       categories = NULL, category_totals = NULL, between_degree = 2L,
                       within_degree = 2L,
                       blocks = NULL,
                       randomize = FALSE, seed = 1L)
}
\arguments{
  \item{spec}{A `mix_spec` or `mix_region` object.}
  \item{type}{Design type. Supported values include `simplex_lattice`, `simplex_centroid`, `axial`, `augmented_centroid`, `symmetric_simplex`, `extreme_vertices`, `rotatable`, `multiple_lattice`, `categorized_components`, `mixture_process`, `split_plot`, and `mixture_amount`.}
  \item{degree}{Lattice degree for `simplex_lattice` or base resolution.}
  \item{alpha}{Axial mixture coordinate; if `NULL`, a midpoint-type value is used.}
  \item{include_centroid}{Add the feasible center where relevant.}
  \item{edge_midpoints}{Include midpoints of extreme-vertex pairs when feasible.}
  \item{base_type}{Base mixture design for mixture-process/amount designs.}
  \item{process}{Named list of process-variable levels.}
  \item{amount}{Numeric levels for total mixture amount.}
  \item{fraction}{Optional fraction `(0,1]` of the crossed design to retain.}
  \item{hard_to_change}{Character names of process variables defining whole plots.}
  \item{fraction_method}{Use `D` for model-based D-information fractionation or `random` for an explicitly random teaching/control fraction.}
  \item{fraction_model}{Mixture basis protected during D-information fractionation.}
  \item{fraction_process_order}{Process polynomial order protected during fractionation.}
  \item{fraction_mixture_process}{Include mixture-by-process interactions in the protected fractionation model.}
  \item{major}{Component groups for `multiple_lattice`.}
  \item{minor}{Component groups for `multiple_lattice`.}
  \item{major_totals}{Totals allocated to the major group.}
  \item{categories}{Named component categories for `categorized_components`.}
  \item{category_totals}{Optional category totals for categorized designs.}
  \item{between_degree}{Lattice degrees for categorized designs.}
  \item{within_degree}{Lattice degrees for categorized designs.}
  \item{blocks}{Optional number of blocks for balanced block labels.}
  \item{randomize}{Randomize run order.}
  \item{seed}{Random seed.}
}
\description{
Generate classical and mixture-process designs
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
d <- mix_design(sp, "simplex_centroid")
head(d$data)
d2 <- mix_design(sp, "simplex_lattice", degree = 3)
d3 <- mix_design(sp, "axial")
head(d3$data)
}
