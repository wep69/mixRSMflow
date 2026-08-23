\name{mix_segmented_fit}
\alias{mix_segmented_fit}
\title{Fit a two-region segmented mixture model}
\usage{
mix_segmented_fit(response, data, spec = NULL, split_component, cut,
                              model_left = "scheffe_quadratic", model_right = model_left,
                              family = stats::gaussian(), ...)
}
\arguments{
  \item{response}{Response column name.}
  \item{data}{Data frame or `mix_design`.}
  \item{spec}{Mixture specification.}
  \item{split_component}{Component defining the two regions.}
  \item{cut}{Split threshold in original mixture units.}
  \item{model_left}{Mixture models fitted below/above the threshold.}
  \item{model_right}{Mixture models fitted below/above the threshold.}
  \item{family}{GLM family used by both segments.}
  \item{...}{Additional arguments passed to or from other methods.}
}
\description{
This implementation fits separate mixture response surfaces on two scientifically specified regions separated by a component threshold. It intentionally does not impose continuity unless a future model-specific constraint is supplied, and the
}
\details{
This help page is a prebuilt source-snapshot reference. The roxygen2 comments in the R source are authoritative and should be regenerated with roxygen2 during the local release gate.
}
\value{
A `mix_segmented_fit` object.
}
\seealso{\code{mix_capabilities()}, the package vignettes, and \code{mix_report()}.}
\examples{
sp <- mix_spec(c("A", "B", "C"))
d <- mix_demo_data("mixture", n_rep = 3, seed = 14)
sf <- mix_segmented_fit("response", d, sp, split_component = "A", cut = .3,
                        model_left = "scheffe_linear", model_right = "scheffe_linear")
sf
sf2 <- mix_segmented_fit("response", d, sp, split_component = "A", cut = .4,
                         model_left = "scheffe_linear", model_right = "scheffe_linear")
sf2
mix_segmented_fit("response", d, sp, split_component = "B", cut = .4,
                  model_left = "scheffe_linear", model_right = "scheffe_linear")
}
