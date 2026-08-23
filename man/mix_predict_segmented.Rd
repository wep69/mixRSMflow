\name{mix_predict_segmented}
\alias{mix_predict_segmented}
\title{Predict from a segmented mixture model}
\usage{
mix_predict_segmented(object, newdata = NULL, interval = c("none", "confidence",
"prediction"), level = 0.95)
}
\arguments{
  \item{object}{A `mix_segmented_fit`.}
  \item{newdata}{New data.}
  \item{interval}{Prediction interval type passed to `mix_predict`.}
  \item{level}{Confidence level.}
}
\description{
Predict from a segmented mixture model
}
\details{
This help page is a prebuilt source-snapshot reference. The roxygen2 comments in the R source are authoritative and should be regenerated with roxygen2 during the local release gate.
}
\value{
Predictions in original row order.
}
\seealso{\code{mix_capabilities()}, the package vignettes, and \code{mix_report()}.}
\examples{
sp <- mix_spec(c("A", "B", "C"))
d <- mix_demo_data("mixture", n_rep = 3, seed = 15)
sf <- mix_segmented_fit("response", d, sp, split_component = "A", cut = .3,
                        model_left = "scheffe_linear", model_right = "scheffe_linear")
head(mix_predict_segmented(sf))
head(mix_predict_segmented(sf, interval = "confidence"))
mix_predict_segmented(sf, newdata = data.frame(A = .2, B = .4, C = .4),
                      interval = "confidence")
}
