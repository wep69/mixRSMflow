\name{mix_plot}
\alias{mix_plot}
\title{Unified static and interactive plotting for mixture workflows}
\usage{
mix_plot(object,type=NULL,engine=c("ggplot2","base","plotly"),resolution=30L,views=2L,
                     file=NULL,width=7,height=6,dpi=300,...)
}
\arguments{
  \item{object}{A `mix_fit`, `mix_design`, `mix_design_evaluation`, `mix_optimum`, `mix_optimum_ci`, `mix_effect`, or `mix_multiopt` object.}
  \item{type}{Plot type. Common choices include `design`, `surface3d`, `ternary_contour`, `ternary_filled`, `heatmap`, `residuals`, `qq`, `leverage`, `fds`, `vdg`, `component_trace`, `optimum`, `optimum_ci`, `desirability`, and `pareto`.}
  \item{engine}{`ggplot2`, `base`, or `plotly`.}
  \item{resolution}{Surface/grid resolution.}
  \item{views}{Number of views for Cornell-style static 3D wireframes.}
  \item{file}{Optional PDF/SVG/PNG/TIFF output path. Base 3D PDF/SVG output is vector.}
  \item{width}{Device size in inches.}
  \item{height}{Device size in inches.}
  \item{dpi}{Raster resolution.}
  \item{...}{Additional arguments passed to or from other methods.}
}
\description{
Unified static and interactive plotting for mixture workflows
}
\details{
This help page is a prebuilt source-snapshot reference. The roxygen2 comments in the R source are authoritative and should be regenerated with roxygen2 during the local release gate.
}
\value{
A plot object when applicable, otherwise the plotted data invisibly.
}
\seealso{\code{mix_capabilities()}, the package vignettes, and \code{mix_report()}.}
\examples{
sp <- mix_spec(c("A", "B", "C"))
d <- mix_demo_data("mixture", n_rep = 2, seed = 25)
fit <- mix_fit("response", d, sp)
mix_plot(fit, type = "ternary_contour", resolution = 15)
mix_plot(fit, type = "ternary_filled", resolution = 10)
mix_plot(fit, type = "residuals")
}
